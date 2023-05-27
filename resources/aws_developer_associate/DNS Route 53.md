# DNS: Route 53

What is DNS?

- Domain Name Server — which translate human friendly host names into IP address
- DNS is a backbone of the Internet
- Terminology:
    - **DNS Records**: A, AAAA, CNAME, NS, etc.
    - **Zone File**: contains DNS records
    - **Name Servers**: resolves DNS queries
    - **Top Level Domain** (TLD): .com, .us, .gov, .org, etc.
    - **Second Level Domain** (SLD): amazon.com, google.com, etc.

Amazon Route 53:

- A highly available, scalable and fully managed and *Authoritative* DNS
    - *Authoritative* = you can update the DNS records
- Route 53 is also **Domain Registrar**
- Ability to check the health of your resources
- The only AWS service that provides 100% availability SLA
- Each record contains:
    - **Domain/subdomain name**, e.g. example.com
    - **Record Type**, e.g. A or AAAA
    - **Value**, e.g. 1.2.3.4
    - **Routing Policy** — how Route 53 responds to queries
    - **TTL** — amount of time the response cached at DNS Resolvers
- Route 53 supports the following DNS record types:
    - **(must know) A / AAAA / CNAME / NS**
    - (advanced) CAA / DS / MX, etc.

DNS Record Types:

- **A — maps a hostname to IPv4**
- **AAAA — maps a hostname to IPv6**
- **CNAME — maps a hostname to another hostname**
    - The target is a domain name which must have an A or AAAA record
    - **You can’t create CNAME for [example.com](http://example.com) (top node of DNS), but you can create for www.example.com**
- **NS — Name Severs for the Hosted Zone**
    - Controls how traffic is routed for a domain

Route 53 Hosted Zones:

- A container for records that define how to route traffic to a domain and its subdomains
- We have got two types of hosted zones: public and private
- **Public Hosted Zone** — contains records that specify how to route traffic on the Internet (public domain names)
- **Private Hosted Zone** — contains records that specify how you route traffic within one or more VPCs (private domain names)
    - Can be only queried by your private resources within VPC
- **You pay $0.50 per moth per any hosted zone**

Record TTL:

- DNS tells client “please cache this result for a duration of the TTL” (default 300 seconds)
- We don’t want to query DNS server to often
- High TTL → less traffic to Route 53 + possibly outdated records
- Low TTL → high traffic to Route 53 💵 + easy to change records
- **TTL is mandatory — except the alias records (Alias records)**

<aside>
ℹ️ Each DNS record has a TTL (Time To Live) which orders clients for how long to cache these values and not overload the DNS Resolver with DNS requests. The TTL value should be set to strike a balance between how long the value should be cached vs. how many requests should go to the DNS Resolver.

</aside>

CNAME vs Alias:

- AWS Resources (Load Balancer, Cloud Front, etc.) exposes an AWS hostname
- CNAME:
    - Points a hostname to any other hostname, e.g. `app.[mydomain.com](http://mydomain.com)` → [`xyz.anything.com`](http://xyz.anything.com)
    - **ONLY FOR NON-ROOT DOMAIN**
- Alias:
    - Points a hostname to an AWS Resource, e.g. `[app.mydomain.com](http://app.mydomain.com)` → `xyz.amazonaws.com`
    - **Works for ROOT DOMAIN and NON-ROOT DOMAIN**
    - Free of charge
    - Native health check

Alias Record — details:

- Maps a hostname to an AWS Resource
- Automatically recognizes changes in the resource’s IP addresses
- Unlike CNAME, it can be used for the **top node of DNS namespace (Zone Apex)**
- Alias record is always of type A/AAAA for AWS Resources (IPv4 or IPv6)
- **You cannot set TTL to Alias Record** (It’s set automatically by Route 53)
- Alias Record Targets:
    - ELB
    - CloudFront Distributions
    - API Gateway
    - Elastic Beanstalk environments
    - S3 Websites
    - VPC Interface endpoints
    - Global Accelerator
    - Route 53 record in the same hosted zone
- **You cannot set an ALIAS RECORD FOR an ECS DNS name**

Routing Policies:

- Routing policy defines how Route 53 responds to DNS queries
- DNS doesn’t route any traffic, it only responds to the DNS queries
    - After response, the client will know to which way it should be doing requests
- Available Routing Policies:
    - **Simple**
    - **Weighted**
    - **Failover**
    - **Latency based**
    - **Geolocation**
    - **Multi-Value Answer**
    - **Geoproximity**
- **Simple Routing Policy** — typically, route traffic to a single resource
    - Can specify multiple values in the same record
    - **If multiple values are returned, a random one is chosen by the client**
    - When Alias record is **enabled** → specify **only one AWS Resource**
    - **Cannot be associated with Health Checks**

- **Weighted Routing Policy** — control the % of the requests that go to each specific resources
    - Assign each record a relative weight
    - **Assign a weight of 0 to a record to stop sending traffic to a resource**
    - **If all records have weight of 0, then all records will be returned equally**
    - DNS record must have the same name and type
    - Can be associated with Health Checks
    - Use cases:
        - Load balancing between regions, testing new app version
    
    <aside>
    ℹ️ Weighted Routing Policy allows you to redirect part of the traffic based on weight (e.g., percentage). It's a common use case to send part of traffic to a new version of your application.
    
    </aside>
    

- **Latency Based Routing Policy** —  redirect to the resource that has the lowest latency close to client
    - Super helpful when latency is priority for our users
    - **Latency is based on traffic between users and AWS Regions**
        - We must specify the region of the record
        - Route 53 is not smart enough to get the region automatically from IP address, because you can specify any IP address you want (not only AWS resource IP)
    - Can be associated with Health Checks (has a failover capability)
    
- **Failover Routing Policy** (Active-Passive) —
    - For 2 resources (one is **primary**, and **secondary**)
    - If Health Check fails for primary resource → Route 53 automatically failover to the second resource (secondary one has also HC)

- **Geolocation Routing Policy** —
    - Different from Latency Based Routing Policy!
    - **This routing policy is based on USER LOCATION**
    - Specify location by Continent/Country/US State etc. → the most precise location is selected
        - **You should create “Default” record** → in case of no matches
    - Can be associated with Health Checks

- **Geoproximity Routing Policy** —
    - Route traffic to resources based on the geographical location of users and resources
    - **Ability to shift more traffic to resources based on the default bias**
    - To change the size of a geographic region, specify **bias** values:
        - To expand (1 to 99)  → more traffic to the resource
        - To shrink (-1 to -99) → less traffic to the resource
    - Resources can be:
        - AWS Resources → specify AWS region
        - Non-AWS Resources → specify longitude and latitude
    - **You must use Route 53 Traffic Flow for this feature**

![Untitled](DNS%20Route%2053%20c30e399cdf2c432a8d1fb65b5e8118ed/Untitled.png)

- **Multi Value Routing Policy** — use when routing traffic to multiple resources
    - Route 53 return multiple value/resources
    - Can be associated with Health Checks (return only values for healthy resources)
    - Up to 8 healthy records are returned for each Multi-Value query
    - **Multi-Value Routing Policy is not a substitute for having an ELB**
        - MV Policy is a client-side load balancer → not server-side
- ****IP-based Routing Policy**** — based on clients’ IP addresses
    - You provide a list of CIDRs for your clients and the corresponding endpoints/locations (user-IP-to-endpoint mappings)

Route 53 Health Checks:

- HTTP Health Checks are only for **Public Resources**
- Health Checks → automated DNS failover:
- Three types of Route 53 Health Checks:
    - Health Checks that monitor **public endpoint** (app, server, other AWS resource)
    - Health Checks that monitor **other health checks** (Calculated Health Check)
    - Health Checks that monitor **CloudWatch Alarm**
- Health Checks are integrated with CloudWatch metrics
- Monitor an Endpoint:
    - **About 15 global health checkers will check the endpoint health**
        - Healthy/Unhealthy threshold → 3 is default
            - If fails 3 times in row → fails HC
        - Interval → 30 second (lower interval → higher costs)
        - Supported protocols: HTTP, HTTPS and TCP
        - If > 18% of health checkers report the endpoint is **healthy** → Route 53 considers the endpoint is **healthy**
        - Ability to choose which **location** you want Route 53 to use
    - **Health Checks pass only when endpoint responds with 2XX or 3XX status code**
    - **Health Checks can be setup to pass/fails based on the text in the first 5120 bytes of the response** (it checks if response text contains specified data)
    - Configure your router/firewall to allow incoming requests from Route 53 Health Checks
- Calculated Health Checks:
    - Combine multiple results of Health Checks into a single Health Check
    - We can define child HC and parent HC → Calculated one
    - **You can use OR, AND, NOT** for conditions
    - You can monitor up to **256 Child HC**
    - You can specify how many of the child HC need to pass to make parent HC healthy

Health Checks — Private Hosted Zones:

- Route 53 health checks are outside the private VPCs
- **They cannot access private** endpoint (private VPCs)
- **You can create CloudWatch Metric and associate CloudWatch Alarm, then create a HC that checks the alarm itself**

Route 53 Traffic Flow:

- Simplify maintaining/creating records in large/complex configurations
- Visual editor to manage/control routing decision tree
- Configuration can be saved as **Traffic Flow Policy**
    - Can be applied to different Route 53 Hosted Zone (different Domain Name)
    - Supports versioning

Route 53 Domain Registrar:

- The Domain Registrar usually provides you with a DNS service to manage your DNS records
    - You can use another DNS service to manage your DNS records
- If you buy domain in 3rd party registrar, you can use it Route 53 Hosted Zone
- Using custom name servers → paste to Route 53 Hosted Zone configuration (Name Servers)
- **Domain Registrar ≠ DNS Service**

<aside>
ℹ️ Public Hosted Zones are meant to be used for people requesting your website through the Internet. Finally, NS records must be updated on the 3rd party Registrar.

</aside>