# Elastic Load Balancer, ASG

AWS ELB (Elastic Load Balancer) — is a managed load balancer:

- AWS guarantees that it will be working
- AWS takes care of upgrades, maintenance and high availability
- AWS provides only a few configuration knobs

- It costs less to setup your own load balancer but it will be a lot more effort on your end
- Elastic Load Balancer automatically distributes your incoming traffic across multiple targets, such as EC2 instances, etc. **in one or more Availability Zones (AZs)**
- Using a load balancer increases the **availability** and **fault tolerance** of your applications.
- ELB is integrated with many AWS services, e.g. EC2, ACM, CloudWatch, etc.

- Health Check is a way for your elastic load balancer to verify whether an EC2 instance is properly working (healthy)
    - It monitors the health of its registered targets, and routes traffic only to the healthy targets
    - The health check is done on a port and a route (`/health` is common)
    - If the response is not 200 (OK), then the instance is unhealthy

<aside>
ℹ️ When you enable ELB Health Checks, your ELB won't send traffic to unhealthy (crashed) EC2 instances.

</aside>

Types of load balancer on AWS:

- Classic Load Balancer (CLB) — v1 old generation — compatible with HTTP, HTTPS, TCP, SSL
- Application Load Balancer (ALB) — v2 2016 — HTTP, HTTPS, WebSocket
- Network Load Balancer (NLB) — v2 2017 — TCP, TLS, UDP
- Gateway Load Balancer (GWLB) — 2022 — operates at layer 3 (Network), IP Protocol
    
    

Load Balancer Security Groups:

- Users can access your load balancer from anywhere using HTTP/HTTPS - using load balancers make EC2 instances that they can accept only traffic coming directly from load balancer by setting proper security group

### Application Load Balancer ALB (v2)

- ALB is Layer 7 (HTTP)
- A *load balancer* serves as the single point of contact for clients.
- The load balancer distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones.
- Load balancing to multiple HTTP applications across machines (*target groups*)
- Load balancing to multiple application on the same machine, e.g. containers
- **Supports HTTP/2 and WebSockets**
- **Supports redirects (e.g. from HTTP to HTTPS)**
- Supports routing tables to different target groups:
    - Routing based on path in URL
    - Routing based on hostname in URL
    - Routing based on query string in URL
    - Routing based on Headers
- ALB are a great fit for microservices and container-based applications
- ALB has a port mapping feature to redirect to a dynamic port in ECS

![Untitled](Elastic%20Load%20Balancer,%20ASG%20bcb1d7bbb4e547e88191d7fb14566130/Untitled.png)

<aside>
ℹ️ ALBs can route traffic to different Target Groups based on URL Path, Hostname, HTTP Headers, and Query Strings.

</aside>

Target Groups:

- Each *target group* is used to route requests to one or more registered targets.
    - When a rule condition is met, traffic is forwarded to the corresponding target group.
    - You can create different target groups for different types of requests.
- EC2 instances can be managed by an Auto Scaling Group (ASG) — HTTP
- ECS tasks managed by ECS itself — HTTP
- Lambda Functions — HTTP request is translated into a JSON event
- IP Addresses — must be private IP

- **ALB can route to multiple target groups**
    - You can register a target with multiple target groups
- Health checks are at the target group level
    - Health checks are performed on all targets registered to a target group
- Each *target group* routes requests to one or more registered targets, such as EC2 instances, using the protocol and port number that you specify

![Untitled](Elastic%20Load%20Balancer,%20ASG%20bcb1d7bbb4e547e88191d7fb14566130/Untitled%201.png)

How it works?

- After the load balancer receives a request, it evaluates the listener rules in priority order to determine which rule to apply, and then selects a target from the target group for the rule action.
- You can configure listener rules to route requests to different target groups based on the content of the application traffic.
- An Application load balancer distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones.
    - A listener checks for connection requests from clients, using the protocol and port that you configure.
    - The rules that you define for a listener determine how the load balancer routes requests to its registered targets.
    - Each rule consists of a priority, one or more actions, and one or more conditions.

### Network Load Balancer (NLB)

- Lower Level Load Balancer → Layer 4 OSI
- Forward TCP & UDP traffic to your instances
- Handle millions of requests per second (very high performance)
- Less latency than ALB (100ms vs 400ms for ALB)
- After the load balancer receives a connection request, it selects a target from the target group for the default rule.
- It attempts to open a TCP connection to the selected target on the port specified in the  configuration.
- **NLB has one static IP per AZ** and supports assigning Elastic IP (for each AZ)
- NLB are used for extreme performance, TCP or UDP traffic
- Target groups can be: EC2 Instances, IP Addresses (private), Application Load Balancer
- Health checks support the TCP, HTTP, HTTPS
- After the network load balancer receives a connection request, it selects a target from the target group for the default rule.
- It attempts to open a TCP connection to the selected target on the port specified in the listener configuration.
    - **Incoming connections remain unmodified, so application software need not support X-Forwarded-For**

<aside>
ℹ️ Only **Network Load Balancer** provides both **static DNS name** and **static IP**. While, Application Load Balancer provides a static DNS name but it does NOT provide a static IP. The reason being that AWS wants your Elastic Load Balancer to be accessible using a static endpoint, even if the underlying infrastructure that AWS manages changes.

Network Load Balancer has one **static IP** address **per AZ** and you can attach an Elastic IP address to it. Application Load Balancers and Classic Load Balancers has a static DNS name.

</aside>

### Gateway Load Balancer (GWLB)

- Deploy, scale and manage a fleet of 3rd party network virtual appliances in AWS
- Lower Level LB → Layer 3 (Network) - IP Packets
- Functions:
    - Transparent Network Gateway — single entry/exit for all traffic
    - Load Balancer — distributes traffic to your virtual appliances
- **Uses the GENEVE protocol on port 6081**
- Target groups can be: EC2 Instances, IP Addresses (private)

### Sticky Sessions (Session Affinity)

- It is possible to implement stickiness so that the same client is always redirected to the same instance behind a load balance

![Untitled](Elastic%20Load%20Balancer,%20ASG%20bcb1d7bbb4e547e88191d7fb14566130/Untitled%202.png)

- This works for **Classic Load Balancer (CLB)** and **Application Load Balancer (ALB)**
- The “cookie” used for stickiness has an expiration date you control
- Use case: make sure the user doesn’t lose his session data

- By **default**, an Application Load Balancer routes each request **independently** to a registered target based on the chosen load-balancing algorithm
- You can use the **sticky session** feature (also known as session affinity) to enable the load balancer to **bind** a user's **session** to a **specific** **target**
- **To use sticky sessions, the client must support cookies**
- ALB support both **duration-based** cookies and **application-based** cookies:
    - If your application has its own session cookie, then you can use application-based stickiness and the load balancer session cookie follows the duration specified by the application's session cookie
- **Application-based Cookies:**
    - Custom cookie → generated by the target:
        - Can include any custom attributes required by the application
        - Cookie name must be specified for each target group
        - ALB uses `AWSALB, AWSALBAPP, AWSALBTG` cookies, so the custom cookie name should be different
    - Application cookie → generated by the load balancer:
        - Cookie name is `AWSALBAPP`
- **Duration-based Cookies:**
    - Cookie generated by the load balancer
    - Cookie name is `AWSALB` for ALB, `AWSELB` for CLB
    - Cookie duration/expiration date is generated by LB

<aside>
ℹ️ ELB Sticky Session feature ensures traffic for the same client is always redirected to the same target (e.g., EC2 instance). This helps that the client does not lose his session data.

The following cookie names are reserved by the ELB (AWSALB, AWSALBAPP, AWSALBTG).

</aside>

### Cross-Zone Load Balancing

- With Cross Zone Load Balancing — each load balancer instance distributes **evenly** across **all** registered instances in all **AZ**
- If cross-zone load balancing is **disabled**, each load balancer node distributes requests evenly across the registered instances in **its Availability Zone only**

![Untitled](Elastic%20Load%20Balancer,%20ASG%20bcb1d7bbb4e547e88191d7fb14566130/Untitled%203.png)

- Application Load Balancer (ALB):
    - Cross-Zone LB is **enabled** by default (can be disabled at the Target Group level)
    - No charges for inter AZ data
- Network Load Balancer (NLB) + Gateway Load Balancer (GWLB):
    - Cross-Zone LB is **disabled** by default
    - You pay charges (💵) for inter AZ data if enabled
- Classic Load Balancer (CLB):
    - Cross-Zone LB is **disabled** by default
    - No charges for inter AZ data if enabled

<aside>
💡 A Classic Load Balancer with HTTP or HTTPS listeners might route more traffic to **higher-capacity instance types**. 

This distribution aims to prevent lower-capacity instance types from having too many outstanding requests. It’s a best practice to use similar instance types and configurations to reduce the likelihood of capacity gaps and traffic imbalances.

A **traffic imbalance** might also occur if you have instances of similar capacities running on different Amazon Machine Images (AMIs). In this scenario, the imbalance of the traffic in favor of higher-capacity instance types is desirable.

</aside>

### SSL/TLS Certificates - AWS Certificate Manager (ACM)

- An SSL Certificate allows traffic between your clients and your load balancer to be **encrypted** in transit (in-flight encryption → data can be decrypted only by it sender/receiver)
- SSL refers to Secure Sockets Layer → used to encrypt connection
- TLS refers to Transport Layer Security → newer version of SSL

- Public SSL Certificates are issued by Certificate Authorities (CA)
- SSL Certificates have an expiration date (you set) and must be renewed

![Untitled](Elastic%20Load%20Balancer,%20ASG%20bcb1d7bbb4e547e88191d7fb14566130/Untitled%204.png)

- The load balancer uses an X.509 certificates (SSL/TLS)
- **Traffic behind the load balancer (to EC2) is decrypted (it’s in private network)**
- To use an HTTPS listener, you must deploy at least one SSL/TLS server certificate on your load balancer.
    - You can create an HTTPS listener, which uses encrypted connections (also known as SSL offload).
    - This feature enables traffic encryption between your load balancer and the clients that initiate SSL or TLS sessions.
    - As the EC2 instances are under heavy CPU load, the load balancer will use the server certificate to terminate the front-end connection and then decrypt requests from clients before sending them to the EC2 instances.
- You can manage certificates using ACM (AWS Certificate Manager) or you can create and upload your own certificate
- HTTPS Listener:
    - You must specify default certificate
    - Clients can use **SNI (Server Name Indication)** to specify the hostname they reach
    - Ability to specify a security policy to support older versions of SSL/TLS

<aside>
💡 You cannot have an HTTP listener for an Application Load Balancer to support SSL termination or SSL pass-through.

</aside>

- **SNI (Server Name Indication)** — solves the problem of loading multiple SSL certificates onto one web server — to serve multiple websites from one server
    - It’s a newer protocol and requires the client to indicate the hostname of the target server in the initial SSL handshake
    - The server will find the correct certificate or return the default one
- **SNI only works for ALB, NLB and CloudFront** (not work for CLB)

![Untitled](Elastic%20Load%20Balancer,%20ASG%20bcb1d7bbb4e547e88191d7fb14566130/Untitled%205.png)

- Classic Load Balancer (CLB):
    - **supports only one SSL certificate**
    - must use multiple CLB for multiple hostname with multiple SSL certificates
- ALB:
    - Supports multiple listeners with multiple SSL certificates — uses SNI to make it work
- NLB:
    - Supports multiple listeners with multiple SSL certificates — uses SNI to make it work

<aside>
ℹ️ Server Name Indication (SNI) allows you to expose multiple HTTPS applications each with its own SSL certificate on the same listener. Read more here: [https://aws.amazon.com/blogs/aws/new-application-load-balancer-sni/](https://aws.amazon.com/blogs/aws/new-application-load-balancer-sni/)

</aside>

### Connection Draining / Deregistration Delay

Connection Draining - for CLB

Deregistration Delay - for ALB and NLB

- Time to complete “in-flight requests” while the instance is de-registering or unhealthy
- Stops sending new requests to the EC2 instance which is de-registering (waiting for **existing** connections to complete)
    - The other EC2 instances will receive new connections to estabilish
- Between 1 to 3600 seconds (default 300 seconds)
- Can be disabled (set value to 0)
- It is good to set low value if your requests are short
- If you have long requests -> set high value

### Auto Scaling Group (ASG)

- Scale out/in (add/remove EC2 instances) to match an in/decreased load
- Auto Scaling groups are **regional constructs**. They can span Availability Zones, but not AWS regions.
- An *Auto Scaling group* contains a collection of EC2 instances that are treated as a logical grouping for the purposes of automatic scaling and management.
- Both maintaining the number of instances in an Auto Scaling group and automatic scaling are the core functionality of the Amazon EC2 Auto Scaling service.
- ASG ensures we have a minimum or maximum number of EC2 instances running
- ASG automatically register new instances to a load balancer
    - ELB is able to distribute traffic to all instances into ASG
    - ELB will spread the load to all “created” instances by ASG
- ASG can re-create an EC2 instance in case a previous one was terminated (e.g. if unhealthy)
    - If ELB discover that any instance in ASG is unhealthy then ASG can re-create it
- ASG is free (you only pay for the underlying EC2 instances)
- ASG Launch Template - contains information how to launch EC2 instances within your ASG:
    - AMI + Instance Type, EC2 User Data, EBS Volumes, Security Groups, SSH Key Pair, IAM Roles for EC2 Instances, Network + Subnetworks, Load Balancer Information
    - Min Size / Max Size / Initial Capacity
    - Scaling Policies

![Untitled](Elastic%20Load%20Balancer,%20ASG%20bcb1d7bbb4e547e88191d7fb14566130/Untitled%206.png)

<aside>
💡 **Amazon EC2 Auto Scaling cannot add a volume to an existing instance if the existing volume is approaching capacity** - A volume is attached to a new instance when it is added. Amazon EC2 Auto Scaling doesn't automatically add a volume when the existing one is approaching capacity. 
You can use the EC2 API to add a volume to an existing instance.

</aside>

<aside>
💡 **Amazon EC2 Auto Scaling works with both Application Load Balancers and Network Load Balancers** - Amazon EC2 Auto Scaling works with Application Load Balancers and Network Load Balancers including their health check feature.

</aside>

- Scaling Policies:
    - It is possible to scale an ASG based on CloudWatch alarms
- An alarm monitors a metric (e.g. average CPU or any custom metric)
- **Metrics such as average CPU are computed for the overall ASG Instances**
- Based on the alarm:
    - We can create scale-out policies (increase the number of the instances)
    - We can create scale-in policies
    

Autoscaling policies — **Dynamic** Scaling Policies**:**

- **Target Tracking Scaling** — simple, easy to setup
    - Increase and decrease the current capacity of the group based on a Amazon CloudWatch metric and a target value.
    - Example: I want the average ASG CPU to stay at around 40%
- **Simple / Step Scaling** —
    - Increase and decrease the current capacity of the group based on a set of/single scaling adjustments.
    - Example:
        - When a CloudWatch alarm is triggered (example CPU > 70%) then add 2 units
        - When a CloudWatch alarm is triggered (example CPU < 40%) then remove 1 unit

- **AWS recommend that you use target tracking scaling policies**
    - With target tracking, an Auto Scaling group scales in direct proportion to the actual load on your application.
    - That means that in addition to meeting the immediate need for capacity in response to load changes.
    - Target tracking policy can also adapt to load changes that take place over time, for example, due to seasonal variations.
- By default, new Auto Scaling groups start **without any scaling policies.**
    - When you use an Auto Scaling group without any form of dynamic scaling, it doesn't scale on it own unless you set up scheduled scaling or predictive scaling.

Autoscaling policies — **Scheduled Scaling / Predictive Scaling:**

- **Scheduled Scaling** — anticipate scaling based on known usage patterns
- **Predictive Scaling** — continuously forecast load and schedule scaling ahead
    - Use predictive scaling to increase the number of EC2 instances in your Auto Scaling group in advance of daily and weekly patterns in traffic flows.
    - You should specify metric and target what will be fullfilled by ML forecast
- In general, if you have **regular patterns of traffic** increases and applications that take a long time to initialize, you should consider using predictive scaling.
- Predictive scaling can also potentially save you money on your EC2 bill by helping you avoid the need to overprovision capacity.
- Predictive scaling finds patterns in CloudWatch metric data from the previous 14 days to create an hourly forecast for the next 48 hours.

Good Metrics to scale on:

- **CPU Utilization** — average CPU utilization across your instances
- **Request Count Per Target** — to make sure the number of requests per EC2 instance is stable, e.g. we know that application works fine for 1000 requests, so when >1000 req then we need another instance
- **Average Network In/Out** —
- Any Custom Metric from Cloud Watch

**Scaling Cooldown:**

- After the scaling happens, you are in the **cooldown period** (default is 300 seconds)
- During the cooldown period the ASG will not launch or terminate additional instances
- Why? To stabilize metrics

<aside>
ℹ️ For each Auto Scaling Group, there's a Cooldown Period after each scaling activity. In this period, the ASG doesn't launch or terminate EC2 instances. This gives time to metrics to stabilize. The default value for the Cooldown Period is 300 seconds (5 minutes).

</aside>

⚠️ ASG with ELB healthchecks:

- The default health checks for an **Auto Scaling group are EC2 health checks** only.
    - If an instance fails these health checks, it is marked unhealthy and is terminated while Amazon EC2 Auto Scaling launches a new replacement instance.
- You can attach one or more load balancer target groups, one or more Classic Load Balancers, or both to your Auto Scaling group.
- However, by default, the Auto Scaling group does not consider an instance unhealthy and replace it **if it fails the Elastic Load Balancing health checks**.
- To ensure that your Auto Scaling group can determine instance health based on additional load balancer tests, **configure the Auto Scaling group to use Elastic Load Balancing (ELB) health checks**.
    - The load balancer periodically sends pings, attempts connections, or sends requests to test the EC2 instances and determines if an instance is unhealthy.
- If you configure the Auto Scaling group to use Elastic Load Balancing health checks, it considers the instance unhealthy if it fails either the EC2 health checks or the Elastic Load Balancing health checks.
- If you attach multiple load balancer target groups or Classic Load Balancers to the group, all of them must report that an instance is healthy in order for it to consider the instance healthy.
    - If any one of them reports an instance as unhealthy, the Auto Scaling group replaces the instance, even if others report it as healthy
    

ASG — Instance Refresh:

- Instance Refresh is a feature of AWS Auto Scaling Group (ASG) that allows you to automatically **refresh the instances in your ASG** to the latest configuration of the **launch template** and then re-creating all EC2 instances.
- This feature is particularly useful when you are rolling out updates, such as changing the instance type, updating the operating system, or changing the initialization script (user data script).
- During an Instance Refresh, the ASG gradually replaces older instances with new ones, maintaining service and minimizing impact on performance.
- You can control the pace of this process by setting a "*minimum healthy percentage*", which refers to the minimum percentage of instances that must remain in service during the refresh process.
- Here's how it works:
    1. The ASG creates a new instance according to the latest configuration of the launch template or launch configuration.
    2. Once the new instance is launched and passes health checks, it joins the ASG.
    3. The ASG then terminates one of the older instances.
    4. This process repeats until all instances have been refreshed.