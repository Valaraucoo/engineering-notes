# AWS Monitoring: CloudWatch, X-Ray, CloudTrail

Monitoring in AWS:

- AWS CloudWatch:
    - Metrics: collect and track key metrics
    - Logs: collect, monitor, analyze and store log files
    - Events: send notifications when certain events happen in your AWS
- AWS X-Ray:
    - Troubleshooting application performance and errors
    - Distributed tracing of microservices
- AWS CloudTrail:
    - Internal monitoring of API calls being made
    - audit changes to AWS Resources by your users

CloudWatch Metrics:

- CW provides metrics for **every** service in AWS
- **Metric is a variable to monitor (CPU Utilization, Network Input, etc.)**
- Metric belong to **namespaces**
- **Dimension** is an attribute of a metric (instance id, env, etc.)
    - Up to 10 dimensions per metric
- Metrics have **timestamps**
- You can create CW dashboards of metrics

EC2 Detailed Monitoring

- EC2 instances metrics have metrics **every 5 minutes**
    - with detailed monitoring (additional costs), you get data every 1 minute
    - use detailed monitoring if you want to scale faster for your ASG!
- Free Tier → 10 detailed monitoring metrics
- Note: Memory/Ram usage of EC2 instance is not pushed by default (you should create custom metric)

CloudWatch Custom Metrics:

- Possibility to define and send your own custom metrics
    - Example: RAM usage, disk space, number of users
- Use API call **PutMetricData `aws cloudwatch put-metric-data`**
- Ability to use dimensions (attributes) to segment metrics
    - Instance.id
    - Environment.name
- Metric resolution (**StorageResolution** API parameter):
    - Standard: 1 minute
    - High Resolution: 1/5/10/30 second(s) -< costs
- **Important: Accepts metric data points two weeks in the past and two hours in future (make sure to configure your EC2 instance time correctly)**

CloudWatch Logs:

- **Log groups**: arbitrary name, usually representing an application
- **Log stream**: instances within application / log files / containers
- Can define log expiration policies (never expire, 30 days, etc.)
- **In CloudWatch Logs, Log Retention Policy defined at Log Groups level.**
- **CloudWatch Logs can send logs to:**
    - S3, Kinesis, Lambda, ElasticSearch

CloudWatch Logs — Sources:

- SDK, CloudWatch Logs Agent, CloudWatch Unified Agent
- Elastic Beanstalk: collection of logs from app
- ECS: logs from containers
- Lambda
- VPC Flow Logs
- API Gateway
- CloudTrail
- Route53: DNS queries

- Metric filters can be used to trigger **CloudWatch Alarms**

- CloudWatch Logs Insights can be used to query logs and add queries to CloudWatch Dashboards

- You can Export logs to S3 bucket
    - You can export log data from your log groups to an Amazon S3 bucket and use this data in custom processing and analysis or to load onto other systems
    - **Log data can take up to 12 hours to become available to export**
    - The API call is **CreateExportTask**
    - Not real-time → use Logs Subscriptions instead to stream logs
- Logs Subscriptions → filter logs and send them to a destination, e.g. Lambda function

- Logs Aggregation Multi-Account & Multi-Regions:
    - you can subscribe logs from multiple accounts (and regions) and send them to **Kinesis Data Streams → Kinesis Data Firehose → S3**

CloudWatch Logs for EC2:

- By default no logs from EC2 instance will go to CW
- You need to run a **CW agent** on EC2 to push the log files you want
- Make sure IAM permissions are correct

![Untitled](AWS%20Monitoring%20CloudWatch,%20X-Ray,%20CloudTrail%2038b59c17dc004b078439849f95def184/Untitled.png)

- The CW log agent can be setup on-premises too

CW Logs Agent & Unified Agent:

- **CloudWatch Logs Agent** — old version, can only sent to CW Logs
- **CloudWatch Unified Agent** — collect additional system-level metrics such as RAM, processes, etc. → collect logs to send to CW Logs
    - Centralized configuration using SSM Parameter Store for all Unified Agents

CW Unified Agent — Metrics:

- Collected directly on your Linux Server / EC2 instance
- **CPU** (active, guest, idle, system, user, steal)
- **Disk** **Metrics** (free, used, total), Disk IO (writes, reads, …)
- **RAM** (free, inactive, …)
- **Netstat**
- **Processes** (total, dead, blocked, running, …)
- **Swap Space** (free, used, used %)
- and more

CW Logs Metric Filter:

- CW Logs can use filter expressions
    - e.g. find specific IP inside a log
- Metric filters can be used to **trigger alarms**
- **Filters do not retroactively filter data.**
- **Filters only publish the metric data points for events that happen after the filter was created.**

CW Alarms:

- Alarms are used to trigger notifications for any **metric**
- Various options (sampling, max, min, etc. )
- Alarm states: OK, INSUFFICIENT_DATA, ALARM
- Period:
    - length of time in seconds to evaluate the metric
    - high resolution metrics: 10s, 30s, …, 60s
- Alarms can be created based on **CW Logs Metrics Filters**
- To test alarms and notifications, set the alarm state to Alarm using CLI:
    - `set-alarm-state`

CW Alarms Targets:

- **Actions on EC2** instances: stop, terminate, reboot, recover
- **Trigger Auto Scaling Action**
- **Send notification to SNS** (you can do anything you want with SNS notification → e.g. trigger Lambda Func)

Composite Alarms:

- CW Alarms are on a single metric
- **Composite Alarms are monitoring the states of multiple other alarms**
- AND and OR conditions
- Helpful to reduce “alarm noise” by creating complex composite alarms

CW Synthetics Canary:

- Configurable script that monitor your APIs, URLs, Websites
- Reproduce what your customers do programmatically to find issues before customers are impacted
- Checks the availability and latency of your endpoints and can store load time data and screenshots of the UI
- If CW Synthetics Canary monitoring fails → triggers CloudWatch Alarm
    - and CW Alarm can invoke Lambda
- Scripts written in Node.js or Python
- Programmatic access to a headless Google Chrome browser
- Can run once or on a regular schedule
- The blueprints are available:
    - **********************************Heartbeat Monitor********************************** — load URL, store screenshot and an HTTP archive file
    - ********************API Canary******************** — test basic read and write functions of REST APIs
    - **************************************Broken Link Checker************************************** — check all links inside the URL that you are testing
    - **********************************Visual Monitoring********************************** — compare a screenshot taken during a canary run with a baseline screenshot
    - ******************************Canary Recorder****************************** — record your actions on a website
    - ****************************************GUI Workflow Builder****************************************

CloudWatch Event:

- Amazon CloudWatch Events delivers a near real-time stream of system events that describe changes in Amazon Web Services (AWS) resources.
    - you can match events and route them to one or more target functions or streams
- CloudWatch Events responds to these operational changes and takes corrective action as necessary, by sending messages to respond to the environment, activating functions, making changes, and capturing state information.
    - A JSON payload is created from the event and passed to a target
    - example targets: SQS, SNS, Step Functions, CodePipeline, etc.
- You can also use CloudWatch Events to **schedule automated actions** that self-trigger at certain times using cron or rate expressions.
    - Scheduler or Cron — example: create an event every 4 hours

CW Events Definitions:

- **Events** – An event indicates a change in your AWS environment.
    - example: Amazon EC2 generates an event when the state of an EC2 instance changes from pending to running
    - example sources: EC2 instance start, CodeBuild Failure, S3
    - Can intercept any API call with CloudTrail integration
- **Rules** – A rule matches incoming events and routes them to targets for processing.
- **Targets** – A target processes events.

Amazon EventBridge:

- EventBridge is the next evolution of CW Events
- *EventBridge was formerly called Amazon CloudWatch Events. Amazon CloudWatch Events and EventBridge are the same underlying service and API, however, EventBridge provides more features.*
- **Default Event Bus** — generated by AWS services (same for CW Events)
- Event Bridge has also **Partner Event Bus** — receive events from SaaS service or applications (Zendesk, DataDog, Auth0, etc.)
- ****************************Custom Event Bus**************************** — for your own applications
- Event buses can be accessed by other AWS accounts
- You can **archive** **events** (all/filtered) sent to an event bus
- Ability to **replay archived events**
- **Rules** (like in CW Events) → how to process the events

EventBridge — Schema Registry:

- EventBridge can analyze the events in your bus and infer the **schema**
- The Schema Registry allows you to generate code for your application, that will know in advance how data is structured in the event bus
- Schema can be versioned

EventBridge — Resource-based Policy:

- Manage permissions for a specific Event Bus

EventBridge vs CloudWatch Events:

- EB builds upon and extends CW Events
- It uses the same service API and endpoints, and the same underlying service infra
- EB allows extension to add event buses for your custom applications and your 3rd party sass apps
- EB has the schema registry capability
- EB has a different name to mark the new features
- Over time, the CW Events name will be replaces with EB

EventBridge — Multi-account Aggregation:

- There is a possibility to access event from another accounts via Event Rule

AWS X-Ray:

- AWS X-Ray provides a complete view of requests as they travel through your application
    - Troubleshooting application performance and errors
    - Distributed tracing of microservices
- AWS X-Ray is a service that collects data about requests that your application serves, and provides tools that you can use to view, filter, and gain insights into that data to identify issues and opportunities for optimization.
    - For any traced request to your application, you can see detailed information not only about the request and response, but also about calls that your application makes to downstream AWS resources, microservices, databases, and web APIs.
    - AWS X-Ray receives traces from your application, in addition to AWS services your application uses that are already integrated with X-Ray.
- Why?
    - Debugging with logs is hard — log formats differ across applications using CW and analytics is hard
    - Debugging monolith is easy, but for distributed services is really hard

- X-Ray provides visual analysis of your applications
- X-Ray helps you find application bottlenecks (troubleshooting performance)
    - Also, it helps understand dependencies in a microservices architecture
    - Find errors and exceptions
- X-Ray compatibility:
    - Lambda, EB, ECS, ELB, API GW, EC2 instances (also on-premises)
- Tracing — is an end-to-end way to follow a request
    - Each component dealing with the request add its own “trace”
    - Annotations can be added to traces to provide extra-informations
    - Ability to trace: every request or sample requests (% or rate per minute)
- X-Ray Security:
    - IAM form authorization
    - KMS for encryption at rest
- How to enable X-Ray?
    - **Your Code (Java, Python, Go, Node) must import the AWS X-Ray SDK**
        - Little code modification needed
        - The application SDK will then capture: calls to other services, HTTP requests, database calls (RDS), queue calls (SQS)
    - **Install the X-Ray deamon or enable X-Ray AWS Integration**
        - X-Ray deamon works as a low level UDP packet interceptor (Linux/Windows/Mac)
        - AWS Lambda (and other services) already run the X-Ray deamon for you
        - Each application must have the **IAM Rolet** to write data to X-Ray
        

**AWS X-Ray: Instrumentation and Concepts**

- Instrumentation — the measure of product’s performance, diagnose errors, and to write trace informations
- To instrument your app code -> use the X-Ray SDK
- Many SDK require only configuration changes
- You can modify your application code to customise and annotation the data that the SDK sends to X-Ray, using **interceptors, filters, handlers, middleware**, etc.

Advanced X-Ray concepts:

- Segments — each application / service will send them
    - A segment provides the resource's name, details about the request, and details about the work done.
    - For example, when an HTTP request reaches your application, it can record the following data about: host, request method, client address, user-agent, response status/content, etc.
- Subsegments — if you need more details in your segments
    - A subsegment can contain additional details about a call to an AWS service, an external HTTP API, or an SQL database
- Trace — segments collected together to form an end-to-end trace
    - A trace collects all the segments generated by a single request
- Sampling — decrease the amount of requests sent to X-ray, reduce costs
    - the X-Ray SDK applies a **sampling** algorithm to determine which requests get traced.
    - Be default X-Ray does not record all requests
    - For example, you might want to disable sampling and trace all requests for calls that modify state or handle user accounts or transactions
- Annotations — key value pairs used to index traces and use with filters
    - You can add other information to the segment document as annotations and metadata
    - Annotations can be added to any segment or subsegment
- Metadata — key values pairs, **not indexed** not used for searching
    - Use metadata to record data you want to store in the trace but don't need to use for searching traces
- The X-ray deamon / agent has a config to send traces cross account:
    - Allows us to have a central account for all your apps tracing

Sampling Rules:

- With sampling rules, you can control the amount of data that you record
- Sampling rules tell the X-Ray SDK how many requests to record for a set of criteria.
- By default the X-Ray SDK records the first requests **EACH SECOND** and **FIVE PERCENT** of any additional requests
- **One request per second is the *reservoir***
    - This ensures that at least one trace is recorded each second as long as the service is serving requests
- **Five percent is the *rate*** at which additional requests beyond the reservoir size are sampled
- You can create your own sampling rules with the **reservoir** and **rate**
    - Also we can set priority, and matching criteria: service name, service type, host, HTTP method, URL path, resource are
    - String values can use wildcards to match a single character (?) or zero or more characters (*)

AWS X-Ray Write API (used by the X-Ray daemon):

- **PutTraceSegments** — upload segment document to AWS X-Ray
- **PutTelemetryRecords** — used by the AWS X-Ray daemon to upload telemetry — metrics → how many requests received, rejected, errors
- **GetSamplingRules** — retrieve all sampling rules (to know what/when to send)
- GetSamplingTargets + GetSamplingStatisticsSummaries — advanced
- The X-Ray daemon need to have an ********************IAM Policy******************** authorizing the correct API calls to function correctly

AWS X-Ray Read API:

- ********************************GetServiceGraph******************************** — main graph
- ****************************BatchGetTraces**************************** — retrieves a list of traces specified by ID, each trace is a collection of segment documents that originates from a single request
- **********************************GetTraceSummaries********************************** — retrieves IDs and annotations for traces available for a specified time frame using an optional filter, to get the full traces, pass the trace IDs to BatchGetTraces
- **************************GetTraceGraph************************** — retrieves a service graph for one or more specific trace IDs

X-Ray with Elastic Beanstalk

- AWS EB platforms include the X-Ray daemon
- You can run the daemon by setting an option in the EB console or with a configuration file (in `.ebextensions/xray-daemon.config`)
- The X-Ray daemon is not provided for Multicontainer Docker

X-Ray + ECS:

- 3 Ways to run X-Ray in ECS Cluster:
- **X-Ray Container as a Daemon** (EC2 Instances)**:**
    - X-Ray Daemon Container will be running in every single EC2 Instances
- **X-Ray Containter as a “Side Car”** (EC2 Instances)**:**
    - One X-Ray Daemon Container alongside each application container
- **X-Ray Containter as a “Side Car”** (Fargate)**:**
    - One X-Ray Daemon Container alongside each application container in Fargate Task

AWS Distro for OpenTelemetry:

- Secure, production-ready AWS-supported distribution of the open-source project OpenTelemetry
- Provides a single set of APIs, libraries, agents..
- Collects distributed traces and metrics from your apps
- Collects metadata from your AWS resources and services
- Similar to X-ray but open-source
- ********************************************************************************************************Auto-instrumentation Agents to collect traces without changing your code********************************************************************************************************
- Send traces and metrics to multiple AWS services and partner solutions
    - X-Ray, CloudWatch, Prometheus, …
- Instrument you apps running on AWS as well as on-premises
- ********************************************************************************************Migrate from X-Ray to AWS Distro for OpenTelemetry if you want to standardize with open-source APIs from Telemetry or send traces to multiple destinations simultaneously********************************************************************************************

AWS CloudTrail:

- Provides governance, compliance and audit for your AWS Account
- With AWS CloudTrail, you can monitor your AWS deployments in the cloud by getting a history of AWS API calls for your account, including API calls made by using the AWS Management Console, the AWS SDKs, the command line tools, and higher-level AWS services.
- You can view the past **90 days** of recorded API activity (management events) in an AWS Region in the CloudTrail console by going to **Event history**.
- You can also identify which users and accounts called AWS APIs for services that support CloudTrail
- **CloudTrail is enabled by default**
- Get an history of events / API calls made within your AWS Account by: Console, SDK, API, CLI, AWS Services
- Can put logs from CloudTrail into CloudWatch Logs or S3
- **A trail can be applied to All Regions (default) or a single Region**

CloudTrail Events:

- There are 3 type of CT Events
- **Management Events**:
    - Operations that are performed on resources, e.g. configuring security `Attach IAM Role Policy`
    - By default, trails are configure to log management events
    - Can separate **Read** **Events** (that don’t modify resources) from **Write** **Events** (that may modify resources)
- **Data Events**:
    - By default, data events are **not logged** (due to high volume operations)
    - e.g. Amazon S3 object-level activity: GetObject, DeleteObject → we can separate Read and Write Events
- **CloudTrail Insights Events**
- We can integrate CT events with EventBridge

Organization Trail:

- If you have created an organization in AWS Organizations, you can also create a trail that will log all events for all AWS accounts in that organization.
    - This is referred to as an organization trail.
- An Organization Trail in AWS is a feature of AWS CloudTrail.
- AWS CloudTrail is a service that enables governance, compliance, operational auditing, and risk auditing of your AWS account.
- An Organization Trail, specifically, is a type of trail that can log events for **all AWS accounts** in an organization created using AWS Organizations.
- When you create a trail and designate it as an organization trail, CloudTrail applies the trail to all AWS accounts in the organization.
- It logs events in each account and delivers those events to a **single S3 bucket** that you specify.
    - It allows you to uniformly apply and enforce your event logging strategy across all accounts in your organization.
- This is particularly useful for centralized logging and analysis, where a security or administrative team might want to monitor and analyze AWS account activity across an entire organization.

- **By default, CloudTrail tracks only bucket-level actions. To track object-level actions, you need to enable Amazon S3 Data Events ([more](https://aws.amazon.com/about-aws/whats-new/2016/11/aws-cloudtrail-supports-s3-data-events/))**
    - AWS CloudTrail supports Amazon S3 Data Events, apart from bucket Events.
    - You can record all API actions on S3 Objects and receive detailed information such as the AWS account of the caller, IAM user role of the caller, time of the API call, IP address of the API, and other details.
    - All events are delivered to an S3 bucket and CloudWatch Events, allowing you to take programmatic actions on the events.
- **Member accounts will be able to see the organization trail, but cannot modify or delete it**
    - Organization trails must be created in the master account, and when specified as applying to an organization, are automatically applied to all member accounts in the organization.
    - Member accounts will be able to see the organization trail, but cannot modify or delete it.
- **By default, member accounts will not have access to the log files for the organization trail in the Amazon S3 bucket.**
- **By default, CloudTrail event log files are encrypted using Amazon S3 server-side encryption (SSE).**

CloudTrail Insights:

- Enable CT Insights to **detect unusual activity** in your account, e.g.
    - Inaccurate resource provisioning
    - Hitting service limits
    - Bursts of AWS IAM actions
- CT Insights analyzes normal management events to create a baseline
- And then analyzes **write events to detect unusual patterns**
- Management Events are analyzed by CT Insights→ generate Insights Events

CloudTrail Events Retention:

- Events are store for 90 days in CT
- To keep events beyond this period, log them to S3 and use Athena