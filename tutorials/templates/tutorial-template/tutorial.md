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

This is the introductory paragraph for the tutorial.  This section will typically introduce the topic and the overall goals and objectives of the tutorial. A paragraph that introduces what technologies the user will learn to use in the tutorial to solve the problem for some use case.

## Prerequisites

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
provide the right color of text highlighting on our website.
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

Another section of the tutorial. **Here's an example** of some strong font, and _Italicized font_ use sparingly. Also, here is an image.

![An example of an image image](assets/some-image.png)

> Note: In the above image link, we link to an image in the included assets folder.  Put all of your assets (images, files, etc.) in that folder for easy linking to.  When your markdown gets built by the system, it will automatically link to the correct place on the web to find your images, downloadable files, etc.

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
