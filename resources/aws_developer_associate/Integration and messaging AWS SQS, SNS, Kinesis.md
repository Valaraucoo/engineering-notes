# Integration and messaging: AWS SQS, SNS, Kinesis

- AWS SQS Standard Queue:
    - unlimited throughput
    - unlimited number of messages
    - default retention: 4 days
        - maximum retention: 14 days
    - low latency
    - limitation to of 246KB per message
    - can have duplicated messages
    - can have out of the order messages → best effort message ordering
    - send message → SendMessage API
    - read message → up to 10 messages at a time
    - delete message → DeleteMessage API
    - Inflight encryption using HTTPS API
    - At-rest using KMS Keys
- Metrics to scale consumers:
    - CloudWatch Metric → Queue Length → approx. number of messages
    - Metric triggers CW Alarm → scale Auto Scaling Group

- Message Visibility Timeout
    - After a message is polled by consumer → becomes **invisible** to other consumers
    - Default: 30 seconds
    - After visibility timeout → message is available for other consumers in SQS
    - Message should be explicit deleted
    - To extend message’s visibility timeout → consumer calls **ChangeMessageVisibility** API

- DLQ:
    - Messages have **MaximumReceive** threshold → if its exceeded → message goes to DLQ
    - Useful for debugging
    - **DLQ of a FIFO queue must also be a FIFO queue**
    - **DLQ of a Standard queue must also be a FIFO Standard**
    - Redrive to Source Feature:
        - Move messages from DLQ to SQS
        
- Delay Queue:
    - you can delay message up to 15min → consumer don’t see the message immediately
    - default delay is 0 seconds

- FIFO Queues:
    - Limited throughput: 300 msg/s without batching, 3000 msg/s with batching
    - Exactly-once send capability (by removing duplicates)
    - Messages are processed in order by the consumer
    - **DLQ of a FIFO queue must also be a FIFO queue**
    - De-duplication interval is **5 minutes**
    - Two de-duplication methods:
        - **Content-based** deduplication: will do an SHA-256 hash of the message body
        - Explicitly provide a Message **Deduplication ID**
    - Message Grouping (for FIFO queues):
        - If you specify the same value of MessageGroupID in an SQS FIFO queue, you can only have one consumer, and all the messages are in order
        - You can set different values for MessageGroupID at the level of a subset of messages
        - Each group ID can have a different consumer (parallel processing)
        - Ordering across groups is not guaranteed
    
    <aside>
    ℹ️ **MessageGroupId** is the tag that specifies that a message belongs to a specific message group. Messages that belong to the same message group are always processed one by one, in a **strict order** relative to the message group (however, messages that belong to different message groups might be processed out of order).
    
    </aside>
    
- SNS:
    - One message to many receivers (pub-sub)
    - The “event producer” only sends a message to one SNS topic
    - As many “event receivers” (subscribers) as we want to listen to the SNS topic notifications
    - Each subscriber to the topic will get all the messages
    - Up to 12.5 mln subscriptions per topic
    - 100k topics limit
    - SNS Subscribers: emails, SMS & Mobile Notifications, HTTP Endpoints, SQS, Lambda, Kinesis
    - SNS integrates with many services, e.g. CW Alarms, Lambda, ASG, etc.
    - How to publish?
        - Topic Publish (SDK/API) → create topic → create a subscription → publish to the topic
        - Direct Publish (for mobile apps SDK) → create a platform app, platform endpoint, publish to the platform endpoint

- SNS + SQS: Fan Out Pattern
    - Push one in SNS, receive in all SQS queues that are subscribers
    
    ![Untitled](Integration%20and%20messaging%20AWS%20SQS,%20SNS,%20Kinesis%200baf44bf3c714d2ca0f981fb13655574/Untitled.png)
    
    - Fully decoupled, no data loss
    - Ability to add more SQS subscribers over time
    - Example: if you want to send the same S3 event to many SQS queues → use fan-out

- SNS has support for FIFO topics
    - Ordering by Message Group ID
    - Deduplication using a Deduplication ID or Content Based Deduplication
- **Can only have SQS FIFO queues as subscribers**
- Limited throughput (same throughput as SQS FIFO)

- SNS Message Filtering:
    - JSON policy used to filter messages sent to SMS topic’s subscribers
    - Useful in Fan-out pattern

- AWS Kinesis:
    - Amazon Kinesis makes it easy to collect, process, and analyze real-time, streaming data, so you can get timely insights and react quickly to new information
    - Kinesis Data Streams: capture, process and store data streams
    - Kinesis Data Firehose: load data streams into AWS data stores
    - Kinesis Data Analytics: analyze data streams with SQL or Apache Flink
    - Kinesis Video Streams: capture, process and store video streams

- Kinesis Data Streams:
    - Stream big data in your systems
    - A typical Kinesis Data Streams application reads data from a *data stream*
     as data records
    - A Kinesis data stream is a set of **shards**. Each shard has a sequence of data records. Each data record has a sequence number that is assigned by Kinesis Data Streams.
        - A shard is a uniquely identified sequence of data records in a stream.
        - A stream is composed of one or more shards, each of which provides a fixed unit of capacity.
    - **Data Record** — a data record is the unit of data stored in a Kinesis data stream. Data records are composed of a **sequence number**, **a partition key** and **Data Blob**, which is an immutable sequence of bytes.
        - A data blob can be up to 1 MB
        - **Partition Key** determine in which shard will the record go to
            - A partition key is used to group data by shard within a stream
    - Producers sending data at the rate of 1MB/sec or 1000 msg/sec per shard
        - e.g. 6 shards → max 6000 msg/sec
        - Producer → web application that send logs
    - Kinesis Data Streams can be consumed by many consumers
        - Two consumption modes:
        - 2MB/sec (shared) per shard all consumers
        - 2MB/sec (enhanced) per shard per consumer
    - Kinesis Data Stream Retention between 1 dat to 365 days
    - Ability to reprocess (replay) data
    - Once data is inserted in Kinesis it cannot be deleted (immutability)
    - Data that shares the same partition goes to the same shard (ordering)
    - Capacity Modes:
        - A data stream capacity mode determines how capacity is managed and how you are charged for the usage of your data stream
        - **Provisioned mode**:
            - You choose the number of shards provisioned, scale manually or using API
            - Each shard gets 1MB/sec or 1000 records per second INPUT
            - Each shard gets 2MB/s OUTPUT
            - You pay per shard provisioned per hour
        - **On-demand mode:**
            - No need to provision or manage the capacity
            - Kinesis Data Streams automatically manages the shards in order to provide the necessary throughput
            - Default capacity provisioned 4MB/sec or 4000 records per second
            - Scales automatically based on observed throughput peak during the last 30 days
            - Pay per stream per hour & data in/our per GB

Kinesis Producers:

- Producers puts data records into data streams
- Data record: sequence number, partition key, data blob
- AWS SDK, Kinesis Producer Library (KPL), Kinesis Agent (monitor log files)
- Write throughput: 1 MB/sec or 1000 records/sec per shard
- PutRecord API
- Use batching with **PutRecords** API to reduce costs & increase throughput
- **************************************************************************************Use highly distributed partition key to avoid “hot partition”**************************************************************************************

Kinesis Consumers:

- Consumers get records from Amazon Kinesis Data Streams and process them
- Lambda, kinesis data analytics, data firehose, custom consumer (AWS SDK), KCL (kinesis client library)
- **Shared (classic) fan-out consumer - pull:**
    - low number of consuming applications
    - **read throughput: 2MB/s per shard across all consumers**
    - Max. 5 GetRecords API calls/sec
    - Latency ~200ms
    - Minimize cost
    - Consumers poll data from Kinesis using GetRecords API call
    - Returns up to 10MB or up to 10k records
- **Enhanced Fan-out Consumer - push:**
    - Uses SubscribeToShard API call
    - Shard send the data to Consumer
    - Multiple consuming applications for the same stream
    - 2MB/sec per consumer per shard
    - Latency ~70ms (shard itself will push the data into out consumer)
    - Higher Costs $$$
    - Kinesis pushes data to consumers over HTTP/2
    - Soft limit of 5 consumers apps per data stream
- Consumers and Lambda:
    - Supports Classic & Enhanced fan-out consumers
    - Read records in batches
    - Can configure batch size and batch window
    - If errors occurs, Lambda retries until succeed or data expired
    - Can process up to 10 batches per shard simultaneously

- Kinesis Client Library (KCL)
    - A Java library that helps read a record from a Kinesis Data Stream with distributed applications sharing the read workload
    - Each shard is to be read by only one KCL instance
        - 4 shards = max. 4 KCL instances
    - Reading progress is checkpointed into DynamoDB (needs IAM access)
        - If KCL runs in multiple instances - DynamoDB is used to orchestrate reading
    - Track other workers and share the work amongst shards using DynamoDB
    - KCL can run on EC2 and EB
    - Records are read in order at the shard level
    - KCL 1.X → supports shared consumer
    - KCL 2.X → supports shared consumer and fan-out consumer

- Kinesis Operations — Shard Splitting
    - Used to split one shard into two → more shards → more capacity → and also more costs
    - Used to increase the Stream Capacity (1 MB/s data in per shard)
    - Used to divide a “hot shard”
    - To split a shard in Amazon Kinesis Data Streams, you need to specify how hash key values from the parent shard should be redistributed to the child shards.
    
    ![Untitled](Integration%20and%20messaging%20AWS%20SQS,%20SNS,%20Kinesis%200baf44bf3c714d2ca0f981fb13655574/Untitled%201.png)
    
    - The old shard is closed and will be deleted once the data is expired
    - No automatic scaling
    - Cannot split into more than two shards in a single operation
- Shard Merging:
    - Decrease the stream capacity → save costs
    - can be used to group two shards with low traffic → “cold shards”
    
    ![Untitled](Integration%20and%20messaging%20AWS%20SQS,%20SNS,%20Kinesis%200baf44bf3c714d2ca0f981fb13655574/Untitled%202.png)
    
    - Old shards are closed and will be deleted once the data is expired
    - Cannot merge more than two shards in as single operation

- Kinesis Data Firehose
    - Amazon Kinesis Data Firehose is a fully managed service (autoscaling, serverless) for delivering real-time streaming data
    - KDF take data from producers (apps, clients, SDK, KPL, Kinesis Agent, Kinesis Data Stream, Amazon Cloud Watch, AWS IoT)
    - Up to 1MB per record input
    - Optionally, it can transform data using Lambda Functions
    - KDF write data in batches into destinations:
        - AWS Destinations: S3, Redshift (copy through S3), OpenSearch
        - 3rd party: Datadog, Splunk, New Relic, MongoDB
        - Custom Destinations: HTTP Endpoint
    - Pay for data going through Firehose
    - No data storage
    - **Near real time**
        - 60 seconds latency minimum for non full batches
        - or minimum 1MB of data at a time
    - Supports many data formats, conversions, transformations, compression
    - Supports custom data transformations using Lambda
    
    ![Untitled](Integration%20and%20messaging%20AWS%20SQS,%20SNS,%20Kinesis%200baf44bf3c714d2ca0f981fb13655574/Untitled%203.png)
    
- Kinesis Data Analytics
    - KDA for SQL apps:
        - data sources: KDS, KDF
        - then apply SQL statements for real time analytics
        - outputs: KDS, KDF
    - Real-time analytics on KDS & KDF using SQL
    - Fully managed, serverless, automatic scaling
    - Pay for actual consumption rate
    - use cases: time-series, real time dashboards, real time metrics
- KDA for Apache Flink
    - Use Flink (Java, Scala, SQL) to process and analyze streaming data
    - Source: KFS, Amazon MSK
    - Run any Apache Flink application on a managed cluster on AWS
    - Provisioning compute resources, parallel computation, automatic scaling
    - automatic backups

- Ordering data into Kinesis
    - Use partition key → the same key will always go to the same shard
- Ordering data into SQS (standard)
    - no ordering
- Ordering data into SQS FIFO
    - if you don’t use a Group ID, messages are consumed in the order they are sent, with only **one consumer**
    - You want to scale the number of consumers but you want messages to be “grouped” when they are related to each other → use Group ID (similar to Partition Key in Kinesis)
    
- SQS:
    - Consumer pull data
    - Data is deleted after being consumed
    - Can have as many consumers as we want
    - No need to provision throughput
    - Ordering guarantees only on FIFO queues
    - Individual message delay capability
- SNS:
    - push data to many subscribers
    - up to 12.5mln subscribers
    - data is not persisted (lost if not delivered)
    - up to 100k topics
    - no need to provision throughput
    - Integrates with SQS → fan-out
    - FIFO capability for SQS FIFO
- Kinesis:
    - Standard: pull data → 2MB per second per shard
    - Enhanced-fan out: push data → 2MV per second per shard
    - Possibility to replay data
    - Meant for real-time big data, analytics and ETL
    - Ordering at the shard level
    - Data expires after X days
    - Provisioned mode or on-demand capacity mode