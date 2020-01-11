# Deploy an Azure Function to Kubernetes
This guide will demonstrate how to deploy a bare bone azure function to a local kubernetes cluster.

### Prerequisites
* dotnet core
* func [get-started](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
* docker
* kubectl

Run the following to ensure you have installed the dependencies.
```bash
> dotnet --version
3.1.100

> func --version
2.7.1846

> docker --version
19.03.5, build 633a0ea

> kubectl version
...
```

### Create an azure function project with a Dockerfile
Create an empty dotnet azure function project and add a http trigger function. Finally, add a Dockerfile to the project.
```bash
> func init MyFuncProject --worker-runtime dotnet
> cd MyFuncProject
> func new --name MyHttpTrigger --template "HttpTrigger"
> func init --docker-only
```

### Build a docker image
Build a docker image from the Dockerfile and ensure it runs locally.
```bash
> docker build --tag <docker-id>/azurefunc:v1.0.0 .
```
Verify the docker image built successfully.
```bash
> docker image list
```
Optional: run the image locally to verify it works. 
```bash
> docker run -p 8080:80 -it <docker-ID>/azurefunc:v1.0.0
```
Verify the function app and container are functioning correctly by browsing to http://localhost:8080.
Note: If you want to test your function running in the local container, you can change the authorization key to anonymous.

### Deploy to kubernetes
Install KEDA in your cluster by running the following install command:
```bash
> func kubernetes install --namespace keda
```
Create a deploy.yml file for the image:
```bash
> func kubernetes deploy --name <name-of-function-deployment> --image-name <docker-ID>/azurefunc:v1.0.0 --dry-run > deploy.yml
```
Deploy the .yml:
```bash
> kubectl apply -f deploy.yml
```
Ensure the new pod has status 'Running':
```bash
> kubectl get pods --all-namespaces
```
Test out the deployment:
```bash
kubectl get service --watch
```
Verify the function app is functioning correctly by browsing to http://localhost:80.
Note: You can modify the deploy.yml file to change the port on which the application listens on.

### Cleanup
Delete the deployment:
```bash
> kubectl get deployment
> kubectl delete deployment <name-of-function-deployment>
> kubectl delete ScaledObject <name-of-function-deployment>
> kubectl delete secret <name-of-function-deployment>
```
Uninstall KEDA:
```bash
> func kubernetes remove --namespace keda
```

### References
* [Azure Functions on Kubernetes with KEDA](https://docs.microsoft.com/en-us/azure/azure-functions/functions-kubernetes-keda)
* [Create a function on Linux using a custom image](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-function-linux-custom-image?tabs=nodejs)
* [Run Azure Functions in Kubernetes with KEDA](https://markheath.net/post/azure-functions-aks-keda)
