# Elastic Load Balancer

AWS ELB (Elastic Load Balancer) — is a managed load balancer:

- AWS guarantees that it will be working
- AWS takes care of upgrades, maintenance and high availability
- AWS provides only a few configuration knobs

- It costs less to setup your own load balancer but it will be a lot more effort on your end
- Elastic Load Balancing automatically distributes your incoming traffic across multiple targets, such as EC2 instances, etc. **in one or more Availability Zones (AZs)**
- Using a load balancer increases the **availability** and **fault tolerance** of your applications.
- ELB is integrated with many AWS services, e.g. EC2, ACM, CloudWatch, etc.

- Health Check is a way for your elastic load balancer to verify whether an EC2 instance is properly working
    - It monitors the health of its registered targets, and routes traffic only to the healthy targets
    - The health check is done on a port and a route (`/health` is common)
    - If the response is not 200 (OK), then the instance is unhealthy

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
- Supports HTTP/2 and WebSockets
- Supports redirects (e.g. from HTTP to HTTPS)
- Supports routing tables to different target groups:
    - Routing based on path in URL
    - Routing based on hostname in URL
    - Routing based on query string in URL
- ALB are a great fit for microservices and container-based applications
- ALB has a port mapping feature to redirect to a dynamic port in ECS

Target Groups:

- Each *target group* is used to route requests to one or more registered targets.
    - When a rule condition is met, traffic is forwarded to the corresponding target group.
    - You can create different target groups for different types of requests.
- EC2 instances can be managed by an Auto Scaling Group (ASG) — HTTP
- ECS tasks managed by ECS itself — HTTP
- Lambda Functions — HTTP request is translated into a JSON event
- IP Addresses — must be private IP

- ALB can route to multiple target groups
    - You can register a target with multiple target groups
- Health checks are at the target group level
    - Health checks are performed on all targets registered to a target group
- Each *target group* routes requests to one or more registered targets, such as EC2 instances, using the protocol and port number that you specify

How it works?

- After the load balancer receives a request, it evaluates the listener rules in priority order to determine which rule to apply, and then selects a target from the target group for the rule action.
- You can configure listener rules to route requests to different target groups based on the content of the application traffic.

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

### Cross-Zone Load Balancing

- With Cross Zone Load Balancing — each load balancer instance distributes **evenly** across **all** registered instances in all **AZ**
- If cross-zone load balancing is **disabled**, each load balancer node distributes requests evenly across the registered instances in **its Availability Zone only**


- Application Load Balancer (ALB):
    - Cross-Zone LB is **enabled** by default (can be disabled at the Target Group level)
    - No charges for inter AZ data
- Network Load Balancer (NLB) + Gateway Load Balancer (GWLB):
    - Cross-Zone LB is **disabled** by default
    - You pay charges (💵) for inter AZ data if enabled
- Classic Load Balancer (CLB):
    - Cross-Zone LB is **disabled** by default
    - No charges for inter AZ data if enabled
    

### SSL/TLS Certificates - AWS Certificate Manager (ACM)

- An SSL Certificate allows traffic between your clients and your load balancer to be **encrypted** in transit (in-flight encryption → data can be decrypted only by it sender/receiver)
- SSL refers to Secure Sockets Layer → used to encrypt connection
- TLS refers to Transport Layer Security → newer version of SSL

- Public SSL Certificates are issued by Certificate Authorities (CA)
- SSL Certificates have an expiration date (you set) and must be renewed


- The load balancer uses an X.509 certificates (SSL/TLS)
- Traffic behind the load balancer (to EC2) is decrypted (it’s in private network)
- You can manage certificates using ACM (AWS Certificate Manager) or you can create and upload your own certificate
- HTTPS Listener:
    - You must specify default certificate
    - Clients can use **SNI (Server Name Indication)** to specify the hostname they reach
    - Ability to specify a security policy to support older versions of SSL/TLS

- **SNI (Server Name Indication)** — solves the problem of loading multiple SSL certificates onto one web server — to serve multiple websites from one server
    - It’s a newer protocol and requires the client to indicate the hostname of the target server in the initial SSL handshake
    - The server will find the correct certificate or return the default one
- **SNI only works for ALB, NLB and CloudFront** (not work for CLB)


- Classic Load Balancer (CLB):
    - **supports only one SSL certificate**
    - must use multiple CLB for multiple hostname with multiple SSL certificates
- ALB:
    - Supports multiple listeners with multiple SSL certificates — uses SNI to make it work
- NLB:
    - Supports multiple listeners with multiple SSL certificates — uses SNI to make it work

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
- An *Auto Scaling group* contains a collection of EC2 instances that are treated as a logical grouping for the purposes of automatic scaling and management.
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

- Scaling Policies:
    - It is possible to scale an ASG based on CloudWatch alarms
- An alarm monitors a metric (e.g. average CPU or any custom metric)
- **Metrics such as average CPU are computed for the overall ASG Instances**
- Based on the alarm:
    - We can create scale-out policies (increase the number of the instances)
    - We can create scale-in policies
