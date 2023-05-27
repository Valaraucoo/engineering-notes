# Other Services: SES, OpenSearch, Athena, MSK, ACM, AppConfig

AWS SES — Simple Email Service:

- Send emails to people using: SMTP interface or AWS SDK
- Ability to receive email, integrates with: S3, SNS, Lambda
- Integrated with IAM for allowing to send emails

Amazon OpenSerach Service:

- it’s successor to Amazon ElasticSearch
- In DynamoDB queries only exist by primary key or indexes
- **With OpenSearch you can search any field, even partially matches**
- It’s common to use OpenSearch as a complement to another database and services:
    - DynamoDB, CloudWatch Logs, Kinesis Data Streams
- Two modes: **managed** cluster or **serverless** cluster
- Does not natively support SQL (can be enabled via plugin)
- Security through Cognito, IAM, KMS encryption, TLS
- Comes with OpenSearch Dashboards

Amazon Athena:

- **Serverless** query service to analyze **data stored in S3**
- Uses SQL language to query the files
- Supports CSV, JSON, ORC, Avro, …
- Pricing: $5 per TB of data scanned
- Commonly used with **Amazon Quicksight** for reporting/dashboards
- Use cases: BI/ analytics, rerpoting, analyze logs
- **Exam Tip:** analyze data in S3 using serverless SQL → use Athena
- Performance Improvement:
    - Use **columnar data** for cost-saving (less scan)
        - Appache Parquet or ORC format is recommended
        - Huge performance improvement
        - Use Glue to convert your data to Parquet or ORC
    - **Compress data** for smaller retrievals (bzip2, gzip, lz4, ..)
    - **Partition datasets** in S3 for easy querying on virtual columns
    - ********Use larger files >128 MB to minimize********
- Federated Query:
    - Allow you to run SQL queries across data stored in relational, non-relational, object and custom data sources
    - Uses **Data Source Connectors** that run on AWS Lambda to run **********************************Federated Queries********************************** (e.g. CW Logs, DynamoDB, RDS, …)
    - Store results back in S3

Amazon MSK (Managed Streaming for Apache Kafka):

- Alternative to Amazon Kinesis
- Fully managed Apache Kafka on AWS
    - Allow you to create, update, delete clusters
    - MSK creates & manages Kafka brokers nodes & zookeeper nodes for you
    - Deploy the MSK cluster in your VPC, multi-AZ (up to 3 for HA)
    - Automatic recovery from common Apache Kafka failures
    - Data is stored on EBS volumes **********************************************for as long as you want**********************************************
- You can also run MSK **serverless**
    - Run Apache Kafka on MSK without managing the capacity
    - MSK automatically provisions resources and scales compute & storage
- Similar to Kinesis Data Streams
    - Message Size: 1MB (default) → can be higher (KDS limit is 1MB)
    - Kafka Topics are partitioned into Partitions
    - PLAINTEXT or TLS in-flight encryption
    - KMS at-rest encryption
- MSK Consumers:
    - Kinesis Data Analytics for Apache Flink
    - AWS Glue
    - Lambda
    - Applications running on EC2, ECS, EKS

AWS Certificate Manager (ACM):

- provision, manage and deploy **SSL/TLS Certificates**
    - Used to provide in-flight encryption for websites (HTTPS)
- Supports both public and private TLS certificates
- Free of charge for public TLS certificates
- Automatic TLS certificate renewal
- Integrations with:
    - Elastic Load Balancers
    - CloudFront Distributions
    - API Gateway

AWS Private Certificate Authority (CA):

- Managed service allows you to create private CAs, including root and subordinaries CAs
- Can issue and deploy end-entity X.509 certificates
- **Certificates are trusted only by your Organization** (not the public Internet)
- Works for AWS Services that are integrated with ACM (e.g. CloudFront, API GW, ELB, EKS)
- Use cases: encrypted TLS communication, cryptographically signing code, authenticate users, computers, API endpoints and IoT devices

AppConfig:

- AWS AppConfig is a service offered by Amazon Web Services that enables developers to manage, deploy, and monitor application configurations quickly and easily, without downtime.
- Application configurations are settings that can be tweaked without changing the codebase of an application.
    - For instance, **feature toggles** (or feature flags), **operational parameters**, or constants could be considered as application configurations.
- Configure, validate and deploy dynamic configurations
- You don’t need to restart the application
- Use with apps on EC2, Lambda, ECS, EKS, …
- Gradually deploy the configuration changes and rollback if issues occur
- Validate configuration changes before deployment using:
    - JSON schema (syntatic check) or Lambda Function (semantic check)

Here's a brief overview of what AWS AppConfig provides:

1. Configuration Deployment: AWS AppConfig allows you to deploy application configurations in a controlled and monitored way across your applications. This can be done across different environments and AWS regions.
2. Validation: AWS AppConfig allows you to set up validation checks for your configuration data to avoid deploying a bad configuration. These checks ensure that your application behaves as expected when the new configuration is deployed.
3. Monitoring: AWS AppConfig integrates with AWS CloudWatch and AWS CloudTrail, providing insights into when and how configurations are deployed and allowing you to track changes over time.
4. Rollback: If a configuration change results in undesired application behaviour, AWS AppConfig allows you to quickly roll back the changes, minimising the potential impact on your application users.
- The goal of AWS AppConfig is to improve the speed, safety, and stability of application updates.
- It simplifies the process of managing and deploying application configurations, reducing the likelihood of errors and the impact of bad deployments.