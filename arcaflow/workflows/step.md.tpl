# Writing workflow steps

If your [input](input.md) is complete, you can now turn to writing your workflow steps. You can connect workflow steps by using [expressions](expressions.md). For example, if step `A` has an input that needs data from step `B`, Arcaflow will automatically run step `B` first.

To define a step type, you can do the following:

```yaml
steps:
  step_a: # Specify any ID here you want to reference the step by
    plugin: quay.io/some/container/image # This must be an Arcaflow-compatible image
    input: # specify input values as a data structure, mixing in expressions as needed
      some:
        key: !expr $.steps.step_b.outputs.success.some_value 
  step_b:
    plugin: quay.io/some/container/image
    input:
      some:
        key: !expr $.input.some_value # Reference an input value
```

## Plugin steps

Plugin steps run Arcaflow plugins in containers. They can use Docker, Podman, or Kubernetes as deployers. If no deployer is specified in the workflow, the plugin will use the [local deployer](../running/setup.md).

Plugin steps have the following properties:

| Property | Description                                                                                                                      |
|----------|----------------------------------------------------------------------------------------------------------------------------------|
| `plugin` | Full name of the container image to run. This must be an Arcaflow-compatible container image.                                    |
| `step`   | If a plugin provides more than one possible step, you can specify the step ID here.                                              |
| `deploy` | Configuration for the deployer. (See below.) This can contain expressions, so you can dynamically specify deployment parameters. |
| `input`  | Input data for the plugin. This can contain expressions, so you can dynamically define inputs.                                   |

You can reference plugin outputs in the format of <code>$.steps.<em>your_step_id</em>.outputs.<em>your_plugin_output_id</em>.<em>some_variable</em></code>.

### Deployers

The `deploy` key for plugins lets you control how the plugin container is deployed. You can use expressions to use other plugins (e.g. the [kubeconfig plugin](https://github.com/arcalot/arcaflow-plugin-kubeconfig/)) to generate the deployment configuration and feed it into other steps.

=== "Docker"

    You can configure the Docker deployer like this:

    ```yaml
    step:
      your_step_id:
        plugin: ...
        input: ...
        deploy: # You can use expressions here
          type: docker
          connection:
            # Change this to point to a TCP-based Docker socket
            host: host-to-docker
            # Add a certificates here. This is usually needed in TCP mode.
            cacert: |
              Add your CA cert PEM here
            cert: |
              Add your client cert PEM here.
            key: |
              Add your client key PEM here.
          deployment:
            # For more options here see: https://docs.docker.com/engine/api/v1.42/#tag/Container/operation/ContainerCreate
            container:
              # Add your container config here.
            host:
              # Add your host config here.
            network:
              # Add your network config here
            platform:
              # Add your platform config here
            imagePullPolicy: Always|IfNotPresent|Never
          timeouts:
            # HTTP timeout
            http: 5s
    ```

    ??? "All options for the Docker deployer"
        {{ prefix (partial "type_with_header" .DockerDeployer) "        " }}

=== "Kubernetes"

    The Kubernetes deployer deploys on top of Kubernetes. You can set up the deployer like this:

    ```yaml
    step:
      your_step_id:
        plugin: ...
        input: ...
        deploy: # You can use expressions here
          type: kubernetes
          connection:
            host: localhost:6443
            cert: |
              Add your client cert in PEM format here.
            key: |
              Add your client key in PEM format here.
            cacert: |
              Add the server CA cert in PEM format here.
    ```

    ??? "All options for the Kubernetes deployer"
        {{ prefix (partial "type_with_header" .KubernetesDeployer) "        " }}

=== "Podman"

    If you want to use Podman as your local deployer, you can do so like this:

    ```yaml
    step:
      your_step_id:
        plugin: ...
        input: ...
        deploy: # You can use expressions here
          type: podman
          podman:
            # Change where Podman is. (You can use this to point to a shell script
            path: /path/to/your/podman
            # Change the network mode
            networkMode: host
          deployment:
            # For more options here see: https://docs.docker.com/engine/api/v1.42/#tag/Container/operation/ContainerCreate
            container:
              # Add your container config here.
            host:
              # Add your host config here.
            imagePullPolicy: Always|IfNotPresent|Never
          timeouts:
            # HTTP timeout
            http: 5s
    ```

    ??? "All options for the Podman deployer"
        {{ prefix (partial "type_with_header" .PodmanDeployer) "        " }}
