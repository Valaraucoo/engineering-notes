# Amazon Cognito

- Cognito gIves users an identity to interact with our web or mobile applications
- Two types of subservices in Cognito
- **Cognito User Pools:**
    - Sign in functionality for app users
    - **Integrate with API GW & ALB**
- **Cognito Identity Pools (Federated Identity)**:
    - Provide AWS credentials to users so they can access AWS resources directly
    - Integrate with Cognito Users Pools as an identity provider
    

Cognito User Pools (CUP) — User Features:

- Create a serverless database of user for your web & mobile apps
- Simple login, password reset, email verification, MFA, Federated Identities (fb, ggl, etc.)
- You can block users if their credentials are compromised elsewhere
- Login sends back a ****JWT****

Integrations:

- **CUP integrates with API Gateway and Application Load Balancer**
- For production it’s better to use Amazon SES to send emails to users
- **Cognito hosts UI for authentication**
    - It can be easily integrated with your app
- **Federated Identity Providers** — Google, Facebook, Amazon, Apple, SAML, OpenID Connect

Cognito User Pools — Lambda Triggers:

- You can use Lambda function to react to things happening within your user poll and build any kind of integration you want
- CUP can invoke a Lambda function synchronously on these triggers:
    - Authentication Events
    - Sign-Up
    - Messages
    - Token Creation

Hosted Authentication UI:

- Cognito has a hosted authentication UI that you can add to your apps
- Using the hosted UI you have a foundation for integration with social logins, OIDC or SAML
- Can customize with a custom logo and custom CSS
- We can configure **Custom Domain** for hosted UI
    - you must create an ACM certificate in ************us-east-1************
- The custom domain must be defined in the “App integration” section

CUP Adaptive Authentication:

- **Block sign-ins or required MFA if the login appears suspicious**
- Cognito examines each sign-in attempt and generates a risk score
- Users are prompted for a second MFA only when risk is detected
- Risk score is based on many factors: device, location or IP Address
- Checks for compromised credentials, account takeover protection, and phone and email verification
- Integration with CW Logs

Decoding a JWT Token:

- CUP issues JWT Tokens (Base64 encoded):
    - Header
    - Payload
    - Signature
- **The signature must be verified to ensure the JWT can be trusted (and we can use payload)**
- The payload will contain the user information (UUID, name, email, phone, etc.)
- From the `sub` UUID you can retrieve all users details from Cognito / OIDC

Application Load Balancer — Authenticate Users:

- Your ALB can securely authenticate users
- Authenticate users through:
    - Identity Provider: OIDC compliant
    - Cognito User Pools: Social Identity Provider (IdP), SAML, LDAP or MS AD
- **Must use an HTTPS listener to set authenticate-oidc / authenticate-cognito-rules**
- **OnUnauthenticatedRequest** — authenticate (default), deny, allow (allow to login page)
- ALB can add additional information about user (from Cognito) to forwarded HTTP request
- Application Load Balancer can be used to securely authenticate users for accessing your applications.
    - This enables you to offload the work of authenticating users to your load balancer so that your applications can focus on their business logic.
    - You can use Cognito User Pools to authenticate users through well-known social IdPs, such as Amazon, Facebook, or Google, through the user pools supported by Amazon Cognito or through corporate identities, using SAML, LDAP, or Microsoft AD, through the user pools supported by Amazon Cognito.
- To use Cognito with ALB and CloudFront distribution:
    - **Forward requests headers** (all) — ensures that CF does not cache responses for authenticated requests
    - **Cookie forwarding** (all) — ensures that CF forwards all authentication cookies to the load balancer

<aside>
💡 **You cannot use Cognito Authentication with CloudFront distribution**.

</aside>

Cognito Identity Pools (Federated Identities):

- Get identities for “users”/”clients” so they obtain temporary AWS Credentials
- Your Identity Pool can include:
    - Public Providers (Login with Amazon, Facebook, etc.)
    - Users in an Amazon Cognito user pool
    - OpenID Connect Providers
    - Developer Authenticated Identities (custom login server)
    - Cognito Identity Pools allow for ******************unauthenticated (guest) access******************
- **********************************************Users can then access AWS Services directly or through API Gateway**********************************************
    - The IAM policies → applied to the credentials defined in Cognito
    - They can be customized based on the user_id for fine grained control
- IAM Roles:
    - We can define default IAM roles for authenticated and guest users
    - Define rules to choose the role for each user based on the user’s ID
    - You can partition your user’s access using ********************************policy variables********************************
    - IAM credentials are obtained by Cognito Identity Pools through STS
    - The roles must have a ”trust” policy of Cognito Identity Pools

Cognito User Pools vs. Cognito Identity Pools:

- Cognito User Pools:
    - Identity verifications = authentication
    - Allows to federate logins through Public Social, OIDC, SAML,..
- Cognito Identity Pools:
    - access control = authorization
    - obtain AWS credentials for your users
    - Users/guests are mapped to IAM roles & policies, can leverage policy variables
- CUP + CIP = authentication + authorization