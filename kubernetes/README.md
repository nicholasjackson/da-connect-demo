# Consul Connect Demo on Kubernetes

This demo shows how connect can be used in a multi-tier microservice environment

## Architecture
The application is comprised of 3 microservices, none of which are publically accessible:
1. Web Frontend (React, browser based)
1. API Service (Golang)
1. Face detection service (Machinebox)

The microservices are running in a pod which is also configured with a Consul Connect proxy which is running as a sidecar.

To route requests to the frontend and api microservices a router is sitting behind a public loadbalancer.  The router is using the Connect Go SDK to proxy requests to the upstream services.

Every node in the Kubernetes cluster has a Consul Agent running which is accessible via the Node IP adddress.  Currently the Consul server is running as a single instance however ultimately this will be moved out to a separate cluster not managed by Kubernetes.

To register the services with the Consul Service Catalog, Consul Register is running, Register monitors the Kubernetes cluster and when a pod starts it automatically registers the containers with Consul.

![architecture](./assets/k8s_demo.png)

## Applications

### Emojify Frontend
GitHub: [http://github.com/nicholasjackson/emojify-frontend](http://github.com/nicholasjackson/emojify-frontend)

Docker: nicholasjackson/emojify-frontend

The frontend application is a simple browser based ReactJS application, it leverages the API, posting the URL of an image to be processed and presenting the returned image.  The frontend expects the API to be accessible on the same IP as the website at the `api` path.

### Emojify API
GitHub: [http://github.com/nicholasjackson/emojify-api](http://github.com/nicholasjackson/emojify-api)

Docker: nicholasjackson/emojify-api

The API server accepts POST requests with the body containing a url to an image, the server downloads the image from the URL and sends it to the face detection service for processing.  When the response from the face detection service is received the service overlays random emoji at the location of the detected faces, saves the result as a PNG and returns a URL where the image can be retrieved in the response.

### Face detection service
[www.machinebox.io](http://www.machinebox.io)

<small>
	Artificial Intelligence powered by <a href='https://machinebox.io/' target='_blank'>Machine Box</a>
</small>

To detect faces an image is sent to the `Facebox` instance, this is a 3rd party black box service.

### Consul Connect Router
GitHub [http://github.com/nicholasjackson/consul-connect-router](http://github.com/nicholasjackson/consul-connect-router)

Docker: nicholasjackson/consul-connect-router

To route requests from the public internet to the private services the Consul Connect Router project is used.  This service uses the  Connect Go SDK which allows requests to be transparently and securely proxied to the upstream services.


## Setup
The example project runs on Kubernetes, currently the example Terraform will create a cluster in Azure however any Kubernetes cluster will work.

### Install the helm provider

```bash
make install_helm_provider
```

### Configure environment variables
You will need to set the following environment variables which correspond to your account in azure

```bash
export ARM_SUBSCRIPTION_ID=xxxxxxxxxx
export ARM_CLIENT_ID=xxxxxxxxxxx
export ARM_CLIENT_SECRET=xxxxxxxxx
export ARM_TENANT_ID=xxxxxxxxxxx

export TF_VAR_client_id=${ARM_CLIENT_ID}
export TF_VAR_client_secret=${ARM_CLIENT_SECRET}

# Machine Box API Key
export TF_VAR_machinebox_key=xxxxxxxxxx
```

A MachineBox API key can be obtained by creating an account at: [https://machinebox.io/account](https://machinebox.io/account)

## Core infrastructure
The application is broken into two components, the core infrastructure consists of the Kubernetes cluster with running Consul server, and a Vault instance.

The core infrastructure takes approximately 10 minutes to provision.

### Create k8s cluster and provision application with Helm
To create the cluster on Azure use the Terraform configuration to create a basic cluster.

```bash
make apply_core
```

### Open dashboard
To view the Kubernetes dashboard we can start the Kube proxy and then open the dashboard in a browser

```bash
make open_dashboard
```
![](./assets/k8s_dashboard.png)

### View the Consul UI
To view the consul UI you can port forward to the clusters consul-server

```bash
make open_consul_ui
```

![](./assets/consul_ui.png)

### Fetch K8s config
Once the cluster has been created the configuration which allows connections with `kubectl` can be retrieved with the following script.

```bash
make get_k8s_config
```

We then need to set an environment variable pointing to the downloaded configuration

```bash
export KUBECONFIG=$(pwd)/kube_config.yml
```

You can now use `kubectl` to interact with the cluster

## Application infrastructure
To install the application and create its required infrastructure perform the following steps, this will take approximately 3 minutes to complete depending on how long it take to create the external loadbalancer.

### Installing the application
To install and run the application first ensure you have created the core infrastructure then run

```bash
make apply_app
```

### Open application frontpage

```bash
make open_app
```

![](./assets/app.png)

## TODO
[] Implement Consul ACLs to correctly secure the Consul Agents and Proxies  
[] Add SSL to public loadbalancer
