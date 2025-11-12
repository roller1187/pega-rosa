# Welcome - introduction to the exercises
Today, we’re diving into the powerful combination of Pega’s digital process automation platform and Red Hat OpenShift, the industry-leading enterprise Kubernetes platform. This session is designed to help you gain practical, real-world experience installing, configuring, and managing Pega workloads on OpenShift.

Throughout this workshop, we’ll explore key topics that will build your confidence in deploying and operating Pega in a containerized environment:

- **Navigating OpenShift** — Get comfortable with the OpenShift Web Console and CLI, exploring how resources are organized and managed across projects.
 
- **Deploying Workloads** — Learn multiple deployment methods including Helm charts, Operators, and direct YAML/oc deployments.

- **Deployment Strategies** — Understand how to design resilient, scalable Pega environments using rolling, blue-green, and canary strategies.

- **Networking Deep Dive** — Examine OpenShift’s networking model, routes, and service exposure options to ensure Pega is reachable and secure.

- **Troubleshooting & Best Practices** — Use built-in tools and logs to diagnose and resolve common issues in Pega deployments.

By the end of the workshop, you’ll have hands-on experience deploying Pega on OpenShift, understanding not just how to make it work—but why OpenShift is the ideal foundation for modernizing and scaling your Pega applications.

Let’s get started and see what’s possible when Pega meets OpenShift!

# Dev Console walkthrough
The Developer Perspective in OpenShift is designed to give application developers a streamlined, visual way to build, deploy, and manage workloads — without needing to dive deep into cluster administration. It focuses on application delivery, developer productivity, and rapid iteration.

1. Topology View — The Big Picture

    The Topology view gives you a visual map of all your applications and components running in a project (namespace). You can see deployments, services, routes, and how they connect — all in real-time. It’s great for understanding relationships between microservices or quickly spotting unhealthy pods.

2. Add Menu — Multiple Deployment Options

    The “+Add” page is your launchpad for creating new workloads. You can deploy apps using:
    - Git Repository (build and deploy directly from source)
    - Container Image (deploy pre-built images)
    - Helm Charts (template-based deployments)
    - Operator Backed Services (deploy via certified operators)

3. Build & Pipelines

    Integration with Tekton Pipelines means you can automate build-test-deploy workflows seamlessly.

4. Networking Made Easy

    Quickly view and manage Routes, Services, and Ingress directly from the UI.

5. Monitoring & Troubleshooting

    Get direct access to pod logs, events, and metrics without switching to the Administrator Perspective. Drill down into pods or components to identify issues fast — great for day-to-day debugging.

The Developer Perspective is all about speed and self-service — empowering developers to:
    Deploy faster, without waiting for ops teams.
    Visualize applications and dependencies instantly.
    Integrate modern CI/CD and GitOps workflows.
    Stay focused on building, not managing infrastructure.

# Deploying and Managing applications

OpenShift provides multiple ways to create and manage workloads — giving developers and operators flexibility depending on their skill level, deployment complexity, and automation needs. Let’s look at the main approaches you can use.

## Templates — Parameterized, Reusable Blueprints

### What they are:
OpenShift Templates are predefined sets of Kubernetes objects (like Deployments, Services, Routes, ConfigMaps, etc.) packaged together with parameters that can be customized at deployment time.

### Why they’re useful:
- Great for standardized, repeatable deployments — e.g., quickly spinning up dev environments or demo apps. You can use parameters to customize image versions, replicas, or resource limits.
- Templates are easy to store in Git and apply via the CLI or web console
## Operators — Declarative, Lifecycle-Aware Automation

### What they are:
Operators extend Kubernetes by embedding domain-specific operational knowledge into the cluster. They use Custom Resource Definitions (CRDs) to automate not just deployment, but day-2 operations — upgrades, backups, scaling, configuration, etc.

### Why they’re powerful:

- Provide full lifecycle management of complex applications (like Pega, databases, Kafka, etc.).

- Reduce human error through automation and consistent configuration.

- Delivered and managed through the OperatorHub in OpenShift.

## Helm Charts — Kubernetes Package Manager

### What they are:
Helm is the package manager for Kubernetes, allowing you to deploy and manage applications as versioned “charts.” A chart bundles all Kubernetes manifests plus configuration values into a single deployable unit.

### Why they’re convenient:

- Simplifies deployment of complex applications with multiple components.

- Allows parameter customization via values.yaml or CLI overrides.

- Easily integrates into CI/CD and GitOps workflows.
# Different types of workloads - ChatGPT - Create a paragraph that explains the different mechanisms for managing workloads. You should highlight Kubernetes Deployments, stateful sets, daemon sets, and jobs
    * Deployment - use one of the deployments and talk about it - ChatGPT - generate a 2 sentence explanation highlighting Deployments in OpenShift
    * Stateful Set/Daemon set - OpenSearch is a stateful set, highlight when and why they are used 
        * ChatGPT - provide an explanation of statefulsets and deamonsets. Explain when they are used and provide examples.
    * Jobs - the Pega batch process that spins up and creates the database. When it finishes it terminates ChatGPT - explain Kubernetes jobs and provide an example use case.
# Troubleshooting - When things start going wrong what do you do? CHATGPT - generate an explanation of some of the basic means for troubleshooting applications on OpenShift. Highlight logs, web terminals, events and any other means for troubleshooting. 
    * console logs - switch to a pod and look at the logs for errors
    *  dev terminal - open up a terminal to a pod via the CLI or the oc command from the bastion
    *  events - look at the different types of events and talk about what is happening here
    * Other troubleshooting tools to talk about - oc rsh, debug pods, ssh into coreos host, 
# Networking  - ChatGPT - generate a brief introduction to networking in OpenShift and explain some of the core concepts including services, ingress, routes and network policies
    * Services - Talk about service connections. A good place to talk about this is when the Pega Database is being created. Highlight how the Pega pod connects to the database via the service URL
    * Routes - explain what they are and access the Pega console via the OpenShift Route and end the workshop here
# Wrap up
You’ve just taken a full tour through what it means to run Pega on OpenShift, from installation all the way through deployment, scaling, and troubleshooting.

We explored the OpenShift console and CLI, deployed Pega using Helm, Operators, and manifests, experimented with different deployment strategies, and even dug into networking and debugging to see how everything connects under the hood.

What you did today is what real-world cloud engineering looks like — hands-on, problem-solving, and iterative.

If there’s one takeaway, it’s this: OpenShift gives you the power and flexibility to run enterprise apps like Pega the right way — consistently, securely, and at scale.

Thank you all for the energy, questions, and collaboration today. Keep experimenting, keep breaking things safely, and keep building awesome solutions on OpenShift!




Things I could do BEFORE workshop - 
		deploy images, machines and prep the nodes
		create single node machine pool with a 4xl instance type - do this first 
		import all images into each workshop - then do this
		prep every node with the images - oc new-app installer —i=pega/installer —replicas=5
		clean up everything (except image streams) or just recreate them - oc delete installer