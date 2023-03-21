# Setting up Arcaflow

In order to use Arcaflow, you will need to download the [Arcaflow Engine](https://github.com/arcalot/arcaflow-engine/releases). You can simply unpack and run it, no need for installing it.

On Linux and MacOS, you may need to run `chmod +x` on the engine binary.

## Configuration

If you are using Docker as the local deployer (see below), you generally **do not need to perform any extra configuration**.

If you wish to customize Arcaflow, you can pass a YAML configuration file to Arcaflow with the `-config your-arcaflow-config.yaml` parameter.

### Local deployer

The Arcaflow Engine needs a local container deployer to temporarily run plugins and read their schema. We recommend either Docker (default) or Podman for this purpose. You can use a Kubernetes cluster for this purpose too, but a local container engine is the better choice for performance reasons.

You can then change the deployer type like this:

```yaml
deployer:
  type: podman
  # Deployer-specific options 
```

=== "Docker"

    The docker deployer is the default. You can configure it like this:
    
    ```yaml
    deployer:
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
    deployer:
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

    If you want to use Podman as your local deployer instead of Docker, you can do so like this:
    
    ```yaml
    deployer:
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


### Logging

Logging is useful when you need more information about what is happening while you run a workload.

#### Basic logging

Here is the syntax for setting the log level:
```yaml
log:
  level: info
```

Options are:
- Debug: Info useful to the developers
- Info: General info
- Warning: Something went wrong, and you should know about it
- Error: Something failed. This info should help you figure out why

This sets which types of log output are shown or hidden. `debug` shows everything, while `error` shows the least, only showing `error` output. Each output shows more, rather than just its type, so `debug`, `info`, and `warning` still show `error` output.

#### Step logging

Step logging is useful for getting output from failed steps, or general debugging.
It is not recommended that you rely on this long term, as there may be better methods of debugging failed workflows.

To make it output just error logs when a step fails, set it as shown:
```yaml
logged_outputs:
  error:
    level: error
```

You can specify multiple types of output and their log levels. For example, if you also want to output success steps as debug, set it as shown:
```yaml
logged_outputs:
  error:
    level: error
  success:
    level: debug
```

**Note**: If you set the level lower than the general log level shown above, it will not show up in the output.
