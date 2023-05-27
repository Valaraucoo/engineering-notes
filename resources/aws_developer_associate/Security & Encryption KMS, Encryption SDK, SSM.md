# Security & Encryption: KMS, Encryption SDK, SSM Parameter Store, Secrets Manager, IAM & STS

Encryption Overview:

- Encryption in flight (SSL):
    - Data is encrypted before sending and decrypted after receiving
    - SSL certificates → encryption with HTTPS
    - Encryption in flights ensures no Man In The Middle Attack can happen
    - also known as data in transit encryption, refers to the protection of data while it's being transferred over networks
        - ensuring that it cannot be intercepted or tampered with during transmission
- Server Side Encryption at rest:
    - It is the process of encrypting data at the server level when it is stored, protecting it from unauthorized access or breaches
    - Data is encrypted after being received by the server
    - Data is decrypted before being sent
    - It is stored in an encrypted form thanks to a key (data key)
    - The encryption / decryption keys must be managed somewhere and the server must have access to it
        - AWS KMS (Key Management Service)
- Client Side Encryption:
    - Data is encrypted by the client and never decrypted by the server
    - Data will be decrypted by a receiving client
    - The server should not be able to decrypt the data!
    - Could leverage Envelope Encryption
    

KMS Overview:

- AWS Key Management Service (KMS) is a managed service that makes it easy for you to create and manage cryptographic keys and control their use across a wide range of AWS services and in your applications.
- AWS KMS is **integrated with AWS CloudTrail** to provide you with logs of all key usage, helping you meet your regulatory and compliance needs.
- You can create, import, rotate, disable, delete, and manage permissions on keys.
- It's an essential tool for managing encryption keys at scale and enforcing policies around them, providing robust security for your data in AWS.
- Fully integrated with IAM for auth
- Easy way to control access to your data
- **Able to audit KMS Key usage using CloudTrail**
- Seamlessly integrated into most AWS Services (EBS, S3, RDS, SSM, …)

KMS Keys Types:

- **KMS Keys is the new name of KMS Customer Master Key (CMK)**
- **Symmetric** (AES-256 keys)
    - Single encryption key that is used to Encrypt and Decrypt data
    - AWS Services that are integrated with KMS use Symmetric CMKs
    - You never get access to the KMS Key unencrypted
- **Asymmetric** (RSA & ECC key pairs)
    - Public (encrypt) and Private Key (Decrypt) pair
    - Used for Encrypt/Decrypt or Sign/verify operations
    - The public key is downloadable, but you cannot access the Private Key
    - Use case: encryption outside of AWS by users who cannot call the KMS API
- KMS keys can be symmetric or asymmetric.
- Symmetric KMS key represents a 256-bit key used for encryption and decryption.
- An asymmetric KMS key represents an RSA key pair used for encryption and decryption or signing and verification, but not both. Or it represents an elliptic curve (ECC) key pair used for signing and verification.

Types of KMS Keys:

- **AWS Owned Keys** (free): SSE-S3, SSE-SQS, SSE-DDB (default key)
    - These are not directly accessible to you but are used on your behalf by AWS services to protect your data
- **AWS Managed Keys** (free)
    - These are created, managed, and used on your **behalf by an AWS services** that are integrated with AWS KMS.
    - These keys can only be used within the service that created them and cannot be manually rotated
- **Customer Managed Keys** → created in KMS $1/month
- **Customer Managed Keys Imported** (must be symmetric key) $1/month
    - + pay for API call to KMS
- Automatic Key Rotation:
    - **AWS-managed KMS Key → automatic every 1 year**
    - **Customer-managed KMS Key (must be enabled) automatic every 1 year**
    - **Imported KMS Key** → only manual rotation using alias

KMS Key Policies:

- Control access to KMS keys → “similar” to S3 bucket policy
- Difference: you cannot control access without them
    - If you don’t have a KMS Key Policy → no one can access it
- Default KMS Key Policy:
    - Created if you don’t provide a specific KMS Key Policy
    - Complete access to the key to the root user = entire AWS account
- Custom KMS Key Policy:
    - Define users, roles that can access the KMS Key
    - Define who can administer the key
    - Useful for cross-account access of your KMS Key

KMS CLI commands:

```bash
# 1) Encryption
aws kms encrypt --key-id <keyId> \
	--plaintext fileb://secret.txt \
	--output text \
	--query CiphertextBlog
	--region eu-west-2 > encryptedSecret.base64

# 2) Decryption
aws kms decrypt --ciphertext-blog fileb://encryptedSecret \
	--output text \
	--region eu-west-2 \
	--query Plaintext > decryptedSecret.base64
```

How does KMS work?

- **Decrypt** and **Encrypt** API
- Limitation: **secret size < 4KB**
- If you want to encrypt >4KB → use **************************************Envelope Encryption**************************************
    - The main API → **GenerateDataKey API**
    - Generates a unique **symmetric data key** (DEK)
    - Returns a plaintext copy of the **data key** and copy of **encrypted** under the CMK that you specify
- **************************************************************GenerateDataKeyWithoutPlaintext**************************************************************
    - Generate a DEK to use at some point (not immediately)
    - DEK that is encrypted under the CMK that you specify
- **GenerateRandom** API

Encryption SDK:

- The AWS Encryption SDK implemented Envelope Encryption for us
- The Encryption SDK also exists as a CLI tool we can install
- **Feature → Data Key Caching**:
    - re-use data keys instead of creating new ones for each encryption
    - less calls to KMS with a security trade-off
    - use **************************************************LocalCryptoMarerialCache**************************************************

KMS Request Quotas (Limits):

- when you exceed a request quota → **************************************ThrottlingException**************************************
    - use exponential backoff
- For each cryptographic operations → they share a quota
    - This includes requests made by AWS on your behalf
- For **************************GeneratedDataKey************************** API, consider using DEK caching from the Encryption SDK
- **************************************************************************************************************************************You can request a Request Quotas increase through API or AWS Support**************************************************************************************************************************************

S3 Bucket Key for SSE-KMS encryption:

- New setting to decrease number of API calls made to KMS from S3 by 99%
- This leverages data keys → **S3 bucket key**
- That key is used to encrypt KMS objects with new data keys
- S3 bucket key will generate new data keys used to encrypt objects in S3 bucket
- You will see ********************************************************************************less KMS CloudTrail events in CloudTrail********************************************************************************

KMS Key Policies — Principal Options in IAM:

- AWS Account and Root User:

```json
"Principal": {"AWS": "123123123"}
"Principal": {"AWS": "arn:aws:iam:123123123:root"}
```

- IAM Roles:

```json
"Principal": {"AWS": "arn:aws:iam:123123123:role/role-name"}
```

- IAM Role Sessions:

```json
"Principal": {"AWS": "arn:aws:sts:123123123:assumed-role/role-name/role-session-name"}
"Principal": {"AWS": "cognito-identity.amazon.com"}
```

- IAM Users

```json
"Principal": {"AWS": "arn:aws:iam:123123123:user/user-name"}
```

- Federated User Sessions
- AWS Services

```json
"Principal": {"Service": ["ecs.amazonaws.com"]}
```

- All Principals

```json
"Principal": {"AWS": "*"}
```

CloudHSM:

- KMS → AWS manages the software for encryption
- CloudHSM → AWS provisions encryption ****************hardware****************
    - Dedicated Hardware
    - HSM = Hardware Security Module
- You manage your own encryption keys entirely (not AWS)
- Supports both **symmetric** and **asymmetric** encryption  (SSL/TLS keys)
- No free tier available
- Must use the CloudHSM Client Software
- ********************************************************************************Good option to use with SSE-C encryption********************************************************************************
- High availability: Multi AZ (HA) with replication
- Integration with AWS Services:
    - Through AWS KMS
    - Configure KMS Custom Key Store with CloudHSM
- Only Customer Managed CMK
- MFA Support

SSM Parameter Store:

- Secure storage for configurations and secrets
- Optional Seamless Encryption using KMS
- Serverless, scalable, durable, easy SDK
- Version tracking of configurations / secrets
- Security through IAM
- Notifications with Amazon EventBridge
- Integration with CF

Parameter store hierarchy:

```json
/my-department/
	my-app/
		sta/
			db_url
		prod/
			db_url
```

- Possibility to create **public parameters**
- Two parameter tiers:
    - Standard:
        - Total number of parameters: 10k per AWS account and region
        - Maximum size of a parameter value: 4 KB
        - Parameter policies available: NO
        - Cost: free
        - Storage Pricing: Free
    - Advanced:
        - Total number of parameters: 100k per AWS account and region
        - Maximum size of a parameter value: 8 KB
        - Parameter policies available: YES
        - Cost: charges apply
        - Storage Pricing: $0.005 per advanced parameter per month

Parameter Policies (for advanced parameters):

- Allow to assign a TTL to a parameter (expiration date) to force updating or deleting sensitive data such as passwords
- Can assign multiple policies at a time
- Example notifications/policies:
    - Expiration, Expiration Notification (event bridge), No change notification (event bridge)

SSM Parameter Store CLI:

```bash
aws ssm **get-parameters** --names /my-app/dev/db-password /my-app/dev/db-password
aws ssm **get-parameters** --names /my-app/dev/db-password **--with-decryption**

aws ssm **get-parameters-by-path** --path /my-app/dev/
```

AWS Secrets Manager:

- Newer service → for storing secrets
- capability to force **rotation of secrets** every X days
- Automate generation of secrets on rotation (uses **Lambda**)
- Integration with **Amazon RDS**
- Ability to store any secret in key/value format
- Secrets are encrypted using KMS
- Multi-Region Secrets:
    - Replicate secrets across multiple AWS Regions
    - Secrets Manager keeps read replicas in sync with the primary Secret
    - Ability to promote a read replica Secret to a standalone Secret
    - Use case: multi-region apps, disaster recovery strategies, multi-region DBs
- CloudFormation Integration with RDS & Aurora:
    - **********************************************ManageMasterUsrPassword********************************************** → creates admin secret implicitly
    - RDS automatically creates secret in Secret Manager and generates password for its admin
    - RDS, Aurora will manage the secret in Secrets Manager and its rotation
- We can also create Secret Manager’s secret in CF and use **Dynamic Reference**

SSM Parameter Store vs. Secrets Manager:

- Secrets Manager:
    - $$$
    - Automatic rotation of secrets with AWS Lambda
    - Lambda function is provided for RDS, Redshift, DocumentDB
    - KMS encryption is mandatory
    - Can integrate with CloudFormation
- SSM Parameter Store:
    - $
    - Simple API
    - No secret rotation (can enable rotation using Lambda triggered by CW Events)
    - KMS encryption is optional
    - Can integrate with CloudFormation
    - Can pull a Secrets Manager secret using the SSM Parameter Store API
    

CloudWatch Logs Encryption:

- You can encrypt CW Logs with KMS Keys
- Encryption is enabled at the **log group level** by associating a CMK with a log group
    - Either when you create the log group or after if exists
- You cannot associate a CMK with log group using the CW Console
- You must use the CW Logs API:
    - `associate-kms-key` → if the log group already exists
    - `create-log-group` → if the log group does not exist yet
    

CodeBuild Security:

- To access resources in your VPC → make sure you specify a VPC configuration for your CodeBuild
- Secrets in CodeBuild:
    - Do not store them as plaintext
    - **Environment variables can reference Parameter Store / Secrets Manager Secrets**
    

AWS Nitro Enclaves:

- Process highly sensitive data in an isolated compute environment
    - PIIs, Healthcare, financial data
- Fully isolated virtual machines, hardened and highly constrained
    - Not a container; not persistent storage; no interactive access; no external networking
- Helps reduce the attack surface for sensitive data processing apps
    - **Cryptographic Attenstation** — only authorized code can be running in your Enclave
    - Only Enclaves can access sensitive data (integration with KMS)