# Arcaflow plugins

Arcaflow is designed as an interoperable system between programming languages. Therefore, plugins are started as external processes and the communication with the plugin takes place over its standard input and output. The Arcaflow Engine passes data between the plugins as required by the workflow file. 

In the vast majority of cases, plugins run inside a container, while the Arcaflow Engine itself does not. This allows Arcaflow to pass data between several Kubernetes clusters, local plugins, or even run plugins via Podman over SSH. These capabilities are built into the Arcaflow Engine with the help of deployers.

Since Arcaflow has an internal [typing system](typing.md), each plugin must declare at the start what input data it requires and what outputs it produces. This allows the Engine to verify that the workflow can be run, and that no invalid data is being used. If invalid data is detected, the workflow is aborted to prevent latent defects in the data.

In summary, you can think of Arcaflow as a strongly (and at some time in the future possibly statically) typed system for executing workflows, where individual plugins run in containers across several systems.