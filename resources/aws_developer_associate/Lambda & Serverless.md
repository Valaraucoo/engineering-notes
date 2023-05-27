# Lambda & Serverless

- AWS Lambda
    - Virtual functions → no servers to manage
    - Limited by time → short execution
    - Run on-demand → runs only if you need
    - Scaling is automated
    - Easy pricing: pay per requests and compute time; free tier
    - Integrated with the whole AWS suite of services:
        - API Gateway - to create rest apis
        - Kinesis - data transformations
        - DynamoDB - triggers
        - S3 - triggers
        - CloudWatch Events/EventBridge
        - CW Logs
        - SNS
        - SQS
        - Cognito - to react when user logs in to services
    - Easy monitoring → AWS CloudWatch
    - Pricing example:
        - Pay per **calls**: first 1mln requests are free
        - $0.20 per 1 mln requests
        - Pay per **duration**:
            - 400k GB-seconds of computer time per month if FREE
            - == 400k seconds if function is 1GB RAM
            - after that $1.00 for 600 GB-seconds
        - **Very cheap**
    - Limited RAM: 128MB - 10GB
    - Limited timeout: max 15min

- Lambda Synchronous Invocation:
    - Synchronous: **CLI, SDK, API Gateway, Application Load Balancer**
        - Results are returned right away
        - You are waiting for the result
        - Error handling must happen client side (retries, exponential backoff, etc.)
    - Services:
        - User Invoked: ELB, Gateway, CloudFront, S3 Batch
        - Service Invoked: Cognito, StepFunction

- Lambda and Application Load Balancer:
    - To expose a Lambda function as an HTTP endpoint you can use the ALB (or an API Gateway)
    - The Lambda function must be registered in a **target group**
    - How does ALB converts an HTTP request into a lambda invocation?
        - ALB to Lambda → transforms HTTP to JSON document
        - Lambda to ALB → JSON to HTTP
    - ALB multi-header values
        - ALB can support multi header values (**ALB setting**) e.g. `?name=foo&name=bar`
        - When you enable multi-value headers, **HTTP headers and query string parameters that are sent with multiple values** are shown as arrays within the AWS Lambda event and response objects

- Lambda Asynchronous Invocations:
    - **S3, SNS, CW Events**
    - The events are placed in an **Event Queue**
    - Lambda reads from Event Queue
    - Lambda attempts to retry on errors
        - 3 tries total
        - 1 minute wait after 1st, then 2 minutes wait
    - Make sure the processing is **idempotent**
    - If the function is retried you will see duplicate logs entries in CW Logs
    - Can define a **DLQ** (SNS or SQS) for failed processing (need correct IAM permissions)
    - Async invocations allow you to speed up the processing if you do not need to wait for the result
    
- Lambda CloudWatch Events / EventBridge Integration
    - Create CRON (EventBridge Rate) to trigger lambda invocation
    - Create EventBridge Rule to trigger lambda invocation
- Lambda and S3 Event Notification
    - S3 Notification targets → SNS, SQS, Lambda Function
    - If two writes are made to a single non-versioned object at the same time → it’s possible that only a single event notification will be sent
    - If you want to ensure that an event notification is sent for every successful write → you can enable versioning on bucket

- Event Source Mapping
    - Kinesis Data Streams, SQS & SQS FIFO queue, DynamoDB Streams
    - Records need to be polled from the source by Lambda
    - Your Lambda function is invoked sync
    - An event source mapping is a Lambda resource that **reads from an event source** and invokes a Lambda function
        - You can use event source mappings to process items from a stream or queue in services that don't invoke Lambda functions directly, e.g. Kinesis, DynamoDB, SQS
    - Event Source Mapping is created into Lambda and it’s responsible for polling data stream/queue
    - **By default, if your function returns an error, the event source mapping reprocesses the entire batch until the function succeeds, or the items in the batch expire**
    - Discarded events can go to a **Destination**
    - SQS:
        - ESM will poll SQS → Long Pooling
        - You can specify batch size → 1-10 messages
        - **You can use DLQ on the SQS queue** → not on Lambda
            - **DLQ for Lambda only works for async invocations**
        - Number of lambda function is scaling up to the number of active message groups (SQS FIFO) → for in-order processing in FIFO
        - Lambda scales up to process a standard queue as quickly as possible
        - Lambda deletes items from the queue

- Lambda Event & Context Objects
    - Event Object:
        - JSON document contains data for the function to process
        - Contains information from the invoking service, e.g. EventBridge
        - Lambda runtime converts the event to an object
        - Example: input arguments, invoking service arguments
    - Context Object:
        - Provides methods and properties that provide information about the invocation, function, and runtime env
        - Passed to your function by Lambda at runtime
        - Example: aws_request_id, function_name, memory_limit_in_mb, etc.

- Lambda Destinations
    - To send records of **asynchronous invocations** to another service, add a destination to your function
        - To send the result of async invocation or the failure into somewhere
        - You can configure separate destinations for events that **fail** processing and events that are **successfully** processed.
        - Like error handling settings, you can configure destinations on a function, a version, or an alias.
    - Async invocations → can define destinations for successful and failed events:
        - SQS
        - SQS
        - Lambda
        - EventBridge
    - AWS recommends you use destinations instead of DLQ now
    - Event Source mapping: for discarded event batches
        - SQS, SNS
    - Note: you can send events to a DLQ directly from SQS
    
- **When you use an event source mapping to invoke your function, Lambda uses the execution role to read event data**
    - In the other way, the lambda function was invoked by other services so we didin’t need a specific IAM Role
- Best practice: create on Lambda Execution Role per function

Cross-Account Lambda:

- Use **********************************************resource based policies********************************************** to give other accounts and AWS services permission to use Lambda resources
    - You can give a Lambda function created in one account ("account A") permissions to assume a role from another account ("account B") to access resources such as DynamoDB or S3 bucket (in account B).
    - You need to create an execution role in Account A that gives the Lambda function permission to do its work.
    - Then you need to create a role in account B that the Lambda function in account A assumes to gain access to the cross-account DynamoDB table.
    - Make sure that you modify the trust policy of the role in Account B to allow the execution role of Lambda to assume this role.

- Lambda Service adds its own system env vars as well
- Helpful to store secrets (encrypted by KMS)

- Lambda Logging & Monitoring
    - CloudWatch Logs
    - CloudWatch Metrics — displayed in Lambda UI and CW UI
        - Invocations, Durations, Concurrent Executions, Errors, Success, Throttles, Iterator Age
    - Tracing with X-Ray:
        - enable in Lambda configuration (**Active Tracing**)
        - Use AWS X-Ray SDK in Code
        - Env vars to communicate with X-Ray:
            - `_X_AMZN_TRACE_ID` — tracing header
            - `AWS_XRAY_CONTEXT_MISSING` by default LOG_ERROR
            - `**AWS_XRAY_DAEMON_ADDRESS` the X-Ray deamon ip_addr:port - where daemon is running for lambda func**

Customization At The Edge

- Many modern apps execute some form of the logic at the edge
- ****************************Edge Functions****************************:
    - A code that you write and attach to CloudFront distribution
    - Runs close to your users to minimize latency
- CloudFront provides two types: CloudFront Functions & Lambda@Edge
- Use case: customize the CDN content, Real Time image transformation, A/B Testing

- CloudFront Functions:
    - Lightweight JavaScript functions
    - For high-scale latency-sensitive CDN customization
    - Sub-ms startup times, **millions of requests/sec**
    - Max. Execution Time < 1ms
    - Used to change Viewer request and responses
        - **Viewer request** — after CF receives a request from a viewer
        - **Viewer response** — before CF forwards the response to the viewer
    - Native feature of CF
    - Use Cases:
        - Cache key normalization (transform request attributes to create an optimal Cache Key)
        - Header manipulation
        - URL rewrites or redirects
        - Request authentication & authorization — validate JWT tokens
- Lambda@Edge
    - Lambda functions written in NodeJs or Python
    - Scales to **1000s of requests/second**
    - Max. Execution Time 5-10s
    - Used to change CF request and responses:
        - **Viewer request** — after CF receives a request from a viewer
        - **Viewer response** — before CF forwards the response to the viewer
        - ****************************Origin Request**************************** — before CF forwards the request to the origin
        - ******************************Origin Response****************************** — after CF receives the response from the origin
    - Author your function in one AWS Region, then CF replicates to its locations
    - Use Cases:
        - Longer execution time
        - Adjustable CPU or memory
        - Code can depend on AWS services
        - File system access
    

Lambda in VPC:

- By default, Lambda function is launched outside your own VPC
- Therefore, it cannot access resources in your VPC (RDS, ElastiCache, internal ELB, etc.)
    - It can access external internet and DynamoDB
- You can deploy Lambda in VPC — you must define the VPC ID, the Subnets and the SG
- Behind the scenes, Lambda will create an ENI (Elastic Network Interface) in your subnets
    - Traffic will go through ENI to VPC in Private Subnet
- you need AWSLambdaVPCAccessExecutionRole

Lambda in VPC — Internet Access:

- A lambda function in your VPC does not have access to external Internet by default
- **Deploying a Lambda function in a public subnet does not give it internet access or a public IP**
- We can deploy a Lambda function in a private subnet — gives it internet access if you have a **NAT Gateway / Instance**
- To access AWS services  (in AWS Cloud) we can use NAT or **VPC Endpoints**

Lambda Configuration:

- RAM:
    - 128MB - 10GB
    - The more RAM you add, the more vCPU credits you get
    - At 1.792MB a function has the equivalent of one full vCPU
    - After 1.792MB you get more then one CPU, and need to use multi-threading in your code to benefit from it
- **If your application is CPU-bound (computation heavy) → increase RAM**
- Timeout: **default 3 seconds**, maximum is **900** seconds (15 minutes)
    - Do not set high timeout if it’s not needed → if your lambda stuck?

Lambda Execution Context:

- The execution context is a temporary runtime environment that initializes any external dependencies of your lambda code
- Great for database connections, HTTP Clients, SDK clients, etc.
- The execution context is maintained for some time in anticipation of another Lambda function invocation → if you invoke lambda multiple times in a row → the next invocation will reuse all these existing contexts
- The execution context includes the /tmp directory

```python
import os

DB_URL = os.getenv("DB_URL")
db_client = db.connect(DB_URL)

def get_user_handler(event, context):
	user = db_client.get(user_id=event["user_id"])
	return user	
```

Lambda function /tmp space:

- If your lambda needs to download a big file to work…
- You can use the /tmp directory
- **Max size is 10GB**
- The directory content remains when the execution context is frozen, providing a transient cache that can be used for multiple invocations
- Helpful to checkpoint your work
- For permanent persistence of object (non-temporary) → use S3

Lambda Layers:

- Custom Runtimes → other languages → Rust
- Externalize Dependencies to re-use them:
    - We can zip all dependencies and libraries and re-use them

*Lambda File System Mounting:

- Lambda can access EFS file systems if they are **running in a VPC**
- Configure Lambda to mount EFS file systems to local directory during init
- Must leverage EFS Access Point
- Limitation: watch out for the EFS connection limits (one function instance = one connection) and connection burst limits

Lambda Concurrency and Throttling:

- Concurrency limit: up to **1000** concurrent execution per account
- Can set a “**reserved** **concurrency**” at the function level = limit, e.g. max 15 concurrent invocations for specified lambda function
    - Unreserved concurrency → 1000 - reverved concurrency
- Each invocation over the concurrency limit will trigger a “throttle”
- You can reserve concurrency to prevent your function from using all the available concurrency in the Region
    - Without reserved concurrency, other function can use up all of the available concurrency
    - This prevents your function from scaling up when needed
- Throttle behavior:
    - If synchronous invocation → return ThrottleError → 429
    - If async invocation → return automatically and then go to DLQ
- If you do not reserve concurrency (limit) → throttling in other lambdas
- To ensure that a function can always reach a certain level of concurrency, you can configure the function with reserved concurrency.
    - When a function has reserved concurrency, no other function can use that concurrency.
    - More importantly, reserved concurrency also limits the maximum concurrency for the function, and applies to the function as a whole, including versions and aliases.

Concurrency and async invocations:

- If the function does not have enough concurrency available to process all events → additional requests are throttled
- For throttling errors (429) and system errors (5XX) → Lambda returns the event to the queue and attempts to run the function again for up to 6hours
- The retry interval increases exponentially from 1 second after the first attempt to a maximum of 5 minutes

Cold Starts & Provisioned Concurrency:

- **Cold Start** → new instance → code is loaded and code outside the handler run (init)
    - If the init is large (code, deps, SDK, …) this process can take some time
    - First request served by new instances has higher latency than the rest
- **Provisioned Concurrency (hot starts)**:
    - Concurrency is allocated before the function is invoked
    - So the cold start never happens and all invocations have low latency
    - Application Auto Scalling can manage concurrency (schedule or target utilization)
- You should use provisioned concurrency to enable your function to scale without fluctuations in latency.
    - By allocating provisioned concurrency before an increase in invocations, you can ensure that all requests are served by initialized instances with very low latency.
    - **Provisioned concurrency is not used to limit the maximum concurrency for a given Lambda function**
- Note:
    - Cold starts in VPC have been dramatically reduced

Lambda function dependencies:

- If your function depends on external libraries, e.g. AWS X-Ray SDK, Databases clients, et.c
- ************************************************************************************************************************************************You need to install the packages alongsied your code and zip it together************************************************************************************************************************************************
    - For node → use npm and node_modules directory
    - For python → pip —target option
- Upload the ****zip**** straight to Lambda if less than 50MB; else to s3 first
- Native libraries work → they need to be compiled on Amazon Linux
- AWS SDK comes by default with every Lambda function

Lambda and CloudFormation:

- Two ways to upload lambda function via CF: inline, through S3
- **Inline** - we define code in CF template
    - inline functions are very simple
    - use `Code.ZipFile` property
    - you cannot include function dependencies with inline functions
- Through S3
    - You must store the Lambda zip in S3
    - You must refer the S3 zip location in CF code: `S3Bucket`, `S3Key` (full path to zip), `S3ObjectVersion` (if versioned bucket)
    - **If you update the code in S3, but do not update S3Bucket, S3Key or S3ObjectVersion, CF won’t update your function**
- Through S3 Multiple Accounts → deploy CF in many accounts, and in S3 bucket policy we need to access from other account id (allow get and list to s3 bucket execution role)

Lambda Container Images:

- Deploy Lambda function as container images of **up to 10GB from ECR**
- Pack complex dependencies in a container
- Base Image must implement the **Lambda Runtime API**
- Base images: Python, Java, .NET, Go, Ruby
- Can create your own images as long as it implements the Lambda Runtime API
- Test the containers locally using the Lambda Runtime Interface Emulator
- Unified workflow to build apps
- Best practices:
    - Strategies for optimizing container images:
        - Use AWS-provided Base Images (cached by Lambda service)
        - Use Multi-Stage Builds
        - Use a Single Repository for Functions with Large Layers
    - Use them to upload large Lambda Functions (up to 10GB)

Lambda Versions and Aliases:

- $LATEST → mutable
    - You can treat $LATEST version as a draft/work in progress function
- Publish → create a version (versions are immutable and has unique number)
    - You cannot edit/update lambda version after publication
- Versions get their own, unique ARN
- Version = code + configuration
- Each version of the lambda function can be accessed

Aliases:

- Aliases are “pointers” to Lambda function versions
    - You can create name alias for specified lambda version
- We can define a “dev”, “test”, “prod” aliases and have them point at different lambda versions
- Aliases are mutable
    - You can change the version for which alias points to
- **Aliases enable Canary deployment by assigning weights to lambda functions**
    - You can create one or more aliases for your AWS Lambda function.
    - A Lambda alias is like a pointer to a specific Lambda function version.
    - You can use routing configuration on an alias to send a portion of traffic to a Lambda function version.
    - For example, you can reduce the risk of deploying a new version by configuring the alias to send most of the traffic to the existing version, and only a small percentage of traffic to the new version
    - ************Weight************ is the percentage of traffic that is assigned to that version when the alias is invoked.
- Aliases have their own ARNs
- **Aliases cannot reference aliases**

Lambda and CodeDeploy:

- CodeDeploy can help you automate traffic shift for Lambda aliases
- Feature is integrated within the SAM framework
- **Linear**: grow traffic every N minutes until 100%
    - `Linear10PercentEvery3Minutes`
    - `Linear10PercentEvery10Minutes`
- **Canary**: try X percent then 100%
    - `Canary10Percent5Minutes`
    - `Canary10Percent30Minutes`
- **AllAtOnce**: immediate
- Can create Pre & Post Traffic hooks to check the health of the lambda function
- CodeDeploy configuration in `AppSpec.yml`
    - ******************************Name (required)****************************** — the name of the Lambda function to deploy
    - **Alias (required)** — the name of the alias to the Lambda function
    - **************************************************CurrentVersion (required)************************************************** — the version of the Lambda function traffic currently points to
    - ************************************************TargetVersion (required)************************************************ — the version of the lambda function traffic is shifted to

Lambda Function URL:

- A dedicated HTTP(S) endpoint for you lambda function
- A unique URL endpoint is generated for you (never changes)
    - `https://<url-id>.lambda-url.<region>.on.aws`
- Access your function URL through the public Internet only
- Supports Resource-based Policies & CORS
    - RBP: Authorize other accounts / specific CIDR / IAM Principals
    - CORSL if you call lambda function URL from different domain
- Can be applied to any function alias or to $LATEST (cannot be applied to other function versions)
- Create and configure using AWS Console or AWS API
- Throttle your function by using Reserved Concurrency
- Security:
    - **AuthType NONE** — allow public and unauthencitated access
    - **AuthType AWS_IAM** — IAM is used to authenticate and authorize requests

Lambda Limits:

- Execution:
    - Memory Allocation: 128 MB - 10GB
    - When we increase the memory → more vCPU
    - Max execution time: 900 seconds (15 minutes)
    - Environment variables (4 KB)
    - Disk capacity in the function container → 512 MB to 10GB
    - 1000 concurrenct exections
- Deployments:
    - Max-size of zipped function: 50MB
    - Size of uncompressed deployment (code + deps): 250MB
    - Size of env vars: 4KB

Best practices:

- **Perform heavy-duty work outside of function handler**
- **Use env vars** for: database connections, s3 buckets, etc.
- **Minimize your deployment package size to its runtime necessities**
    - Use Layers where necessary
    - Break down the function if need be
- **Avoid using recursive code, never have a Lambda function call itself**