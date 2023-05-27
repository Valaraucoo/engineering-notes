# VPC

Should know:

- VPC, Subnets, Internet Gateway, NAT Gateway
- Security Groups, Network ACL (NACL), VPC Flow Logs
- VPC Peering, VPC Endpoints
- Site to Site VPN & Direct Connect

VPC — Virtual Private Cloud:

- Private Network to deploy your **regional** resources
- Subnets allow you to **partition your network** inside your VPC (Availability Zone resources)
    - Subnets are defined at AZ level
    - e.g. in one Availability Zone A we can have multiple VPC Subnets
- **Public Subnet** — is a subnet that is accessible from the Internet
    - Can access WWW and can be accessed from outside world
- **Private Subnet** — is a subnet that is not accessible from the Internet
- To define access to the Internet and between subnets, we use **Route Tables**
- VPC has a set of available IP ranges, e.g. `10.0.0.0/16`

![Untitled](VPC%20102ce1c78668409dab5f6d3b62ecb371/Untitled.png)

Internet Gateway, NAT Gateway:

- **Internet Gateway** — helps our VPC instances connect with the external Internet
    - Public Subnets have a route to the Internet Gateway
    - at the VPC Level
    
    ![Untitled](VPC%20102ce1c78668409dab5f6d3b62ecb371/Untitled%201.png)
    
- **NAT Gateways** (managed by AWS) & **NAT Instances** (self-managed) — allow your instances in **Private Subnets** to access the external Internet while remaining private
    - You need to deploy **NAT Gateway/NAT Instance** in public subnet and then create the **route from private subnet to NAT Gateway/Instance** in public subnet
    - Then Private subnet has access to the Internet through the NAT

![Untitled](VPC%20102ce1c78668409dab5f6d3b62ecb371/Untitled%202.png)

Network ACL (NACL) & Security Groups:

- **Network ACL (NACL)** — firewall which controls traffic from/to subnet
    - NACL can have **Allow** and **Deny** rules
    - All traffic must be explicitly allowed by rules
    - NACLs are attached at the **Subnet Level**
    - **Rules only includes IP Addressed**
        - e.g. *all traffic from this address is allowed*
    - Incoming traffic to subnet first should be processed by NACL
    - Automatically applies to all resources in Subnet it’s associated with
    
    ![Untitled](VPC%20102ce1c78668409dab5f6d3b62ecb371/Untitled%203.png)
    

- **Security Groups** — firewall that controls traffic to/from **Elastic Network Interface** / an **EC2 Instance**.
    - Can have only **Allow** rules
    - Rules include IP Addresses and other security groups
    - Operates at the **Instance level**
    - Applies only for specified resources
    
    <aside>
    ℹ️ Security groups are stateful and if traffic can go out, then it can go back in.
    
    </aside>
    

VPC Flow Logs:

- Capture information about IP traffic going into your interfaces:
    - VPC Flow Logs
    - Subnet Flow Logs
    - Elastic Network Interface (ENI) Flow Logs
- **Anytime you have network going through your VPC it will be logged in a Flow Logs**
- Helps to monitor and troubleshoot connectivity issues
- VPC Flow Logs can go to S3 / Cloud Watch Logs

VPC Peering:

- To establish connectivity between VPCs
- Connect two VPCs privately using AWS’ network
    - Make them behave as if they were in the same network
- **VPSs must not have overlapping CIRD** (IP address range)

![Untitled](VPC%20102ce1c78668409dab5f6d3b62ecb371/Untitled%204.png)

- VPC Peering is **not transitive** (must be established for each VPC that need to communicate with one another)
    - If there is two VPC Peers from A to B and from A to C, then B cannot talk with C (it’s not transitive)

VPC Endpoint:

- **Endpoints allow you to connect to AWS Services using a private network instead of the public www network; works within the VPC**
    - This gives you enhanced security and lower latency to access AWS Services
- Used to connect services in other, private Subnets through VPC Endpoint:

![Untitled](VPC%20102ce1c78668409dab5f6d3b62ecb371/Untitled%205.png)

- We’ve got two VPC Endpoint types:
    - **VPC Endpoint Gateway**: to communicate with **S3 / DynamoDB**
    - **VPC Endpoint Interface**: to communicate with the rest
- **VPC Endpoint is only used within your VPC**

Site to Site VPN & Direct Connect:

- **Site to Site VPN:**
    - Connect an On-Premises VPN to AWS
    - The connection is **automatically encrypted**
    - The connection goes over **public Internet**

![Untitled](VPC%20102ce1c78668409dab5f6d3b62ecb371/Untitled%206.png)

- **Direct Connect (DX):**
    - Establish **physical** connection between AWS VPC and On-Premises Network
    - The connection is private, secure and fast
    - The connection goes over **private network**
    - **Takes at least a month to establish** 💸

![Untitled](VPC%20102ce1c78668409dab5f6d3b62ecb371/Untitled%207.png)

**Site-to-Site VPN and Direct Connect (DX) cannot access to VPC Endpoints.**

**LAMP Stack on EC2:**

- **Linux**: OS for EC2 Instances
- **Apache**: Web Server that run on Linux (EC2)
- **MySQL**: database on RDS
- **PHP**: app logic running on EC2