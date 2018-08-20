---
title: New tutorial name
author: You, because you are writing it!
tutorial-id: Ask for tutorial ID assignment policy.
experience: Beginer, Intermediate, Advanced
persona: Example (Data Scientist & Analyst)
source: Hortonworks
use case: Example (Data Discovery)
technology: Be as detailed as you can while still being accurate, for example (Apache Spark, Apache Ozone, Apache Hive with LLAP)
release: Latest updated version for example (hdp-2.6.5)
environment: Sandbox
product: HDP, HDF, CDA (Ask a team member before using CDA here, website might not be ready yet)
series: This important as it will determine where the tutorial is posted example (HDP > Develop with Hadoop > Apache Spark)
---

# Sample Tutorial (this is the title)

## Introduction

This is the introductory paragraph for the tutorial. This section will typically introduce the topic and the overall goals and objectives of the tutorial. A paragraph that introduces what technologies the user will learn to use in the tutorial to solve the problem for some use case. This template is made for Spark specifically because many of these tutorials will include a Zeppelin Notebook, because we are in the business of tutorials and increasing traffic to the Hortonworks website we want to keep all relevant content and important information in the tutorial and not in the Notebook.
<!-- If you need to add comments HTML commenting is recommended -->

## Prerequisites

<!--
Ine thing that all of these tutorials will have in common are these two prerequisites, add more requirements as needed 
-->

- Downloaded and deployed the [Hortonworks Data Platform (HDP)](https://hortonworks.com/downloads/#sandbox) Sandbox
- [Getting Started with Apache Zeppelin](https://hortonworks.com/tutorial/getting-started-with-apache-zeppelin/)
- [Title of a required tutorial to have been completed](http://example.com/link/to/required/tutorial)
- [Another prerequisite](http://example.com/link/to/required/tutorial)

## Outline

- [Concepts](#concepts)
- [Section Title 1](#section-title-1)
- [Section Title 2](#section-title-2)
- [Summary](#summary)
- [Further Reading](#further-reading)
- [Appendix A: Troubleshoot](#appendix-a-troubleshoot)
- [Appendix B: Extra Features](#appendix-b-extra-features)

> Note: It may be good idea for each procedure to start with an action verb (e.g. Install, Create, Implement, etc.). Also note that for notes we use ">" to start a note. There are other ways to do it but this is our standard

## Concepts

Sometimes, it's a good idea to include a concepts section to go over core concepts before the real action begins.  That way:

- Readers get a preview of the tech that'll be introduced.
- The section can be used as a reference for terminology brought up throughout the tutorial.
- By the way, this is an example of a list.  Feel free to copy/paste this for your own use.
- Use a single space for lists, not tabs.
  - Also, a sublist.

## Section Title 1

One of the sections of the tutorial.

Also, `here is how to wrap text in a code field` for a single line; however, it is strongly encouraged to use the format used below.

~~~text
You can also wrap multi-line
text in a code block by using
three tildes along with the name of the language contained in the code block, this will make the code cleaner and
provide the right color text highlighting on our website.
~~~

Example:

~~~java
public class HelloWorld {

    public static void main(String[] args) {
        // Prints "Hello, World" to the terminal window.
        System.out.println("Hello, Sandbox!");
    }

}
~~~

> Note: This is a note that stands out to readers.  Catch users attention about image, command, or key concepts.

## Section Title 2

Another section of the tutorial. **Here's an example** of some strong font, and _Italicized font_, use sparingly. Also, it is **important** to note that the standard image to be included in Spark tutorials with Zeppelin notebooks are in this format:

![sample-image-from-zeppelin](assets/sample-image-from-zeppelin.jpg)

meaning that the image is not oversized and clearly shows the results you are trying to convey. **Hint** make your browser window small in order to capture all of the desired content.

The standard to add an image is this:

~~~md
![sample-image-from-zeppelin](assets/sample-image-from-zeppelin.jpg)
~~~

The image name is simply the name of screenshot without the folder path or the image extension. It is important to mention that our images must be **_.jpg_** file type and must be named in all lower case letters.

> Note: In the above image link, we link to an image in the included assets folder.  Put all of your assets (images, files, etc.) in that folder for easy linking to.  When your markdown gets built by the system, it will automatically link to the correct place on the web to find your images, downloadable files, etc.

<!-- 
This is the language used for tutorials which include a Zeppelin Notebook as of HDP 3.0 
Keep your language as close as possible to this for consistency's sake
-->

## Import the Zeppelin Notebook

 Great! now you are familiar with the concepts used in this tutorial and you are ready to Import the _Learning Spark Tutorials_ notebook into your Zeppelin environment. (If at any point you have any issues, make sure to checkout the [Getting Started with Apache Zeppelin](https://hortonworks.com/tutorial/getting-started-with-apache-zeppelin/) tutorial).

To import the notebook, go to the Zeppelin home screen.

1\. Click **Import note**

2\. Select **Add from URL**

3\. Copy and paste the following URL into the **Note URL**

~~~text
https://raw.githubusercontent.com/hortonworks/data-tutorials/master/tutorials/templates/tutorial-template-spark/assets/Learning%20Spark%20Tutorials.json
~~~

> NOTE: The standard to add Zeppelin Notebooks is by URL, reason for this is that users should always get latest and greatest.

4\. Click on **Import Note**

Once your notebook is imported, you can open it from the Zeppelin home screen by:

5\. Clicking **Clicking on the Learning Spark Tutorials**

Once the **Learning Spark Tutorials** notebook is up, follow all the directions within the notebook to complete the tutorial.

## Summary

Congratulations, you've finished your first tutorial!  Including a review of the tutorial or tools they now know how to use would be helpful.

## Further Reading

- [Reference Article Title](https://example.com)
- [Title of Another Useful Tutorial](https://hortonworks.com)

> Note: A tutorial does not go as in depth as documentation, so we suggest you include links here to all documents you may have utilized to build this tutorial.

### Appendix A: Troubleshoot

The appendix covers optional components of the tutorial, including help sections that might come up that cover common issues.  Either include possible solutions to issues that may occur or point users to [helpful links](https://hortonworks.com) in case they run into problems.

### Appendix B: Extra Features

Include any other interesting features of the big data tool you are using.

Example: when learning to build a NiFi flow, we included the necessary steps required to process the data. NiFi also has additional features for adding labels to a flow to make it easier to follow.
