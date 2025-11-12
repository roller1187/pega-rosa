# Welcome - introduction to the exercises
    Welcome, everyone!
Today, we’re diving into the powerful combination of Pega’s digital process automation platform and Red Hat OpenShift, the industry-leading enterprise Kubernetes platform. This session is designed to help you gain practical, real-world experience installing, configuring, and managing Pega workloads on OpenShift.

Throughout this workshop, we’ll explore key topics that will build your confidence in deploying and operating Pega in a containerized environment:

Navigating OpenShift — Get comfortable with the OpenShift Web Console and CLI, exploring how resources are organized and managed across projects.

Deploying Workloads — Learn multiple deployment methods including Helm charts, Operators, and direct YAML/oc deployments.

Deployment Strategies — Understand how to design resilient, scalable Pega environments using rolling, blue-green, and canary strategies.

Networking Deep Dive — Examine OpenShift’s networking model, routes, and service exposure options to ensure Pega is reachable and secure.

Troubleshooting & Best Practices — Use built-in tools and logs to diagnose and resolve common issues in Pega deployments.

By the end of the workshop, you’ll have hands-on experience deploying Pega on OpenShift, understanding not just how to make it work—but why OpenShift is the ideal foundation for modernizing and scaling your Pega applications.

Let’s get started and see what’s possible when Pega meets OpenShift!

# Dev Console walkthrough - talk about the different personas in OCP, particularly developer since they should have spent a lot of time in the admin console by now. ChatGPT - generate a explanation of the OpenShift developer perspective and highlight the key functionality
    * Self service portal - templates, quick starts 
    * Topology view - nothing deployed by this point so just talk about it
    * Web terminal & + button at the top for adding new things
# Deploying and Managing applications  - talk about different ways that users create and manage resources on a Kubernets cluster ChatGPT - Generate an explanation of the different ways that a user could create workloads on OpenShift. Highlight templates, Operators and Helm charts.
    * Templates - show self service catalog and highlight the postgresql template. 
        * We can open the Postgres template and configure the database via self service catalog OR just let them oc apply -f pgdb.yaml
    * Operators - explain operators and what they are for, highlight CRDs and the OLM within open shift
        * We can deploy kafka (streams) as a operator and talk about that here
        * CHATGPT - create a quick blurb to explain Kubernetes Operators, what they do and how they work. 
    * Helm - provide a quick helm overview - CHATGPT - Provide a quick overview of Helm and explain some of the key concepts. Highlight the integration between Helm and OpenShift - ChatGPT - provide a brief overview on the integration between OpenShift and Helm
        * Explain charts and config files when configuring the backing services and pega.yaml. talk about the commands used to install, uninstall and upgrade chats
        * Show the helm integration within open shift
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
# Wrap up - at this point everyone should have pega installed so they can do whatever they want ChatGPT - Conclude the workshop highlighting what we covered already. Provide additional calls to action




Things I could do BEFORE workshop - 
		deploy images, machines and prep the nodes
		create single node machine pool with a 4xl instance type - do this first 
		import all images into each workshop - then do this
		prep every node with the images - oc new-app installer —i=pega/installer —replicas=5
		clean up everything (except image streams) or just recreate them - oc delete installer