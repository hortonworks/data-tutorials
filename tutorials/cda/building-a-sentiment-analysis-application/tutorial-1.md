---
title: Application Development Concepts
---

# Application Development Concepts

## Introduction

Your first objective is to gain background in sentiment analysis, so you have
context when you go into developing the sentiment analysis application. You will
become familiar with what sentiment analysis is, the different types of sentiment
analysis, the importance of sentiment analysis, how sentiment analysis works and
the various sentiment analysis use cases.

## Prerequisites

- Read through "Building a Sentiment Analysis Application" overview

## Outline

- [Sentiment Analysis Fundamentals](#sentiment-analysis-fundamentals)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Sentiment Analysis Fundamentals

### What is Sentiment Analysis?

**Sentiment analysis is identifying and extracting opinions within text and
extracting attributes from expression through using a system that leverages
Natural Language Processing.** An opinion is a subjective expression
describing people's sentiments, appraisals and feelings toward a subject or
topic. Subjective classification can determine whether a sentence or expression
is subjective or objective. Polarity classification can determine the sentiment
from a body of text (complete document, paragraph, single sentence or sub
expression) whether it be positive, negative or neutral. Opinions have two
types: direct and comparative opinions. Direct opinions give a subjective
expression about an entity directly while comparative opinions express
similarities or differences between two or more entities using comparative or
superlative form of an adjective or adverb.

### What are the Different Types of Sentiment Analysis?

There are many types of sentiment analysis systems ranging from focus on
polarity, detection of feelings and emotions or identification of intentions.
The types of sentiment analysis include **fine-grained sentiment analysis**,
**emotion detection**, **aspect-based sentiment analysis**, **intent analysis**,
**multilingual sentiment analysis**. **Fine-grained sentiment analysis** expands
the range of polarity from positive, neutral or negative to _very positive_,
_positive_, _neutral_, _negative_ or _very negative_. **Emotion detection**
usually leverage lexicons or machine learning algorithms to list words or body
of text and analyze the emotion they convey. **Aspect-based sentiment analysis**
dives into analyzing the particular aspects or features of a product or service
people talk about in addition to the polarity level. **Intent analysis** detects
what people would do with a text rather than what people say about that text.
**Multilingual sentiment analysis** detects the language in texts automatically
often using machine learning algorithms and performs analysis on the text
to retrieve the sentiment.

### Why is Sentiment Analysis Important?

**80% of the world's data is unstructured**, most of it comes from text data,
which is difficult, time consuming and expensive to analyze, understand and
sort through. **Sentiment analysis is critical in allowing companies to make
sense of this abundance of unstructured text because they can automate business
processes, obtain actionable insight, save hours of manual data processing and
ultimately make teams more efficient.** Sentiment analysis offers
_scalability_, _real-time analysis_, _consistent criteria_. Can you
imagine the daunting task of sorting through thousands of tweets, customer
support conversations or customer reviews? There's too much data to manually
process, but with assistance from a sentiment analysis system, people can
process data at scale in an efficient way. Sentiment analysis can be used
to identify critical situations in real-time and allow for taking immediate
action. Companies who use a centralized sentiment analysis system can apply
consistent criteria to all of their data reducing the errors and inconsistencies
that come from people judging the sentiment of text. People often time
associate their personal experiences, thoughts and beliefs when performing
sentiment analysis on a piece of text.

### How Does Sentiment Analysis Work?

There are many methods and algorithms used in practice to develop sentiment
analysis systems: ***Rule-Based***, ***Automatic*** and ***Hybrid***.

**Rule-based** systems incorporate a set of manually crafted rules to perform
sentiment analysis. These rules usually use a variety of inputs, classic Natural
Language Processing techniques and lexicons. An example of how to **implement
Rule-based system** is to **first** define a list of polarized words, **second** is to
count the number of positive words and negative words from input, **final** is to
check if the amount of positive word appearances is greater than negative word
appearances, if true, then return positive sentiment else return negative.

**Automatic** systems use a Machine Learning Classifier, feed it text as input
and return the corresponding category: positive, negative or neutral (if
polarity analysis is performed). The Machine Learning Classifier is implemented
in typically two phases:

- The first phase involves **training** our model to associate **input** (text) to
corresponding **output** (label or tag), which are based on test samples used for
training. The pipeline for this process involves sending the input data through
a **feature extractor** that transfers text input into a feature vector. The
feature vectors go through a queue and pairs of both feature vectors and labels
(positive, negative or neutral sentiment) are fed into the machine learning
algorithm to create the model.

<!-- Include picture on the training process -->

- The final phase involves **prediction** of sentiment score for random input.
The data pipeline consists of sending raw input data through a feature extractor
to be transformed into a feature vector, which is then fed to the model to
generate predicted labels, such as positive, negative or neutral.

<!-- Include picture on the prediction process -->

Common Machine Learning Algorithms that can be used in text classification
include **Naive Bayes**, **Linear Regression**, **Support Vector Machines**,
**Deep Learning** and **Gradient Boosted Trees(GBTs)**.

- **Gradient Boosted Trees (GBTs)**: trains a sequence of decision trees to
build the classification model, uses the current group of feature vectors to
predict the polarity of the label, such as positive, negative or neutral of each
training instance and finally compares the prediction against the true label.

- **Deep Learning**: tries to imitate how the human brain
functions by using artificial neural networks to process data. Sentiment
analysis can be implemented to classify text in 2 ways, the first way is to use
supervised learning if there is enough training data, else use unsupervised
training followed by a supervised classifier to train a deep neural network
model. Deep learning neural networks used for building sentiment classification
models include **recursive neural networks, word2vec, paragraph vectors,
recurrent neural networks, etc**

- **Support Vector Machines**: are non-probabilistic models that represent text
examples as points in a multidimensional space. These text examples map to
different categories, such as sentiments: pleased or happy, sad or angry, etc.
These categories belong to distinct regions of that multidimensional space.
New texts are mapped to the same space and predicted to belong to a certain
category.

- **Linear Regression**: is an algorithm used in statistics and machine learning
to predict some value (Y) given the set of features (X).

- **Naive Bayes**: are set of supervised machine learning algorithms that use
Bayes' theorem to predict category of text.

### Sentiment Analysis Use Cases

- Social media monitoring
- Brand monitoring
- Voice of customer (VoC)
- Customer service
- Workforce analytics and voice of employee
- Product analytics
- Market research and analysis

## Summary

Congratulations! You now have familiarity with the fundamentals of sentiment
analysis. You are ready to setup the development environment for the
application.

## Further Reading

- For an in-depth dive into Sentiment Analysis, reference **MonkeyLearn's article** [Sentiment Analysis - nearly everything you need to know](https://monkeylearn.com/sentiment-analysis/)
- [How is deep learning used in sentiment analysis?](https://www.quora.com/How-is-deep-learning-used-in-sentiment-analysis)
