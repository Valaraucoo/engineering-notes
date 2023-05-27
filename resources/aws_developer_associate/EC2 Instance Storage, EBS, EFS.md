# EC2: Instance Storage, EBS, EFS

### EBS Volume

- EBS (Elastic Block Store) Volume is a **network** **drive** you can attach to your instances while they run.
- It allows your instances to persist data, even after their termination.
- You can mount these volumes as devices on your instances.
- EBS volumes are particularly well-suited for use as the primary storage for file systems, databases, or for any applications that require fine granular updates and access to raw, unformatted, block-level storage.
- You create an EBS volume in a **specific** **AZ**, and then attach it to an EC2 instance in that same Availability Zone.
    - EBS Volume is bound to a specific AZ
- **EBS** **Volume** can only be mounted to **one instance** at a time.
    - However, you can use [Multi-Attach](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volumes-multi.html) to mount a volume to multiple instances at the same time.
- You can use EBS volumes as primary storage for data that requires frequent updates, such as the system drive for an instance or storage for a database application
- **Free tier**: 30 GB of free EBS storage of type General Purpose (SSD) or Magnetic per month

- EBS is a network drive (not a physical drive)
- It uses the network to communicate with the instance, which means there might be a bit of latency
- It can be detached from an EC2 instance and attached to another one quickly
- You can attach multiple EBS Volumes to one EC2 instance
- EBS Volume can be unattached to any instance
- EBS Volume is locked to an AZ
- To move a volume across AZs, you first need to create **snapshot**

Benefits:

- Data Availability — When you create an EBS volume, it is automatically replicated within its Availability Zone to prevent data loss due to failure of any single hardware component.
- Data Persistence — EBS volumes that are attached to a running instance can automatically detach from the instance with their data intact when the instance is terminated (by default) (but you can delete volume on ec2 termination).
- Data Encryption
- Snapshots — Amazon EBS provides the ability to create snapshots (backups) of any EBS volume and write a copy of the data in the volume to Amazon S3, where it is stored redundantly in multiple Availability Zones.

<aside>
💡 **EBS volumes support both in-flight encryption and encryption at rest using KMS**
Encryption operations occur on the servers that host EC2 instances, ensuring the security of both data-at-rest and data-in-transit between an instance and its attached EBS storage.

</aside>

- EBS Volumes can be deleted on terminations
- By default the root EBS volume is deleted
- By default any other attached EBS volume is not deleted

- **EBS Snapshot** — backup of EBS volume at a point of time, not necessary to detach volume to do snapshot, but it’s recommended.
    - You can back up the data on your Amazon EBS volumes to Amazon S3 by taking point-in-time snapshots.
    - Snapshots are *incremental* backups, which means that only the blocks on the device that have changed after your most recent snapshot are saved.
    - Each snapshot contains all of the information that is needed to restore your data to new EBS Volume.
- You can copy snapshots across AZ or Region
- When you create an EBS volume based on a snapshot, the new volume begins as an exact replica of the original volume that was used to create the snapshot.

![Untitled](EC2%20Instance%20Storage,%20EBS,%20EFS%207db0674d65364314923f02c72d4dd0ff/Untitled.png)

- **EBS** **Snapshot** **Archive** — move a snapshot to an “archive tier” that is 75% cheaper:
    - Amazon EBS Snapshots Archive is a new storage tier that you can use for low-cost, long-term storage of your rarely-accessed snapshots that do not need frequent or fast retrieval.
    - By default, when you create a snapshot, it is stored in the Amazon EBS **Snapshot** **Standard** **tier** (*standard tier).*
    - When you need to access an archived snapshot, you can restore it from the archive tier to the standard tier.
    - The restoring takes 24-72 hours from archive to standard tier.
- When you archive a snapshot, the incremental snapshot is **converted** to a **full snapshot**, and it is moved from the standard tier to the Amazon EBS Snapshots Archive tier (archive tier).
    - Full snapshots include all of the blocks that were written to the volume at the time when the snapshot was created.

- **Recycle Bin for EBS Snapshots** — Recycle Bin is a data recovery feature that enables you to restore accidentally deleted Amazon EBS snapshots.
    - Setup rules to retain deleted snapshot, so you can recover them after an accidental deletion.
    - If your resources are deleted, they are retained in the Recycle Bin for a time period that you specify before being permanently deleted.
    - You can restore a resource from the Recycle Bin at any time before its retention period expires.
    - If the retention **period expires** and the resource is not restored, the resource is **permanently** **deleted** from the Recycle Bin and it is no longer available for recovery.

- **Fast Snapshot Restore (FSR)** — $$$ force full initialization of snapshot to have no latency on the first use.

### AMI Overview

- AMI = Amazon Machine Image
- AMI is a customization of an EC2 instance
- AMI is a supported and maintained image provided by AWS that provides the information required to launch an instance
- An AMI includes:
    - AWS EBS snapshots of the instance OS, apps etc.
    - Launch permissions that control which AWS accounts can use the AMI to launch instances
    - A block device mapping that specifies the volumes to attach to the instance when it’s launched

![Untitled](EC2%20Instance%20Storage,%20EBS,%20EFS%207db0674d65364314923f02c72d4dd0ff/Untitled%201.png)

- AMIs are built for a **specific region** (and can be copied across regions)
- You can launch EC2 instances from:
    - Public AMIs — provided by AWS
    - Your own AMIs
    - An AWS Marketplace AMI
- How to move instance to another region?
    - Start an EC2 instance and customize it
    - Stop the instance (for data integrity)
    - Build an AMI - create EBS snapshot
    - Launch instances in other region

![Untitled](EC2%20Instance%20Storage,%20EBS,%20EFS%207db0674d65364314923f02c72d4dd0ff/Untitled%202.png)

### EC2 Instance Store

- EBS Volumes are **network drives** with good but “limited” performance
- **If you need a high-performance hardware disk, use EC2 Instance Store**
    - EC2 Instance is a virtual machine, and it’s attached to a real hardware server
    - An *instance store* provides **temporary** block-level storage for your instance
    - Instance store is ideal for **temporary** **storage** of information that changes frequently
- EC2 Instance Store is located on disks that are physically attached to the host computer
    - The size of an instance store as well as the number of devices available varies by instance type.

![Untitled](EC2%20Instance%20Storage,%20EBS,%20EFS%207db0674d65364314923f02c72d4dd0ff/Untitled%203.png)

- **EC2 Instance Store lose their storage if they’re stopped. (ephemeral storage)**
- Good for buffer / cache / scratch data / temporary content.
- Risk of data loss if hardware fails.
- **Backups and Replications are your responsibility.**

### EBS Volume Types

- `gp2 / gp3` (SSD) — general purpose SSD volume that balances price and performance for a wide variety of workloads
- `io1 / io2` (SSD) — highest-performance SSD volume for mission-critical low-latency or high-throughput workloads
- `st1` (HDD) — low cost HDD volume designed for frequently accessed, throughput-intensive workloads
- `sc1` (HDD) — lowest cost HDD volume designed for less frequently accessed workloads

- EBS Volumes are characterized in Size / Throughput / IOPS

General Purpose SSD (gp):

- Can be boot volume!
- Cost-effective storage, low-latency
- Development and test envs
- 1 - 16 GB Size
- gp3: newer with better performance, can independently set the IOPS
- gp2: size of the volume and IOPS are linked, max IOPS is 16k

Provisioned IOPS SSD (io):

- Can be boot volume!
- Critical business applications
- Apps that need more than 16k IOPS
- Great for databases workloads (sensitive to storage performance and consistency)
- io 1:
    - Size: 4 GB - 16 TB
    - Max IOPS: 64k for Nitro EC2 Instances
- io2 have more durability and more IOPS per GB at the same price as io1
- io2:
    - Size: 4 GB - 64 TB
    - Max IOPS: 256k
- Supports EBS Multi Attach

Hard Disk Drives (HDD):

- Cannot be a boot volume
- Size: 125 MB - 16 TB
- Throughput optimized HDD (st1):
    - Apps: big data, data warehousing, log processing
    - Max IOPS: 500
- Cold HDD (sc1):
    - Apps: for data that is infrequently accessed
    - Scenarios where lowest cost is important
    - Max IOPS: 250

<aside>
ℹ️ When **creating EC2** instances, you can only use the following EBS volume types as boot volumes: **gp2, gp3, io1, io2**, and Magnetic (Standard).

</aside>

### EBS Multi-Attach (io1/io2)

- Attach the same EBS Volume to multiple EC2 instances in **the same AZ**
- EBS Multi-Attach enables you to attach a single Provisioned IOPS SSD (**io1** or **io2**) volume to multiple EC2 instances that are in the same AZ
    - You can attach multiple Multi-Attach enabled volumes to an instance or set of instances
- Each instance to which the volume is attached has full **read and write permission** to the high-performance volume
- Use Case:
    - Multi-Attach makes it easier for you to achieve **higher application availability** in clustered applications
    - Application must manage concurrent write operations
- **Up to 16 EC2 Instances at a time**
- Must use a file system that’s cluster-aware (not XFS, EX4, etc.)

### AWS EFS — Elastic File System

- Amazon EFS provides scalable file storage for use with Amazon EC2
- You can use an EFS file system as a common data source for workloads and applications running on multiple instances
- EFS is managed NFS (network file system) that can be mounted on many EC2s
- EFS works with EC2 instances in **multi-AZ**
- Highly available, scalable, but expensive (3x cost of gp2)
- Use cases: content management, web serving, data sharing
- Uses **security group** to control access to EFS
- **Compatible with Linux based AMIs (not Windows)**
- Encryption at rest using KMS

Performance:

- EFS Scale:
    - 1000s of concurrent NFS clients, 10 GB+ /s throughput
    - Grow to Petabyte-scale network file system automatically
- Performance mode (set at EFS creation time):
    - General Purpose (default)
    - Max I/O — higher latency, etc. for big data, media processing
- Throughput mode:
    - Bursting — throughput scales with file system size
    - Provisioned: set you throughput regardless of storage size, ex: 1 GB for 1TB; throughput is fixed at specified amount

Storage Classes:

- Storage Tiers:
    - Standard: for frequently accessed files
    - Infrequent access (EFS-IA)
- Availability and durability:
    - Standard: Multi A-Z
- One Zone EFS: great for dev

### EFS vs EBS

- EBS Volumes:
    - Can be attached to only one instance at a time
    - Are locked at the AZ level
    - To migrate an EBS volume across AZ: take snapshot, restore the snapshot to another AZ
    - Root EBS Volume of instances get terminated by default if the EC2 instance gets terminated
- EFS:
    - Mounting 100s of instances across AZ
    - EFS share files
    - Only for Linux Instances (POSIX) — not works for Windows
    - EFS has a higher prices
    - Can leverage EFS-IA for cost saving