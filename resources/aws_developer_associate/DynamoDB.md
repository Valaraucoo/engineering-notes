# DynamoDB

DynamoDB:

- NoSQL Serverless Database
- Integrated with AWS Lambda and another AWS services
- Distributed and easy to scale horizontally
- Fully managed, high available with replication across multiple AZs
- Scales to massive workloads
- Fast an consistent in performance
- Integrated with IAM for security
- Low cost and auto-scaling
- DynamoDB is made of **Tables**
- Each table has a **Primary Key** (must be decided at creation time)
- Each table can have an infinite number of items (rows)
- Each item has attributes (can be added over time - can be null)
- **Maximum size of an item is 400KB**
- Data types supported: scalars, document types, set types

Primary Keys:

- **Partition Key** (Hash):
    - Partition key must be unique for each item
    - Partition key must be “diverse” so that the data is distributed
- **Partition Key + Sort Key** (Hash + Range):
    - The combination must be unique for each item
    - Data is grouped by partition key

Table Class:

- **DynamoDB Standard**
- **DynamoDB Standard-IA** → for infrequently accessed tables

Read/Write Capacity Modes:

- Control how you manage your’s table capacity (RW throughput)
- **Provisioned** (default, free tier)
    - You specify the number of reads/writes per second
    - You need to plan capacity beforehand
    - Pay for **provisioned** read & write capacity units
    - Pay every hour for specified/provisioned capacity
    - Table must have provisioned read and write capacity units
    - **Read Capacity Units** (RCU) — throughput for reads
    - **Write Capacity Units** (WCU) — throughput for writes
    - Option to setup auto-scaling of throughput to meet demand
    - In case of “ProvisionedThroughputExceededException” it’s advised to do an **exponential backoff** retry
- **On-demand** → billing by paying for the actual reads and writes
    - Read/writes automatically scale up/down with your workloads
    - No capacity planning needed (no need to specify WCU and RCU)
    - Unlimited WCU/RCU no throttle
    - Pay for what you use, more expensive
    - RRU (Read Request Units)
    - WRU (Write Request Units)
    - 2.5x more expensive then provisioned capacity
    - Use cases: unknown workloads
- You can switch between different modes once every 24 hours

**Write Capacity Units (WCU):**

- **One WCU represents one write per second for an item up to 1 KB in size**
- If the items are larger than 1 KB, more WCUs are consumed
- If item size is 4.5 KB → it gets rounded to the upper 5 KB

Read modes for DynamoDB — Strongly Consistent Read vs. Eventually Consistent Read:

- **Eventually Consistent Read** (default):
    - If we read just after a write, it’s possible we’ll get some stale data because of replication
    - Eventually consistent reads are cheaper and are less likely to experience high latency
- **Strongly Consistent Read**:
    - If we read just after a write, we will get the correct data
    - Set “**ConsistentRead**” parameter to **True** in API calls (GetItem, BatchGetItem, Query and Scan)
    - **Consume twice the RCU (and higher latency)**

**Read Capacity Units (RCU):**

- **One RCU represents one Strongly Consistent Read per second, or two Eventually Consistent Reads per second, for an item up to 4KB in size**

Partitions Internal:

- DynamoDB has tables and tables are partitioned
- Data is stored in partitions
- Partition Keys go through a internal hashing algorithm to know to which partition they go to
- **WCUs RCUs are spread evenly across partitions**

Throttling:

- If we exceed provisioned RCUs or WCUs we get “ProvisionedThroughputExceededException”
- Reasons:
    - **Hot Keys** — one partition key is being read too many times (popular item)
    - **Hot Partitions**
    - **Very Large Items** — RCU and WCU depends on size of items
- Solutions:
    - **Exponential backoff** when exception
    - **Distribute partition keys** as much as possible
    - If RCU issue, we can use **DynamoDB Accelerator** (DAX)

Writing Data:

- **PutItem**
    - Creates a new item or update an old item (same Primary Key)
    - Consumes WCUs
- **UpdateItem**
    - Edits an existing item’s attributes or adds a new item if it does not exist
    - Can be used to implement **Atomic** **Counters**
- **Conditional Writes**
    - Accept a write/update/delete only if conditions are met, otherwise returns an error

Reading Data:

- **GetItem**
    - Read based on PK
    - PK can be HASH or HASH+Range
    - Eventually Consistent Read (default)
    - Set “**ConsistentRead**” parameter to **True** in API calls (GetItem, BatchGetItem, Query and Scan)
        - More RCU + more latency
    - **ProjectionExpression** can be specified to retrieve only certain attributes:
        - A projection expression is a string that identifies the attributes you want.
        - To retrieve a single attribute, specify its name. For multiple attributes, the names must be comma-separated.
        
        ```bash
        aws dynaodb get-item --table-name <table-name> **--projection-expression** "Id, Name"
        ```
        

- **Query** — returns items based on:
- `--query` parameter:
    - The Query operation in Amazon DynamoDB finds items based on primary key values. You must provide the name of the partition key attribute and a single value for that attribute.
    - The Query returns all items with that partition key value
    - **KeyConditionExpression**
        - PK value (must be = operator) — required
        - Sort Key value (=, <, >, ≤, ≥, between, begins with) — optional
    - **FilterExpression**
        - Additional filtering after the Query operation (before data returned to you)
        - If you need to further refine the Query results, you can optionally provide a filter expression
        - A filter expression determines which items within the Query results should be returned to you
        - A filter expression is applied after Query finishes, but before the results are returned
        - Therefore, a Query consumes the same amount of read capacity, regardless of whether a filter expression is present
        - A Query operation can retrieve a maximum of 1 MB of data. This limit applies before the filter expression is evaluated.
        - Use only with non-key attrs (does not allow HASH or RANGE atts)
    - Returns:
        - The number of items specified in **Limit**
        - Or up to 1MB of data
- **Scan** — scan the entire table and then filter out data (inefficient):
    - Returns up to 1 MB of data — use pagination to keep on reading
    - Consume a lot of RCU
    - Limit impact using **Limit** or reduce the size of the result and pause
    - For faster performance use **Parallel** **Scan**
        - Multiple workers scan multiple data segments at the same time
        - Increases the throughput and RCU consumption
    - Can use **ProjectionExpression** & **FilterExpression** (no changes to RCU)

Deleting Data:

- **DeleteItem**
    - delete an individual item
    - Ability to perform a conditional delete
- **DeleteTable**
    - Delete a whole table an all its items
    - Quicker than ^^^

Batch Operations:

- Allows you to save in latency by reducing the number of API calls
- Operations are done in parallel for better efficiency
- **BatchWriteItem**
    - Up to 25 **PutItem** and/or **DeleteItem** in one call
    - Up to 16MB of data written, up to 400 KB of data per item
    - Cannot update items (use UpdateItem)
    - **UnprocessedItems** for failed write operations
- **BatchGetItem**
    - Returns items from one or more tables
    - Up to 100 items up to 16MB of data
    - Items are retrieved in parallel
    - **UnprocessedKeys** for failed read operations
    

PartiQL:

- SQL-compatible query language for DynamoDB
- Supports some (but not all) SQL statements: Insert, update, select, delete

Conditional Writes:

- For PutItem, UpdateItem, DeleteItem and BatchWriteItem
- You can specify a Condition expression to determine which items should be modified:
    - attribute_exists
    - attribute_not_exists
    - attribute_type
    - contains
    - begins_with
    - between
    - size
- **Note: filter expressions filters the results of read queries while Condition Expressions are for write operations**
- Example:
    
    ```
    aws dynamodb delete-item \
    	--table-name Products
    	--key '{"Id": {"N": "123"}}'
    	**--condition-expression** "attribute_not_exists(Price)"
    ```
    
- You can use conditional writes to not overwrite existing elements:
- `attribute_not_exists(partition_key)`
    - make sure the item is not overwritten
- `attribute_not_exists(partition_key) and attribute_not_exists(sort_key)`
    - make sure the partition / sort key combination is not overwritten

Indexes — Local Secondary Index (LSI):

- **Alternative Sort Key** for your table (same Partition Key as that of base table)
- LSI consists up to 5 local secondary indexes per table
- **Must be defined at table creation time**
- Attribute Projections — can contain some or all attrs of the base table
- Uses the WCUs and RCUs of the main table
    - No special throttling considerations
- You cannot delete LSI without deleting entire table

Indexes — Global Secondary Index (GSI):

- **Alternative Primary Key** (HASH or HASH + Range) from the base table
- Speed up queries on non-key attrs
- The Index Key consists of scalar attrs (String, Number, Binaries)
- Attribute Projections — some or all the attrs of the base table
- Must provision RCUs & WCUs for the index
- **Cab be added/modified after table creation**
- **If the writes are throttled on the GSI, then the main table will be throttled**
    - Even if the WCUs on the main tables are fine
    - Choose your GSI partition key carefully!
    - Assign your WCU capacity carefully!

**Global tables:**

- use if your application is accessed by globally distributed users
- With global tables, you can specify the AWS Regions where you want the table to be available.
- This can significantly reduce latency for your users.
- So, reducing the distance between the client and the DynamoDB endpoint is an important performance fix to be considered.

Optimistic Locking:

- A strategy to ensure an item has not changed before you update/delete it
- Each item has an attr that acts as a **************version number**************

DynamoDB Accelerator (DAX):

- Fully-managed, highly available, seamless in-memory cache for DynamoDB
- Microseconds latency for cached reads & queries
- Cache most popular data → used in case of throttling → Hot Partition
- Does not require application logic modification
    - Compatible with existing DynamoDB APis
- Solves the “Hot Key” problem (too many reads → throttling)

```
Application --> DAX Cluster --> DynamoDB
```

- 5 minutes TTL for cache (default)
- Up to 10 nodes in the cluster
- Multi-AZ (3 nodes minimum is recommended)
- You can chose node type, node family and select cluster size

DAX vs ElastiCache:

- DAX has caches for individual objects / query / scan cache
- ElastiCache will be better to store aggregation results etc.
- We can use them together

DynamoDB Streams:

- Ordered stream of item-level modifications (create/update/delete) in tables
- Streams records can be:
    - sent to Kinesis
    - read by Lambda (ans sent to SNS etc.)
- Data retention for up to 24 hours
- Use cases:
    - react to changes in real-time
    - analytics
    - insert into another tables
    - cross region replication
    - archiving to S3 (through kinesis)
- Ability to choose the information that will be written to the stream
    - KEYS_ONLY
    - NEW_IMAGE
    - OLD_IMAGE
    - NEW_AND_OLD_IMAGES
- DynamoDB Streams are made of shards (like Kinesis Data Stream)
- **Records are not retroactively populated in a stream after enabling it**

DynamoDB Streams + Lambda:

- define EventSource Mapping to read from a stream
- you need to ensure the Lambda has the permissions
- **Your Lambda function is invoked sync**

DynamoDB TTL:

- Automatically delete items after an expiry timestamp
- Does not consume any WCUs
- TTL attribute must be a Number data type with Unix Epoch timestamp value
- Expired items deleted within 48 hours of expiration (no immediately)
- Use case: reduce stored data by keeping only current items
- Expired items, that haven’t been deleted → appears in reads/queries/scans (if you don’t want them, filter them out)
- Expired items are deleted from both LSIs and GSIs

DynamoDB CLI:

- `--projection-expression` one or more attributes to retrieve
- `--filter-expression` filter items before returned to you
- Pagination options:
    - `--page-size`
    - `--max-items` max number of items to show in the CLI, returns NextToken
    - `--starting-token` specify the last NextToken to retrieve the next set of items
    

DynamoDB Transactions:

- Coordinated, all-or-nothing operations (add/update/delete) to **multiple items across one or more tables**
- Provides ACID
- **Read Modes**: Eventual Consistency, Strong Consistency, **Transactional**
- **Write Modes**: Standard, **Transactional**
- **Consumes 2x WCUs & RCUs**
    - DynamoDB performs 2 operations for every item (prepare & commit)
- Two operations:
    - **TransactGetItems** — one or more GetItem operations
    - **TransactWriteItems** — one or more PutItem, updateItem or DeleteItem
- **Capacity Computations (2x):**
    - Ex: 3 transactional writes per second with items zie 5 KB: `3 * 5KB/1KB * 2 = 30 WCUs`
    

Partitioning Strategies — Write Sharding:

- Add a sufix to Partition Key value to distribute PK within shards
- Two methods:
    - **Sharding using random suffix**
    - **Sharding using calculated suffix**

Write Types:

- **Concurrent Writes**
- **Conditional Writes**  (Optimistic Locking)

```
update value = 1 if value = 0
```

- **Atomic Writes**
- **Batch Writes**

Table Cleanup:

- Scan + DeleteItem → very slow
- Drop Table + Recreate table → fast

Copying a DynamoDB Table:

- Use AWS Data Pipeline
- Backup and restore into a new table
- Scan + PutItem or BatchWriteItem