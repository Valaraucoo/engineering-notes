## 🐋 Docker and Kubernetes: The Complete Guide

[🔙 Home Page](https://github.com/Valaraucoo/engineering-notes/)

| Title         | Docker and Kubernetes: The Complete Guide                                                                         |
|---------------|-------------------------------------------------------------------------------------------------------------------|
| Source        | [Udemy](https://www.udemy.com/course/docker-and-kubernetes-the-complete-guide/)                                   |
| Author        | [Stephen Grider](https://www.udemy.com/user/sgslo/)                                                               |
| What to learn | `Docker` `Kubernetes` `AWS`                                                                                       |
| Scope/Topic   | `Software Architecture`                                                                                           |
| Description   | Build, test, and deploy Docker applications with Kubernetes while learning production-style development workflows |
| Status        | `In progress`                                                                                                     |
| Last update   | 01.05.2022                                                                                                        |

### Notes

Docker command cheat sheet:
```shell
# run containers
docker run <image name>
docker run --rm <image name> # delete container after run
docker run --detach <container id> # run in background

# retrieve container from background
docker attach <container id>

# create a container
docker create <image name>

# start a container
docker start <image name>

# list containers
docker ps 
docker ps --all
docker container ls
docker container ls --all

# list images
docker images
docker image ls

# running/restarting stopped containers
docker start -a <container id> # id from docker ps

# removing stopped containers
docker system prune # delete any containers, networks, cache etc.

# get logs from containers
docker logs <container id>

# stop containers
docker stop <container id>
docker kill <container id>

# executing commands in running containers
docker exec -it <container id> <command>

# build image from Dockerfile
docker build -t <docker id>/<project name>:<version (latest)> <build context dir>

# port exposing
docker run -p <localhost port>:<container port> <image>

# volumes
docker run -v <local machine path>:<container path>
docker run -v $(pwd):/app
```

### 📦Container Lifecycle

- Creating and running container: `docker run <image name>`
    - `docker run = docker create + docker start`
- Creating a container prepare file system snapshot to be use to create container
    - `docker create <image name>` → returns container id
    - `docker create` → prepare container by getting file system ready
- Starting a container execute a startup command, example: `echo hi there`
    - `docker start -a <container id`> → starts container created above
        - `-a` → Attach STDOUT/STDERR and forward signals
    - `docker start <container id>` → start one or more stopped containers (without logs)
        - It runs container in the background (you cant see any output) → `docker logs`
- While container is **stopped** (status `Exited`) you can restart container again in the future using its id: `docker start -a <container id>` (id from `docker ps`)
    - Container is still ready to start in file system (it’s already created), **but you cannot run this container with other startup command**
- You can remove stopped containers:
    - `docker system prune` → removes everything
- Get logs from container:
    - `docker logs <container id>` → returns logs from started container
- Stopping containers:
    - Running container has the main process (`PID=1`), which can be killed → then container is stopped/exited
    - `docker stop <container id>` → sends `SIGTERM` signal to running process in the container
        - If docker cannot stop container in 10 second it runs `docker kill` command
    - `docker kill <container id>` → sends `SIGKILL` signal to running process in the container
        - It stops container right now without any additional work (example clean up)
- Executing commands in running containers:
    - `docker exec -it <container id> <command>`
    - `-i` / `--interactive`→ interactive, Keep `STDIN` open even if not attached
    - `-t` / `--tty`→ Allocate a pseudo-TTY
    - Example: `docker exec -it <container id> sh` → opens container’s shell
- Starting container with shell:
    - `docker run -it <image name> sh` → runs container and open its shell

### 🛠️ Creating & build Docker images

- `Dockerfile` → configuration to define how our container should behave

```docker
# Use an existing docker image as a base'
# FROM specify what image you want to use as a base
FROM alpine

# Download and install dependencies
RUN apk add --update redis

# Tell the image what to do when it starts as a container
CMD ["redis-server"]
```

- Build `Dockerfile`: `docker build .`
- What’s a *base* image?
    - Operating System (OS) with initial set of programs and dependencies
    - `alpine` — initial OS, alpine has preinstalled set of programs that are useful

- Build procress details:
    - Step 1:
        - Download `alpine` image
    - Step 2: `RUN`
        - Get image from Step 1 (`alpine`)
        - Before `RUN` → creates temporary container from base `alpine` image
        - Then run `apk add --update redis` in temporary container → Container with modified File System
        - After executing command, temporary container is stopped
    - Step 3: `CMD`
        - Before `CMD` we look at the image created in Step 2 (temp. container) and make FS snapshot
        - Remove temporary container from Step 2
        - Run `CMD` → create new (final) container

- Tagging an Image:
    - After `Dockerfile` build we receive: `Successfully built <image id>`
        - We can: `docker run <image id>`
    - Better solution is to use `tag` to run built image
    - `docker build -t <docker id>/<project name>:<version (latest)> .`
        - example: `docker build -t byku/test:latest .`
    - Then you can create container from this image using specified tag
    
- Build context — directory containing Dockefile
    - We can copy files from build context into container

- Containers has its **own isolated set of ports** that can receive traffic
    - You can forward **incoming** traffic from [localhost](http://localhost) into container
    - Containers by default can reach out the outcoming traffic
    - Port mapping: `docker run -p <localhost port>:<container port> <image>`
        - Example: `docker run -p 8080:8080 web`
    - or using `EXPOSE` in `Dockerfile`
    
- Containers restart policies:
    - Exit status codes:
        - 0 - we exited and everything is OK
        - 1, 2, 3, etc - we exited because something went wrong
    - Policies (for `docker-compose`):
        - `no` — do not attempt to restart container if it stops or crashes
        - `always` — if container stops (for any reason) always attempt to restart it
        - `on-failure` — only restart if the container stops with an error code
        - `unless-stopped` — always restart unless we forcibly stop it
    
- Volumes — references from docker to local machine:
    - `docker run -v $(pwd):/app`
    - `-v` — Bind mount a volume
    - Binding volumes to `node_modules` allows you to “cache” installed modules
        - `docker run -v /app/node_modules` — without `:` means that we want to the `/app/node_modules` will be a placeholder into container
    - `docker run -v /doesnt/exist:/foo -w /foo -i -t ubuntu bash`
        - When the host directory of a bind-mounted volume doesn’t exist, Docker will automatically create this directory on the host for you.
    - Shortcut with `docker-compose`:

```yaml
version: '3'
services:
	web:
		build:
			context: .
			dockerfile: Dockerfile.dev  
		ports:
			- "3000:3000"
		volumes:
			- /app/node_modules
			- .:/app
```

### 🧊 Kubernetes

**Kubernetes** is a portable, extensible, open source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation

- Cluster = Nodes + Master
- Nodes = VM or Physical Computer that contains one or more container
- Master = Master Node that controls what each Node does

 
**Minikube** — CLI to create K8S cluster on local machine.
- **Minikube** allows you to create Node (VM) on your local machine — it’s used for managing VM/Nodes and run some containers
    - Minikube is used just to create and run K8S cluster on your local machine
    - Minikube is used on in your local environment
- **Kubectl** allows you to interact with containers in Nodes
    - Kubectl is used both locally and production
    
**Pod** —  contains one or more containers inside of it; Pod is the smallest deployable entity in Kubernetes; In Pods we are grouping together containers that are very tightly coupled and must be executed with each other.
- Pod — group of coupled containers
- Pods are the smallest thing that we can deploy.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  labels:
    component: web
spec:
  containers:
    - name: app
      image: valarauco/app
      ports:
        - containerPort: 8000
```

**Services** — is used to expose an application running on a set of [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
 as a network service
- Kubernetes gives Pods their own IP addresses and a single DNS name for a set of Pods, and can load-balance across them.

**NodePort** — shouldn’t be used in production


`kube-proxy` is Kubernetes’ (one, single) gateway to outside world
- Any time when request comes to the node it will be flow through the proxy

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-node-port
spec:
  type: NodePort
  ports:                <-- we can map many ports to target object
    - port: 8050        <-- it's a port that could be accessed by other pod (in same app)
      targetPort: 8000  <-- any incoming traffic will be sent to this port (container's port)
      nodePort: 31515   <-- it's port for outside world (30000-32767)
  selector:
    component: web      <-- indicates web pod - "I need send traffic to web pod"
                            label-selector system is used to query specified pod
```

- Feed a config file to Kubectl: `kubectl apply -f <filename>`
    - `apply` — change the current configuration of our cluster
- Print the status of all running pods: `kubectl get pods`
    - You can specify the object types that we want to get information about
- Get detailed info about an object: `kubectl describe <object type> <object name>`

### 🏭 Deployments

**Deployment** — kubernetes object is used to maintain set of **identical** pods
- Deployment ensure that pods have the correct config and that the right number exists
- Managing pods
- Example:
```yaml
apiVersion: apps/v1
kind: Deployment           <- New object type
metadata:
  name: app-deployment
spec:
  replicas: 2              <- num of (identical) pods created by deployment
  selector:
    matchLabels:
      component: web      
  template:
    metadata:
      labels:
        component: web
    spec:                   <- same as pod config
      containers:
        - name: web
          image: valarauco/app
          ports:
            - containerPort: 3000
```

### 🏛️ Services:
- [What's the difference between ClusterIP, NodePort and LoadBalancer service types in Kubernetes?](https://stackoverflow.com/questions/41509439/whats-the-difference-between-clusterip-nodeport-and-loadbalancer-service-types)
- **Cluster IP Service** — Services are reachable by pods/services in the Cluster
    - Expose service through k8s cluster
    - Service is not reachable from internal network (e.g. you can’t reach service via http client using `ip:port`)
    
    ```yaml
    # other object in cluster ---> (port) Cluster IP -> Pod(s)
    
    apiVersion: v1
    kind: Service
    metadata:
        name: server-cluster-ip-service
    spec:
        type: ClusterIP
        selector:
            component: server
        ports:
            - port: 5000
                targetPort: 5000
    ```
- **Load Balancer Service** — [Deprecated] Service object, legacy way of getting network traffic into a cluster
  - Exposes only **one set of Pods** (cannot expose multiple set of Pods for outsite network)
- **Ingres Service** — exposes a set of services (multiple set of Pods) to the outside world (newer load balancer)
    - Nginx Ingress — is a specific implementation of k8s’ Ingress Service
    - Ingress config contains routing/route balancing rules
        - For GCP deprecated Load Balancer is still in use
        - We should add DEFAULT BACKEND POD with health check for Ingress

### 💾 Volumes in K8s
- **Volume in container terminology** — some type of mechanism that allows a container to access a **filesystem** outside itself
- **Volume in K8s** — an **object** that allows a container to store data **at the Pod level**

    - Types: `Volume`, `Persistent Volume`, `Persistent Volume Claim`
    - `Volume` — we don’t want this for data that need to last:
        - Volumes is tied to the Pod, if the Pod itself ever dies, the volume dies and goes away as well
        - Volume in k8s will survive **container restarts** inside of the Pod
    - `Persistent Volume` (PV) — we are creating some type of long term durable storage that is not tied to any specific pod or any specific container
        - `Persistent Volume` is outside of the Pod and it’s sperated
        - If container/pod crashes/recreated/restarted the new container/pod will be able to connect that persistent volume
    - `Persistent Volume Claim`  (PVC) — PVC is **a request for storage by a user**
        - PVC is **not an actual instance of storage**
        - PVC is created dynamically when user ask for it
        - PVC is an “advertisement for options” you can ask for in your pod config
        - PVC can request specific size and access modes
        - IF you attach PVC to Pod, K8s must find an instance of storage (like a slice on your hard drive) that meets your requirements
    
    ```yaml
    # db-persistent-volume-claim.yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
    	name: db-pvc
    spec:
    	accessModes:
    		- ReadWriteOnce             -> Can be used by a **single node**
    	resources:
    		requests:
    			storage: 2Gi
    ```
    
- **Volume Access Modes:**
    - `ReadWriteOnce` — can be used (read, write) by a **single node**
    - `ReadOnlyMany` — can be **read** by **multiple nodes**
    - `ReadWriteMany` — can be used (read, write) by a **multiple node**

- **Where does k8s allocate persistent volumes?**

- Attach PVC to Pod template

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      component: postgres
  template:
    metadata:
      labels:
        component: postgres
    spec:
			volumes:
				- name: postgres-storage
					persistentVolumeClaim:
						claimName: db-pvc***
      containers:
        - name: postgres
          image: postgres
          ports:
            - containerPort: 5432
					volumeMounts:
						- name: postgres-storage
							mountPath: /var/lib/postgresql/data     -> where container stores data
							subPath: postgres                       -> data from mountPath will
																												 be stored in 'postgres' directory
																												 in PVC***
```

- Environment Variables and secrets:
```yaml
...
      containers:
        - name: postgres
          image: postgres
          ports:
            - containerPort: 5432
					volumeMounts:
						- name: postgres-storage
							mountPath: /var/lib/postgresql/data
							subPath: postgres
					env:
						- name: PGUSER
							value: postgres
						- name: PGPASSWORD              -> value from secrets					
							valueFrom:
								secretKeyRef:
									name: pgpassword
									key: PGPASSWORD									 
```
    
- Secrets is an k8s object that contains a small amount of sensitive data such as a password, a token, or a key.
    
    ```bash
    kubectl create secret generic <secretName> --from-literal key=value
    ```