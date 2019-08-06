---
title: Assigning Tag Based policies with Atlas
---

# Tag Based Policies with Apache Ranger and Apache Atlas

## Assigning Tag Based Policies with Atlas

## Introduction

In this section of the tutorial you will begin assigning policies to the users of our sandbox, you will be introduced to user accounts available and then you will assign permissions on data based on the persona's role.

## Prerequisites

- Downloaded and deployed the [Hortonworks Data Platform (HDP)](https://www.cloudera.com/downloads/hortonworks-sandbox/hdp.html?utm_source=mktg-tutorial) Sandbox
- [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)

## Outline

- [Concepts](#concepts)
- [Sandbox User Personas Policy](#sandbox-user-personas-policy)
- [Access Without Tag Based Policies](#access-without-tag-based-policies)
- [Create a Ranger Policy to Limit Access of Hive Data](#create-a-ranger-policy-to-limit-access-of-hive-data)
- [Create Atlas Tag to Classify Data](#create-atlas-tag-to-classify-data)
- [Create Ranger Tag Based Policy](#create-ranger-tag-based-policy)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Concepts

The Sandbox's Hive policies are such that when a new table is created, everyone has access to it. This is convenient for us because the data in the tables we create is fictitious; however, image a scenario where a Hive table hold sensitive information (e.g. SSN, or Birthplace) we should be able to Govern the data and only give access to authorized users. In this section we will recreate a scenario where certain users do not have access to sensitive data; however, Raj our cluster operator has been approved to access the data, so we will create Tag Based Policies to granularly grant him access to the sensitive data.

## Access Without Tag Based Policies

In this section you will create a brand new hive table called `employee` in the `default` database of our Sandbox.

Keep in mind, for this new table, no policies have been created to authorize what our sandbox users can access within this table and its columns.

1\. Go to **Data Analytics Studio** or **DAS** and click on the **Data Analytics Studio UI** or go to [sandbox-hdp.hortonworks.com:30800](http://sandbox-hdp.hortonworks.com:30800).

2\. Create the `employee` table:

~~~sql
create table employee (ssn string, name string, location string)
row format delimited
fields terminated by ','
stored as textfile;
~~~

Then, click the green `Execute` button.

![create-hive-table](assets/images/create-hive-table-employee.jpg)

3\. Verify the table was created successfully by going to **Database**>**Table** tab:

![list-hive-table](assets/images/list-hive-table-employee.jpg)

4\. Now we will populate this table with data.

5\. Enter the HDP Sandbox's CentOS command line interface by using the Web Shell Client at:

[sandbox-hdp.hortonworks.com:4200](http://sandbox-hdp.hortonworks.com:4200/)

Login credentials are:

username = `root`
password = `hadoop`

>Note: hadoop is the initial password, but you will asked to change it after first sign in.

6\. Create the `employee` file with the following data using the command:

~~~bash
printf "111-111-111,James,San Jose\\n222-222-222,Christian,Santa Clara\\n333-333-333,George,Fremont" > employeedata.txt
~~~

7\. Copy the employeedata.txt file from your centOS file system to HDFS. The particular location the file will be stored in is Hive warehouse's employee table directory:

~~~bash
hdfs dfs -copyFromLocal employeedata.txt /warehouse/tablespace/managed/hive/employee
~~~

8\. Go back to **DAS** Verify the hive table **employee** has been populated with data:

~~~sql
select * from employee;
~~~

**Execute** the hive query to the load the data.

![load-employee-data](assets/images/load-employee-data.jpg)

Notice you have an **employee** data table in Hive with ssn, name and location
as part of its columns.

The **ssn** and **location** columns hold **sensitive** information
and most users should not have access to it.

## Create a Ranger Policy to Limit Access of Hive Data

Your goal is to create a Ranger Policy which allows general users access to the **name**
column while excluding them access to the **ssn and location** columns.

This policy will be assigned to **maria_dev** and **raj_ops**.

1\. Go to Ranger UI on and Click on **sandbox_hive**

[sandbox-hdp.hortonworks.com:6080](http://sandbox-hdp.hortonworks.com:6080)

**Table 2**: Ranger Login credentials

| Username | Password |
|:---:|:---:|
| admin | hortonworks1 |

The Ranger UI homepage should look similar to the image below:

![ranger-homepage-admin](assets/images/ranger-homepage-admin.jpg)

2\. Select **grant-XXXXXXXXXXX** (policy value will varies per sandbox)

![ranger-maria-dev-permission](assets/images/ranger-maria-dev-permission.jpg)

3\. Ensure that the policy for table **default** is **disabled** as shown in the image below, then **Save** the changes.

![ranger-maria-dev-permission-disabled](assets/images/ranger-maria-dev-permission-disabled.jpg)

4\. Now select **Add New Policy**:

![new-sandbox-hive-policies](assets/images/new-sandbox-hive-policies.jpg)

5\. In the **Policy Details** field, enter following values:

~~~text
Policy Name - Policy to Restrict Employee Data
Database - default
table - employee
Hive Column - ssn, location (NOTE : Do NOT forget to EXCLUDE these columns)
Description - Any description
~~~

6\. In the **Allow Conditions**, it should have the following values:

~~~text
Select Group – blank, no input
Select User – raj_ops, maria_dev
Permissions – Click on the + sign next to Add Permissions and click on select and then green tick mark.
~~~

![add-permission](assets/images/add-permission.jpg)

You should have your policy configured like this, then click on `Add`.

![policy-restrict](assets/images/policy-restrict.jpg)

7\. You can see the list of policies that are present in `Sandbox_hive`.

![employee-policy-added-admin](assets/images/employee-policy-added-admin.jpg)

8\. Disable the `all - global` Policy to take away `raj_ops` and `maria_dev`
access to the employee table's ssn and location column data.

![hive-global-policy-admin](assets/images/hive-global-policy-admin.jpg)

 Go inside this Policy,
to the right of `Policy Name` there is an `enable button` that can be toggled to
`disabled`. Toggle it. Then click **save**.

![disabled-access](assets/images/disabled-access.jpg)

### Verify Ranger Policy is in Effect

 We are going to verify if `maria_dev` has access to the Hive `employee` table. To do this we will use beeline.

1\. Login to Ambari with user/password: **maria_dev/maria_dev**

![maria-dev-ambari-login](assets/images/maria-dev-ambari-login.jpg)

2\. Go to **Hive** > **HIVESERVER2 JDBC URL** and click on the Clipboard at the end of the JDBC URL. This will copy the Hiverserver2 JDBC URL.

![maria-hive-jdbc-url](assets/images/maria-hive-jdbc-url.jpg)

3\. Go to Shell-in-Box at:

[sandbox-hdp.hortonworks.com:4200](http://sandbox-hdp.hortonworks.com:4200/)

username = `root`
password = `hadoop`

>Note: hadoop is the initial password, but you will asked to change it after first sign in.

4\. Type the following command in beeline and paste the JDBC URL in between the quotes.

~~~bash
beeline -u "Paste the JDBC URL here" -n maria_dev
~~~

![beeline-maria-dev-user](assets/images/beeline-maria-dev-user.jpg)

5\. Enter the command below in beeline:

~~~sql
select * from employee;
~~~

6\. An authorization error will appear. This is expected as the user `maria_dev` and
`raj_ops` do not have access to 2 columns in this table (ssn and location).

![load-data-authorization-error](assets/images/load-data-authorization-error.jpg)

7\. For further verification, you can view the **Audit** tab in Ranger.
Go back to Ranger and click on `Audits=>Access` and select
`user => maria_dev`. You will see the entry of Access Denied
for maria_dev. maria_dev tried to access data she didn't have authorization
to view.

![new-policy-audit](assets/images/new-policy-audit.jpg)

5\. Return to **beeline**, try running a query to access the `name` column
from the `employee` table. `maria_dev` should be able to access that data.

~~~sql
SELECT name FROM employee;
~~~

![beeline-mariadev-access-successful](assets/images/beeline-mariadev-access-successful.jpg)

The query runs successfully.
Even, **raj_ops** user cannot not see all the columns for the location and SSN.
We will provide access to this user to all columns later via Atlas Ranger Tag
Based Policies.

## Create Atlas Tag to Classify Data

The goal of this section is to classify all data in the ssn and location columns
with a **PII*** tag. So later when we create a Ranger Tag Based Policy, users
who are associated with the **PII** tag can override permissions established in
the Ranger Resource Board policy.

1\. Reset Admin user password:

If you haven't already reset your [Ambari Admin password](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/#admin-password-reset)
we will use it to log into Atlas.

1\. Login into Atlas UI:

[sandbox-hdp.hortonworks.com:21000](http://sandbox-hdp.hortonworks.com:21000/)

username & password : **admin/admin123**

![atlas_login](assets/images/atlas-login.jpg)

2\. Go to **Classification** and press the `+ Create Tag` button to create a new tag.

- Name the tag: `PII`
- Add Description: `Personal Identifiable Information`

![create_new_tag](assets/images/create-new-tag.jpg)

Press the **Create** button. Then you should see your new tag displayed on the Classification page.

![atlas-pii-tag-created](assets/images/atlas-pii-tag-created.jpg)

3\. Go to the `Search` tab. In `Search By Type`, write `hive_table`

![search-hive-tables](assets/images/search-hive-tables.jpg)

4\. `employee` table should appear. Select it.

![employee-table-atlas](assets/images/employee-table-atlas.jpg)

- How does Atlas get Hive employee table?

Hive communicates information through Kafka, which then is transmitted to Atlas.
This information includes the Hive tables created and all kinds of data
associated with those tables.

5\. View the details of the `employee` table by clicking on its name.

![hive-employee-atlas-properties](assets/images/hive-employee-atlas-properties.jpg)

6\. View the **Schema** associated with
the table. It'll list all columns of this table.

![hive-employee-atlas-schema](assets/images/hive-employee-atlas-schema.jpg)

7\. Press the **green +** button to assign the `PII` tag to the `ssn` column.
Click **save**.

![add-pii-tag-to-ssn](assets/images/add-pii-tag-to-ssn.jpg)

8\. Repeat the same process to add the `PII` tag to the `location` column.

![added-pii-tag-to-ssn-and-location](assets/images/added-pii-tag-to-ssn-and-location.jpg)

We have classified all data in the `ssn and location` columns as `PII`.

## Create Ranger Tag Based Policy

Head back to the Ranger UI and log in using

~~~text
Username/Password: admin/hortonworks1
~~~

The tag and entity (ssn, location) relationship will be automatically inherited by Ranger. In Ranger, we can create a tag based policy
by accessing it from the top menu. Go to `Access Manager → Tag Based Policies`.

![ranger-tag-based-policies](assets/images/ranger-tag-based-policies.jpg)

You will see a folder called TAG that does not have any repositories yet.

Click `+` button to create a new tag repository.

![new-tag-rajops](assets/images/new-tag-rajops.jpg)

Name it `Sandbox_tag` and click `Add`.

![add-sandbox-tag-rajops](assets/images/add-sandbox-tag-rajops.jpg)

Click on `Sandbox_tag` to add a policy.

![added-sandbox-tag-rajops](assets/images/added-sandbox-tag-rajops.jpg)

Click on the `Add New Policy` button.

![add-new-policy-rajops](assets/images/add-new-policy-rajops.jpg)

Enter the following details:

~~~text
Policy Name – PII column access policy
Tag – PII
Description – Any description
Audit logging – Yes
~~~

![pii-column-access-policy-rajops](assets/images/pii-column-access-policy-rajops.jpg)

In the Allow Conditions, it should have the following values:

~~~text
Select Group - blank
Select User - raj_ops
Component Permissions - Select hive
~~~

You can select the component permission through the following popup. Check the
**checkbox** to the left of the word component to give `raj_ops` permission to
`select, update, create, drop, alter, index, lock, all, read, write, repladmin, service admin, temporary udf admin` operations against
the hive table `employee` columns specified by `PII` tag.

![new-allow-permissions](assets/images/new-allow-permissions.jpg)

Please verify that Allow Conditions section is looking like the image below:

![allow-conditions-rajops](assets/images/allow-conditions-rajops.jpg)

This signifies that only `raj_ops` is allowed to do any operation on the columns that are specified by PII tag. Click `Add`.

![pii-policy-created-rajops](assets/images/pii-policy-created-rajops.jpg)

Now click on `Access Manager` > `Resource Based Policies` and edit `Sandbox_hive` repository by clicking on the button next to it.

![editing-sandbox-hive](assets/images/editing-sandbox-hive.jpg)

Click on `Select Tag Service` and select `Sandbox_tag`. Click on `Save`.

![new-edited-sandbox-hive](assets/images/new-edited-sandbox-hive.jpg)

The Ranger tag based policy is now enabled for **raj_ops** user. You can test it by running the query on all columns in employee table on beeline.

Type the following command in beeline and paste the JDBC URL in between the quotes.

~~~bash
!q
beeline -u "Paste the JDBC URL here" -n raj_ops
~~~

![beeline-rajops-user](assets/images/beeline-rajops-user.jpg)

~~~sql
select * from employee;
~~~

![rajops-has-access-to-employee](assets/images/rajops-has-access-to-employee.jpg)

The query executes successfully. The query can be checked in the `Ranger Audit` log which will show the access granted and associated policy which granted access.

Clear the existing query and select `User` > `raj_ops` in the search bar.

![audit-results-rajops](assets/images/audit-results-rajops.jpg)

> **NOTE**: There are 2 policies which provided access to raj_ops user, one is a tag based policy and the other is hive resource based policy. The associated tags (PII) is also denoted in the tags column in the audit record).

## Summary

Ranger traditionally provided group or user based authorization for resources such as table, column in Hive or a file in HDFS.
With the new Atlas - Ranger integration, administrators can conceptualize security policies based on data classification, and not necessarily in terms of tables or columns. Data stewards can easily classify data in Atlas and use in the classification in Ranger to create security policies.
This represents a paradigm shift in security and governance in Hadoop, benefiting customers with mature Hadoop deployments as well as customers looking to adopt Hadoop and big data infrastructure for first time.

## Further Reading

- For more information on Ranger and Solr Audit integration, refer to [Install and Configure Solr For Ranger Audits](https://cwiki.apache.org/confluence/display/RANGER/Install+and+Configure+Solr+for+Ranger+Audits+-+Apache+Ranger+0.5)
- How Ranger provides Authorization for Services within Hadoop, refer to [Ranger FAQ](http://ranger.apache.org/faq.html)
- [HDP Security Doc](https://docs.hortonworks.com/HDPDocuments/HDP3/HDP-3.0.1/security.html)
- [Integration of Atlas and Ranger Classification-Based Security Policies](https://hortonworks.com/solutions/security/)
