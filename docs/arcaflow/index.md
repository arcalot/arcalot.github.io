# Arcaflow: The noble workflow engine

Arcaflow is a **workflow engine** that lets you run individual steps and pass data between them. The **data is validated** according to a schema along the way to make sure there is no corrupt data. Arcaflow runs on your laptop, a jump host, or in a CI system and deploys **plugins as containers** on target systems via Docker, Podman, or Kubernetes.

!!! tip "Did you know?"
    In Docker/Kubernetes, Arcaflow only needs network access to the API, not the plugin container itself. You can safely place a restrictive firewall on most plugins.

<h2>Use cases</h2>

Arcaflow is a good fit to:

- Run ad-hoc tasks across container systems
- Pass data between them
- Make sure your data is correct
- Make workflows portable with minimal dependencies

You can use Arcaflow for many things. We use it for:

- Performance and chaos testing
- Ad-hoc workflows without previous deployment
- Vendor-independent CI workflows

[Get started &raquo;](getting-started.md){ .md-button--primary .md-button } [Contribute &raquo;](contributing/index.md){ .md-button }

<h2>Shipping expertise</h2>

Good workflows take time and expertise to develop. Often these workflows evolve organically into bespoke scripts and/or application stacks, and knowledge transfer or the ability to run the workflows in new environments can be very difficult. Arcaflow addresses this problem by focusing on being the *plumbing* for the workflow, standardizing on a plugin architecture for all actions, minimizing dependencies, focusing on quality, and enforcing strong typing for data passing.

Arcaflow's design can drastically simplify much of the workflow creation process, and it allows the workflow author to ensure the workflow is *locked in end-to-end*. **A complete workflow can be version-controlled as a simple YAML file and in most cases can be expected to run in exactly the same way in any compatible environment.**

<h2>Not a CI system</h2>

Arcaflow is **not designed to run as a persistent service nor to record workflow histories**, and in most cases it is **probably not the best tool to setup or manage infrastructure**. For end-to-end CI needs, you should leverage a system that provdes these and other features (possibly something from the Alternatives list below).

Arcaflow is, however, **an excellent companion to a CI system**. In many cases, building complex workflows completely within a CI environment can effectively lock you into that system because the workflow may not be easily portable outside of it or run independently by a user. An Arcaflow workflow **can be easily integrated into most CI systems**, so a workflow that you define once may be moved in most cases without modification to different environments or run directly by users.

<h2>Alternatives</h2>

It's important that you pick the right tool for the job. Sometimes, you need something simple. Sometimes, you want something persistent that keeps track of the workflows you run over time. We have collected some common and well-known open source workflow and workflow-like engines into this list and have provided some comparisons to help you find the right tool for your needs.

**Here are some of the features that make Arcaflow a unique solution to the below alternatives:**

- Designed for complex branching-action workflows and parallelization
- Prioritizes data passing and management via strong typing and schemas to ensure machine readabilitly, workflow validation, and data integrity
- Runs actions as plugins via container orchestrator APIs
- Engine is deployed as a single Golang binary, and plugins are run as containers, minimizing dependencies and maximizing portability
- Workflows are designed to be explicitly version controlled to ensure portability to other environments without code or feature drift
- Plugins can be written in a variety of languages, and plugins from different languages can be mixed into the same workflow (SDKs provided currently for Python and Golang)

??? "Ansible"

    [Ansible](https://www.ansible.com/) is an IT automation and configuration management system. It handles configuration management, application deployment, cloud provisioning, ad-hoc task execution, network automation, and multi-node orchestration. Ansible makes complex changes like zero-downtime rolling updates with load balancers easy.

    **How are Arcaflow and Ansible similar?**

    - They both perform actions on local and remote systems using modular architectures.
    - Their core engines can both run on your laptop and don't need a large server.
    - You don't need to deploy them on target hosts or run them permanently.
    - They both allow for passing of data between steps.
    - They both use YAML to define their workflows.
    - Their plugins and modules can be written in a variety of languages.

    **How is Ansible different?**

    - Ansible is well-established with a wide range of available plugins.
    - Ansible runs its tasks typically as commands over remote shells.
    - Ansible’s approach to parallelization is in terms of executing the same tasks against different hosts in parallel (see “forks” and “strategy”). Defining different tasks to perform in parallel is more challenging.
    - Ansible is written in Python and has many dependencies on the control host, though it can be run as a container to simplify this.
    - Some modules may have system requirements for python or other dependencies on the target hosts/containers. (See [Ansible documentation](https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#how-do-i-handle-not-having-a-python-interpreter-at-usr-bin-python-on-a-remote-machine))
    - Ansible workflows may not be consistent or portable across bare metal and Kubernetes environments.

??? "Apache Airflow"

    [Airflow](https://airflow.apache.org/) is a platform to programmatically author, schedule, and monitor workflows. It is a deployed workflow engine written in Python. 

    **How are Arcaflow and Airflow similar?**

    - They both run workflows that allow you to pass data between individual steps.
    - They are both good a parallelizing tasks.
    - They both allow you to write workflow steps in Python.
    
    **How is Airflow different?**
    
    - Airflow must be deployed and run continuously.
    - Airflow needs a persistence engine (database) to store data long-term.
    - Airflow workflows and operators can only be written in Python.
    - Operator code is tightly coupled to Airflow.
    - Operators have to explicitly consider container engines if you want to run things in a container.

??? "Argo Workflows"
    
    [Argo Workflows](https://argoproj.github.io/argo-workflows/) is a container-native workflow engine for orchestrating parallel jobs on Kubernetes. Argo Workflows is implemented as a Kubernetes CRD (Custom Resource Definition).

    **How are Arcaflow and Argo Workflows similar?**

    - They can both run several steps.
    - They can both run containers as workflow steps.
    - They both allow for passing of data between steps.

    **How is Argo Workflows different?**

    - Argo Workflows allows you to define workflows directly in Kubernetes custom resources.
    - Argo Workflows allows you to run any container image as a step.
    - Argo Workflows only runs as a Kubernetes operator and cannot run outside of it.
    - Argo Workflows only supports a single Kubernetes cluster.
    - In order to run things in parallel, you need to [hand-write a DAG](https://argoproj.github.io/argo-workflows/walk-through/dag/)

??? "Netflix Conductor"

    [Conductor](https://conductor.netflix.com/) is a platform created by Netflix to orchestrate workflows that span across microservices.

    **How are Arcaflow and Conductor similar?**

    - They both allow for passing of data between steps.
    - They are both good a parallelizing tasks.

    **How is Conductor different?**

    - Conductor has a user interface.
    - Conductor keeps a history of jobs that have run in the past.
    - Conductor must be deployed and run continuously.
    - Conductor needs a persistence engine (database) to store data long-term.
    - Conductor requires at least 16 GB of RAM to run everything.
    - Workers must reach Conductor over HTTP and must be explicitly deployed.

??? "Tekton"

    [Tekton](https://tekton.dev/) is a framework for creating CI/CD systems, allowing developers to build, test, and deploy across cloud providers and on-premise systems.
    
    **How are Arcaflow and Tekton similar?**

    - They both have tasks and pipelines to run steps in sequence.
    - They both allow for passing of data between steps.

    **How is Tekton different?**
    
    - Tekton is a full CI/CD system that can be coupled to your version control system without additional tools.
    - Tekton has built-in supply chain security.
    - Tekton allows you to run any container image without additional integrations.
    - Tekton is deployed inside a Kubernetes cluster and cannot exist without it.
    - Tekton has no officially-supported integrations with other platforms and tools.

??? "qDup"
    
    [qDup](https://github.com/Hyperfoil/qDup) allows shell commands to be *queued up* across multiple servers to coordinate performance tests. It is designed to follow the same workflow as a user at a terminal so that commands can be performed with or without qDup. Commands are grouped into re-usable scripts that are mapped to different hosts by roles.

    **How are Arcaflow and qDup similar?**

    - They are both workflow systems.
    - They both run on your laptop and don't need a large server.
    - You don't need to deploy them on target hosts or run them permanently.
    - They can both run things on remote systems out of the box.

    **How is qDup different?**

    - qDup has advanced controls for creating loops, signaling, waiting for events, etc.
    - qDup makes it very simple to run scripts in a parallelized way.
    - qDup runs commands over SSH locally, or integrates with podman. There are plans to support Docker and Kubernetes in the future.
    - qDup is written in Java.
