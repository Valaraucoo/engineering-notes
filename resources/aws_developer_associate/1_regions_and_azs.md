# Global infrastructure: Regions, AZs

**AWS Regions:**

- AWS has regions all around the world, names can be `eu-west-1`, `us-east-1` etc.
- Each region is a separate geographic area
- A **region** is a cluster of data centers (one data center is Availability Zone)
- Each Region is designed to be isolated from the other Regions:
    - Most AWS services are **region-scoped** — if you use service in one region and we try to use it in another region it will be like a new time of using the service
    - This achieves the greatest possible fault tolerance and stability
    - AWS doesn’t automatically replicate resources across Regions

**AWS Availability Zones (AZ):**

- Each AWS Region has many, isolated availability zones, e.g. `eu-west-1a` and `eu-west-1b`
- AZ is isolated location in specified Region
- Each AZ is one or more discrete data centers with separated redundant power, networking, connectivity etc.
- Each AZs are separate from each other, so that they are isolated from disasters
- AZs are connected with each other with high bandwidth, ultra-low latency networking
- AZs are physically separated by a meaningful distance, many kilometers, from any other AZ, although all are within 100 km (60 miles) of each other.
- If you distribute your instances across multiple Availability Zones and one instance fails, you can design your application so that an instance in another Availability Zone can handle requests.
- By launching your instances in separate Availability Zones, you can protect your applications from the failure of a single location.

**Local Zones:**

- A Local Zone is an extension of an AWS Region in geographic proximity to your users
- Local Zones have their own connections to the internet

**AWS Points of Presence / Edge Locations:**

- AWS has +200 Points of Presence across the world
- Edge Locations are delivering content to end users with lower latency

<aside>
⚠️ **AWS has Global Services:** IAM, Route 53, CloudFront, WAF (Web apps firewall)
Most of AWS services are **region-scoped,** e.g. EC2, Lambda.

</aside>
