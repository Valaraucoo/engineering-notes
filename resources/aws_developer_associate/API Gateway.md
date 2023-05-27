# API Gateway

- Lambda + API GW = no infrastructure to manage
- Support for the WebSocket Protocol
- Handle API versioning
- Handle multiple envs
- Handle security (Authentication and Authorization)
- Create API keys, handle request throttling
- Swagger / Open API  support
- Transform and validate requests and responses
- Cache API responses

Integrations:

- Lambdas
    - Invoke Lambdas
    - Easy way to expose APIs backend by Lambda
- HTTP
    - Expose HTTP endpoints in the backend
    - Internal HTTP API on premise, Application Load Balancer etc.
- AWS Service:
    - Expose any AWS API through the API Gateway, e.g. SQS

Endpoint Types:

- **Edge-Optimized** (default): For global Clients
    - Requests are routed through the CloudFront Edge locations (improves latency)
    - The API Gateway still lives in only one region
- ****************Regional****************:
    - For clients within the same region
    - Could manually combine with CloudFront
- **************Private**************:
    - Can only be accessed from your VPC

API Gateway — Security:

- User Authentication through:
    - IAM Roles (internal apps)
    - Cognito (external users, e.g. mobile users)
    - Custom Authorizer (own logic)
- Custom Domain Name HTTPS security through AWS ACM

Deployment Stages:

- You need to make a “deployment” for changes in API Gateway to be effective
- Changes are deployed to “Stages”
    - Use the naming you like for stages (dev, test, prod)
- Each stage has its own configuration
- Stages can be rolled back as a history of deployments is kept

Stage Variables:

- Stage variables are like env vars for API GW
- Use them to change often changing config values instead of redeploying API
- They can be used in: Lambda function ARN, HTTP Endpoint, Parameter mapping templates
- Stage variables are passed to the “context” object in AWS Lambda
- Format: `${stageVariables.variableName}`
- Stage variables are name-value pairs that you can define as configuration attributes associated with a deployment stage of an API.
    - They act like environment variables and can be used in your API setup and mapping templates.
    - With deployment stages in API Gateway, you can manage multiple release stages for each API, such as alpha, beta, and production.
    - Using stage variables you can configure an API deployment stage to interact with different backend endpoints.
- For example, your API can pass a GET request as an HTTP proxy to the backend web host (for example, [http://example.com](http://example.com/)).
    - In this case, the backend web host is configured in a stage variable so that when developers call your production endpoint, API Gateway calls [example.com](http://example.com/).
    - When you call your beta endpoint, API Gateway uses the value configured in the stage variable for the beta stage and calls a different web host (for example, [beta.example.com](http://beta.example.com/)).

Use Case:

- We create a stage variable to indicate the corresponding Lambda alias
- API GW will automatically invoke the right Lambda

Canary Deployment:

- Possibility to enable canary deployments for any stage
- Chose the % of traffic the canary channel receives
- Metrics & Logs are separate
- This is blue / green deployment with Lambda & API GW

Integration Types:

- **MOCK** — API GW returns response without sending the request to the backend
- **HTTP / AWS (Lambda & Services)** — you must configure both the integration request and response
    - Setup data mapping using **********************************mapping templates********************************** for the request and response
    - Here API Gateway has the power to change the request and the response
- **AWS_PROXY (Lambda Proxy)**:
    - incoming request from the client is the input to Lambda
    - the function is fully responsible for the logic of request / response
    - **No mapping templates, No headers, No query strings** → passed as arguments to the function directly
    
    ```json
    // Example lambda function response
    {
    	"isBase64Encoded": true,
    	"statusCode": 200,
    	"headers": {"headerName": "value"},
    	"multiValueHeaders": {"headerName": ["values"]}
    	"body": "..."
    }
    ```
    
    - API GW works only as a proxy here
- **HTTP_PROXY**:
    - No mapping template
    - The HTTP request is passed to the backend (e.g. Application Load Balancer)
    - The HTTP response from the backend is forwarded by API GW
    - Possibility to add HTTP Headers if need be
    

Mapping Templates:

- Modify request / response
- **Rename / Modify query string parameters**
- Modify **body content**
- Add **headers**
- Filter output results (remove unnecessary data)
- Content-Type can be set to **application/json** or ******************************application/xml******************************
- Mapping template overrides provides you with the flexibility to perform many-to-one parameter mappings;
    - override parameters after standard API Gateway mappings have been applied;
    - conditionally map parameters based on body content or other parameter values;
    - programmatically create new parameters on the fly, and override status codes returned by your integration endpoint.
- JSON to XML with SOAP:
    - API GW + Mapping Template can transform JSON payload into an XML document
    - API HW extract data from the request and build SOAP messaged based on request data
- Mapping Query String parameters:
    - API GW takes query parameters into JSON object and can map them into anything you want
    

Open API spec:

- API GW can import OpenAPI 3.0 spec and setup every single option
- Can export current API as OpenAPI spec
- Can generate SDK for applications

Rest API — Request Validation:

- You can configure API GW to perform basic validation of an API request before proceeding with the integration request
    - When the validation fails, API GW immediately fails the request
    - Returns a 400-error response to the caller
- This reduces unnecessary calls to the backend
- Checks:
    - The required request parameters in the URI, query string, and headers of an incoming request are included and non-blank
    - The applicable request payload adheres to the configured  JSON Schema request model of the method

Caching responses:

- Default TTL is 300 seconds (min 0, max 3600s)
- **Caches are defined per stage**
- Possible to override cache settings **per method**
- Cache encryption option
- Cache capacity between 0.5GB to 237GB
- Cache is expensive → makes sense in production

Cache invalidation:

- **Able to flush the entire cache**
- Clients can invalidate the cache with header:
    - `Cache-Control: max-age=0` (with proper IAM authorization)
- If you don’t impose an **InvalidateCache** policy, any client can invalidate the API cache

API GW Usage Plans & API Keys:

- Usage Plan:
    - who can access one or more deployed API stages and methods
    - how much and how fast they can access them
    - uses API keys to identify API clients and meter access
    - configure throttling limits and quota limits (e.g. how many requests per month) that are enforced on individual clients
- API Keys:
    - alphanumeric string values to distribute yo your customers
    - can use with usage plans to control access
    - throttling limits are applied to the API Keys
    - quota limits is the overall number of maximum requests
- To configure a usage plan:
    - Create one or more APIs, configure the methods to require an API key, and deploy the APIs to stages
    - Generate or import API keys to distribute to application developers/customers who will be using you APIs
    - Create the usage plan with the desired throttle and quota limits
    - **Associate API stages and API keys with the usage plan**
    - Callers of the API must supply an assigned API key in the `x-api-key` header in requests to the API
    

API GW Monitoring — Logging & Tracing:

- CloudWatch Logs:
    - Logs request/response body
    - Enable CW logging at the stage level (ERROR, DEBUG, INFO)
    - Can override settings on a per API basis
- X-Ray:
    - Enable tracing to get extra information about requests in API GW
    - X-Ray API GW + Lambda gives you the full picture

Metrics:

- Metrics are by stage, possibility to enable detailed metrics
- **CacheHitCount** & **CacheMissCount** → efficiency of the cache
- **Count** → total number of API requests
- **IntegrationLAtency**
- **Latency** → time between receive a request from client and response to the client (total latency) → max latency is **29 seconds (max timeout)**
- **4XXError**
- **5XXError**

Throttling:

- **Account Limit** → num of 429 Too Many Requests
    - API GW throttles requests at 10k req/sec across all APIs
    - limits can be increased upon request
    - Can set **********************Stage limit********************** and **************************Method limits************************** to improve performance
    - or you can define **********************Usage Plans********************** to throttle per customer

<aside>
💡 Just like Lambda Concurrency, one API that is overloaded, if not limited, **can cause the other APIs to be throttled**.

</aside>

API GW Errors:

- 4XX:
    - 400 → Bad Request
    - 403 → Access Denied
    - 429 → quota exceeded → throttle
- 5XX:
    - 502 → Bad Gateway, backend is overloaded, incompatible output returned
    - 503 → service outage
    - 504 → integration failure → e.g. timeout
    

CORS:

- CORS must be enabled when you receive API calls from another domain
- The OPTIONS pre-flight request must contain:
    - `Access-Control-Allow-*` headers
- Resources → Actions → Enable CORS → Deploy to stage
- If lambda-proxy → add CORS headers to response

IAM Permissions:

- Create an IAM policy authorization and attach to User/Role
- Authentication = IAM & Authorization = IAM Policy
- Great for users / roles already within your AWS account + resource policy for cross account
- Leverages “Sig v4” headers
- Resource Policies:
    - Resource Policies are similar to Lambda Resource Policies
    - **Allow for Cross Account access**
    - Allow for a specific source IP address
    - Allow for a VPC Endpoint

Cognito User Pools:

- Cognito fully manages user lifecycle
- API gateway verifies identity automatically from AWS Cognito
- No custom implementation required
- Must implement authorization in the backend

Lambda Authorizer (Custom Authorizer):

- Token-based authorizer (bearer token)
- A **request parameter-based** → headers, query string, stage var
- Lambda must return an **IAM policy for the user**, result policy is cached
- Great for 3rd party token
- Flexible in terms of what IAM policy is returned

<aside>
💡 **HTTP APIs are much cheaper then REST APIs (REST supports resource policies)**

</aside>

WebSocket API:

- Connecting to the API → `onConnect` + `connectionId`
    - `connectionID` is re-used
- In next connection client uses same `connectionId` and invokes lambda function

Server to Client Messaging:

- API GW has **connection URL callback:**
    - POST (sends a message), GET (get the latest connection status), DELETE (disconnect)

WS Routing:

- Incoming JSON messages are routed to different backend → API Gateway has route key table
- If no routes → sent to $default
- You request a ****************************************************route selection expression**************************************************** to select the field on JSON to route from