# AWS CLI, SDK, IAM Roles & Policies

IAM Roles:

- Can have attached IAM policies
- IAM Role is an AWS identity with permission policies that determine what the identity can and cannot do in AWS
    - A role is intended to be assumable by anyone who needs it
- How can I test Policies:
    - AWS Policy Simulator — online tool to test your IAM Policies
    - AWS CLI with `—dry-run` flag, e.g.

<aside>
ℹ️ `dry-run` flag checks whether you have the required permissions for the action via AWS CLI.

</aside>

AWS CLI STS Decode Errors:

- **Security Token Service** (STS) enables you to request temporary, limited-privilege credentials for Identity and Access Management (IAM) users or for users that you authenticate (federated users).
    
    ```bash
    **aws sts decode-authorization-message** --encoded-message <message>
    ```
    
- Using STS we can assume roles, get session token, etc.

AWS EC2 Instance Metadata:

- AWS EC2 Instance Metadata is very powerful but one of the least known features to developers
- It allows EC2 Instances to “learn about themselves” — **without using an IAM Roles for that purpose**
    - EC2 Instance can get information about itself using metadata → it has no needed to get info from AWS
- The URL with metadata: `http://169.254.169.254/latest/meta-data/`
    - You can also retrieve user-data: `http://169.254.169.254/latest/user-data/`
- **You can retrieve IAM Role name from metadata**
    - but you **CANNOT** retrieve IAM Policy
    - The only way to test IAM Policy → using simulator or dry-run
- Metadata = info about EC2 Instance
    - Metadata contains security groups and the instance id of the current instance
- Userdata = launch script of the EC2 Instance
- This can be helpful when you're writing scripts to run from your instance.
    - For example, you can access the local IP address of your instance from instance metadata to manage a connection to an external application.
    - To view all categories of instance metadata from within a running instance, use the following URI - `http://169.254.169.254/latest/meta-data/`.
    - The IP address 169.254.169.254 is a link-local address and is valid only from the instance.
    - All instance metadata is returned as text (HTTP content type text/plain).

<aside>
ℹ️ You can retrieve the **IAM role name** attached to your EC2 instance using the Instance Metadata service, but you **can not retrieve the IAM policies themselves**.

</aside>

- **Create new AWS CLI profile:** `aws configure --profile <profileName>`
- **How to use MFA with AWS CLI/SDK?**
    - To use MFA with CLI → create temporary session
    - To do so, you must run the **STS GetSessionToken** API call
    - `aws sts get-session-token --serial-number <arn-of-the-mfa-device> --token-code <code-from-token> --duration-seconds 3600`
        - You can get `arn-of-the-mfa-device` from IAM > Users > Security Credentials
    - In results you get: `SecretAccessKey, SessionToken, Expiration, AccessKeyId`
- If you don’t specify/configure default region in SDK → the `us-east-1` will be default

AWS Limits (Quotas):

- Two types of limits:
    - **API Rate limits** — examples:
        - *DescribeInstances* API for EC2 has a limit of 100 call per second
        - *GetObject* API for S3 has a limit of 5500 GET per second per prefix
        - For Intermittent Errors → implement exponential backoff
    - **Service Quotas (Service Limits)** — how many resources we can run on something
        - Running On-Demand Standard Instances: up 1152 vCPUs
        - You can request a service limits increase by **opening a ticket**
        - You can request a service Quota increase by using **Service Quota API**
- Exponential Backoff:
    - When to use? If you get **Throttling Exception → due to to many calls**
    - Retry mechanism already included in AWS SDK API calls
    - You must implement backoff while using AWS API
        - You must implement the retries on **5XX Server errors and throttling**
        - Do not implement backoff on the 4XX client errors

AWS CLI Credentials Chain:

- The CLI will look for credentials in this order:
    - **Command line options**, e.g. `--region --output or/and --profile`
    - **Environment variables**, e.g. `AWS_ACCESS_KEY AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN`
    - **CLI Credentials File** — `~/.aws/credentials`
    - **CLI Configuration File** — `~/.aws/config`
    - **Container Credentials** — for ECS tasks
    - **Instance Profile Credentials**

Signing AWS API Requests:

- When you call the AWS HTTP API, you sign the request so that AWS can identify you, using your AWS credentials (access key + secret 🔑 )
    - Note: Some requests to S3 do not need to be signed
    - While using CLI, SDK, the HTTP requests are automatically signed
- You should sign HTTP request using **Signature v4 (SigV4)**
    - SigV4 can be in: HTTP Header or in Query String