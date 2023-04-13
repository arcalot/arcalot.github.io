# Writing workflow steps

If your [input](input.md) is complete, you can now turn to writing your workflow steps. You can connect workflow steps by using [expressions](expressions.md). For example, if step `A` has an input that needs data from step `B`, Arcaflow will automatically run step `B` first.

To define a step type, you can do the following:

```yaml title="workflow.yaml"
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
        |    |    |
        |----|----|
        | Type: | `scope` |
        | Root object: | Config |
        ???+ note "Properties"
            ??? info "connection (`reference[Connection]`)"
                |    |    |
                |----|----|
                | Name: | Connection |
                | Description: | Docker connection information. |
                | Required: | No || Type: | `reference[Connection]` |
                | Referenced object: | Connection *(see in the Objects section below)* |
                
                
            ??? info "deployment (`reference[Deployment]`)"
                |    |    |
                |----|----|
                | Name: | Deployment |
                | Description: | Deployment configuration for the plugin. |
                | Required: | No || Type: | `reference[Deployment]` |
                | Referenced object: | Deployment *(see in the Objects section below)* |
                
                
            ??? info "timeouts (`reference[Timeouts]`)"
                |    |    |
                |----|----|
                | Name: | Timeouts |
                | Description: | Timeouts for the Docker connection. |
                | Required: | No || Type: | `reference[Timeouts]` |
                | Referenced object: | Timeouts *(see in the Objects section below)* |
                
                
        ???+ note "Objects"
            ??? info "**Config** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "connection (`reference[Connection]`)"
                        |    |    |
                        |----|----|
                        | Name: | Connection |
                        | Description: | Docker connection information. |
                        | Required: | No || Type: | `reference[Connection]` |
                        | Referenced object: | Connection *(see in the Objects section below)* |
                        
                        
                    ??? info "deployment (`reference[Deployment]`)"
                        |    |    |
                        |----|----|
                        | Name: | Deployment |
                        | Description: | Deployment configuration for the plugin. |
                        | Required: | No || Type: | `reference[Deployment]` |
                        | Referenced object: | Deployment *(see in the Objects section below)* |
                        
                        
                    ??? info "timeouts (`reference[Timeouts]`)"
                        |    |    |
                        |----|----|
                        | Name: | Timeouts |
                        | Description: | Timeouts for the Docker connection. |
                        | Required: | No || Type: | `reference[Timeouts]` |
                        | Referenced object: | Timeouts *(see in the Objects section below)* |
                        
                        
            ??? info "**Connection** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "cacert (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | CA certificate |
                        | Description: | CA certificate in PEM format to verify the Dockerd server certificate against. |
                        | Required: | No || Required if the following fields are set: |cert, key || Type: | `string` |
                        | Minimum: | 1 |
                        | Must match pattern: | `^\s*-----BEGIN CERTIFICATE-----(\s*.*\s*)*-----END CERTIFICATE-----\s*$` |
                        
                        
                        ??? example "Examples"
                            ```json
                            "-----BEGIN CERTIFICATE-----\nMIIB4TCCAYugAwIBAgIUCHhhffY1lzezGatYMR02gpEJChkwDQYJKoZIhvcNAQEL\nBQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM\nGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMjA5MjgwNTI4MTJaFw0yMzA5\nMjgwNTI4MTJaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw\nHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwXDANBgkqhkiG9w0BAQEF\nAANLADBIAkEArr89f2kggSO/yaCB6EwIQeT6ZptBoX0ZvCMI+DpkCwqOS5fwRbj1\nnEiPnLbzDDgMU8KCPAMhI7JpYRlHnipxWwIDAQABo1MwUTAdBgNVHQ4EFgQUiZ6J\nDwuF9QCh1vwQGXs2MutuQ9EwHwYDVR0jBBgwFoAUiZ6JDwuF9QCh1vwQGXs2Mutu\nQ9EwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAANBAFYIFM27BDiG725d\nVkhRblkvZzeRHhcwtDOQTC9d8M/LymN2y0nHSlJCZm/Lo/aH8viSY1vi1GSHfDz7\nTlfe8gs=\n-----END CERTIFICATE-----\n"
                            ```
                        
                        
                    ??? info "cert (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Client certificate |
                        | Description: | Client certificate in PEM format to authenticate against the Dockerd with. |
                        | Required: | No || Required if the following fields are set: |key || Type: | `string` |
                        | Minimum: | 1 |
                        | Must match pattern: | `^\s*-----BEGIN CERTIFICATE-----(\s*.*\s*)*-----END CERTIFICATE-----\s*$` |
                        
                        
                        ??? example "Examples"
                            ```json
                            "-----BEGIN CERTIFICATE-----\nMIIB4TCCAYugAwIBAgIUCHhhffY1lzezGatYMR02gpEJChkwDQYJKoZIhvcNAQEL\nBQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM\nGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMjA5MjgwNTI4MTJaFw0yMzA5\nMjgwNTI4MTJaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw\nHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwXDANBgkqhkiG9w0BAQEF\nAANLADBIAkEArr89f2kggSO/yaCB6EwIQeT6ZptBoX0ZvCMI+DpkCwqOS5fwRbj1\nnEiPnLbzDDgMU8KCPAMhI7JpYRlHnipxWwIDAQABo1MwUTAdBgNVHQ4EFgQUiZ6J\nDwuF9QCh1vwQGXs2MutuQ9EwHwYDVR0jBBgwFoAUiZ6JDwuF9QCh1vwQGXs2Mutu\nQ9EwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAANBAFYIFM27BDiG725d\nVkhRblkvZzeRHhcwtDOQTC9d8M/LymN2y0nHSlJCZm/Lo/aH8viSY1vi1GSHfDz7\nTlfe8gs=\n-----END CERTIFICATE-----\n"
                            ```
                        
                        
                    ??? info "host (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Host |
                        | Description: | Host name for Dockerd. |
                        | Required: | No || Type: | `string` |
                        | Minimum: | 1 |
                        | Maximum: | 255 |
                        | Must match pattern: | `^[a-z0-9./:_-]&#43;$` |
                        
                         ```json title="Default"
                         "npipe:////./pipe/docker_engine"
                         ```
                        
                        
                        ??? example "Examples"
                            ```json
                            'unix:///var/run/docker.sock'
                            ```
                        "
                            ```json
                            'npipe:////./pipe/docker_engine'
                            ```
                        
                        
                    ??? info "key (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Client key |
                        | Description: | Client private key in PEM format to authenticate against the Dockerd with. |
                        | Required: | No || Required if the following fields are set: |cert || Type: | `string` |
                        | Minimum: | 1 |
                        | Must match pattern: | `^\s*-----BEGIN ([A-Z]&#43;) PRIVATE KEY-----(\s*.*\s*)*-----END ([A-Z]&#43;) PRIVATE KEY-----\s*$` |
                        
                        
                        ??? example "Examples"
                            ```json
                            "-----BEGIN PRIVATE KEY-----\nMIIBVAIBADANBgkqhkiG9w0BAQEFAASCAT4wggE6AgEAAkEArr89f2kggSO/yaCB\n6EwIQeT6ZptBoX0ZvCMI+DpkCwqOS5fwRbj1nEiPnLbzDDgMU8KCPAMhI7JpYRlH\nnipxWwIDAQABAkBybu/x0MElcGi2u/J2UdwScsV7je5Tt12z82l7TJmZFFJ8RLmc\nrh00Gveb4VpGhd1+c3lZbO1mIT6v3vHM9A0hAiEA14EW6b+99XYza7+5uwIDuiM+\nBz3pkK+9tlfVXE7JyKsCIQDPlYJ5xtbuT+VvB3XOdD/VWiEqEmvE3flV0417Rqha\nEQIgbyxwNpwtEgEtW8untBrA83iU2kWNRY/z7ap4LkuS+0sCIGe2E+0RmfqQsllp\nicMvM2E92YnykCNYn6TwwCQSJjRxAiEAo9MmaVlK7YdhSMPo52uJYzd9MQZJqhq+\nlB1ZGDx/ARE=\n-----END PRIVATE KEY-----\n"
                            ```
                        
                        
            ??? info "**ContainerConfig** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "Domainname (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Domain name |
                        | Description: | Domain name for the plugin container. |
                        | Required: | No || Type: | `string` |
                        | Minimum: | 1 |
                        | Maximum: | 255 |
                        | Must match pattern: | `^[a-zA-Z0-9-_.]&#43;$` |
                        
                        
                    ??? info "Env (`map[string, string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Environment variables |
                        | Description: | Environment variables to set on the plugin container. |
                        | Required: | No || Type: | `map[string, string]` |
                        
                        ??? info "Key type"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Minimum: | 1 |
                            | Maximum: | 255 |
                            | Must match pattern: | `^[A-Z0-9_]&#43;$` |
                            
                        ??? info "Value type"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Maximum: | 32760 |
                            
                        
                        
                    ??? info "Hostname (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Hostname |
                        | Description: | Hostname for the plugin container. |
                        | Required: | No || Type: | `string` |
                        | Minimum: | 1 |
                        | Maximum: | 255 |
                        | Must match pattern: | `^[a-zA-Z0-9-_.]&#43;$` |
                        
                        
                    ??? info "MacAddress (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | MAC address |
                        | Description: | Media Access Control address for the container. |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^[a-fA-F0-9]{2}(:[a-fA-F0-9]{2}){5}$` |
                        
                        
                    ??? info "NetworkDisabled (`bool`)"
                        |    |    |
                        |----|----|
                        | Name: | Disable network |
                        | Description: | Disable container networking completely. |
                        | Required: | No || Type: | `bool` |
                        
                        
                    ??? info "User (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Username |
                        | Description: | User that will run the command inside the container. Optionally, a group can be specified in the user:group format. |
                        | Required: | No || Type: | `string` |
                        | Minimum: | 1 |
                        | Maximum: | 255 |
                        | Must match pattern: | `^[a-z_][a-z0-9_-]*[$]?(:[a-z_][a-z0-9_-]*[$]?)$` |
                        
                        
            ??? info "**Deployment** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "container (`reference[ContainerConfig]`)"
                        |    |    |
                        |----|----|
                        | Name: | Container configuration |
                        | Description: | Provides information about the container for the plugin. |
                        | Required: | No || Type: | `reference[ContainerConfig]` |
                        | Referenced object: | ContainerConfig *(see in the Objects section below)* |
                        
                        
                    ??? info "host (`reference[HostConfig]`)"
                        |    |    |
                        |----|----|
                        | Name: | Host configuration |
                        | Description: | Provides information about the container host for the plugin. |
                        | Required: | No || Type: | `reference[HostConfig]` |
                        | Referenced object: | HostConfig *(see in the Objects section below)* |
                        
                        
                    ??? info "imagePullPolicy (`enum[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Image pull policy |
                        | Description: | When to pull the plugin image. |
                        | Required: | No || Type: | `enum[string]` |
                        ??? info "Values"
                            - `Always` Always
                            - `IfNotPresent` If not present
                            - `Never` Never
                         ```json title="Default"
                         "IfNotPresent"
                         ```
                        
                        
                    ??? info "network (`reference[NetworkConfig]`)"
                        |    |    |
                        |----|----|
                        | Name: | Network configuration |
                        | Description: | Provides information about the container networking for the plugin. |
                        | Required: | No || Type: | `reference[NetworkConfig]` |
                        | Referenced object: | NetworkConfig *(see in the Objects section below)* |
                        
                        
                    ??? info "platform (`reference[PlatformConfig]`)"
                        |    |    |
                        |----|----|
                        | Name: | Platform configuration |
                        | Description: | Provides information about the container host platform for the plugin. |
                        | Required: | No || Type: | `reference[PlatformConfig]` |
                        | Referenced object: | PlatformConfig *(see in the Objects section below)* |
                        
                        
            ??? info "**HostConfig** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "CapAdd (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Add capabilities |
                        | Description: | Add capabilities to the container. |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "CapDrop (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Drop capabilities |
                        | Description: | Drop capabilities from the container. |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "CgroupnsMode (`enum[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | CGroup namespace mode |
                        | Description: | CGroup namespace mode to use for the container. |
                        | Required: | No || Type: | `enum[string]` |
                        ??? info "Values"
                            - `` Empty
                            - `host` Host
                            - `private` Private
                        
                    ??? info "Dns (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | DNS servers |
                        | Description: | DNS servers to use for lookup. |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "DnsOptions (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | DNS options |
                        | Description: | DNS options to look for. |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "DnsSearch (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | DNS search |
                        | Description: | DNS search domain. |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "ExtraHosts (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Extra hosts |
                        | Description: | Extra hosts entries to add |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "NetworkMode (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Network mode |
                        | Description: | Specifies either the network mode, the container network to attach to, or a name of a Docker network to use. |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^(none|bridge|host|container:[a-zA-Z0-9][a-zA-Z0-9_.-]&#43;|[a-zA-Z0-9][a-zA-Z0-9_.-]&#43;)$` |
                        
                        
                        ??? example "Examples"
                            ```json
                            "none"
                            ```
                        "
                            ```json
                            "bridge"
                            ```
                        "
                            ```json
                            "host"
                            ```
                        "
                            ```json
                            "container:container-name"
                            ```
                        "
                            ```json
                            "network-name"
                            ```
                        
                        
                    ??? info "PortBindings (`map[string, list[reference[PortBinding]]]`)"
                        |    |    |
                        |----|----|
                        | Name: | Port bindings |
                        | Description: | Ports to expose on the host machine. Ports are specified in the format of portnumber/protocol. |
                        | Required: | No || Type: | `map[string, list[reference[PortBinding]]]` |
                        
                        ??? info "Key type"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Must match pattern: | `^[0-9]&#43;(/[a-zA-Z0-9]&#43;)$` |
                            
                        ??? info "Value type"
                            |    |    |
                            |----|----|
                            | Type: | `list[reference[PortBinding]]` |
                            
                            ??? info "List Items"
                                |    |    |
                                |----|----|
                                | Type: | `reference[PortBinding]` |
                                | Referenced object: | PortBinding *(see in the Objects section below)* |
                                
                        
                        
            ??? info "**NetworkConfig** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**PlatformConfig** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**PortBinding** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "HostIP (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Host IP |
                        | Required: | No || Type: | `string` |
                        
                        
                    ??? info "HostPort (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Host port |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^0-9&#43;$` |
                        
                        
            ??? info "**Timeouts** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "http (`int`)"
                        |    |    |
                        |----|----|
                        | Name: | HTTP |
                        | Description: | HTTP timeout for the Docker API. |
                        | Required: | No || Type: | `int` |
                        | Minimum: | 100000000 |
                        | Units: | nanoseconds |
                        
                         ```json title="Default"
                         "15s"
                         ```


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
        |    |    |
        |----|----|
        | Type: | `scope` |
        | Root object: | Config |
        ???+ note "Properties"
            ??? info "deployment (`reference[Deployment]`)"
                |    |    |
                |----|----|
                | Name: | Deployment |
                | Description: | Deployment configuration for the plugin. |
                | Required: | No || Type: | `reference[Deployment]` |
                | Referenced object: | Deployment *(see in the Objects section below)* |
                
                
            ??? info "podman (`reference[Podman]`)"
                |    |    |
                |----|----|
                | Name: | Podman |
                | Description: | Podman CLI configuration |
                | Required: | No || Type: | `reference[Podman]` |
                | Referenced object: | Podman *(see in the Objects section below)* |
                
                
        ???+ note "Objects"
            ??? info "**Config** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "deployment (`reference[Deployment]`)"
                        |    |    |
                        |----|----|
                        | Name: | Deployment |
                        | Description: | Deployment configuration for the plugin. |
                        | Required: | No || Type: | `reference[Deployment]` |
                        | Referenced object: | Deployment *(see in the Objects section below)* |
                        
                        
                    ??? info "podman (`reference[Podman]`)"
                        |    |    |
                        |----|----|
                        | Name: | Podman |
                        | Description: | Podman CLI configuration |
                        | Required: | No || Type: | `reference[Podman]` |
                        | Referenced object: | Podman *(see in the Objects section below)* |
                        
                        
            ??? info "**ContainerConfig** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "Domainname (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Domain name |
                        | Description: | Domain name for the plugin container. |
                        | Required: | No || Type: | `string` |
                        | Minimum: | 1 |
                        | Maximum: | 255 |
                        | Must match pattern: | `^[a-zA-Z0-9-_.]&#43;$` |
                        
                        
                    ??? info "Env (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Environment variables |
                        | Description: | Environment variables to set on the plugin container. |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Minimum: | 1 |
                            | Maximum: | 32760 |
                            | Must match pattern: | `^.&#43;=.&#43;$` |
                            
                        
                    ??? info "Hostname (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Hostname |
                        | Description: | Hostname for the plugin container. |
                        | Required: | No || Type: | `string` |
                        | Minimum: | 1 |
                        | Maximum: | 255 |
                        | Must match pattern: | `^[a-zA-Z0-9-_.]&#43;$` |
                        
                        
                    ??? info "MacAddress (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | MAC address |
                        | Description: | Media Access Control address for the container. |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^[a-fA-F0-9]{2}(:[a-fA-F0-9]{2}){5}$` |
                        
                        
                    ??? info "NetworkDisabled (`bool`)"
                        |    |    |
                        |----|----|
                        | Name: | Disable network |
                        | Description: | Disable container networking completely. |
                        | Required: | No || Type: | `bool` |
                        
                        
                    ??? info "User (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Username |
                        | Description: | User that will run the command inside the container. Optionally, a group can be specified in the user:group format. |
                        | Required: | No || Type: | `string` |
                        | Minimum: | 1 |
                        | Maximum: | 255 |
                        | Must match pattern: | `^[a-z_][a-z0-9_-]*[$]?(:[a-z_][a-z0-9_-]*[$]?)$` |
                        
                        
            ??? info "**Deployment** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "container (`reference[ContainerConfig]`)"
                        |    |    |
                        |----|----|
                        | Name: | Container configuration |
                        | Description: | Provides information about the container for the plugin. |
                        | Required: | No || Type: | `reference[ContainerConfig]` |
                        | Referenced object: | ContainerConfig *(see in the Objects section below)* |
                        
                        
                    ??? info "host (`reference[HostConfig]`)"
                        |    |    |
                        |----|----|
                        | Name: | Host configuration |
                        | Description: | Provides information about the container host for the plugin. |
                        | Required: | No || Type: | `reference[HostConfig]` |
                        | Referenced object: | HostConfig *(see in the Objects section below)* |
                        
                        
                    ??? info "imagePullPolicy (`enum[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Image pull policy |
                        | Description: | When to pull the plugin image. |
                        | Required: | No || Type: | `enum[string]` |
                        ??? info "Values"
                            - `Always` Always
                            - `IfNotPresent` If not present
                            - `Never` Never
                         ```json title="Default"
                         "IfNotPresent"
                         ```
                        
                        
            ??? info "**HostConfig** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "Binds (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Volume Bindings |
                        | Description: | Volumes |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Minimum: | 1 |
                            | Maximum: | 32760 |
                            | Must match pattern: | `^.&#43;:.&#43;$` |
                            
                        
                    ??? info "CapAdd (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Add capabilities |
                        | Description: | Add capabilities to the container. |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "CapDrop (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Drop capabilities |
                        | Description: | Drop capabilities from the container. |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "CgroupnsMode (`enum[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | CGroup namespace mode |
                        | Description: | CGroup namespace mode to use for the container. |
                        | Required: | No || Type: | `enum[string]` |
                        ??? info "Values"
                            - `` Empty
                            - `host` Host
                            - `private` Private
                        
                    ??? info "Dns (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | DNS servers |
                        | Description: | DNS servers to use for lookup. |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "DnsOptions (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | DNS options |
                        | Description: | DNS options to look for. |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "DnsSearch (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | DNS search |
                        | Description: | DNS search domain. |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "ExtraHosts (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Extra hosts |
                        | Description: | Extra hosts entries to add |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "NetworkMode (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Network mode |
                        | Description: | Specifies either the network mode, the container network to attach to, or a name of a Docker network to use. |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^(none|bridge|host|container:[a-zA-Z0-9][a-zA-Z0-9_.-]&#43;|[a-zA-Z0-9][a-zA-Z0-9_.-]&#43;)$` |
                        
                        
                        ??? example "Examples"
                            ```json
                            "none"
                            ```
                        "
                            ```json
                            "bridge"
                            ```
                        "
                            ```json
                            "host"
                            ```
                        "
                            ```json
                            "container:container-name"
                            ```
                        "
                            ```json
                            "network-name"
                            ```
                        
                        
                    ??? info "PortBindings (`map[string, list[reference[PortBinding]]]`)"
                        |    |    |
                        |----|----|
                        | Name: | Port bindings |
                        | Description: | Ports to expose on the host machine. Ports are specified in the format of portnumber/protocol. |
                        | Required: | No || Type: | `map[string, list[reference[PortBinding]]]` |
                        
                        ??? info "Key type"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Must match pattern: | `^[0-9]&#43;(/[a-zA-Z0-9]&#43;)$` |
                            
                        ??? info "Value type"
                            |    |    |
                            |----|----|
                            | Type: | `list[reference[PortBinding]]` |
                            
                            ??? info "List Items"
                                |    |    |
                                |----|----|
                                | Type: | `reference[PortBinding]` |
                                | Referenced object: | PortBinding *(see in the Objects section below)* |
                                
                        
                        
            ??? info "**Podman** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "cgroupNs (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | CGroup namespace |
                        | Description: | Provides the Cgroup Namespace settings for the container |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^host|ns:/proc/\d&#43;/ns/cgroup|container:.&#43;|private$` |
                        
                        
                    ??? info "containerName (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Container Name |
                        | Description: | Provides name of the container |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^.*$` |
                        
                        
                    ??? info "imageArchitecture (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Podman image Architecture |
                        | Description: | Provides Podman Image Architecture |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^.*$` |
                        
                         ```json title="Default"
                         "amd64"
                         ```
                        
                        
                    ??? info "imageOS (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Podman Image OS |
                        | Description: | Provides Podman Image Operating System |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^.*$` |
                        
                         ```json title="Default"
                         "linux"
                         ```
                        
                        
                    ??? info "networkMode (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Network Mode |
                        | Description: | Provides network settings for the container |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^bridge:.*|host|none$` |
                        
                        
                    ??? info "path (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Podman path |
                        | Description: | Provides the path of podman executable |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^.*$` |
                        
                         ```json title="Default"
                         "podman"
                         ```
                        
                        
            ??? info "**PortBinding** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "HostIP (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Host IP |
                        | Required: | No || Type: | `string` |
                        
                        
                    ??? info "HostPort (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Host port |
                        | Required: | No || Type: | `string` |
                        | Must match pattern: | `^0-9&#43;$` |


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
        |    |    |
        |----|----|
        | Type: | `scope` |
        | Root object: | Config |
        ???+ note "Properties"
            ??? info "connection (`reference[Connection]`)"
                |    |    |
                |----|----|
                | Name: | Connection |
                | Description: | Docker connection information. |
                | Required: | No || Type: | `reference[Connection]` |
                | Referenced object: | Connection *(see in the Objects section below)* |
                
                
            ??? info "pod (`reference[Pod]`)"
                |    |    |
                |----|----|
                | Name: | Pod |
                | Description: | Pod configuration for the plugin. |
                | Required: | No || Type: | `reference[Pod]` |
                | Referenced object: | Pod *(see in the Objects section below)* |
                
                
            ??? info "timeouts (`reference[Timeouts]`)"
                |    |    |
                |----|----|
                | Name: | Timeouts |
                | Description: | Timeouts for the Docker connection. |
                | Required: | No || Type: | `reference[Timeouts]` |
                | Referenced object: | Timeouts *(see in the Objects section below)* |
                
                
        ???+ note "Objects"
            ??? info "**AWSElasticBlockStoreVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**AzureDiskVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**AzureFileVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**CSIVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**CephFSVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**CinderVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**Config** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "connection (`reference[Connection]`)"
                        |    |    |
                        |----|----|
                        | Name: | Connection |
                        | Description: | Docker connection information. |
                        | Required: | No || Type: | `reference[Connection]` |
                        | Referenced object: | Connection *(see in the Objects section below)* |
                        
                        
                    ??? info "pod (`reference[Pod]`)"
                        |    |    |
                        |----|----|
                        | Name: | Pod |
                        | Description: | Pod configuration for the plugin. |
                        | Required: | No || Type: | `reference[Pod]` |
                        | Referenced object: | Pod *(see in the Objects section below)* |
                        
                        
                    ??? info "timeouts (`reference[Timeouts]`)"
                        |    |    |
                        |----|----|
                        | Name: | Timeouts |
                        | Description: | Timeouts for the Docker connection. |
                        | Required: | No || Type: | `reference[Timeouts]` |
                        | Referenced object: | Timeouts *(see in the Objects section below)* |
                        
                        
            ??? info "**ConfigMapVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**Connection** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "bearerToken (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Bearer token |
                        | Description: | Bearer token to authenticate against the Kubernetes API with. |
                        | Required: | No || Type: | `string` |
                        
                        
                    ??? info "burst (`int`)"
                        |    |    |
                        |----|----|
                        | Name: | Burst |
                        | Description: | Burst value for query throttling. |
                        | Required: | No || Type: | `int` |
                        | Minimum: | 0 |
                        
                         ```json title="Default"
                         10
                         ```
                        
                        
                    ??? info "cacert (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | CA certificate |
                        | Description: | CA certificate in PEM format to verify Kubernetes server certificate against. |
                        | Required: | No || Required if the following fields are set: |cert, key || Type: | `string` |
                        | Minimum: | 1 |
                        | Must match pattern: | `^\s*-----BEGIN CERTIFICATE-----(\s*.*\s*)*-----END CERTIFICATE-----\s*$` |
                        
                        
                        ??? example "Examples"
                            ```json
                            "-----BEGIN CERTIFICATE-----\nMIIB4TCCAYugAwIBAgIUCHhhffY1lzezGatYMR02gpEJChkwDQYJKoZIhvcNAQEL\nBQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM\nGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMjA5MjgwNTI4MTJaFw0yMzA5\nMjgwNTI4MTJaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw\nHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwXDANBgkqhkiG9w0BAQEF\nAANLADBIAkEArr89f2kggSO/yaCB6EwIQeT6ZptBoX0ZvCMI+DpkCwqOS5fwRbj1\nnEiPnLbzDDgMU8KCPAMhI7JpYRlHnipxWwIDAQABo1MwUTAdBgNVHQ4EFgQUiZ6J\nDwuF9QCh1vwQGXs2MutuQ9EwHwYDVR0jBBgwFoAUiZ6JDwuF9QCh1vwQGXs2Mutu\nQ9EwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAANBAFYIFM27BDiG725d\nVkhRblkvZzeRHhcwtDOQTC9d8M/LymN2y0nHSlJCZm/Lo/aH8viSY1vi1GSHfDz7\nTlfe8gs=\n-----END CERTIFICATE-----\n"
                            ```
                        
                        
                    ??? info "cert (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Client certificate |
                        | Description: | Client certificate in PEM format to authenticate against Kubernetes with. |
                        | Required: | No || Required if the following fields are set: |key || Type: | `string` |
                        | Minimum: | 1 |
                        | Must match pattern: | `^\s*-----BEGIN CERTIFICATE-----(\s*.*\s*)*-----END CERTIFICATE-----\s*$` |
                        
                        
                        ??? example "Examples"
                            ```json
                            "-----BEGIN CERTIFICATE-----\nMIIB4TCCAYugAwIBAgIUCHhhffY1lzezGatYMR02gpEJChkwDQYJKoZIhvcNAQEL\nBQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM\nGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMjA5MjgwNTI4MTJaFw0yMzA5\nMjgwNTI4MTJaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw\nHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwXDANBgkqhkiG9w0BAQEF\nAANLADBIAkEArr89f2kggSO/yaCB6EwIQeT6ZptBoX0ZvCMI+DpkCwqOS5fwRbj1\nnEiPnLbzDDgMU8KCPAMhI7JpYRlHnipxWwIDAQABo1MwUTAdBgNVHQ4EFgQUiZ6J\nDwuF9QCh1vwQGXs2MutuQ9EwHwYDVR0jBBgwFoAUiZ6JDwuF9QCh1vwQGXs2Mutu\nQ9EwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAANBAFYIFM27BDiG725d\nVkhRblkvZzeRHhcwtDOQTC9d8M/LymN2y0nHSlJCZm/Lo/aH8viSY1vi1GSHfDz7\nTlfe8gs=\n-----END CERTIFICATE-----\n"
                            ```
                        
                        
                    ??? info "host (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Host |
                        | Description: | Host name and port of the Kubernetes server |
                        | Required: | No || Type: | `string` |
                        
                         ```json title="Default"
                         "kubernetes.default.svc"
                         ```
                        
                        
                    ??? info "key (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Client key |
                        | Description: | Client private key in PEM format to authenticate against Kubernetes with. |
                        | Required: | No || Required if the following fields are set: |cert || Type: | `string` |
                        | Minimum: | 1 |
                        | Must match pattern: | `^\s*-----BEGIN ([A-Z]&#43;) PRIVATE KEY-----(\s*.*\s*)*-----END ([A-Z]&#43;) PRIVATE KEY-----\s*$` |
                        
                        
                        ??? example "Examples"
                            ```json
                            "-----BEGIN PRIVATE KEY-----\nMIIBVAIBADANBgkqhkiG9w0BAQEFAASCAT4wggE6AgEAAkEArr89f2kggSO/yaCB\n6EwIQeT6ZptBoX0ZvCMI+DpkCwqOS5fwRbj1nEiPnLbzDDgMU8KCPAMhI7JpYRlH\nnipxWwIDAQABAkBybu/x0MElcGi2u/J2UdwScsV7je5Tt12z82l7TJmZFFJ8RLmc\nrh00Gveb4VpGhd1+c3lZbO1mIT6v3vHM9A0hAiEA14EW6b+99XYza7+5uwIDuiM+\nBz3pkK+9tlfVXE7JyKsCIQDPlYJ5xtbuT+VvB3XOdD/VWiEqEmvE3flV0417Rqha\nEQIgbyxwNpwtEgEtW8untBrA83iU2kWNRY/z7ap4LkuS+0sCIGe2E+0RmfqQsllp\nicMvM2E92YnykCNYn6TwwCQSJjRxAiEAo9MmaVlK7YdhSMPo52uJYzd9MQZJqhq+\nlB1ZGDx/ARE=\n-----END PRIVATE KEY-----\n"
                            ```
                        
                        
                    ??? info "password (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Password |
                        | Description: | Password for basic authentication. |
                        | Required: | No || Required if the following fields are set: |username || Type: | `string` |
                        
                        
                    ??? info "path (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Path |
                        | Description: | Path to the API server. |
                        | Required: | No || Type: | `string` |
                        
                         ```json title="Default"
                         "/api"
                         ```
                        
                        
                    ??? info "qps (`float`)"
                        |    |    |
                        |----|----|
                        | Name: | QPS |
                        | Description: | Queries Per Second allowed against the API. |
                        | Required: | No || Type: | `float` |
                        | Minimum: | 0 |
                        | Units: | queries |
                        
                        
                         ```json title="Default"
                         5.0
                         ```
                        
                        
                    ??? info "serverName (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | TLS server name |
                        | Description: | Expected TLS server name to verify in the certificate. |
                        | Required: | No || Type: | `string` |
                        
                        
                    ??? info "username (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Username |
                        | Description: | Username for basic authentication. |
                        | Required: | No || Required if the following fields are set: |password || Type: | `string` |
                        
                        
            ??? info "**Container** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "args (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Arguments |
                        | Description: | Arguments to the entypoint (command). |
                        | Required: | No || Type: | `list[string]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "command (`list[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Command |
                        | Description: | Override container entry point. Not executed with a shell. |
                        | Required: | No || Type: | `list[string]` |
                        | Minimum items: | 1 |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            
                        
                    ??? info "env (`list[object]`)"
                        |    |    |
                        |----|----|
                        | Name: | Environment |
                        | Description: | Environment variables for this container. |
                        | Required: | No || Type: | `list[object]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `object` |
                            
                            ???+ note "Properties"
                                ??? info "name (`string`)"
                                    |    |    |
                                    |----|----|
                                    | Name: | Name |
                                    | Description: | Environment variables name. |
                                    | Required: | Yes || Type: | `string` |
                                    | Minimum: | 1 |
                                    | Must match pattern: | `^[a-zA-Z0-9-._]&#43;$` |
                                    
                                    
                                ??? info "value (`string`)"
                                    |    |    |
                                    |----|----|
                                    | Name: | Value |
                                    | Description: | Value for the environment variable. |
                                    | Required: | No || Required if the following fields are not set: |valueFrom || Conflicts the following fields: |valueFrom || Type: | `string` |
                                    
                                    
                                ??? info "valueFrom (`reference[EnvFromSource]`)"
                                    |    |    |
                                    |----|----|
                                    | Name: | Value source |
                                    | Description: | Load the environment variable from a secret or config map. |
                                    | Required: | No || Required if the following fields are not set: |value || Conflicts the following fields: |value || Type: | `reference[EnvFromSource]` |
                                    | Referenced object: | EnvFromSource *(see in the Objects section below)* |
                                    
                                    
                        
                    ??? info "envFrom (`list[reference[EnvFromSource]]`)"
                        |    |    |
                        |----|----|
                        | Name: | Environment sources |
                        | Description: | List of sources to populate the environment variables from. |
                        | Required: | No || Type: | `list[reference[EnvFromSource]]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `reference[EnvFromSource]` |
                            | Referenced object: | EnvFromSource *(see in the Objects section below)* |
                            
                        
                    ??? info "image (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Image |
                        | Description: | Container image to use for this container. |
                        | Required: | Yes || Type: | `string` |
                        | Minimum: | 1 |
                        | Must match pattern: | `^[a-zA-Z0-9_\-:./]&#43;$` |
                        
                        
                    ??? info "imagePullPolicy (`enum[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Volume device |
                        | Description: | Mount a raw block device within the container. |
                        | Required: | No || Type: | `enum[string]` |
                        ??? info "Values"
                            - `Always` Always
                            - `IfNotPresent` If not present
                            - `Never` Never
                         ```json title="Default"
                         "IfNotPresent"
                         ```
                        
                        
                    ??? info "name (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Name |
                        | Description: | Name for the container. Each container in a pod must have a unique name. |
                        | Required: | Yes || Type: | `string` |
                        | Maximum: | 253 |
                        | Must match pattern: | `^[a-z0-9]($|[a-z0-9\-_]*[a-z0-9])$` |
                        
                        
                    ??? info "securityContext (`object`)"
                        |    |    |
                        |----|----|
                        | Name: | Volume device |
                        | Description: | Mount a raw block device within the container. |
                        | Required: | No || Type: | `object` |
                        
                        ???+ note "Properties"
                            ??? info "capabilities (`object`)"
                                |    |    |
                                |----|----|
                                | Name: | Capabilities |
                                | Description: | Add or drop POSIX capabilities. |
                                | Required: | No || Type: | `object` |
                                
                                ???+ note "Properties"
                                    ??? info "add (`list[string]`)"
                                        |    |    |
                                        |----|----|
                                        | Name: | Add |
                                        | Description: | Add POSIX capabilities. |
                                        | Required: | No || Type: | `list[string]` |
                                        
                                        ??? info "List Items"
                                            |    |    |
                                            |----|----|
                                            | Type: | `string` |
                                            | Minimum: | 1 |
                                            | Must match pattern: | `^[A-Z_]&#43;$` |
                                            
                                        
                                    ??? info "drop (`list[string]`)"
                                        |    |    |
                                        |----|----|
                                        | Name: | Drop |
                                        | Description: | Drop POSIX capabilities. |
                                        | Required: | No || Type: | `list[string]` |
                                        
                                        ??? info "List Items"
                                            |    |    |
                                            |----|----|
                                            | Type: | `string` |
                                            | Minimum: | 1 |
                                            | Must match pattern: | `^[A-Z_]&#43;$` |
                                            
                                        
                                
                            ??? info "privileged (`bool`)"
                                |    |    |
                                |----|----|
                                | Name: | Privileged |
                                | Description: | Run the container in privileged mode. |
                                | Required: | No || Type: | `bool` |
                                
                                
                        
                    ??? info "volumeDevices (`list[object]`)"
                        |    |    |
                        |----|----|
                        | Name: | Volume device |
                        | Description: | Mount a raw block device within the container. |
                        | Required: | No || Type: | `list[object]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `object` |
                            
                            ???+ note "Properties"
                                ??? info "devicePath (`string`)"
                                    |    |    |
                                    |----|----|
                                    | Name: | Device path |
                                    | Description: | Path inside the container the device will be mapped to. |
                                    | Required: | Yes || Type: | `string` |
                                    | Minimum: | 1 |
                                    
                                    
                                ??? info "name (`string`)"
                                    |    |    |
                                    |----|----|
                                    | Name: | Name |
                                    | Description: | Must match the persistent volume claim in the pod. |
                                    | Required: | Yes || Type: | `string` |
                                    | Minimum: | 1 |
                                    
                                    
                        
                    ??? info "volumeMounts (`list[object]`)"
                        |    |    |
                        |----|----|
                        | Name: | Volume mounts |
                        | Description: | Pod volumes to mount on this container. |
                        | Required: | No || Type: | `list[object]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `object` |
                            
                            ???+ note "Properties"
                                ??? info "mountPath (`string`)"
                                    |    |    |
                                    |----|----|
                                    | Name: | Mount path |
                                    | Description: | Path to mount the volume on inside the container. |
                                    | Required: | Yes || Type: | `string` |
                                    | Minimum: | 1 |
                                    
                                    
                                ??? info "name (`string`)"
                                    |    |    |
                                    |----|----|
                                    | Name: | Volume name |
                                    | Description: | Must match the pod volume to mount. |
                                    | Required: | Yes || Type: | `string` |
                                    | Minimum: | 1 |
                                    
                                    
                                ??? info "readOnly (`bool`)"
                                    |    |    |
                                    |----|----|
                                    | Name: | Read only |
                                    | Description: | Mount volume as read-only. |
                                    | Required: | No || Type: | `bool` |
                                    
                                     ```json title="Default"
                                     false
                                     ```
                                    
                                    
                                ??? info "subPath (`string`)"
                                    |    |    |
                                    |----|----|
                                    | Name: | Subpath |
                                    | Description: | Path from the volume to mount. |
                                    | Required: | No || Type: | `string` |
                                    | Minimum: | 1 |
                                    
                                    
                        
                    ??? info "workingDir (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Working directory |
                        | Description: | Override the container working directory. |
                        | Required: | No || Type: | `string` |
                        
                        
            ??? info "**DownwardAPIVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**EmptyDirVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "medium (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Medium |
                        | Description: | How to store the empty directory |
                        | Required: | No || Type: | `string` |
                        | Minimum: | 1 |
                        | Must match pattern: | `^(|Memory|HugePages|HugePages-.*)$` |
                        
                        
            ??? info "**EnvFromSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "configMapRef (`object`)"
                        |    |    |
                        |----|----|
                        | Name: | Config map source |
                        | Description: | Populates the source from a config map. |
                        | Required: | No || Required if the following fields are not set: |secretRef || Conflicts the following fields: |secretRef || Type: | `object` |
                        
                        ???+ note "Properties"
                            ??? info "name (`string`)"
                                |    |    |
                                |----|----|
                                | Name: | Name |
                                | Description: | Name of the referenced config map. |
                                | Required: | Yes || Type: | `string` |
                                | Minimum: | 1 |
                                
                                
                            ??? info "optional (`bool`)"
                                |    |    |
                                |----|----|
                                | Name: | Optional |
                                | Description: | Specify whether the config map must be defined. |
                                | Required: | No || Type: | `bool` |
                                
                                
                        
                    ??? info "prefix (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Prefix |
                        | Description: | An optional identifier to prepend to each key in the ConfigMap. |
                        | Required: | No || Type: | `string` |
                        | Minimum: | 1 |
                        | Must match pattern: | `^[a-zA-Z0-9-._]&#43;$` |
                        
                        
                    ??? info "secretRef (`object`)"
                        |    |    |
                        |----|----|
                        | Name: | Secret source |
                        | Description: | Populates the source from a secret. |
                        | Required: | No || Required if the following fields are not set: |configMapRef || Conflicts the following fields: |configMapRef || Type: | `object` |
                        
                        ???+ note "Properties"
                            ??? info "name (`string`)"
                                |    |    |
                                |----|----|
                                | Name: | Name |
                                | Description: | Name of the referenced secret. |
                                | Required: | Yes || Type: | `string` |
                                | Minimum: | 1 |
                                
                                
                            ??? info "optional (`bool`)"
                                |    |    |
                                |----|----|
                                | Name: | Optional |
                                | Description: | Specify whether the secret must be defined. |
                                | Required: | No || Type: | `bool` |
                                
                                
                        
            ??? info "**EphemeralVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**FCVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**FlexVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**FlockerVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**GCEPersistentDiskVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**GlusterfsVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**HostPathVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "path (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Path |
                        | Description: | Path to the directory on the host. |
                        | Required: | Yes || Type: | `string` |
                        | Minimum: | 1 |
                        
                        
                        ??? example "Examples"
                            ```json
                            "/srv/volume1"
                            ```
                        
                        
                    ??? info "type (`enum[string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Type |
                        | Description: | Type of the host path. |
                        | Required: | No || Type: | `enum[string]` |
                        ??? info "Values"
                            - `` Unset
                            - `BlockDevice` Block device
                            - `CharDevice` Character device
                            - `Directory` Directory
                            - `DirectoryOrCreate` Create directory if not found
                            - `File` File
                            - `FileOrCreate` Create file if not found
                            - `Socket` Socket
                        
            ??? info "**ISCSIVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**NFSVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**ObjectMeta** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "annotations (`map[string, string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Annotations |
                        | Description: | Kubernetes annotations to appy. See https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ for details. |
                        | Required: | No || Type: | `map[string, string]` |
                        
                        ??? info "Key type"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Must match pattern: | `^(|([a-zA-Z](|[a-zA-Z\-.]{0,251}[a-zA-Z0-9]))/)([a-zA-Z](|[a-zA-Z\\-]{0,61}[a-zA-Z0-9]))$` |
                            
                        ??? info "Value type"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Maximum: | 63 |
                            | Must match pattern: | `^(|[a-zA-Z0-9]&#43;(|[-_.][a-zA-Z0-9]&#43;)*[a-zA-Z0-9])$` |
                            
                        
                        
                    ??? info "generateName (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Name prefix |
                        | Description: | Name prefix to generate pod names from. |
                        | Required: | No || Conflicts the following fields: |name || Type: | `string` |
                        
                        
                    ??? info "labels (`map[string, string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Labels |
                        | Description: | Kubernetes labels to appy. See https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ for details. |
                        | Required: | No || Type: | `map[string, string]` |
                        
                        ??? info "Key type"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Must match pattern: | `^(|([a-zA-Z](|[a-zA-Z\-.]{0,251}[a-zA-Z0-9]))/)([a-zA-Z](|[a-zA-Z\\-]{0,61}[a-zA-Z0-9]))$` |
                            
                        ??? info "Value type"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Maximum: | 63 |
                            | Must match pattern: | `^(|[a-zA-Z0-9]&#43;(|[-_.][a-zA-Z0-9]&#43;)*[a-zA-Z0-9])$` |
                            
                        
                        
                    ??? info "name (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Name |
                        | Description: | Pod name. |
                        | Required: | No || Conflicts the following fields: |generateName || Type: | `string` |
                        
                        
                    ??? info "namespace (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Namespace |
                        | Description: | Kubernetes namespace to deploy in. |
                        | Required: | No || Type: | `string` |
                        | Maximum: | 253 |
                        | Must match pattern: | `^[a-z0-9]($|[a-z0-9\-_]*[a-z0-9])$` |
                        
                         ```json title="Default"
                         "default"
                         ```
                        
                        
            ??? info "**PersistentVolumeClaimVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**PhotonPersistentDiskVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**Pod** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "metadata (`reference[ObjectMeta]`)"
                        |    |    |
                        |----|----|
                        | Name: | Metadata |
                        | Description: | Pod metadata. |
                        | Required: | No || Type: | `reference[ObjectMeta]` |
                        | Referenced object: | ObjectMeta *(see in the Objects section below)* |
                        
                        
                    ??? info "spec (`reference[PodSpec]`)"
                        |    |    |
                        |----|----|
                        | Name: | Specification |
                        | Description: | Pod specification. |
                        | Required: | No || Type: | `reference[PodSpec]` |
                        | Referenced object: | PodSpec *(see in the Objects section below)* |
                        
                        
            ??? info "**PodSpec** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "affinity (`object`)"
                        |    |    |
                        |----|----|
                        | Name: | Affinity rules |
                        | Description: | Affinity rules. |
                        | Required: | No || Type: | `object` |
                        
                        ???+ note "Properties"
                            ??? info "podAffinity (`object`)"
                                |    |    |
                                |----|----|
                                | Name: | Pod Affinity |
                                | Description: | The pod affinity rules. |
                                | Required: | No || Type: | `object` |
                                
                                ???+ note "Properties"
                                    ??? info "requiredDuringSchedulingIgnoredDuringExecution (`list[object]`)"
                                        |    |    |
                                        |----|----|
                                        | Name: | Required During Scheduling Ignored During Execution |
                                        | Description: | Hard pod affinity rules. |
                                        | Required: | No || Type: | `list[object]` |
                                        | Minimum items: | 1 |
                                        
                                        ??? info "List Items"
                                            |    |    |
                                            |----|----|
                                            | Type: | `object` |
                                            
                                            ???+ note "Properties"
                                                ??? info "labelSelector (`object`)"
                                                    |    |    |
                                                    |----|----|
                                                    | Name: | MatchExpressions |
                                                    | Description: | Expressions for the label selector. |
                                                    | Required: | No || Type: | `object` |
                                                    
                                                    ???+ note "Properties"
                                                        ??? info "matchExpressions (`list[object]`)"
                                                            |    |    |
                                                            |----|----|
                                                            | Name: | MatchExpression |
                                                            | Description: | Expression for the label selector. |
                                                            | Required: | No || Type: | `list[object]` |
                                                            | Minimum items: | 1 |
                                                            
                                                            ??? info "List Items"
                                                                |    |    |
                                                                |----|----|
                                                                | Type: | `object` |
                                                                
                                                                ???+ note "Properties"
                                                                    ??? info "key (`string`)"
                                                                        |    |    |
                                                                        |----|----|
                                                                        | Name: | Key |
                                                                        | Description: | Key for the label that the system uses to denote the domain. |
                                                                        | Required: | No || Type: | `string` |
                                                                        | Maximum: | 63 |
                                                                        | Must match pattern: | `^(|[a-zA-Z0-9]&#43;(|[-_.][a-zA-Z0-9]&#43;)*[a-zA-Z0-9])$` |
                                                                        
                                                                        
                                                                    ??? info "operator (`string`)"
                                                                        |    |    |
                                                                        |----|----|
                                                                        | Name: | Operator |
                                                                        | Description: | Logical operator for Kubernetes to use when interpreting the rules.
                                                                        			 You can use In, NotIn, Exists, DoesNotExist, Gt and Lt. |
                                                                        | Required: | No || Type: | `string` |
                                                                        | Maximum: | 253 |
                                                                        | Must match pattern: | `In|NotIn|Exists|DoesNotExist|Gt|Lt` |
                                                                        
                                                                        
                                                                    ??? info "values (`list[string]`)"
                                                                        |    |    |
                                                                        |----|----|
                                                                        | Name: | Values |
                                                                        | Description: | Values for the label that the system uses to denote the domain. |
                                                                        | Required: | No || Type: | `list[string]` |
                                                                        | Minimum items: | 1 |
                                                                        
                                                                        ??? info "List Items"
                                                                            |    |    |
                                                                            |----|----|
                                                                            | Type: | `string` |
                                                                            | Maximum: | 63 |
                                                                            | Must match pattern: | `^(|[a-zA-Z0-9]&#43;(|[-_.][a-zA-Z0-9]&#43;)*[a-zA-Z0-9])$` |
                                                                            
                                                                        
                                                            
                                                    
                                                ??? info "topologyKey (`string`)"
                                                    |    |    |
                                                    |----|----|
                                                    | Name: | TopologyKey |
                                                    | Description: | Key for the node label that the system uses to denote the domain. |
                                                    | Required: | No || Type: | `string` |
                                                    | Maximum: | 63 |
                                                    | Must match pattern: | `^(|[a-zA-Z0-9]&#43;(|[-_./][a-zA-Z0-9]&#43;)*[a-zA-Z0-9])$` |
                                                    
                                                    
                                        
                                
                            ??? info "podAntiAffinity (`object`)"
                                |    |    |
                                |----|----|
                                | Name: | Pod Affinity |
                                | Description: | The pod affinity rules. |
                                | Required: | No || Type: | `object` |
                                
                                ???+ note "Properties"
                                    ??? info "requiredDuringSchedulingIgnoredDuringExecution (`list[object]`)"
                                        |    |    |
                                        |----|----|
                                        | Name: | Required During Scheduling Ignored During Execution |
                                        | Description: | Hard pod affinity rules. |
                                        | Required: | No || Type: | `list[object]` |
                                        | Minimum items: | 1 |
                                        
                                        ??? info "List Items"
                                            |    |    |
                                            |----|----|
                                            | Type: | `object` |
                                            
                                            ???+ note "Properties"
                                                ??? info "labelSelector (`object`)"
                                                    |    |    |
                                                    |----|----|
                                                    | Name: | MatchExpressions |
                                                    | Description: | Expressions for the label selector. |
                                                    | Required: | No || Type: | `object` |
                                                    
                                                    ???+ note "Properties"
                                                        ??? info "matchExpressions (`list[object]`)"
                                                            |    |    |
                                                            |----|----|
                                                            | Name: | MatchExpression |
                                                            | Description: | Expression for the label selector. |
                                                            | Required: | No || Type: | `list[object]` |
                                                            | Minimum items: | 1 |
                                                            
                                                            ??? info "List Items"
                                                                |    |    |
                                                                |----|----|
                                                                | Type: | `object` |
                                                                
                                                                ???+ note "Properties"
                                                                    ??? info "key (`string`)"
                                                                        |    |    |
                                                                        |----|----|
                                                                        | Name: | Key |
                                                                        | Description: | Key for the label that the system uses to denote the domain. |
                                                                        | Required: | No || Type: | `string` |
                                                                        | Maximum: | 63 |
                                                                        | Must match pattern: | `^(|[a-zA-Z0-9]&#43;(|[-_.][a-zA-Z0-9]&#43;)*[a-zA-Z0-9])$` |
                                                                        
                                                                        
                                                                    ??? info "operator (`string`)"
                                                                        |    |    |
                                                                        |----|----|
                                                                        | Name: | Operator |
                                                                        | Description: | Logical operator for Kubernetes to use when interpreting the rules.
                                                                        			 You can use In, NotIn, Exists, DoesNotExist, Gt and Lt. |
                                                                        | Required: | No || Type: | `string` |
                                                                        | Maximum: | 253 |
                                                                        | Must match pattern: | `In|NotIn|Exists|DoesNotExist|Gt|Lt` |
                                                                        
                                                                        
                                                                    ??? info "values (`list[string]`)"
                                                                        |    |    |
                                                                        |----|----|
                                                                        | Name: | Values |
                                                                        | Description: | Values for the label that the system uses to denote the domain. |
                                                                        | Required: | No || Type: | `list[string]` |
                                                                        | Minimum items: | 1 |
                                                                        
                                                                        ??? info "List Items"
                                                                            |    |    |
                                                                            |----|----|
                                                                            | Type: | `string` |
                                                                            | Maximum: | 63 |
                                                                            | Must match pattern: | `^(|[a-zA-Z0-9]&#43;(|[-_.][a-zA-Z0-9]&#43;)*[a-zA-Z0-9])$` |
                                                                            
                                                                        
                                                            
                                                    
                                                ??? info "topologyKey (`string`)"
                                                    |    |    |
                                                    |----|----|
                                                    | Name: | TopologyKey |
                                                    | Description: | Key for the node label that the system uses to denote the domain. |
                                                    | Required: | No || Type: | `string` |
                                                    | Maximum: | 63 |
                                                    | Must match pattern: | `^(|[a-zA-Z0-9]&#43;(|[-_./][a-zA-Z0-9]&#43;)*[a-zA-Z0-9])$` |
                                                    
                                                    
                                        
                                
                        
                    ??? info "containers (`list[reference[Container]]`)"
                        |    |    |
                        |----|----|
                        | Name: | Containers |
                        | Description: | A list of containers belonging to the pod. |
                        | Required: | No || Type: | `list[reference[Container]]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `reference[Container]` |
                            | Referenced object: | Container *(see in the Objects section below)* |
                            
                        
                    ??? info "initContainers (`list[reference[Container]]`)"
                        |    |    |
                        |----|----|
                        | Name: | Init containers |
                        | Description: | A list of initialization containers belonging to the pod. |
                        | Required: | No || Type: | `list[reference[Container]]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `reference[Container]` |
                            | Referenced object: | Container *(see in the Objects section below)* |
                            
                        
                    ??? info "nodeSelector (`map[string, string]`)"
                        |    |    |
                        |----|----|
                        | Name: | Labels |
                        | Description: | Node labels you want the target node to have. |
                        | Required: | No || Type: | `map[string, string]` |
                        
                        ??? info "Key type"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Must match pattern: | `^(|([a-zA-Z](|[a-zA-Z\-.]{0,251}[a-zA-Z0-9]))/)([a-zA-Z](|[a-zA-Z\\-]{0,61}[a-zA-Z0-9]))$` |
                            
                        ??? info "Value type"
                            |    |    |
                            |----|----|
                            | Type: | `string` |
                            | Maximum: | 63 |
                            | Must match pattern: | `^(|[a-zA-Z0-9]&#43;(|[-_.][a-zA-Z0-9]&#43;)*[a-zA-Z0-9])$` |
                            
                        
                        
                    ??? info "pluginContainer (`object`)"
                        |    |    |
                        |----|----|
                        | Name: | Plugin container |
                        | Description: | The container to run the plugin in. |
                        | Required: | Yes || Type: | `object` |
                        
                        ???+ note "Properties"
                            ??? info "env (`list[object]`)"
                                |    |    |
                                |----|----|
                                | Name: | Environment |
                                | Description: | Environment variables for this container. |
                                | Required: | No || Type: | `list[object]` |
                                
                                ??? info "List Items"
                                    |    |    |
                                    |----|----|
                                    | Type: | `object` |
                                    
                                    ???+ note "Properties"
                                        ??? info "name (`string`)"
                                            |    |    |
                                            |----|----|
                                            | Name: | Name |
                                            | Description: | Environment variables name. |
                                            | Required: | Yes || Type: | `string` |
                                            | Minimum: | 1 |
                                            | Must match pattern: | `^[a-zA-Z0-9-._]&#43;$` |
                                            
                                            
                                        ??? info "value (`string`)"
                                            |    |    |
                                            |----|----|
                                            | Name: | Value |
                                            | Description: | Value for the environment variable. |
                                            | Required: | No || Required if the following fields are not set: |valueFrom || Conflicts the following fields: |valueFrom || Type: | `string` |
                                            
                                            
                                        ??? info "valueFrom (`reference[EnvFromSource]`)"
                                            |    |    |
                                            |----|----|
                                            | Name: | Value source |
                                            | Description: | Load the environment variable from a secret or config map. |
                                            | Required: | No || Required if the following fields are not set: |value || Conflicts the following fields: |value || Type: | `reference[EnvFromSource]` |
                                            | Referenced object: | EnvFromSource *(see in the Objects section below)* |
                                            
                                            
                                
                            ??? info "envFrom (`list[reference[EnvFromSource]]`)"
                                |    |    |
                                |----|----|
                                | Name: | Environment sources |
                                | Description: | List of sources to populate the environment variables from. |
                                | Required: | No || Type: | `list[reference[EnvFromSource]]` |
                                
                                ??? info "List Items"
                                    |    |    |
                                    |----|----|
                                    | Type: | `reference[EnvFromSource]` |
                                    | Referenced object: | EnvFromSource *(see in the Objects section below)* |
                                    
                                
                            ??? info "imagePullPolicy (`enum[string]`)"
                                |    |    |
                                |----|----|
                                | Name: | Volume device |
                                | Description: | Mount a raw block device within the container. |
                                | Required: | No || Type: | `enum[string]` |
                                ??? info "Values"
                                    - `Always` Always
                                    - `IfNotPresent` If not present
                                    - `Never` Never
                                 ```json title="Default"
                                 "IfNotPresent"
                                 ```
                                
                                
                            ??? info "name (`string`)"
                                |    |    |
                                |----|----|
                                | Name: | Name |
                                | Description: | Name for the container. Each container in a pod must have a unique name. |
                                | Required: | No || Type: | `string` |
                                | Maximum: | 253 |
                                | Must match pattern: | `^[a-z0-9]($|[a-z0-9\-_]*[a-z0-9])$` |
                                
                                 ```json title="Default"
                                 "arcaflow-plugin-container"
                                 ```
                                
                                
                            ??? info "securityContext (`object`)"
                                |    |    |
                                |----|----|
                                | Name: | Volume device |
                                | Description: | Mount a raw block device within the container. |
                                | Required: | No || Type: | `object` |
                                
                                ???+ note "Properties"
                                    ??? info "capabilities (`object`)"
                                        |    |    |
                                        |----|----|
                                        | Name: | Capabilities |
                                        | Description: | Add or drop POSIX capabilities. |
                                        | Required: | No || Type: | `object` |
                                        
                                        ???+ note "Properties"
                                            ??? info "add (`list[string]`)"
                                                |    |    |
                                                |----|----|
                                                | Name: | Add |
                                                | Description: | Add POSIX capabilities. |
                                                | Required: | No || Type: | `list[string]` |
                                                
                                                ??? info "List Items"
                                                    |    |    |
                                                    |----|----|
                                                    | Type: | `string` |
                                                    | Minimum: | 1 |
                                                    | Must match pattern: | `^[A-Z_]&#43;$` |
                                                    
                                                
                                            ??? info "drop (`list[string]`)"
                                                |    |    |
                                                |----|----|
                                                | Name: | Drop |
                                                | Description: | Drop POSIX capabilities. |
                                                | Required: | No || Type: | `list[string]` |
                                                
                                                ??? info "List Items"
                                                    |    |    |
                                                    |----|----|
                                                    | Type: | `string` |
                                                    | Minimum: | 1 |
                                                    | Must match pattern: | `^[A-Z_]&#43;$` |
                                                    
                                                
                                        
                                    ??? info "privileged (`bool`)"
                                        |    |    |
                                        |----|----|
                                        | Name: | Privileged |
                                        | Description: | Run the container in privileged mode. |
                                        | Required: | No || Type: | `bool` |
                                        
                                        
                                
                            ??? info "volumeDevices (`list[object]`)"
                                |    |    |
                                |----|----|
                                | Name: | Volume device |
                                | Description: | Mount a raw block device within the container. |
                                | Required: | No || Type: | `list[object]` |
                                
                                ??? info "List Items"
                                    |    |    |
                                    |----|----|
                                    | Type: | `object` |
                                    
                                    ???+ note "Properties"
                                        ??? info "devicePath (`string`)"
                                            |    |    |
                                            |----|----|
                                            | Name: | Device path |
                                            | Description: | Path inside the container the device will be mapped to. |
                                            | Required: | Yes || Type: | `string` |
                                            | Minimum: | 1 |
                                            
                                            
                                        ??? info "name (`string`)"
                                            |    |    |
                                            |----|----|
                                            | Name: | Name |
                                            | Description: | Must match the persistent volume claim in the pod. |
                                            | Required: | Yes || Type: | `string` |
                                            | Minimum: | 1 |
                                            
                                            
                                
                            ??? info "volumeMounts (`list[object]`)"
                                |    |    |
                                |----|----|
                                | Name: | Volume mounts |
                                | Description: | Pod volumes to mount on this container. |
                                | Required: | No || Type: | `list[object]` |
                                
                                ??? info "List Items"
                                    |    |    |
                                    |----|----|
                                    | Type: | `object` |
                                    
                                    ???+ note "Properties"
                                        ??? info "mountPath (`string`)"
                                            |    |    |
                                            |----|----|
                                            | Name: | Mount path |
                                            | Description: | Path to mount the volume on inside the container. |
                                            | Required: | Yes || Type: | `string` |
                                            | Minimum: | 1 |
                                            
                                            
                                        ??? info "name (`string`)"
                                            |    |    |
                                            |----|----|
                                            | Name: | Volume name |
                                            | Description: | Must match the pod volume to mount. |
                                            | Required: | Yes || Type: | `string` |
                                            | Minimum: | 1 |
                                            
                                            
                                        ??? info "readOnly (`bool`)"
                                            |    |    |
                                            |----|----|
                                            | Name: | Read only |
                                            | Description: | Mount volume as read-only. |
                                            | Required: | No || Type: | `bool` |
                                            
                                             ```json title="Default"
                                             false
                                             ```
                                            
                                            
                                        ??? info "subPath (`string`)"
                                            |    |    |
                                            |----|----|
                                            | Name: | Subpath |
                                            | Description: | Path from the volume to mount. |
                                            | Required: | No || Type: | `string` |
                                            | Minimum: | 1 |
                                            
                                            
                                
                        
                    ??? info "volumes (`list[reference[Volume]]`)"
                        |    |    |
                        |----|----|
                        | Name: | Volumes |
                        | Description: | A list of volumes that can be mounted by containers belonging to the pod. |
                        | Required: | No || Type: | `list[reference[Volume]]` |
                        
                        ??? info "List Items"
                            |    |    |
                            |----|----|
                            | Type: | `reference[Volume]` |
                            | Referenced object: | Volume *(see in the Objects section below)* |
                            
                        
            ??? info "**PortworxVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**ProjectedVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**QuobyteVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**RBDVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**ScaleIOVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**SecretVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**StorageOSVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
                
            ??? info "**Timeouts** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "http (`int`)"
                        |    |    |
                        |----|----|
                        | Name: | HTTP |
                        | Description: | HTTP timeout for the Docker API. |
                        | Required: | No || Type: | `int` |
                        | Minimum: | 100000000 |
                        | Units: | nanoseconds |
                        
                         ```json title="Default"
                         "15s"
                         ```
                        
                        
            ??? info "**Volume** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    ??? info "awsElasticBlockStore (`reference[AWSElasticBlockStoreVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | AWS EBS |
                        | Description: | AWS Elastic Block Storage. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[AWSElasticBlockStoreVolumeSource]` |
                        | Referenced object: | AWSElasticBlockStoreVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "azureDisk (`reference[AzureDiskVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Azure Data Disk |
                        | Description: | Mount an Azure Data Disk as a volume. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[AzureDiskVolumeSource]` |
                        | Referenced object: | AzureDiskVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "azureFile (`reference[AzureFileVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Azure File |
                        | Description: | Mount an Azure File Service mount. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[AzureFileVolumeSource]` |
                        | Referenced object: | AzureFileVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "cephfs (`reference[CephFSVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | CephFS |
                        | Description: | Mount a CephFS volume. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[CephFSVolumeSource]` |
                        | Referenced object: | CephFSVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "cinder (`reference[CinderVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Cinder |
                        | Description: | Mount a cinder volume attached and mounted on the host machine. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[CinderVolumeSource]` |
                        | Referenced object: | CinderVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "configMap (`reference[ConfigMapVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | ConfigMap |
                        | Description: | Mount a ConfigMap as a volume. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[ConfigMapVolumeSource]` |
                        | Referenced object: | ConfigMapVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "csi (`reference[CSIVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | CSI Volume |
                        | Description: | Mount a volume using a CSI driver. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, ephemeral || Type: | `reference[CSIVolumeSource]` |
                        | Referenced object: | CSIVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "downwardAPI (`reference[DownwardAPIVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Downward API |
                        | Description: | Specify a volume that the pod should mount itself. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[DownwardAPIVolumeSource]` |
                        | Referenced object: | DownwardAPIVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "emptyDir (`reference[EmptyDirVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Empty directory |
                        | Description: | Temporary empty directory. |
                        | Required: | No || Required if the following fields are not set: |hostPath, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[EmptyDirVolumeSource]` |
                        | Referenced object: | EmptyDirVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "ephemeral (`reference[EphemeralVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Ephemeral |
                        | Description: | Mount a volume that is handled by a cluster storage driver. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi || Type: | `reference[EphemeralVolumeSource]` |
                        | Referenced object: | EphemeralVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "fc (`reference[FCVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Fibre Channel |
                        | Description: | Mount a Fibre Channel volume that&#39;s attached to the host machine. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[FCVolumeSource]` |
                        | Referenced object: | FCVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "flexVolume (`reference[FlexVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Flex |
                        | Description: | Mount a generic volume provisioned/attached using an exec based plugin. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[FlexVolumeSource]` |
                        | Referenced object: | FlexVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "flocker (`reference[FlockerVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Flocker |
                        | Description: | Mount a Flocker volume. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[FlockerVolumeSource]` |
                        | Referenced object: | FlockerVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "gcePersistentDisk (`reference[GCEPersistentDiskVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | GCE disk |
                        | Description: | Google Cloud disk. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[GCEPersistentDiskVolumeSource]` |
                        | Referenced object: | GCEPersistentDiskVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "glusterfs (`reference[GlusterfsVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | GlusterFS |
                        | Description: | Mount a Gluster volume. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[GlusterfsVolumeSource]` |
                        | Referenced object: | GlusterfsVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "hostPath (`reference[HostPathVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Host path |
                        | Description: | Mount volume from the host. |
                        | Required: | No || Required if the following fields are not set: |emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[HostPathVolumeSource]` |
                        | Referenced object: | HostPathVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "iscsi (`reference[ISCSIVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | iSCSI |
                        | Description: | Mount an iSCSI volume. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[ISCSIVolumeSource]` |
                        | Referenced object: | ISCSIVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "name (`string`)"
                        |    |    |
                        |----|----|
                        | Name: | Name |
                        | Description: | The name this volume can be referenced by. |
                        | Required: | Yes || Type: | `string` |
                        | Maximum: | 253 |
                        | Must match pattern: | `^[a-z0-9]($|[a-z0-9\-_]*[a-z0-9])$` |
                        
                        
                    ??? info "nfs (`reference[NFSVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | NFS |
                        | Description: | Mount an NFS share. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[NFSVolumeSource]` |
                        | Referenced object: | NFSVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "persistentVolumeClaim (`reference[PersistentVolumeClaimVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Persistent Volume Claim |
                        | Description: | Mount a Persistent Volume Claim. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[PersistentVolumeClaimVolumeSource]` |
                        | Referenced object: | PersistentVolumeClaimVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "photonPersistentDisk (`reference[PhotonPersistentDiskVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | PhotonController persistent disk |
                        | Description: | Mount a PhotonController persistent disk as a volume. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[PhotonPersistentDiskVolumeSource]` |
                        | Referenced object: | PhotonPersistentDiskVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "portworxVolume (`reference[PortworxVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Portworx Volume |
                        | Description: | Mount a Portworx volume. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, scaleIO, storageos, csi, ephemeral || Type: | `reference[PortworxVolumeSource]` |
                        | Referenced object: | PortworxVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "projected (`reference[ProjectedVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Projected |
                        | Description: | Projected items for all in one resources secrets, configmaps, and downward API. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[ProjectedVolumeSource]` |
                        | Referenced object: | ProjectedVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "quobyte (`reference[QuobyteVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | quobyte |
                        | Description: | Mount Quobyte volume from the host. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[QuobyteVolumeSource]` |
                        | Referenced object: | QuobyteVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "rbd (`reference[RBDVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Rados Block Device |
                        | Description: | Mount a Rados Block Device. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[RBDVolumeSource]` |
                        | Referenced object: | RBDVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "scaleIO (`reference[ScaleIOVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | ScaleIO Persistent Volume |
                        | Description: | Mount a ScaleIO persistent volume. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, storageos, csi, ephemeral || Type: | `reference[ScaleIOVolumeSource]` |
                        | Referenced object: | ScaleIOVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "secret (`reference[SecretVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | Secret |
                        | Description: | Mount a Kubernetes secret. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[SecretVolumeSource]` |
                        | Referenced object: | SecretVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "storageos (`reference[StorageOSVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | StorageOS Volume |
                        | Description: | Mount a StorageOS volume. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, csi, ephemeral || Type: | `reference[StorageOSVolumeSource]` |
                        | Referenced object: | StorageOSVolumeSource *(see in the Objects section below)* |
                        
                        
                    ??? info "vsphereVolume (`reference[VsphereVirtualDiskVolumeSource]`)"
                        |    |    |
                        |----|----|
                        | Name: | vSphere Virtual Disk |
                        | Description: | Mount a vSphere Virtual Disk as a volume. |
                        | Required: | No || Required if the following fields are not set: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Conflicts the following fields: |hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral || Type: | `reference[VsphereVirtualDiskVolumeSource]` |
                        | Referenced object: | VsphereVirtualDiskVolumeSource *(see in the Objects section below)* |
                        
                        
            ??? info "**VsphereVirtualDiskVolumeSource** (`object`)"
                |    |    |
                |----|----|
                | Type: | `object` |
                
                ???+ note "Properties"
                    *None*
