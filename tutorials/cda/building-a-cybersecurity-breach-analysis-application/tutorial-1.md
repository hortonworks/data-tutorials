---
title: Application Development Concepts
---

# Application Development Concepts

## Introduction

Security breaches happen. And when they do, your server logs may be your best line of defense. Hadoop takes server-log analysis to the next level by speeding and improving security forensics and providing a low cost platform to show compliance.

## Prerequisites

- Read overview of tutorial series

## Outline

- [Server Log Data]
- [NASA Server Logs Dataset](#nasa-server-logs-dataset)
- [What are Attackers After?](#what-are-attackers-after?)
- [Security Breach Analysis](#security-breach-analysis)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Server Log Data

Server logs are computer-generated log files that capture network and server operations data. They are useful for managing network operations, especially for security and regulatory compliance.

## Potential Uses of Server Log Data

IT organizations use server log analysis to answer questions about:

**Security** – For example, if we suspect a security breach, how can we use server log data to identify and repair the vulnerability?

**Compliance** – Large organizations are bound by regulations such as HIPAA and Sarbanes-Oxley. How can IT administrators prepare for system audits?
In this tutorial, we will focus on a network security use case. Specifically, we will look at how Apache Hadoop can help the administrator of a large enterprise network diagnose and respond to a distributed denial-of-service attack.

## What are Attackers After?

User Level Footprints

What happens in the application level

What happens in the network level: especially internal network traffic

What happens in the OS environment: especially system internals, remote IT admin tools

How much visibility do you have today

## The Real Cyber Security Unicorn?

Machine learning

How it works?

ML used in various forms in over 10 years

Supervised - train progrma with trained levels when given new dataset

Have a dataset

Feature extraction - extract things of interest

Train it through ML algorithm and you get some form of anomoly detection results or you want to apply clustering and grouping of the object and then take a oook at those Further

ONE Thing Important to understand is the Confidence Score - clean or malicious?

## Log Data

Most of the data is not quality data

In order to make sense of this ML that makes detections

## What is the data you process?

Then you know what can it detect?

How do we analyze

## NASA Server Logs Dataset

The dataset which we are going to use in this lab is of NASA-HTTP. It has HTTP requests to the NASA Kennedy Space Center WWW server in Florida. The logs are an ASCII file with one line per request, with the following columns:

- **host** making the request. A hostname when possible, otherwise the Internet address if the name could not be looked up.
- **timestamp** in the format "DAY MON DD HH:MM:SS YYYY", where DAY is the day of the week, MON is the name of the month, DD is the day of the month, HH:MM:SS is the time of day using a 24-hour clock, and YYYY is the year. The timezone is -0400.
- **request** given in quotes.
- **HTTP** reply code.
- **bytes** in the reply.

## Security Breach Analysis

## Summary

## Further Reading

- [How to detect a cyber security breach?](https://www.youtube.com/watch?v=RF7O_sNZWNQ)
- [What's the deal with Machine Learning?](https://labsblog.f-secure.com/2016/08/26/whats-the-deal-with-machine-learning/)
- [Lockheed Martin. Defendable Architectures](https://pdfs.semanticscholar.org/6deb/1b07e4d2e63a0df2883fcc4e5b6deb2ff817.pdf)
- [Gartner on Deception](https://www.gartner.com/doc/reprints?id=1-2LSQOX3&ct=150824&st=sb&aliId=87768)
- [Gartner on User and Entity Behavioral Analytics](https://www.gartner.com/doc/3134524/market-guide-user-entity-behavior)
- [Hortonworks Cybersecurity Platform](https://hortonworks.com/products/data-platforms/cybersecurity/)
