# AWS CI/CD: CodeCommit, CodePipeline, CodeBuild, CodeDeploy, CodeStar, Cloud9

AWC Code Commit:

- version control system
- private code repository
- no size limit on repositories
- code only in AWS Cloud account → security
- code is encrypted and you can have access control
- integrated with CI tools, e.g. AWS CodeBuild and Jenkins
- default branch is **main**

Code Commit Security:

- Authentication:
    - **SSH Keys** — AWS Users can configure SSH keys in their IAM Console
    - **HTTPS** —
- Authorization:
    - IAM Policies to manage users/roles
- Encryption:
    - Repositories are automatically encrypted at rest using AWS KMS
    - Encrypted in transit (HTTPS/SSH)
- Cross-account Access:
    - Do NOT share your SSH keys or your AWS creds
    - Use an IAM Role in your AWS account and use AWS STS (AssumeRole API)

 

- You can create **notification rules** in Code Commit repository
    - you can select event that trigger notification, e.g. on commit/PR
    - you can select notification target: SNS Topic or Slack notification
- You can create **Triggers**:
    - Triggered on events: Push to existing branch, create branch, delete branch
    - Triggers target: SNS Topic or AWS Lambda
- You can create Repository Tags

Setup IAM SSH/HTTPS git credentials for AWS CodeCommit:

- IAM > Users

**AWS CodePipeline:**

- Visual Workflow to orchestrate your CI/CD
- **Source** — CodeCommit, ECR, S3, BitBucket, GitHub
- **Build** — CodeBuild, Jenkins, TeamCity
- **Test** — CodeBuild, AWS Device Farm
- **Deploy** — CodeDeploy, EB, CloudFormation, ECS, S3, …
- Consists of stages:
    - Build → Test → Deploy → Load Testing
    - Each stage can have sequential actions and/or parallel actions
    - **Manual approval** can be defined at any stage

CodePipeline — Artifacts:

- Each pipeline stage can create **artifacts**
    - Artifact is whatever is created out of the pipeline
- Artifacts are stored in S3 bucket and passed on to the next stage
- Stages interact with each other using S3 and artifacts

CodePipeline — Troubleshooting:

- For CodePipeline pipeline/actions/stage execution state changes, you can use **CloudWatch Events (Event Bridge)**
    - You can create events for failed/cancelled stages/pipelines
- If CodePipeline fails a stage, your pipeline stops, and you can get information in the console
- If pipeline cannot perform an actions, make sure the “*IAM Service Role*” attached does have enough permissions (IAM Policy)
- **AWS CloudTrail** can be used to audit AWS API calls

CodePipeline — Events vs. Webhooks vs. Polling

- EventBridge’s event can trigger CodePipeline
- We can trigger CodePipeline via HTTP webhook (using any script) with specified payload
- We can configure CodePipeline to make regular (cron) polls from specified source → not recommended

CodePipeline — Manual Approval Stage:

- we can configure manual approval with events/triggers to for example send emails

CodeBuild:

- CodeBuild is responsible for building and testing your code
    - fully managed build service that compiles your source code, runs unit tests, and produces artifacts that are ready to deploy
- **Source** — CodeCommit, S3, GitHub, etc.
- **Build instructions**: Code file `**buildspec.yml**` or insert manually in Console
- Output logs can be stored in S3 and CloudWatch Logs
- Use CloudWatch Metrics to monitor build stats
- Use CloudWatch Events to detect failed build and trigger notifications
- Use CloudWatch Alarms to notify if you need “thresholds” for failures
- **Build Projects can be defined within CodePipeline or CodeBuild**
- CodeBuild runs instructions from `buildspec.yml` in docker container
    - CodeBuild has ability to cache container builds in S3 Bucket (optional)
    - All logs are stored in S3 / CloudWatch Logs
- In result CodeBuild produces **artifacts** (stored in S3 bucket)

More about `buildspec.yml`

- `buildspec.yml` file must be at the root of your code (or `configuration/buildspec.yml`)
- `env` — define env variables on top of the file
    - `variables` → plaintext
    - `parameter-store` → variables stored in SSM Parameter Store
    - `secrets-manager` → variables stored in AWS Secrets Manager
- `phases` — specify commands to run while build/test:
    - `install` — install dependencies you may need for build
    - `pre-build` — final commands to execute before build
    - `build` — commands to build
    - `post-build` — finishing touches (e.g. zip outputs)
- `artifacts` — what to upload to S3 (encrypted automatically with AWS KMS)
- `cache` — files to cache (usually dependencies) to S3 for future build speedup

CodeBuild — Local Build:

- You can run CodeBuild locally on your desktop (after installing Docker)

CodeBuild — inside VPC:

- By default, your CodeBuild containers are launched outside your VPC
    - It cannot access resources in a VPC
- You can specify a VPC configuration
- Then your build can access resources in your VPC (e.g. RDS, ElastiCache, EC2, ALB, …)

CodeDeploy:

- CodeDeploy is a deployment service that automates application deployments to Amazon EC2 instances, on-premises instances, serverless Lambda functions, or Amazon ECS services.
- CodeDeploy can deploy application content that runs on a server and is stored in Amazon S3 buckets, GitHub repositories, or Bitbucket repositories.
- We want to deploy our application automatically to many EC2 instances
- These EC2 instances are not managed by EB

How it work?

- Each EC2 instance/on-premises server must be running the **CodeDeploy Agent**
- The CodeDeploy agent is a software package that, when installed and configured on an instance, makes it possible for that instance to be used in CodeDeploy deployments.
- Developer pushes code to S3/GitHub repository → **appspec.yml** - configuration of CodeDeploy → how to deploy app
- The agent is continuously polling AWS CodeDeploy for work to do → is there something I should deploy?
- Application + appspec.yml is pulled from repository -> deploy
- EC2 instances will run the deployment instructions in appspec.yml
- CodeDeploy agent will report of success/failure of the deployment

CodeDeploy components:

- **Application** — a unique name functions as a container (revision, deployment, configuration, etc.)
- **Compute Platform** — EC2, on-premises, AWS Lambda or Amazon ECS
- **Deployment Configuration** — a set of deployment rules for success/failure
    - EC2/on-premises — specify min. Number of healthy instances for the deployment
    - AWS Lambda or ECS — specify how traffic is routed to your updated versions
- **Deployment Group** — group of tagged EC2 instances (allows to deploy gradually or dev, test, prod,… )
- **Deployment Type** — method used to deploy the app to a Deployment Group
    - **In-place** Deployment — supports EC2/on-premises
        - The application on each instance in the deployment group is stopped, the latest application revision is installed, and the new version of the application is started and validated.
        - You can use a load balancer so that each instance is deregistered during its deployment and then restored to service after the deployment is complete.
    - **Blue/Green** Deployment — supports EC2 instances only, AWS Lambda and ECS
        - With a blue/green deployment, you provision a new set of instances on which CodeDeploy installs the latest version of your application.
        - CodeDeploy then re-routes load balancer traffic from an existing set of instances running the previous version of your application to the new set of instances running the latest version.
        - After traffic is re-routed to the new instances, the existing instances can be terminated.
- **IAM Instance Profile** — give EC2 instances the permissions to access both S3 / GitHub
- **Application Revision —** application code + appspec.yml
- **Service Role** — an IAM Role for CodeDeploy to perform operations on EC2 instances, ASGs, ELBs, etc.
- **Target Revision** — the most recent revision that you want to deploy to a Deployment Group

**Appspec.yml**

- Files — how to source and copy from S3 / Github to filesystem
    - Source
    - Destination
- Hooks — set of instructions to do to deploy the new version (hooks can have timeout) the order is:
    - ApplicationStop
    - DownloadBundle
    - BeforeInstall
    - Install
    - AfterInstall
    - ApplicationStart
    - **ValidateService -> important!**

Deployment Configuration:

- Configurations:
    - One at a time -> one EC2 instance at a time, if one instance fails then deployment stops
    - Half at a time -> 50%
    - All at once — quick but no healthy host -> downtime
    - Custom — min. Healthy host = 75%
- Failures:
    - EC2 instances stay in “failed” state
    - New deployments will first be deployed to failed instances
    - **To rollback, redeploy old deployment or enable automated rollback for failures**
- Deployment Groups:
    - A set of tagged EC2 instances
    - Directly to an ASG
    - Mix of ASG / Tags, so you can build deployment segments
    - Customization in scripts with DEPLOYMENT_GROUP_NAME

Deployment to Ec2:

- Define how to deploy application using appspec.yml + Deployment Strategy
- Will do in-place update to your fleet of EC2 instances
- Can use hooks to verify the deployment after each deployment phase

Deploy to an ASG:

- In-place deployment:
    - update existing EC2 instances
    - newly created EC2 instances by an ASG will also get automated deploy
- Blue/Green deployment:
    - A new ASG is created (settings are copied)
    - Choose how long to keep the old EC2 instances (old ASG)
    - must be using and ELB

Redeploy & Rollbacks:

- **Automatically** — rollback when a deployment fails or rollback when a CloudWatch Alarm thresholds are met
- **Manually**

- Disable Rollbacks — do not perform rollbacks for this deployment
- **If a rollback happens, CodeDeploy redeploys the last known good revision as a new deployment (not a restored version)**

CodeDeploy — Troubleshooting:

- In case of deployment error → `InvalidSignatureException`
    - If the date and time on your EC2 instance are not set correctly, they might not match the signature data of your deployment request, which CodeDeploy rejects
- Check log files to understand deployment issues

CodeStar:

- AWS CodeStar enables you to quickly develop, build, and deploy applications on AWS
- With AWS CodeStar, you can set up your entire continuous delivery toolchain in minutes, allowing you to start releasing code faster.
- Integrated solution that groups: GitHub, CodeCommit, CodeBuild, CodeDeploy, CloudFormation, CodePipeline
    - also integrated with: Jira, GitHub Issues
- Quickly create CI/CD projects for EC2, Lambda, EB
- Free — you pay only for other services
- Limited Customization

CodeArtifact:

- Software packages depend on each other to be built, and new ones are created
- Storing and retrieving these dependencies is called **artifact management**
- Traditionally, you need to set up your own artifact management system
- **CodeArtifact is secure, scalable and cost-effective artifact management system for software development**
- Works with common dependency management tools such as npm, yarn
- **Developers and CodeBuild can then retrieve dependencies straight from CodeArtifact**
- If dependency is removed → you can still use it via AWS CodeArtifact store — so your app will work continuously in the future, even though the dependency was removed

CodeArtifact — Upstream repositories:

- A CodeArtifact repository can have other CodeArtifact repositories as Upstream Repositories
- Allow a package manager client to access the packages that are contained in more than one repository using a single repository endpoint
- Up to 10 Upstream Repositories
- Only one **external connection**
    - an external connection is a connection between a CodeArtifact Repository and an external/public repository (e.g. Maven, npm, PyPI, …)
    - Allows you to fetch packages that are not already present in you CodeArtifact Repository
    - A repository has a maximum of 1 external connection → create many repositories for many external connections

CodeArtifact — Retention:

- If a requested package version is found in an Upstream Repository, a reference to it is retained and is always available from the Downstream Repository
- The retained package version is not affected by changes to the upstream repo
- Intermediate repositories do not keep the package

CodeGuru:

- **An ML-powered service for automated code reviews and application performance recommendations**
- CodeGuru Reviewer: automated code reviews for static code analysis (development)
    - Works with CodeCommit, GitHub, BitBucket
    - Identify critical issues, security vulnerabilities and hard-to-find bugs
    - Uses ML and automated reasoning
    - Supports Java and Python
- CodeGuru Profiler: recommendations about application performance during runtime (production)
    - Helps understand the runtime behavior of your application
    - Identify and remove code inefficiencies
    - Improve application performance, e.g. reduce CPU utilization
    - Decrease compute costs
    - Provides heap summary
    - Anomaly Detection
    - Support application ruinning on AWS or on-premises

CodeGuru — Agent Configuration:

- **MaxStackDepth** — the maximum depth of the stacks in the code thats is represented in the profile
- **MemoryUsageLimitPercent** — the memor used by the profiler
- **MinimumTimeForReportingInMiliseconds** — the minimum time between sending reports
- **ReportingIntervalInMiliseconds** — the reporting interval used to report profiles
- **********************************************************SamplingIntervalInMiliseconds********************************************************** — the sampling interval that is used to profile samples → reduce to have a higher sampling rate

Cloud9:

- Cloud-based integrated development env (IDE)
- Code editor, debugger, terminal in a browser
- Work on your projects from anywhere with a Internet connection
- Prepacked with essential tools for popular languages
- Share you development env
- Fully integrated with AWS SAM & Lambda to easily build serverless apps
- AWS Cloud9 is an integrated development environment (IDE) that allows developers to write, run, and debug their code using only a web browser.
- It is a service provided by Amazon Web Services (AWS), which means it is hosted on the cloud, and it can support multiple programming languages.
- The platform provides a code editor, debugger, and terminal.
- It's designed to facilitate collaborative work, allowing multiple developers to work on the same project at the same time and see each other's updates in real time.
- AWS Cloud9 also offers seamless integration with other AWS services, making it easier to set up and manage resources directly from the IDE.
    - This includes services like AWS Lambda for serverless computing and Amazon S3 for storage.
- Because Cloud9 is cloud-based, it allows developers to work from anywhere, on any machine, without having to worry about setting up a local development environment.
    - They can simply open their browser, log in, and start coding.