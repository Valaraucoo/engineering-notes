# AWS RDS, Aurora

- RDS → Relational Data Storage
- RDS is managed DB service for databases which uses SQL
    - **RDS databases in the cloud are managed by AWS**
- Available SQL Engines:
    - Postgres, MySQL, MariaDB, Oracle, Microsoft SQL Server
    - Aurora (AWS Proprietary database)

<aside>
ℹ️ Postgres and MySQL support IAM Database Authentication.

</aside>

- Advantages of RDS:
    - RDS is **managed service**
        - Automated provisioning
        - Automated OS patching
    - You can create database **snapshot**
        - You can also migrate database snapshot to another region
    - Continuous **backups** and **restore** to specific timestamp (point in time restore)
    - Monitoring dashboards
    - Read replicas for improved read performance
    - Multi AZ setup for Disaster Recovery (DR)
    - Scaling both vertical and horizontal
    - Storage backed by AWS EBS (gp2 or io1)
- **You cannot SSH to RDS instance**

RDS Storage Auto Scaling:

- When RDS detects that you are running out of free database storage, it scales automatically
    - RDS Storage Auto Scaling continuously monitors actual storage consumption, and scales capacity up automatically when actual utilization approaches provisioned storage capacity.
- **Avoid manually scaling your database storage**
- You have to set **maximum storage threshold**  (maximum limit for database storage)
- Autoscaling will automatically modify storage if:
    - Free storage is less than 10% of allocated storage AND
    - Low-storage lasts at least 5 minutes AND
    - 6 hours have passed since last modification

Read Replicas:

- We can create **up to 5 read replicas**
- Read replicas can be in the **same AZ, Cross AZ or Cross Region**
- Replication is **ASYNC** → reads are eventually consistent
- Replica can be promoted to their own database
- Each read replica creates new endpoint with their own DNS name
    - If you application want to use read replicas you should specify which replica (there is no load balancing by default)
- Network cost:
    - There is a network cost when data goes from one AZ to another
    - **For RDS Read Replicas within the same REGION you don’t pay that fee**
    
    ![Untitled](AWS%20RDS,%20Aurora%200abb216249724203b03bcc061ee5d936/Untitled.png)
    
    <aside>
    ℹ️ Read Replicas add new endpoints with their own DNS name. We need to change our application to reference them individually to balance the read load.
    
    </aside>
    
- RDS Multi AZ (Disaster Recovery):
    - We have multiple databases:
        - **Master** database and **standby** databases
        - Standby databases are not used for scaling — they are exact duplicate of database in another AZ
    - **Synchronous** Replication
    - Increase availability
    - **One DNS Name** — automatic app failover to standby database
        - Your app talks to one DNS name and if the master db is unhealthy there will be automatically failover to standby/slave database
        - Failover in case of loss AZ, loss of network, instance or storage failure
    
    ![Untitled](AWS%20RDS,%20Aurora%200abb216249724203b03bcc061ee5d936/Untitled%201.png)
    

- **The Read Replicas can be setup as Multi AZ for Disaster Recovery**
    - The read replica can have a standby database in another AZ (so we have read replica + synchronous standby database)

From Single AZ to Multi AZ:

- Zero downtime (no need to stop database)
- Just click “modify” for the database and enable multi AZ
- How it works?
    - Database snapshot is taken automatically (to s3 bucket)
    - Snapshot is restored into new standby database (in another AZ)
    - Synchronization is established between two databases
        
        ![Untitled](AWS%20RDS,%20Aurora%200abb216249724203b03bcc061ee5d936/Untitled%202.png)
        

<aside>
ℹ️ Multi-AZ helps when you plan a disaster recovery for an entire AZ going down. If you plan against an entire AWS Region going down, you should use backups and replication across AWS Regions.

</aside>

<aside>
ℹ️ A **Read Replica** in a different AWS Region than the source database can be used as a standby database and promoted to become the new production database in case of a regional disruption. So, we'll have a highly available (because of Multi-AZ) RDS DB Instance in the destination AWS Region with both read and write available.

</aside>

Amazon Aurora:

- Aurora is proprietary technology from AWS (not open sourced)
- Aurora Editions: Postgres and MySQL
- Aurora is “AWS cloud optimized” and claims 5x performance improvements over MySQL on RDS, and over 3x performance of Postgres on RDS
- Aurora storage automatically grows in increments of 10GB  up to 128TB
- Aurora can have **15 read replicas** (while other DBs has only 5) and the **replication process is faster** (<10ms replica lag)
- **Aurora is High Available by native**
- Aurora **costs more than RDS** (20% more) — but it’s more efficient.

Aurora High Availability and Read Scaling:

- Aurora has 6 copies of your database across 3 AZ:
    - 4 copies (of 6) are needed for writes (if one AZ is down it’s ok)
    - 3 copies (of 6) are needed for reads
    - Self healing process with peer-to-peer replication
    - Storage is stripped across 100s of volumes
- **One Aurora instance takes writes** (master database) + up to 15 read replicas
    - There is **one writer endpoint**
        - If master fails your clients still talks to writer endpoint and its automatically redirect to right instance
    - There are **reader endpoints** (it helps with connections load balancing)
        - reader endpoints automatically connect to all read replicas
    - Automated failover for master in less than 30 seconds
    - Any of read replica can be master if master fails
    - Supports **cross regions replication**
    - We can create **autoscaling policy** to scale reader replicas
        - e.g. based on average CPU utilization of Aurora Replica then add another read replica
        - We can also configure cluster autoscaling details (max/min cluster size)
    - In Aurora we can also **Add AWS Region** for RDS Aurora Cluster (available only with some database types)

Features of Aurora:

- Automatic fail-over
- Backup and Recovery
- Isolation and Security
- Push-button scaling
- Backtrack — restore data to any point of time without using backups

RDS / Aurora Security:

- Data is **encrypted** on the volumes
    - Database master & replicas encryption using AWS KMS — must be defined as launch time
    - If master database is not encrypted — the read replicas cannot be encrypted
    - To encrypt an unencrypted database → create DB snapshot → restore DB snapshot as encrypted database
- **In-flight encryption:** TLS-ready by default, use the AWS TLS root certified client-side
- **IAM Authentication:** IAM roles to connect to your database (instead of username/password)
- **Security Groups:** control network access to RDS/Aurora
- **No SSH access** → except on RDS custom
- **Audit Logs** can be enabled and sent to CloudWatch Logs for longer retention

🆕 RDS Proxy:

- Fully managed database proxy for RDS
- Allows apps to pool and share DB connections established with the database
- Improving database efficiency by **********************************************************************************reducing the stress on database resources********************************************************************************** (e.g. CPU, RAM) and **************************************************minimize open connections************************************************** (and timeouts)
- Serverless, autoscaling, HA
- **Reduces RDS & Aurora failover time by up 66%**
- Supports RDS (mysql, psql, mariadb, ms sql server) and aurora
- No code changes required for most apps
- ********************************Enforce IAM Authentication for DB and securely store credentials in AWS Secrets Manager********************************
- **RDS Proxy is never publicly accessible** (must be accessed from VPC)