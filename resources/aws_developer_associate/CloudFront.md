# CloudFront

- CloudFront → Content Delivery Network (CDN)
- **Improves read performance, content is cached at the edge locations**
    - Content is cached all around the world → lower latency for users
- **DDoS protection** — (because of worldwide) + integration with Shield + AWS Web Application Firewall

CloudFront has several types of **Origins**:

- **S3 Buckets** — used to distribute files and cache them at the edge location
    - Enhanced security with CloudFront **Origin Access Control (OAC)**
    - CloudFront can be used as an **ingres** (to upload files to S3)
- **Custom Origin (HTTP):**
    - Application Load Balancer
    - EC2 Instance
    - S3 Website
    - Any HTTP backend you want
    

Cloud Front vs. S3 Cross Region Replication:

- CloudFront:
    - Global Edge network (+216 points of presence)
    - Files are cached for a TTL (maybe a day)
    - **Great for static content that must be available everywhere**
- S3 Cross Region Replication:
    - Must setup for each region you want to replication happen → not for all around the world
    - Files are updated in near real-time → **no caching**
    - Read only
    - **Great for dynamic content that need to be available at low-latency in few regions**

Cache Behaviours:

- Configure different settings for a given URL path patterns
- Route to different kind of origins/origin groups based on the content type or path pattern:
    - `/images/*`
    - `/*` → default cache behaviour
- When adding additional Cache Behaviours, the Default Cache Behaviour is always the **********************************last to be processed and is always `/*`**

CloudFront Caching:

- The cache lives at each **CloudFront Edge Location**
    - If cache is invalid/not exist → CloudFront forward request directly to the origin
- You want to maximize the cache hit rate to minimize requests on the origin
- CloudFront identifies each object in the cache using the ******************Cache Key******************
    - A unique identifier for every object in the cache
    - By default consists of ****************************************************************************hostname + resource portion of the URL****************************************************************************
    - If you have an application that serves up content that varies based on user, device, lang, location, … → You can add other elements HTTP Headers, cookies, query strings → **********************************************CloudFront Cache Policy**********************************************

CloudFront Cache Policy:

- Cache based on:
    - **HTTP Headers**: None or Whitelist
    - ****************Cookies****************: None or Whitelist or Include All-Except or All
    - **************************Query Strings**************************: None or Whitelist or Include All-Except or All
- **You cannot cache by HTTP Methods**
- Control the TTL (0 seconds to 1 year) can be set by the origin using the **************************Cache-Control************************** header and **************Expires************** header
- You can create your own policy or use Predefined Managed Policies
- ********************************************************************************************************************************************************************************************************************************************************All HTTP headers, cookies, and query strings that you include in the Cache Key are automatically included in origin requests********************************************************************************************************************************************************************************************************************************************************

Origin Request Policy:

- Specify values that you want to include in origin requests ******************************************************************************without including them in the Cache Key****************************************************************************** (no duplicated cached content)
- Ability to add CloudFront HTTP headers and Custom Headers to an origin request that were not included in the viewer request

Cache Invalidation:

- In case you update the back-end origin, CF does not know about it and will only get the refreshed content after the TTL has expired
- You can force an entire or partial cache refresh by performing a **CloudFront Invalidation**
- You can invalidate all files (*) or a special paths (/images/*)
- You can invalidate part of the cache using the **CreateInvalidation API**
    - Cache invalidation **describes the process of actively invalidating stale cache entries when data in the source of truth mutates** → we can create rules that omit files in cache
    - We can add paths for each object that you want to remove from the CloudFront cache
- In CloudFront we can **separate** **static** and **dynamic** distributions

CloudFront — ALB or EC2 as an origin (dynamic content):

- **EC2 must be public** — otherwise, the edge locations will not be able to access EC2 instances
    - There is **no private VPC connectivity** in CloudFront
    - We must **create a security group** to allow public IP of Edge Locations to access EC2 instances
- You can also use Application Load Balancer (ALB) — ALB must be **public**, but EC2 instances can be private
    - We must create a security group to allow ALB to connect EC2 instances
    - We must allow public IP of edge location (of CloudFront) to access ALB

CloudFront Geo Restrictions:

- You can restrict who can access your distribution (via countries)
    - **Allowlist:** allow your users to access your content only if they’re in one of the countries on a list of approved countries
    - **Blocklist**: block users from banned countries
- The “country” is determined using a 3rd party Geo-IP database

CloudFront Signed URL / Cookies:

- You want to distribute *paid shared content to premium users* over the world
- We can use CloudFront Signed URL / Cookie → we attach a policy with:
    - **Includes URL expiration**
    - **Includes IP ranges**
    - **Trusted signers** (which AWS accounts can create signers URLs)
- How long should the URL be valid for?
    - Shared content e.g. movies → make it short
    - Private content (private to the user) → long
- Signed URL → access to individual files (one signed URL per file)
- Signed Cookies → access to multiple files (one signed cookie for many files)
- Two types of signers:
    - **Trusted Key Group** (recommended) — can leverage APIs to create and rotate keys (and IAM for API security)
    - Use an AWS Account that contains a CloudFront Key Pair
        - **Need to manage keys using the root account and the AWS Console**
        - Not recommended
- Trusted Key Group is using Public Key which is uploaded by you
- Keys/signers are used by:
    - **Private key** → application to sign URLs
    - **Public key** → used by CloudFront to verify URLs

CloudFront Signed URL vs S3 Pre-Signed URL:

- CloudFront Signed URL:
    - Allow access to a path → no matter the origin (S3, EC2, etc.)
    - Account wide key-pair → only root can manage it
    - Can filter by IP, path, date, expiration
    - Can leverage caching features
- S3 Pre-Signed URL:
    - Issue a request as the person who pre-signed the URL
    - Uses the IAM key of the signing IAM principal
    - Limited Lifetime
    - Direct Access to S3 Bucket
    

CloudFront — Pricing:

- CloudFront Edge Locations are all around the world → **the cost of data out per edge locations varies**
- Price Classes:
    - You can reduce the number of edge locations for **cost reduction**
    - Three price classes:
        - **Price Class All**: all regions — best performance
        - **Price Class 200**: most regions, but excludes the most expensive regions
        - **Price Class 100**: only the least expensive regions (America + Europe)

CloudFront — Multiple Origin (Cache Behaviors):

- To route to different kind of origins based on the content type
- Based on path pattern:
    - /images/* → route to origin with static images
    - /api/* → route to ALB
    - /* → everything else
- **Cache Behaviors** → we can route to specified origin based on path

CloudFront — Origin Groups:

- Origin Group — one primary and one secondary origin
- **To increase high-availability and do failover**
- If the primary origin fails, the second one is used
- Use case: CloudFront serves traffic to two S3 buckets in two different regions, with replication

CloudFront — Field Level Encryption:

- Protect user sensitive information through application stack
- Adds an additional layer of security along with HTTPS
- Sensitive information encrypted at the edge close to user
    - Any time sensitive information is sent by the user, the edge location is going to encrypt it and they will be only be able to be decrypted if someone has access to private key
- Uses asymmetric encryption
- Usage:
    - Specify set of fields in POST requests that you want to be encrypted (up to 10 fields)
    - Specify the public key to encrypt them
    - Then the application decrypt sensitive data using its private key
    

CloudFront — Real Time Logs:

- Get real-time requests received by CF sent to Kinesis Data Streams
- Monitor, analyze and take actions based on content delivery performance
- Allows you to choose:
    - **Sampling Rate** — percentage of requests for which you want to receive
    - Specific fields and specific Cache Behaviours (path patterns)