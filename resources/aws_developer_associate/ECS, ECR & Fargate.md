# ECS,  ECR & Fargate

Amazon Public Docker Images Repository: **Amazon ECR Public Gallery**

**Amazon ECS** is a fully managed container orchestration service that makes it easy for you to deploy, manage, and scale containerized applications.

- You can use it to run, stop, and manage containers on a cluster
- Containers are defined in a task definition that you use to run an individual task or task within a service
- A service is a configuration that you can use to run and maintain a specified number of tasks simultaneously in a cluster

A **Task Definition** is a collection of 1 or more *container **configurations***. Some Tasks may need only one container, while other Tasks may need 2 or more potentially linked containers running concurrently. The Task definition allows you to specify which Docker image to use, which ports to expose, how much CPU and memory to allot, how to collect logs, and define environment variables.

A **Task** is created when you run a Task directly, which launches container(s) (defined in the task definition) until they are stopped or exit on their own, at which point they are not replaced automatically. Running Tasks directly is ideal for short-running jobs, perhaps as an example of things that were accomplished via CRON.

A **Service** is used to guarantee that you always have some number of Tasks running at all times. If a Task's container exits due to an error, or the underlying EC2 instance fails and is replaced, the ECS Service will replace the failed Task. This is why we create Clusters so that the Service has plenty of resources in terms of CPU, Memory and Network ports to use. To us it doesn't really matter which instance Tasks run on so long as they run. A Service configuration references a Task definition. A Service is responsible for creating Tasks.

![Untitled](ECS,%20ECR%20&%20Fargate%20b57029964f9b4b40bcfccbd3ea441b84/Untitled.png)

**ECS Container Agent** — allows container instances to connect to your cluster

- It is responsible for managing containers on behalf of Amazon ECS

Amazon Elastic Container Service (ECS) manages Docker containers and represents their lifecycle states in the following way:

1. **PENDING**: The container is scheduled to run on the ECS cluster but has not started yet. This could be due to the ECS service pulling the Docker image or waiting for enough resources (CPU and memory) to be available on the cluster.
2. **RUNNING**: The container is currently running on an Amazon ECS container instance. This means the Docker container has been started successfully and is currently executing the tasks defined within it.
    1. If you terminate a container instance in the RUNNING state, that container instance is automatically removed, or deregistered, from the cluster.
3. **STOPPED**: The container has stopped running on the Amazon ECS container instance. This could be due to the task within the container being completed, or an error occurring which caused the container to stop. The reason for the container being stopped can be found in the **`stoppedReason`** field in the API or the AWS Management Console.
    1. If you terminate a container instance while it is in the STOPPED state, that container instance isn't automatically removed from the cluster →  **that lead to this synchronization issues**
        1. You will need to deregister your container instance in the STOPPED state by using the Amazon ECS console or AWS Command Line Interface. 
        2. Once deregistered, the container instance will no longer appear as a resource in your Amazon ECS cluster.
    2. ECS keeps a record of stopped tasks for a certain amount of time, so you'll still be able to view the details of the stopped task even after the instance is terminated

Amazon ECS — EC2 Launch Type:

- Launch Docker containers on AWS = Launch **ECS Tasks** on ECS Cluster
- You can use the EC2 launch type to run your containerized applications on Amazon EC2 instances that you register to your Amazon ECS cluster and manage yourself.
- EC2 Launch Type: you must provision & maintain the infrastructure
- Each EC2 Instance must run the ECS Container Agents to register in the ECS Cluster
- AWS takes care of starting/stopping containers

Amazon ECS — Fargate Launch Type:

- Launch Docker containers on AWS, but you don’t provision the infrastructure (no EC2 Instances to manage)
- It’s all serverless!
- **AWS Fargate is the serverless way to host your Amazon ECS workloads.**
- You just create task definitions.
- AWS just runs ECS Tasks for you based on the CPU/RAM you need.
- To scale, just increase the number of tasks — no more EC2 Instances.

IAM Roles for ECS Tasks:

- ECS Instance Profile:
    - Only for EC2 Launch Type
    - Used by the **ECS Container Agent** to manage containers
    - Makes API calls to ECS service
    - Send container logs to CloudWatch Logs
    - Pull Docker image from ECR, etc.
- ECS Task Role:
    - Allows each task to have a specific role (role per task)
    - Use different roles for the different ECS Services you run
    - **Task Role is defined in the task definition of your ECS Service**

<aside>
ℹ️ ECS Task Role is the IAM Role used by the ECS task itself. Use when your container wants to call other AWS services like S3, SQS, etc.

</aside>

Amazon ECS — Load Balancer Integrations:

- We can run Application Load Balancer (ALB) in front of ECS Tasks (containers)
- **ALB is supported and works for most use cases**
    - When you deploy your services using Amazon Elastic Container Service (Amazon ECS), you can use dynamic port mapping to support multiple tasks from a single service on the same container instance.
    - Amazon ECS manages updates to your services by automatically registering and deregistering containers with your target group using the instance ID and port for each container.
    - **The Classic Load Balancer doesn’t allow you to run multiple copies of a task on the same instance**
        - Instead, with the Classic Load Balancer, you must statically map port numbers on a container instance
- **NLB** recommended only for high throughput use cases, or to pair it with AWS Private Link
- Other ELBs supported → but not recommended (no advanced features, no Fargate)

Amazon ECS — Data Volumes (EFS):

- You can use Data Volumes in ECS Tasks
- We can mount EFS File System onto ECS Tasks (for both EC2 and Fargate Launch Types)
- Task running in any AZ will share the same data in the EFS file system
- **Fargate + EFS = Serverless**
- Use cases: persistent multi-AZ shared storage for your containers
- **Amazon S3 cannot be mounted as a file system**

ECS Service Auto Scaling:

- ECS Service Auto Scaling ≠ ASG
- Automatically increase/decrease the desired number of ECS tasks
- ECS Auto Scaling uses **AWS Application Auto Scaling**, metrics:
    - avg. CPU utilization
    - avg. RAM / Memory utilization
    - ALB Request Count Per Target — metric coming from the ALB
- **Target Tracking** — scale based on target value for a specific CloudWatch Metric
- **Step Scaling** — scale based on a specified CloudWatch Alarm
- **Scheduled Scaling** — scale based on a specified data/time
- ECS Service Auto Scaling (task level) ≠ EC2 Auto Scaling (EC2 instance level)
- Fargate Auto Scaling is much easier to setup → Serveless

EC2 Launch Type — Auto Scaling EC2 Instances:

- Accommodate ECS Service Scaling by adding underlying EC2 Instances
    - **Auto Scaling Group Scaling (ASG) → depracated**
    - **ECS Cluster Capacity Provider:**
        - Used to automatically provision and scale the infrastructure for your ECS Tasks
        - Capacity Provider is paired with an ASG
        - Add EC2 Instances when you’re missing capacity (CPU, RAM, …)

ECS Rolling Updates:

- When updating from v1 to v2, we can control how many tasks can be started and stopped, and in which order
    - Minimum healthy percent
    - Maximum capacity percent

Solution Architectures:

- ECS tasks can be invoked by **Event Bridge**
    - Event Bridge can have a rule to **run ECS task**
- ECS tasks can be invoked by **Event Bridge Schedule**
    - e.g. run ECS tasks every 1 hour
- ECS tasks can be invoked by **SQS Queue and ECS Auto Scaling**

**ECS Task Definitions:**

- Task definition is metadata in JSON form to tell ECS how to run a Docker Container
- A task definition is required to run Docker containers in Amazon ECS
- It contains crucial information, such as:
    - Image Name
    - Port Binding for Container and Host
    - Memory and CPU required
    - Env vars
    - Networking information
    - IAM Role
    - Logging Configurations
- **We can define up to 10 containers in a Task Definition**
- For each task we have to specify host port (EC2 instance port) or `0` to random
- **We get a Dynamic Host Port Mapping if you define only the container port in the task definition**
    - But we can define host port (EC2 instance port) to expose it for cluster
    - The ALB finds the right port on your EC2 instances for specified ECS Task
- You must allow on the EC2 instance’s SG **any port** from the ALB’s SG
- **When should you put multiple containers into the same task definition?**
    - Containers share a common lifecycle (that is, they should be launched and terminated together)
    - Containers are required to be run on the same underlying host
    - You want your containers to share resources
    - Your containers share data volumes

Load Balancing Fargate:

- Each task has a **unique private IP** in ECS Cluster
    - Each port gets elastic port (from Elastic Network Interface ENI) mapped with container port
- **Only define the container port** (host port is not applicable)

IAM Roles for ECS:

- **One IAM Role per Task Definition**
    - We attach one IAM Role to task definition to access any other AWS Service
    - When we create ECS Service from this task definition, then each ECS task automatically is going to assume and inherit this IAM task role
    - **Role is defined in the task definition level, not at service level**
        - Therefore, when you create an ECS Service from Task Definition, then each ECS task automatically is going to assume and inherit this ECS task role

ECS Environment Variables:

- Task definition can have env vars, they can come from multiple places:
    - **Hardcoded** — e.g. non secret URLs
    - **SSM Parameter Store** — secret data
    - **Secrets Manager** — secret data
    - **Environment File (bulk) — Amazon S3**
- ECS can fetch data from stores and inject them to env vars in runtime

ECS Data Volumes (bind mounts):

- Containers can share data between each other in the same Task Definition
- **Works for both EC2 and Fargate tasks**
- We can define bind storage for multiple containers (e.g. /var/logs/)
- EC2 Tasks — using EC2 **instance storage**
    - Data are tied to the lifecycle of the EC2 Instance
- Fargate Tasks — using ephemeral storage:
    - Data are tied to the container(s) using them → if your task disappear the data also disappears
    - 20GB — 200 GB
- Use cases:
    - Share ephemeral data between multiple containers
    - “Sidecar” container pattern → example logs / metrics

ECS Tasks Placement:

- When a task of type EC2 is launched, ECS must determine where to place it
    - with the constraints of **CPU**, **memory** and **available port**
- When a service scales in → ECS needs to determine which task to terminate
- To assist with this, you can define a **task placement strategy** and **task placement constraints**
- Note: this is only for **ECS with EC2 Launch Type**, not for Fargate
- Process of selecting container instances by ECS:
    - Identify the instances that satisfy the CPU, memory and port requirements in the task definition
    - Identify the instances that satisfy best the task placement constraints
    - Identify the instances that satisfy best the task placement strategies
    - Select the instances for task placement

ECS Task Placement Strategies:

- **Binpack:**
    - Places tasks based on the **least available** amount of **CPU** or **memory**
    - This minimizes the number of instances in use (**cost saving**)
    - We are placing as many containers on one EC2 instance
- **Random**:
    - Place the task randomly
- **Spread**:
    - Place the task evenly based on the specified value, e.g. instance id, AZ, etc.
    - Maximize the high availability
- You can mix Task placement strategies together
    - Example: 2x spread with different values or spread + binpack

ECS Task Placement Constraints:

- **distinctInstance** → place each task on different container instance
    - No two the same task on the same instance
- **memberOf** → place task on instances that satisfy an expression
    - Uses the Cluster Query Language (advanced), `instance-type ~= t2.*`

Amazon ECR:

- ECR = Elastic Container Registry
- ECR stores and manages Docker images on AWS
- Private and Public repository:
    - Public → **Amazon ECR Public Gallery**
- ECR is fully integrated with ECS → backed by S3
- Access to ECR is controlled by IAM
    - In case an EC2 instance (or you) cannot pull a docker image, check IAM permissions
- ECR supports image scanning, versioning, tags, lifecycle

<aside>
ℹ️ Amazon ECR is a fully managed container registry that makes it easy to store, manage, share, and deploy your container images. It won't help in running your Docker-based applications.

</aside>

```bash
docker ecr get-login-password --region REGION | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
docker push aws_account_id.dkr.ecr.region.amazonaws.com/xyz:latest
docker pull aws_account_id.dkr.ecr.region.amazonaws.com/xyz:latest
```

Amazon EKS:

- It is a way to launch **managed Kubernetes cluster on AWS**
- EKS:
    - Runs and scales the Kubernetes control plane across multiple AWS Availability Zones to ensure high availability
    - Automatically scales control plane instances based on load, detects and replaces unhealthy control plane instances, and it provides automated version updates and patching for them
- EKS is alternative to ECS → similar goal
- EKS → Kubernetes is open-source
- EKS supports ******EC2****** or **Fargate** to deploy
- **Kubernetes is cloud-agnostic (you can use it in any cloud Azure, GCP, etc.)**

EKS Node Types:

- **Managed Node Groups**
    - AWS Creates and manages Nodes (EC2 Instances) for you
    - Nodes are part of an ASG managed by EKS
    - Supports On-Demand or Spot Instances
- **Self Managed Nodes**
    - Nodes are created by you and registered to the EKS cluster and managed by an ASG
    - You can use prebuilt AMI - Amazon EKS Optimized AMI
    - Supports On-Demand or Spot Instances
- **AWS Fargate**
    - No maintenance required → no nodes managed

EKS Data Volumes:

- Need to specify **Storage Class** manifest on your EKS cluster and leverages a **Container Storage Interface (CSI)** compliant driver
- Supports: EBS and EFS (works with Fargate), FSx for Lusture/NetApp

AWS Copilot:

- AWS Copilot is a command line interface (CLI) that helps developers to build, release, and operate containerized applications on AWS.
- Introduced by Amazon Web Services, Copilot simplifies the process of setting up, developing, and managing containerized applications.
- Run your apps on AppRunner, ECS and Fargate
- Provisions all required infrastructure for containerized apps (ECS, VPC, ELB, ECR, …)
- Automated deployments with on command using CodePipeline
- Deploy to multiple envs
- Troubleshooting, logs, health status

Here's a brief overview of what you can do with AWS Copilot:

1. Application Setup and Development: Copilot helps you to build a containerized application from the ground up. It assists in setting up the necessary AWS infrastructure, including **Amazon ECS** (Elastic Container Service) for running the containers and AWS Fargate for serverless compute.
2. Environment Management: With Copilot, you can manage different environments (like test, staging, and production) for your application. It helps to automate the setup of these environments and manage them separately.
3. Deployment: AWS Copilot simplifies the process of deploying your application. It helps automate your deployments, using AWS services like ECS and Fargate.
4. Operations: Once your application is live, Copilot provides tools to monitor and troubleshoot the application. It integrates with AWS services like Amazon CloudWatch for logs and AWS X-Ray for performance insights.

In summary, AWS Copilot is designed to handle a lot of the heavy lifting involved in running containerized applications on AWS, allowing developers to focus more on writing code and less on managing infrastructure.