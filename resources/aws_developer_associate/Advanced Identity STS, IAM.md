# Advanced Identity: STS, IAM

AWS STS:

- Security Token Service
- Allows to grant limited and temporary access to AWS resources (up to 1 hour)
- AWS STS (Security Token Service) allows you to get cross-account access through the creation of an IAM Role in your AWS account authorized to assume an IAM Role in another AWS account.
- **AssumeRole**: assume roles within your account or cross account
- **AssumeRoleWithSAML**: return credentials for users logged with SAML
- **AssumeRoleWithWebIdentity**: return creds for users logged with an IdP (Facebook, Google, etc.)
    - AWS recommends against using this → Cognito
- **GetSessionToken**: for MFA, from a user of AWS account root user
- GetFederationToken
- **GetCallerIdentity**: return details about the IAM user or role used in the API call
- **DecodeAuthorizationMessage**: decode error message when an AWS API is denied

Using STS to Assume a Role:

- Define an IAM Role within your account
- Define which principals can access this IAM Role
- Use AWS STS to retrieve credentials and impersonate the IAM Role you have access to (****************************AssumeRole API****************************)
- Temporary credentials can be valid between 15 minutes to 1 hour

STS with MFA:

- Use ******************************GetSessionToken****************************** from STS
- Appropriate IAM policy using IAM Conditions:
    - **************************************************************aws:MultiFactorAuthPresent:true**************************************************************
- GetSessionToken returns:
    - Access ID
    - Secret Key
    - Session Token
    - Expiration date

Advanced IAM — Authorization Model Evaluation of Policies:

- If there is an explicit DENY → end decision and DENY (higher priority)
- If there is an explicit ALLOW → end decision and ALLOW
- Else DENY

IAM Policies & S3 Bucket Policies:

- IAM Policies are attached to users, roles and groups
- S3 Bucket Policies are attached to **buckets**
- When evaluating if an IAM Principal can perform an operation X on a bucket, the **********union********** of its assigned IAM POlicies and S3 Bucket Policies will be evaluated

Dynamic Policies with IAM:

- How do you assign each user a `/home/<user>` folder in an S3 Bucket?
- Option 1: Create an IAM policy allowing `george` to have access to `/home/george`
    - …One policy per user!
- Option 2: Create one dynamic policy with IAM
    - Leverage the special policy variable `${aws:username}`
    
    ```json
    {
    	...
    	"Effect": "Allow",
    	"Resource": ["arn:aws:s3::::xyz/home/${aws:username}/*"]
    }
    ```
    

Inline vs. Managed Policies:

- AWS Managed Policies
    - Maintained by AWS
    - Good for power users and administrators
    - Updated in case of new services / new APIs by AWS
- Customer Managed Policies
    - Best Practice: re-usable, can be applied to many principals
    - Version Controlled: rollbacks, central change management
    - Managed policies allow you to manage permissions in a more modular and reusable way
- Inline:
    - Strict one-to-one relationship between policy and principal
    - An inline policy is a policy that's directly attached to a single IAM user, group, or role
    - It is typically used for a unique set of permissions that you don't plan to reuse for other entities
    - If you delete an IAM user, group, or role, all inline policies embedded in the entity are also deleted
    - Inline policies can't be versioned or shared between different IAM entities
- In summary, while inline policies can be useful for one-off, unique permission requirements, managed policies provide more flexibility and control for managing permissions at scale, especially when you have a large number of users or complex permissions to manage.
- You can also maintain different versions of managed policies and apply them to multiple IAM entities, which isn't possible with inline policies.
    
    

**Granting a User Permissions to Pass a Role to an AWS Service**:

- To configure many AWS services, you must **pass** an IAM role to the service
    - This happens only once during service setup
- The service will later assume the role and perform actions
- For this, you need the IAM permission `iam:PassRole`
- It often comes with `iam:GetRole` to view the role being passed

Can a role be passed to any service?

- No → roles can only be passed to what their **********trust********** allows
- A **trust policy** for the role → allows the service to assume the role
    - Trust policies are a type of policy that allows an entity (like a user, group, or AWS service) to assume a role.

Explanation:

- A role in IAM is an AWS identity with permission policies that determine what the identity can and cannot do in AWS.
- Unlike a user, a role does not have long-term credentials such as a password or access keys.
- Instead, if a user needs to make a request on behalf of the role, they can assume the role by using AWS STS to request temporary security credentials.
- The **`AssumeRole`** operation returns a set of temporary security credentials that you can use to access AWS resources that you might not normally have access to.
    - These temporary credentials consist of an access key ID, a secret access key, and a security token.
- Now, coming back to trust policies, these are attached to the IAM roles and define which entities are allowed to assume the role.
    - In other words, a trust policy specifies who can assume the role. It's written in JSON format, like other IAM policies.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT-ID-WITHOUT-HYPHENS:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
```

What is Microsoft Active Directory (AD)?

- Found on any Windows Server with AD Domain Services
- Database of **************objects************** → user accounts, computers, printers, file shares, SGs
- Centralized security management
- Objects are organized in **trees**
- A group of trees is a forest

AWS Directory Services:

- AWS Managed Microsoft AD
    - Create your own AD in AWS, manage users locally, supports MFA
    - Establish “trust” connection with you on-premise AD
- AD Connector
    - Directory Gateway (**proxy**) to redirect to on-premise AD, supports MFA
    - Users are managed on the on-premise AD
- Simple AD
    - **AD-compatible managed directory on AWS**
    - Cannot be joined with on-premise AD