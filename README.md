# Solution to the assignment problem

*******************************************************************************************

## **Phase 1: Creating basic infrastructure**

1. Created Amazon EKS cluster for deployment testing and automation

2. Create nodegroup with 2 nodes

3. Updated local kubectl with the cluster kubeconfig using the command

  aws eks --region us-east-2 update-kubeconfig --name eksassigncluster

4. Connected to the cluster and verified

```
kubectl get nodes
NAME                                         STATUS   ROLES    AGE   VERSION
ip-172-31-44-62.us-east-2.compute.internal   Ready    <none>   59m   v1.21.2-eks-c1718fb
ip-172-31-8-215.us-east-2.compute.internal   Ready    <none>   59m   v1.21.2-eks-c1718fb

```

5. Installed all basic softwares on my centralized EC2 instance like git, docker, kubectl and also configured AWS CLI using credentials.

************************************************************************************************


## **Phase 2: Testing the WebServer on local machine**

1. Create httpserver.py 

2. Opened Port 80 on security group to check the webserver directly

3. Checked the url on http://52.14.168.229/ 

4. Verified the logs on Python http server

```
python3 httpserver.py
103.208.71.93 - - [31/Aug/2021 13:51:18] "GET / HTTP/1.1" 200 -
103.208.71.93 - - [31/Aug/2021 13:51:19] "GET /favicon.ico HTTP/1.1" 200 -

``` 

************************************************************************************************

## **Phase 3: Creating the custom image for Http Server**

1. Created the Dockerfile code for containerizing 

```
[root@ip-172-31-21-28 pythonwebserver]# cat Dockerfile
FROM python:3
WORKDIR /usr/src/app
COPY httpserver.py .
CMD [ "python3", "./httpserver.py" ]

```

2. docker build -t pythonhttpserver .

```
docker build -t pythonhttpserver .
Sending build context to Docker daemon  3.584kB
Step 1/4 : FROM python:3
3: Pulling from library/python
4c25b3090c26: Pull complete
1acf565088aa: Pull complete
b95c0dd0dc0d: Pull complete
5cf06daf6561: Pull complete
942374d5c114: Pull complete
64c0f10e4cfa: Pull complete
76571888410b: Pull complete
5e88ca15437b: Pull complete
0ab5ec771994: Pull complete
Digest: sha256:2bd64896cf4ff75bf91a513358457ed09d890715d9aa6bb602323aedbee84d14
Status: Downloaded newer image for python:3
 ---> 1e76b28bfd4e
Step 2/4 : WORKDIR /usr/src/app
 ---> Running in fdf25c39b5a1
Removing intermediate container fdf25c39b5a1
 ---> fc31c73b0948
Step 3/4 : COPY httpserver.py .
 ---> ccb855961e2b
Step 4/4 : CMD [ "python3", "./httpserver.py" ]
 ---> Running in 78fde39719ee
Removing intermediate container 78fde39719ee
 ---> 960f831602fe
Successfully built 960f831602fe
Successfully tagged pythonhttpserver:latest
```
 

3. Verified if the images are created correctly 
```
 docker images
REPOSITORY         TAG       IMAGE ID       CREATED         SIZE
pythonhttpserver   latest    960f831602fe   5 seconds ago   911MB
python             3         1e76b28bfd4e   13 days ago     911MB
```

4. Executed the image to verify its running correctly

```
docker run -d -t -i -p 80:80 pythonhttpserver
642d773e3e2bee0dacfc1b5297861ecbff7dd12bc20448fc5698e2303d355b1c
[root@ip-172-31-21-28 pythonwebserver]# docker ps
CONTAINER ID   IMAGE              COMMAND                  CREATED         STATUS         PORTS                               NAMES
642d773e3e2b   pythonhttpserver   "python3 ./httpserve…"   4 seconds ago   Up 3 seconds   0.0.0.0:80->80/tcp, :::80->80/tcp   loving_vaughan

```

5. Access the webserver from outside, used port forwarding to connect to container and verified logs

```
docker logs -f 642d773e3e2b
103.208.71.93 - - [31/Aug/2021 14:25:45] "GET / HTTP/1.1" 200 -
103.208.71.93 - - [31/Aug/2021 14:25:46] "GET /favicon.ico HTTP/1.1" 200 -
103.208.71.93 - - [31/Aug/2021 14:25:48] "GET / HTTP/1.1" 200 -
103.208.71.93 - - [31/Aug/2021 14:25:48] "GET /favicon.ico HTTP/1.1" 200 -
```

***************************************************************************************************

## **Phase 4: Creating the repository and push images, create helm charts**

1. Created the AWS ECR repository using command below
```
aws ecr create-repository \
>  --repository-name teja-assignment-ecr \
>  --image-scanning-configuration scanOnPush=true \
>  --region us-east-2
{
    "repository": {
        "repositoryUri": "281455864058.dkr.ecr.us-east-2.amazonaws.com/teja-assignment-ecr",
        "imageScanningConfiguration": {
            "scanOnPush": true
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        },
        "registryId": "281455864058",
        "imageTagMutability": "MUTABLE",
        "repositoryArn": "arn:aws:ecr:us-east-2:281455864058:repository/teja-assignment-ecr",
        "repositoryName": "teja-assignment-ecr",
        "createdAt": 1630420975.0
    }
}
```

2. Tag the image and push it to the repo
```
docker tag pythonhttpserver:latest 281455864058.dkr.ecr.us-east-2.amazonaws.com/teja-assignment-ecr:latest
```

3. Perform the docker login

```
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 281455864058.dkr.ecr.us-east-2.amazonaws.com
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

```

4. Pushing  the image to repo

```
docker push 281455864058.dkr.ecr.us-east-2.amazonaws.com/teja-assignment-ecr:latest
The push refers to repository [281455864058.dkr.ecr.us-east-2.amazonaws.com/teja-assignment-ecr]
5fb17c97f6e9: Pushed
6a52048e82de: Pushed
ae3e9b5276f9: Pushed
583768e6b0f9: Pushed
6ec1e18e96a4: Pushed
e80eb58cd4e1: Pushed
21abb8089732: Pushed
9889ce9dc2b0: Pushed
21b17a30443e: Pushed
05103deb4558: Pushed
a881cfa23a78: Pushed
latest: digest: sha256:38f59514c7ddd8967841f0c5cff6159e9b2be3bdfdfb55e289da0e0d8a5c3975 size: 2632
```

***************************************************************************************************
## **Phase 5: Creating the Kubernetes object for the deployment, using Deployments**

1. Created the deployment yaml with follwing contents

```
 cat deployment-http.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pythonhttp-deployment
  labels:
    app: pythonhttp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: pythonhttp
  template:
    metadata:
      labels:
        app: pythonhttp
    spec:
      containers:
      - name: pythonhttp
        image: 281455864058.dkr.ecr.us-east-2.amazonaws.com/teja-assignment-ecr:http-python
        stdin: true
        tty: true
        ports:
        - containerPort: 80
```

2. Expose the deployment to Load Balancer

```
cat loadbalancer.yaml
apiVersion: v1
kind: Service
metadata:
  name: pythonhttp-service-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: pythonhttp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

```
3. Check if the application is accessible from outside world and PODs are running

```
kubectl get pods -l 'app=pythonhttp' -o wide | awk {'print $1" " $3 " " $6'} | column -t
NAME                                    STATUS   IP
pythonhttp-deployment-59bf6466b6-qr762  Running  172.31.33.246
pythonhttp-deployment-59bf6466b6-zqfzb  Running  172.31.7.0


kubectl get service/pythonhttp-service-loadbalancer |  awk {'print $1" " $2 " " $4 " " $5'} | column -t
NAME                             TYPE          EXTERNAL-IP                                                              PORT(S)
pythonhttp-service-loadbalancer  LoadBalancer  a71f383d39a5749718ad6efe4d516eca-1978462511.us-east-2.elb.amazonaws.com  80:32138/TCP

 curl -kv http://a71f383d39a5749718ad6efe4d516eca-1978462511.us-east-2.elb.amazonaws.com
*   Trying 3.133.209.172:80...
* Connected to a71f383d39a5749718ad6efe4d516eca-1978462511.us-east-2.elb.amazonaws.com (3.133.209.172) port 80 (#0)
> GET / HTTP/1.1
> Host: a71f383d39a5749718ad6efe4d516eca-1978462511.us-east-2.elb.amazonaws.com
> User-Agent: curl/7.76.1
> Accept: */*
>
* Mark bundle as not supporting multiuse
* HTTP 1.0, assume close after body
< HTTP/1.0 200 OK
< Server: BaseHTTP/0.6 Python/3.9.6
< Date: Tue, 31 Aug 2021 18:28:47 GMT
< Content-type: text/html; charset=UTF-8
<
* Closing connection 0
Hello World! 今日は

```
**************************************************************************************************************

## **Phase 6: Alternate approach - Creating the Kubernetes object for the deployment, using helm chart templates**

1. Creating the Helm chart templates for python http server

```
 helm create pythonhttp 
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /root/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /root/.kube/config
Creating pythonhttp 

```

5. Modify the values.yaml and Chart.yaml for the Imagepath, Pull Policy, Ingress details and tag
(Templates are uploaded under helmcart folder)

6. Installation of helm charts on EKS cluster

```
helm install pythonhttp pythonhttp/ --values pythonhttp/values.yaml
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /root/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /root/.kube/config
NAME: pythonhttp
LAST DEPLOYED: Tue Aug 31 18:16:12 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  http://python-httpserver.local/
```
