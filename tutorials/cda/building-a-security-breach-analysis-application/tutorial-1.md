---
title: Application Development Concepts
---

# Application Development Concepts

## Introduction

Security breaches happen. And when they do, your server logs may be your best line of defense. Hadoop takes server-log analysis to the next level by speeding and improving security forensics and providing a low cost platform to show compliance.

## Prerequisites

## Outline

- [NASA Server Logs Dataset](#nasa-server-logs-dataset)
- [Security Breach Analysis](#security-breach-analysis)

## Server Log Data

Server logs are computer-generated log files that capture network and server operations data. They are useful for managing network operations, especially for security and regulatory compliance.

## Potential Uses of Server Log Data

IT organizations use server log analysis to answer questions about:

**Security** – For example, if we suspect a security breach, how can we use server log data to identify and repair the vulnerability?

**Compliance** – Large organizations are bound by regulations such as HIPAA and Sarbanes-Oxley. How can IT administrators prepare for system audits?
In this tutorial, we will focus on a network security use case. Specifically, we will look at how Apache Hadoop can help the administrator of a large enterprise network diagnose and respond to a distributed denial-of-service attack.

## NASA Server Logs Dataset

The dataset which we are going to use in this lab is of NASA-HTTP. It has HTTP requests to the NASA Kennedy Space Center WWW server in Florida. The logs are an ASCII file with one line per request, with the following columns:

- **host** making the request. A hostname when possible, otherwise the Internet address if the name could not be looked up.
- **timestamp** in the format "DAY MON DD HH:MM:SS YYYY", where DAY is the day of the week, MON is the name of the month, DD is the day of the month, HH:MM:SS is the time of day using a 24-hour clock, and YYYY is the year. The timezone is -0400.
- **request** given in quotes.
- **HTTP** reply code.
- **bytes** in the reply.

## Security Breach Analysis
