# Elastic Beanstalk

- Elastic Beanstalk is a developer centric view of deploying an application on AWS
    - It uses for example: EC2, ASG, ELB, RDS, etc.
- Beanstalk is ******************************managed service******************************
    - Automatically handles capacity provisioning, load balancing, scaling, monitoring, etc.
    - Just the application code is developer’s responsibility
- We still have full control over the configuration
- Beanstalk is free, but you pay for the underlying instances

Amazon Elastic Beanstalk is a fully managed service provided by AWS that simplifies the deployment and management of applications. It enables developers to quickly deploy web applications and services without worrying about the underlying infrastructure configuration.

Key points to know about Amazon Elastic Beanstalk for the Certified AWS Developer Associate exam include:

1. Application deployment: Elastic Beanstalk allows developers to deploy applications developed in various programming languages such as Java, .NET, PHP, Node.js, Python, Ruby, and Go. It supports both web applications and web services.
2. Managed environment: Elastic Beanstalk abstracts away the complexity of infrastructure management. It automatically handles tasks like capacity provisioning, load balancing, scaling, and application health monitoring.
3. Environment management: Developers can create multiple environments within Elastic Beanstalk, such as development, staging, and production, to manage different stages of application deployment and testing.
4. Configuration options: Elastic Beanstalk provides configuration options for customizing the environment, including setting environment variables, defining instance types, configuring load balancing, and enabling auto-scaling.
5. Integration with other AWS services: Elastic Beanstalk seamlessly integrates with other AWS services, such as Amazon RDS for database management, Amazon S3 for storing application files, and Amazon CloudWatch for monitoring and logging.
6. Platform updates: Elastic Beanstalk automatically handles updates to underlying platform components, including operating system updates, web server software, and language runtime environments.
7. Command line and API support: Elastic Beanstalk can be managed using the AWS Management Console, Command Line Interface (CLI), or API, providing developers with flexibility in managing their applications.

Elastic Beanstalk — Components:

- **Application** — collection of Elastic Beanstalk components (environments, versions, configurations, etc.)
- **Application Version** — iteration of application code
- **********************Environment********************** —
    - Collection of AWS resources running an application version (only one application version at a time)
    - **Tiers**: Web Server Environment Tier / Worker Environment Tier
    - You can create multiple environments: dev, test, prod
- We can set up **multiple environments** (can be web / worker)
- Tiers: Web Server Tier (ELB) and Worker Tier (SQS Queue)

Configuration:

- **Presets:**
    - Single Instance (free), Single Instance (spot), High Availability, High Availability (spot and on-demand), Custom Configuration
- **Custom configuration:**
    - Software:
        - AWS X-Ray
        - S3 logs store (enable/disable)
        - Streaming logs to CloudWatch Logs
    - Instances:
        - Root volume
        - EC2 Security Groups
    - Capacity:
        - ASG: Load balanced (max/min instances) / single instance, composition (on-demand / spot), instance types, ami, AZs
        - Scaling triggers: metrics (CPU, Network, disk, etc.), statistics, units, thresholds
    - Load Balancer: ALB/CLB/NLB, Listeners, Rules, Access logs (s3)— **you cannot update load balancer later on**
    - Rolling updates and deployments
    - Security
    - Monitoring
    - Managed Updates (when update ec2 instances)
    - Notifications
    - Networking
    - Database: RDS database settings
    - Tags

Elastic Beanstalk Deployment Modes:

- Single Instance — great for development → one AZ
- High Availability with Load Balancer → great for production

Options for Updates:

- **All at once (deploy all in one go)** → fastest, but instances aren’t available to serve traffic for a bit (**downtime**)
    - Great for quick iterations and developments
    - No additional costs
- **Rolling** — update a few instances at a time (bucket) and then move onto the next bucket once the first bucket is healthy
    - Application is running below capacity
    - Can set the bucket size
    - Application is running both versions
    - No additional costs
    - Longer deployment
- **Rolling with additional batches** — like rolling, but spins up new instances to move the batch (so that the old application is still available) — full capacity
    - Application is running at capacity
    - Can set the bucket size
    - Application is running both versions
    - Small additional costs
        - The additional batch is removed at the end of the deployment
    - Longer deployment
    - Good for production
- **Immutable** — spins up new instances in a new temporary ASG, deploys version to these instances, and then swaps all the instances when everything is healthy
    - Zero downtime
    - New code is deployed to new instances on a temporary ASG
    - High cost, double capacity
    - Longest deployments
    - Quick rollback in case of failures
    - Great for production
- **Blue/Green**
- **Traffic splitting**

Deployment — Blue / Green Deployments:

- **Not a “direct feature” of Elastic Beanstalk**
- Zero downtime
- **Create a new “stage” environment** and deploy v2 there
- **The new environment** (green) can be validated independently and roll back if issues
- Route 53 can be setup using weighted policies to redirect a little bit of traffic to the stage env
- Using Beanstalk, “swap URLs” when done with the environment test

![Untitled](Elastic%20Beanstalk%203e195f9c9b5a40ee9a6b39d50768de42/Untitled.png)

Deployment — Traffic Splitting:

- **Canary testing** — traffic splitting
- The new application version is deployed to a temporary ASG with the same capacity
- A small % of traffic is sent to the temporary ASG for a configurable amount  of time
- Deployment health is monitored

![Untitled](Elastic%20Beanstalk%203e195f9c9b5a40ee9a6b39d50768de42/Untitled%201.png)

- If there’s a deployment failure, this triggers an **************************************************************automated rollback (very quick)************************************************************** — only limit ALB traffic
- No downtime
- New instances are migrated from the temporary ASG to the original ASG

![Untitled](Elastic%20Beanstalk%203e195f9c9b5a40ee9a6b39d50768de42/Untitled%202.png)

Elastic Beanstalk CLI:

- additional CLI called the “EB cli”

EB Deployment Process:

- Describe dependencies
- Package code as zip and describe dependencies
- Console: upload zip file (creates new app version) and then deploy
- CLI: create new app version using CLI (uploads zip) and then deploy
- EB will deploy the zip on each EC2 instance, resolve dependencies and start the application

EB Lifecycle Policy:

- EB can store at most 1000 application versions
- If you don’t remove old versions, you won’t be able to deploy anymore
- To remove old app versions, use a **lifecycle policy**
    - Based on time (old versions are removed)
    - Based on space (when you have to many versions)
- **Versions that are currently used won’t be deleted**
- Option **not to delete** the source bundle in S3 to prevent data loss

EB Extensions:

- All the parameters set in the UI can be configured with code using files
- Requirements:
    - `.ebextensions/` directory in the root of source code
    - YAML/JSON format → but the extensions of the files must be `.config`
        - e.g. `logging.config`
    - You are able to modify some default settings using `option_settings`
    - You have ability to add resources such as RDS, ElastiCache, DynamoDB, etc.
- Resources managed by EB Extensions get deleted if the environment goes away

How EB works?

- Under the hood, EB relies on CloudFormation
- CF is used to provision other AWS Services
    - You can define CloudFormation resources in you `.ebextensions` to provision ElastiCache, an S3 bucket, anything you want!

EB Cloning:

- You can **clone** an environment with the exact same configuration
- Useful for deploying a “test” version
- All resources and configurations are preserved:
    - Load Balancer type and configuration
    - RDS database type (but the data is not preserved)
    - etc.
- After cloning an env, you can change settings

Elastic Beanstalk Migration: Load Balancer

- After creating an EB env, **you cannot change the Elastic Load Balancer type** (you can change only LB configuration)
- To migrate:
    1. Create a new environment with the same configuration except LB (you cannot perform cloning)
    2. Deploy application onto the new environment
    3. Perform a CNAME swap or Route 53 update (DNS)

Elastic Beanstalk Migration: RDS — Decouple RDS

- RDS can be provisioned with Beanstalk, which is great for dev/test
- The best for production is to separately create an RDS database and provide our EB app with the connection string
- Decoupling steps:
    1. Create a snapshot of RDS 
    2. Go to the RDS console and protect the RDS database from deletion
    3. Create a new EB env without RDS, and point your application to existing RDS
    4. Perform a CNAME swap or Route 53 update
    5. Terminate the old environment
    6. Delete CloudFormation Stack

EB with Docker: Single Docker

- Run your application as a single docker container
- You should provide:
    - `Dockerfile` → EB will build and run the docker container
    - `Dockerrun.aws.json` → describe where **already built** docker image is
- **Beanstalk in Single Docker Container does not use ECS**

<aside>
💡 You must use saved configurations to migrate an Elastic Beanstalk environment **between AWS accounts**. 
You can save your environment's configuration as an object in Amazon Simple Storage Service (Amazon S3) that can be applied to other environments during environment creation, or applied to a running environment. 

Saved configurations are YAML formatted templates that define an environment's platform version, tier, configuration option settings, and tags.

</aside>

Multi Docker Container:

- Multi Docker helps run multiple containers per EC2 instance in EB
- This will create for you:
    - ECS Cluster
    - EC2 Instances, configured to use the ECS CLuster
    - Load Balancer (in high availability mode)
    - Task definitions and executions
- Required a config `Dockerrun.aws.json (v2)`
- `**Dockerrun.aws.json` is used to generate the ECS task definition**
- Your docker images must be pre-built and stored in ECR repo

EB and HTTPS:

- To enable HTTPS:
    - Load SSL onto the Load Balancer
    - Can be done from the Console (EB console, load balancer configuration)
    - Can be done from the code: `.ebextensions/securelistener-alb.config`
    - SSL Certificate can be provisioned using ACM (AWS Certificate Manager) or CLI
    - Must configure a security group rule to allow incoming port 443 (HTTPS port)
- Beanstalk redirect HTTP to HTTPS:
    - Configure redirect
    - OR configure the ALB (Application Load Balancer only) with a rule
    - Make sure health checks are not redirected

Web Server vs. Worker:

- If your app performs tasks that are long to complete → worker
- Decoupling app into two tiers is common
- You can define periodic tasks in a file `cron.yaml`
- Worker = SQS + EC2
- Web Tier = ELB + EC2

EB Custom Platform:

- Custom Platforms allow you to define from scratch:
    - Operating System (OS)
    - Additional Software
- **Use Case: app language is incompatible with Beanstalk & does not use Docker**
- To create your own platform:
    - Define an AMI using `Platform.yaml` file
    - Build that platform using the **Packer**
- Custom Platform vs. Custom Image (AMI):
    - Custom Image is to tweak an **existing** Beanstalk Platform (Python, Node, etc.)
    - Custom Platform is to **create new** Beanstalk Platform