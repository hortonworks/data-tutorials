---
title: Sentiment Analysis with Apache Spark
author: Robert Hryniewicz
tutorial-id: 765
experience: Intermediate
persona: Data Scientist & Analyst
source: Hortonworks
use case: Data Discovery
technology: Apache Spark, HDFS
release: hdp-2.6.0
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Apache Spark
---


# Sentiment Analysis with Apache Spark

## Introduction

This tutorial will teach you how to build sentiment analysis algorithms with Apache Spark. We will be doing data transformation using Scala and Apache Spark 2, and we will be classifying tweets as happy or sad using a Gradient Boosting algorithm. Although this tutorial is focused on sentiment analysis, Gradient Boosting is a versatile technique that can be applied to many classification problems. You should be able to reuse this code to classify text in many other ways, such as spam or not spam, news or not news, provided you can create enough labeled examples with which to train a model.

You can follow this tutorial by running the accompanying [Zeppelin notebook](assets/SentimentAnalysisZeppelin.json).

## Prerequisites

Before starting this model you should make sure HDFS and Spark2 are started.

-   Download and install [Hortonworks Sandbox 2.6](https://hortonworks.com/downloads/)
-   (Optional) Complete the Sentiment Analysis [Part I Tutorial](https://hortonworks.com/tutorial/how-to-refine-and-visualize-sentiment-data/)
-   Start HDFS and Spark2 on your Hortonworks Sandbox


## Outline

-   [Stream Tweets to HDFS](#download-tweets)
-   [Clean and Label Records](#clean-records)
-   [Transform Data for Machine Learning](#transform-data)
-   [Build and Evaluate Model](#build-the-model)
-   [Summary](#summary)
-   [Further Reading](#further-reading)


## Download Tweets

Gradient Boosting is a supervised machine learning algorithm, which means we will have to provide it with many examples of statements that are labeled as happy or sad. In an ideal world we would prefer to have a large dataset where a group of experts hand-labeled each statement as happy or sad. Since we don’t have that dataset we can improvise by streaming tweets that contain the words “happy” or “sad”, and use the presence of these words as our labels. This isn’t perfect: a few sentences like “I’m not happy” will end up being incorrectly labeled as happy. If you wanted more accurate labeled data, you could use a part of speech tagger like Stanford NLP or SyntaxNet, which would let you make sure the word “happy” is always describing “I” or “I’m” and the word “not” isn’t applied to “happy”. However, this basic labeling will be good enough to train a working model.

If you’ve followed the [first sentiment analysis tutorial](https://hortonworks.com/tutorial/how-to-refine-and-visualize-sentiment-data/) you’ve learned how to use Nifi to stream live tweets to your local computer and HDFS storage. If you’ve followed this tutorial you can stream your own tweets by configuring the GetTwitter processor to filter on “happy” and “sad”. If you’re running on the sandbox and want to process a large amount of tweets, you may also want to raise the amount of memory available to YARN and Spark2. You can do that by modifying the setting “Memory allocated for all YARN containers on a node” to > 4G for YARN and spark_daemon_memory to > 4G for Spark2.

Otherwise, you can run the next cell to download pre-packaged tweets.

```
#Log into the Sandbox
ssh -p 2222 root@127.0.0.1
#password: hadoop
```
```
mkdir /tmp/tweets
rm -rf /tmp/tweets/*
cd /tmp/tweets
wget -O /tmp/tweets/tweets.zip https://raw.githubusercontent.com/hortonworks/data-tutorials/master/tutorials/hdp/hdp-2.6/sentiment-analysis-with-apache-spark/assets/tweets.zip
unzip /tmp/tweets/tweets.zip
rm /tmp/tweets/tweets.zip

# Remove existing (if any) copy of data from HDFS. You could do this with Ambari file view.
hdfs dfs -mkdir /tmp/tweets_staging/
hdfs dfs -rmr -f /tmp/tweets_staging/* -skipTrash

# Move downloaded JSON file from local storage to HDFS
hdfs dfs -put /tmp/tweets/* /tmp/tweets_staging
```

### Load into Spark

Let's load the tweets into Spark. Spark makes it easy to load JSON-formatted data into a dataframe. To run these code blocks, you should download [this](https://raw.githubusercontent.com/hortonworks/data-tutorials/af43922eb7188230a85eeee5337bec201c7ce4fb/tutorials/hdp/hdp-2.6/sentiment-analysis-with-apache-spark/assets/SentimentAnalysisZeppelin.json) Zeppelin notebook and run it on the HDP Sandbox.


```
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.SparkContext._
import org.apache.spark.mllib.feature.HashingTF
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.tree.GradientBoostedTrees
import org.apache.spark.mllib.tree.configuration.BoostingStrategy
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.SparkContext._
import scala.util.{Success, Try}

val sqlContext = new org.apache.spark.sql.SQLContext(sc)

var tweetDF = sqlContext.read.json("hdfs:///tmp/tweets_staging/*")
tweetDF.show()
```

The output should look like this:
```
+---------------+--------------------+----------------+---------------+----+--------------------+--------------------+------------------+
|_corrupt_record|        created_time|created_unixtime|    displayname|lang|                 msg|           time_zone|          tweet_id|
+---------------+--------------------+----------------+---------------+----+--------------------+--------------------+------------------+
|           null|Wed Mar 15 00:32:...|   1489537963226|  meantforpeace|  en|ogmorgaan xo_rare...|Eastern Time (US ...|841809347768377344|
|           null|Wed Mar 15 00:32:...|   1489537963229|        mushtxq|  en|Happy early birth...|              London|841809347780972544|
|           null|Wed Mar 15 00:32:...|   1489537962590| Carla_Pereira2|  en|After 10 hrs on a...|                    |841809345100697600|
|           null|Wed Mar 15 00:32:...|   1489537963311|     DillMaddie|  en|i just want to be...|                    |841809348124917761|
|           null|Wed Mar 15 00:32:...|   1489537963397|oabeh7hdYeD5K8a|  ja|RT tsukiuta1 ☆Hap...|                    |841809348485558272|
|           null|Wed Mar 15 00:32:...|   1489537962772|   Hicky_Randel|  en|FlemingYoung happ...|                    |841809345864192000|
|           null|Wed Mar 15 00:32:...|   1489537963397|        yastan9|  en|RT RealTillIMetYo...|                    |841809348485496832|
|           null|Wed Mar 15 00:32:...|   1489537963345|     s_willorsa| und|nikeplus nikeplus...|                    |841809348267409408|
...
```

## Clean Records

We want to remove any tweet that doesn't contain "happy" or "sad". We've also chosen to select an equal number of happy and sad tweets to prevent bias in the model. Since we've loaded our data into a Spark DataFrame, we can use SQL-like statements to transform and select our data.

```

var messages = tweetDF.select("msg")
println("Total messages: " + messages.count())

var happyMessages = messages.filter(messages("msg").contains("happy"))
val countHappy = happyMessages.count()
println("Number of happy messages: " +  countHappy)

var unhappyMessages = messages.filter(messages("msg").contains(" sad"))
val countUnhappy = unhappyMessages.count()
println("Unhappy Messages: " + countUnhappy)

val smallest = Math.min(countHappy, countUnhappy).toInt

//Create a dataset with equal parts happy and unhappy messages
var tweets = happyMessages.limit(smallest).unionAll(unhappyMessages.limit(smallest))
```

### Label Data

Now label each happy tweet as 1 and unhappy tweets as 0. In order to prevent our model from cheating, we’re going to remove the words happy and sad from the tweets. This will force it to infer whether the user is happy or sad by the presence of other words.

Finally, we also split each tweet into a collection of words. For convenience we convert the Spark Dataframe to an RDD which lets you easily transform data using the map function.

```
val messagesRDD = tweets.rdd
//We use scala's Try to filter out tweets that couldn't be parsed
val goodBadRecords = messagesRDD.map(
  row =>{
    Try{
      val msg = row(0).toString.toLowerCase()
      var isHappy:Int = 0
      if(msg.contains(" sad")){
        isHappy = 0
      }else if(msg.contains("happy")){
        isHappy = 1
      }
      var msgSanitized = msg.replaceAll("happy", "")
      msgSanitized = msgSanitized.replaceAll("sad","")
      //Return a tuple
      (isHappy, msgSanitized.split(" ").toSeq)
    }
  }
)

//We use this syntax to filter out exceptions
val exceptions = goodBadRecords.filter(_.isFailure)
println("total records with exceptions: " + exceptions.count())
exceptions.take(10).foreach(x => println(x.failed))
var labeledTweets = goodBadRecords.filter((_.isSuccess)).map(_.get)
println("total records with successes: " + labeledTweets.count())
```

We now have a collection of tuples of the form (Int, Seq[String]), where a 1 for the first term indicates happy and 0 indicates sad. The second term is a sequence of words, including emojis. We removed the words happy and sad from the list of words.

Let's take a look.

```
labeledTweets.take(5).foreach(x => println(x))
```
Output:
```

(1,WrappedArray(i, just, want, to, be))
(1,WrappedArray(flemingyoung, , bday, to, my, boy, c, https//tco/lmjhzggruz))
(1,WrappedArray(rt, mbchavez86, seeing, you, both, thise, , makes, me, so, , toogoodvibes, amp, happinessmaymay, amp, edwardmbmayward, [pctto], https//tco…))
(1,WrappedArray(in, reality, though, im, , the, first, strega, boss, fight, was, unsatisfyingly, easy, i, want, to, answer, one, of, them, and, ik, people, will, ask, me, it))
(1,WrappedArray(rt, cwatkins199, adairbriones6, , birthday, manhave, a, good, one💪🏻🎉))
```

## Transform Data

Gradient Boosting expects as input a vector (feature array) of fixed length, so we need a way to convert our tweets into some numeric vector that represents that tweet. A standard way to do this is to use the hashing trick, in which we hash each word and index it into a fixed-length array. What we get back is an array that represents the count of each word in the tweet. This approach is called the bag of words model, which means we are representing each sentence or document as a collection of discrete words and ignore grammar or the order in which words appear in a sentence. An alternative approach to bag of words would be to use an algorithm like Doc2Vec or Latent Semantic Indexing, which would use machine learning to build a vector representations of tweets.

In Spark we’re using HashingTF for feature hashing. Note that we’re using an array of size 2000. Since this is smaller than the size of the vocabulary we’ll encounter on Twitter, it means two words with different meaning can be hashed to the same location in the array. Although it would seem this would be an issue, in practice this preserves enough information that the model still works. This is actually one of the strengths of feature hashing, that it allows you to represent a large or growing vocabulary in a fixed amount of space.

```
val hashingTF = new HashingTF(2000)

//Map the input strings to a tuple of labeled point + input text
val input_labeled = labeledTweets.map(
  t => (t._1, hashingTF.transform(t._2)))
  .map(x => new LabeledPoint((x._1).toDouble, x._2))
  ```

  Let’s check out the hashed vectors:

  ```
  input_labeled.take(5).foreach(println)

  Output:

(1.0,(2000,[105,1139,1707,1872,1964],[1.0,1.0,1.0,1.0,1.0]))
(1.0,(2000,[0,99,516,746,950,1500,1707,1740],[1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]))
(1.0,(2000,[230,1054,1216,1248,1423,1519,1527,1703,1840,1935],[1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]))
(1.0,(2000,[0,375,708,882,1271,1308,1452,1480,1589,1649,1650,1676,1839,1889,1985,1999],[2.0,1.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]))
(1.0,(2000,[0,30,105,182,368,432,727,741,801,889,939,940,1119,1230,1362,1364,1365,1371,1480,1481,1490,1520,1543,1707,1794,1869,1872],[1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]))
```


As you can see, we've converted each tweet into a vector of integers. This is what we need to run our machine learning model, but we want to preserve some tweets in a form we can read.

```
//We're keeping the raw text for inspection later
var sample = labeledTweets.take(1000).map(
  t => (t._1, hashingTF.transform(t._2), t._2))
  .map(x => (new LabeledPoint((x._1).toDouble, x._2), x._3))
  ```

### Split into Training and Validation Sets

When training any machine learning model you want to separate your data into a training set and a validation set. The training set is what you actually use to build the model, whereas the validation set is used to evaluate the model’s performance afterwards on data that it has never encountered before. This is extremely important, because a model can have very high accuracy when evaluating training data but fail spectacularly when it encounters data it hasn’t seen before.

This situation is called overfitting. A good predictive model will build a generalized representation of your data in a way that reflects real things going on in your problem domain, and this generalization gives it predictive power. A model that overfits will instead try to predict the exact answer for each piece of your input data, and in doing so it will fail to generalize. The way we know a model is overfitting is when it has high accuracy on the training dataset but poor or no accuracy when tested against the validation set. This is why it’s important to always test your model against a validation set.

### Fixing overfitting

A little overfitting is usually expected and can often be ignored. If you see that your validation accuracy is very low compared to your training accuracy, you can fix this overfitting by either increasing the size of your training data or by decreasing the number of parameters in your model. By decreasing the number of parameters you decrease the model’s ability to memorize large numbers of patterns. This forces it to build a model of your data in general, which makes it represent your problem domain instead of just memorizing your training data.


```
// Split the data into training and validation sets (30% held out for validation testing)
   val splits = input_labeled.randomSplit(Array(0.7, 0.3))
   val (trainingData, validationData) = (splits(0), splits(1))
  ```

## Build the Model

We’re using a Gradient Boosting model. The reason we chose Gradient Boosting for classification over some other model is because it’s easy to use (doesn’t require tons of parameter tuning), and it tends to have a high classification accuracy. For this reason it is frequently used in machine learning competitions.

The tuning parameters we’re using here are:
-number of iterations (passes over the data)
-Max Depth of each decision tree

In practice when building machine learning models you usually have to test different settings and combinations of tuning parameters until you find one that works best. For this reason it’s usually best to first train the model on a subset of data or with a small number of iterations. This lets you quickly experiment with different tuning parameter combinations.

This step may take a few minutes on a sandbox VM. If you’re running on a sandbox and it’s taking more than five minutes you may want to stop the process and decrease the number of iterations.

```
val boostingStrategy = BoostingStrategy.defaultParams("Classification")
boostingStrategy.setNumIterations(20) //number of passes over our training data
boostingStrategy.treeStrategy.setNumClasses(2) //We have two output classes: happy and sad
boostingStrategy.treeStrategy.setMaxDepth(5)
//Depth of each tree. Higher numbers mean more parameters, which can cause overfitting.
//Lower numbers create a simpler model, which can be more accurate.
//In practice you have to tweak this number to find the best value.

val model = GradientBoostedTrees.train(trainingData, boostingStrategy)
  ```

### Evaluate model

Let's evaluate the model to see how it performed against our training and test set.

```
// Evaluate model on test instances and compute test error
var labelAndPredsTrain = trainingData.map { point =>
  val prediction = model.predict(point.features)
  Tuple2(point.label, prediction)
}

var labelAndPredsValid = validationData.map { point =>
  val prediction = model.predict(point.features)
  Tuple2(point.label, prediction)
}

//Since Spark has done the heavy lifting already, lets pull the results back to the driver machine.
//Calling collect() will bring the results to a single machine (the driver) and will convert it to a Scala array.

//Start with the Training Set
val results = labelAndPredsTrain.collect()

var happyTotal = 0
var unhappyTotal = 0
var happyCorrect = 0
var unhappyCorrect = 0
results.foreach(
  r => {
    if (r._1 == 1) {
      happyTotal += 1
    } else if (r._1 == 0) {
      unhappyTotal += 1
    }
    if (r._1 == 1 && r._2 ==1) {
      happyCorrect += 1
    } else if (r._1 == 0 && r._2 == 0) {
      unhappyCorrect += 1
    }
  }
)
println("unhappy messages in Training Set: " + unhappyTotal + " happy messages: " + happyTotal)
println("happy % correct: " + happyCorrect.toDouble/happyTotal)
println("unhappy % correct: " + unhappyCorrect.toDouble/unhappyTotal)

val testErr = labelAndPredsTrain.filter(r => r._1 != r._2).count.toDouble / trainingData.count()
println("Test Error Training Set: " + testErr)



//Compute error for validation Set
val results = labelAndPredsValid.collect()

var happyTotal = 0
var unhappyTotal = 0
var happyCorrect = 0
var unhappyCorrect = 0
results.foreach(
  r => {
    if (r._1 == 1) {
      happyTotal += 1
    } else if (r._1 == 0) {
      unhappyTotal += 1
    }
    if (r._1 == 1 && r._2 ==1) {
      happyCorrect += 1
    } else if (r._1 == 0 && r._2 == 0) {
      unhappyCorrect += 1
    }
  }
)
println("unhappy messages in Validation Set: " + unhappyTotal + " happy messages: " + happyTotal)
println("happy % correct: " + happyCorrect.toDouble/happyTotal)
println("unhappy % correct: " + unhappyCorrect.toDouble/unhappyTotal)

val testErr = labelAndPredsValid.filter(r => r._1 != r._2).count.toDouble / validationData.count()
println("Test Error Validation Set: " + testErr)
```

Here's the output:

```
unhappy messages in Training Set: 1362 happy messages: 1318
happy % correct: 0.7132018209408194
unhappy % correct: 0.9265785609397944
testErr: Double = 0.1783582089552239
Test Error Training Set: 0.1783582089552239

unhappy messages in Validation Set: 601 happy messages: 583
happy % correct: 0.6500857632933105
unhappy % correct: 0.9018302828618968
testErr: Double = 0.22212837837837837
Test Error Validation Set: 0.22212837837837837
```

The results show that the model is very good at detecting unhappy messages (90% accuracy), and significantly less adept at identifying happy messages (65% accuracy). To improve this we could provide the model more examples of happy messages to learn from.

Also note that our training accuracy is slightly higher than our validation accuracy. This is an example of slightly overfitting the training data. Since the training accuracy is only slightly higher than the validation accuracy, this is normal and not something we should concerned about. However, if the validation accuracy was significantly worse than the training accuracy it would mean the model had grossly overfit its training data. In that situation, you would want to either increase the amount of data available for training or decrease the number of parameters (the complexity) of the model.

Now let’s inspect individual tweets and see how the model interpreted them. This can often provide some insight into what the model is doing right and wrong.

```
val predictions = sample.map { point =>
  val prediction = model.predict(point._1.features)
  (point._1.label, prediction, point._2)
}

//The first entry is the true label. 1 is happy, 0 is unhappy.
//The second entry is the prediction.
predictions.take(100).foreach(x => println("label: " + x._1 + " prediction: " + x._2 + " text: " + x._3.mkString(" ")))
```

Output:

```
label: 1.0 prediction: 0.0 text: rt mcasalan pinatawag pala cyamarydaleentrat5 many more blessings to come baby girlsuper  talaga kami para sainyo ni ed…
label: 1.0 prediction: 1.0 text: rt dmtroll without this guy we wont have little  moments in the latest episodes of defendant
label: 1.0 prediction: 1.0 text: i  birthday my guy dj_d_rac the bushes seem very comfortable to sleep in lolol
label: 1.0 prediction: 1.0 text: rt maywarddvo_thai trust yourself create the kind of self that you will be  to live with all your lifembmayward
label: 1.0 prediction: 1.0 text: rt tyler_labedz dont forget the  thoughts
label: 1.0 prediction: 0.0 text: rt kia4realz im legit  for cardi bs success bxfinest
label: 0.0 prediction: 1.0 text:  birthday gronk  no one ever wished you a  birthday but youre the reason i started watching footb…
label: 1.0 prediction: 0.0 text: u dont have to say tht u miss me at all i just wanted to let u know tht i do miss u n it sucks to see u  n im not the reason why
```

Once you've trained your first model, you should go back and tweak the model parameters to see if you can increase model accuracy. In this case, try tweaking the depth of each tree and the number of iterations over the training data. You could also let the model see a greater percentage of happy tweets than unhappy tweets to see if that improves prediction accuracy for happy tweets.

### Export the Model

Once your model is as accurate as you can make it, you can export it for production use. Models trained with Spark can be easily loaded back into a Spark Streaming workflow for use in production.

```
model.save(sc, "hdfs:///tmp/tweets/RandomForestModel")
```


## Summary

You’ve now seen how to build a sentiment analysis model. The techniques you’ve seen here can be directly applied to other text classification models, such as spam classification. Try running this code with other keywords besides happy and sad and see what models you can build.


## Further Reading

- [NLP and Sentiment Analysis Using HDP and ITC Infotech Radar](https://hortonworks.com/tutorial/nlp-sentiment-analysis-retailers-using-hdp-itc-infotech-radar/)
- [Analyzing Social Media and Customer Sentiment with Apache Nifi and HDP Search](https://hortonworks.com/tutorial/how-to-refine-and-visualize-sentiment-data/)

Tutorial By Greg Womack (Twitter: @gregw134)
