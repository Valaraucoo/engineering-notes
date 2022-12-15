# EC2: Fundamentals

### Amazon EC2

- one of the most popular AWS service
- EC2 = Elastic Compute Cloud
- EC2 consists:
    - renting virtual machines (EC2)
    - storing data on virtual drives (EBS)
    - distributing load (ELB)
    - scaling the services (ASG)
- You can use Amazon EC2 to launch as many or as few virtual servers as you need, configure security and networking, and manage storage.
- Amazon EC2 enables you to scale up or down to handle changes in requirements or spikes in popularity, reducing your need to forecast traffic.

<aside>
ℹ️ Free tier eligible customers can get up to 30 GB of EBS General Purpose (SSD) or Magnetic storage

</aside>

### EC2 User Data

- Bootstrapping — launching commands when a machine starts (EC2 User Data script)
    - The initial script is only **run** **once** at the instance **first** **start**
    - EC2 User Data is used to automate boot tasks such as: installing updates, software, downloading common files from internet etc.
- The EC2 User Data script runs with the root user.

### EC2 Instance Types

- There are 7 types of EC2 instances and each type has different families: [https://aws.amazon.com/ec2/instance-types/](https://aws.amazon.com/ec2/instance-types/)
- AWS has the following naming convention:

```
m5.2xlarge

m -> instance class
5 -> generation (AWS improves them over time)
2xlarge -> size within the instance class
```

- The most popular instance types: **General Purpose**, **Compute Optimized, Memory Optimized, Storage Optimized.**

- **General Purpose** EC2 instances:
    - Great for a diversity of workloads as web servers
    - Balance between: compute, memory and networking
    - Instance class: `t`
- **Compute Optimized** EC2 Instances:
    - Great for compute-intensive tasks that require high performance processors: batch processing workloads, media transcoding, high performance web servers, ML & AI.
    - Instance class: `c`
- **Memory Optimized** EC2 Instances:
    - Fast performance for workloads that process large data sets in memory
    - Use cases: high performance, relational/non-relational databases, in-memory databases for BI, realtime processing of big unstructured data
    - Instance class: `r`
- **Storage Optimized** EC2 Instances:
    - Great for storage-intensive tasks, sequential read and write access to large data sets on local storage.
    - Use cases: OLTP systems, Relational/NoSQL databases, Cache for in-memory databases (Redis), Data warehousing applications.

### Security Groups

- Security Groups control how traffic is allowed into or out of our ECS Instances
- A *security group* controls the traffic that is allowed to reach and leave the resources that it is associated with.
    - For each security group, you add *rules* that control the traffic based on protocols and port numbers.
    - There are separate sets of rules for inbound traffic and outbound traffic.
- Security groups only contains **allow** rules:
    - You can specify allow rules, but not deny rules.
- Security groups rules can reference by IP or by security groups
- When you first create a security group, it has **no inbound rules**. Therefore, no inbound traffic is allowed until you add inbound rules to the security group.
- When you first create a security group, it has an outbound rule that allows **all outbound traffic** (by default) from the resource.
     

- Security Groups are acting as a “firewall” on EC2 Instances:
    - Regulate access to ports
    - Authorized IP ranges
    - Control of inbound and outbound network

- Security groups can be attached to multiple instances
    - Security Groups can be attached to multiple EC2 instances within the same AWS Region/VPC.
    - When you associate multiple security groups with a resource, the rules from each security group are aggregated to form a single set of rules that are used to determine whether to allow access.
- Security groups are locked down to a region / VPC combinations
- Security groups live “outside” the EC2 instances, if traffic is blocked to EC2 instance we won’t see it
    - Security group is really a “firewall” outside your EC2 instance
- **It’s good to maintain one separate security group for SSH access**
- All **inbound** traffic is **blocked** by default
- All **outbound** traffic is **authorized** by default

- You can reference security group from other security group

- Classic Ports to know:
    - **SSH** — port **22** — allows logging into a Linux instance
    - **FTP** — port **21** — file transfer protocol, upload files into a file share
    - **SFTP** — port **22** — upload files using SSH
    - **HTTP** — port **80** — access unsecured websites
    - **HTTPS** — port **443** — access secured websites
    - **RDP** — port **3389** — remote desktop protocol, log into a Windows instance
- If you get **Timeout** while connecting to EC2 instance — it’s the issue of an EC2 security group

- Default user in AWS AMI instances: `ec2-user`
- You can connect to instance using **SSH** or **EC2 Instance Connect** (in AWS Console UI)
    - For each of connection types you should have configured security group for SSH
- Never enter IAM API KEYs to EC2 instance — you should use IAM Roles

### EC2 Instances Purchasing Options

- **On-Demand Instances** — short workload, predictable pricing, pay by seconds
- **Reserved Instances** — reserved instances for long workloads (1 or 3 years plans)
- **Convertible Reserved Instances** — reserved instances for long workloads with flexible instance types (if you want changing instance types) (1 or 3 years plans)
- **Savings Plans** (1 or 3 years plans) - commitment to an amount of usage, long workload
- **Sport Instances** — short workloads, very cheap, can lose instances (less reliable)
- **Dedicated Hosts** — book an entire physical server; control instance placement
- **Dedicated Instances** — no other customers will share your hardware
- **Capacity Reservations** — reserve capacity in a specific AZ for any duration

EC2 On-Demand:

- Pay for what you see — billing per second, after the first minute → for Linux or Windows
- All other OS → billing per hour
- Has the highest cost but no upfront payment
- No long-term commitment
- Recommended for short-term workloads, where you cannot predict how the application will behave

EC2 Reserved Instances:

- Up to 72% discount compared to On-Demand
- You reserve a **specific instance attributes** → instance type, region, tenancy, OS
- **Reservation period**: 1 year (+ discount) or 3 years (+++ discount)
- Payment Options: No upfront, Partial Upfront, All Upfront
- Reserved Instance’s Scope: Regional or Zonal
- Recommended for steady-state usage applications (e.g. databases)
- You can buy and sell reserved instanced in the marketplace

EC2 Reserved Instances — Convertible Reserved Instances:

- Can change the EC2 instance type, instance family, OS, scope and tenancy
- Up to 66% discount

EC2 Saving Plans:

- Up to 72% discount compared to On-Demand
- Commit to a certain type of usage ($10/hour for 1 or 3 years)
- Locked to a specific instance family and region (e.g. M5 in us-east-1)
- Flexible across: Instance Size, OS, Tenancy

EC2 Spot Instances:

- Up to 90% discount compared to On-Demand
- Instances that you can “lose” at any point of time if your max price is less than the current spot price
- The MOST cost-efficient instances in AWS
- Useful for workloads that are resilient to failure: batch jobs, data analysis, image processing
- Not suitable for critical jobs or databases

EC2 Dedicated Hosts:

- A physical server with EC2 instance capacity fully dedicated to your use
- Allows you address compliance requirements and use your existing server-bound software licenses
- Purchasing Options:
    - On-Demand
    - Reserved
- The most expensive option
- Useful for: software that have complicated licensing model, or for companies that have strong regulatory or compliance needs.

EC2 Dedicated Instances:

- Instances run on hardware that’s dedicated to you
- May share hardware with other instances in same account
- No control over instance placement (can move hardware after start/stop)

EC2 Capacity Reservations:

- Reserve On-Demand instances capacity in a specific AZ for any duration
- You always have access to EC2 capacity when you need it
- No time commitment, no billing discounts!
- Combine with Regional Reserved Instances and Saving Plans to benefit from billing discounts.
