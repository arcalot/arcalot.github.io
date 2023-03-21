# Arcaflow: The noble workflow engine

Arcaflow is a **workflow engine** that lets you run individual steps and pass data between them. The **data is validated** according to a schema along the way to make sure there is no corrupt data. Arcaflow runs on your laptop and deploys **plugins as containers** on Docker, Podman, or Kubernetes.

!!! tip "Did you know?"
    In Docker/Kubernetes, Arcaflow only needs network access to the API, not the plugin container itself. You can safely place a restrictive firewall on most plugins.

<h2>Use cases</h2>

Arcaflow is a good fit to:

- Run ad-hoc tasks across several container systems
- Pass data between them
- Make sure your data is correct

You can use Arcaflow for many things. We use it for:

- Performance and chaos testing
- Ad-hoc workflows without previous deployment
- Vendor-independent CI workflows

[Get started &raquo;](getting-started.md){ .md-button--primary .md-button } [Contribute &raquo;](contributing/index.md){ .md-button }

<h2>Alternatives</h2>

You need to pick the right tool for the job. Sometimes, you need something simple. Sometimes, you want something persistent that keeps track of the workflows you run over time. We have collected the open source workflow and workflow-like engines we could find into this list, so you can find the right tool for the job.

??? "Ansible"

    [Ansible](https://www.ansible.com/) is an automation and configuration management tool often used by system administrators to automate the deployment of servers and other resources.
    
    **How it is similar to Arcaflow**

    - It runs on your laptop and doesn't need a large server
    - You don't need to deploy it or run it permanently
    - It can run things on remote systems out of the box
    - It runs tasks as sequential (and, with some work, parallel) steps
    - You can pass data between steps

    **What it does better than Arcaflow**
    
    - Well established and well known
    - Wide range of available plugins
    - Simple workflows are easy to write
    - It runs comands over SSH by design
    
    **What it does worse than Arcaflow**
    
    - Parallelization is hard, it is intended for resource creation rather than generic workflows
    - It does not have a typing system and cannot guarantee type-safety or validation of data
    - Plugins can only be written in Python
    - Plugins are not transparently runnable in a container engine as Ansible intends to run commands over SSH
    - It is written in Python and needs a large number of dependencies installed

??? "Apache Airflow"

    [Airflow](https://airflow.apache.org/) is a deployed workflow engine written in Python. 

    **How it is similar to Arcaflow**

    - It runs workflows where you can pass data between individual steps
    - It's good at parallelizing things

    **What it does better than Arcaflow**
    
    - It has a user interface
    - It has a history of jobs run in the past
    - Large number of providers
    - Writing workflows in Python is simple
    
    **What it does worse than Arcaflow**
    
    - You need to deploy it and it has to run continuously
    - It needs a persistence engine (database) to store data long-term
    - It does not have a typing system and cannot guarantee type-safety or validation of data
    - Workflows and operators can only be written in Python
    - Operator code is tightly coupled to Airflow
    - Operators have to explicitly consider container engines if you want to run things in a container

??? "Argo Workflows"
    
    [Argo Workflows](https://argoproj.github.io/argo-workflows/) is a workflow system for Kubernetes.

    **How it is similar to Arcaflow**

    - It can run several steps
    - It runs containers as workflow steps
    - You can pass data between steps

    **What it does better than Arcaflow**

    - Define workflows directly in Kubernetes custom resources
    - You can run any container image as a step

    **What it does worse than Arcaflow**

    - It only runs as a Kubernetes operator and cannot run outside of it
    - It only supports a single Kubernetes cluster
    - It does not have a typing system and cannot guarantee type-safety or validation of data
    - In order to run things in parallel, you need to [hand-write a DAG](https://argoproj.github.io/argo-workflows/walk-through/dag/)

??? "Netflix Conductor"

    [Conductor](https://conductor.netflix.com/) is a workflow engine that has to be deployed before running workflows. 

    **How it is similar to Arcaflow**

    - It runs workflows where you can pass data between individual steps
    - It's good at parallelizing things

    **What it does better than Arcaflow**

    - It has a user interface
    - It has a history of jobs run in the past

    **What it does worse than Arcaflow**

    - You need to deploy it and it has to run continuously
    - It needs a persistence engine (database) to store data long-term
    - It needs at least 16 GB of RAM to run everything
    - It does not have a typing system and cannot guarantee type-safety or validation of data
    - Workers must reach Conductor over HTTP and must be explicitly deployed

??? "Tekton"

    [Tekton](https://tekton.dev/) is a full CI/CD system running in Kubernetes.
    
    **How it is similar to Arcaflow**

    - It has tasks and pipelines to run steps in sequence
    - You can pass data between steps

    **What it does better than Arcaflow**
    
    - It is a full CI/CD system that can be coupled to your version control system without additional tools
    - Built-in supply chain security
    - Any container image can be run without additional integrations
    
    **What it does worse than Arcaflow**
    
    - It is deployed inside a Kubernetes cluster and cannot exist without it
    - No officially supported integrations with other platforms and tools
    - It does not have a typing system and cannot guarantee type-safety or validation of data

??? "qDup"
    
    [qDup](https://github.com/Hyperfoil/qDup) is a workflow engine for shell commands.

    **How it is similar to Arcaflow**

    - It's a workflow system
    - It runs on your laptop and doesn't need a large server
    - You don't need to deploy it or run it permanently
    - It can run things on remote systems out of the box

    **What it does better than Arcaflow**

    - It has advanced controls for creating loops, signaling, waiting for events, etc
    - It's very simple to run scripts in a parallelized way
    - It runs comands over SSH by design

    **What it does worse than Arcaflow**

    - It does not have a typing system and cannot guarantee type-safety or validation of data
    - It doesn't integrate with container engines natively
