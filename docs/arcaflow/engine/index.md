# Configuring the Arcaflow Engine

All of these changes require specifying the config when you run the arcaflow-engine. To do so, create a config YAML file, and run the engine with the `-config your-arcaflow-config.yaml` flag.

## Logging

Logging is useful when you need more information about what is happening while you run a workload.

### Basic logging

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

### Step logging

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

## Deployers

If you want to change the default deployer from Docker to Podman or Kubernetes, you will need to set up a configuration YAML file and pass it to the engine with the `-config your-arcaflow-config.yaml` flag.

You can then change the deployer type like this:

```yaml
deployer:
  type: podman
  # Deployer-specific options 
```

### Docker deployer

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

### Podman deployer

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

### Kubernetes deployer

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

For the full list of options please check the reference manual below. If you need to use a kubeconfig, please use the [kubeconfig plugin](https://github.com/arcalot/arcaflow-plugin-kubeconfig) in your workflow to convert it to this data structure.

### Deployer reference manual

This section holds all supported properties of each deployer.

#### Docker deployer

<ul><li><strong>Type:</strong> Scope <span title="Scopes hold one or more objects that can be referenced inside the properties of those objects by ref types. Ref types always reference the closest scope.">💡</span></li><li><strong>Root object:</strong> Config</li>
<li><strong>Properties</strong><ul><li><details><summary>connection (Object reference to &ldquo;Connection&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
                <ul><li><strong>Name: </strong> Connection</li><li><strong>Description: </strong> Docker connection information.</li><li><strong>Type:</strong> Object reference to &ldquo;Connection&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Connection</li></ul>
            </details></li><li><details><summary>deployment (Object reference to &ldquo;Deployment&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
                <ul><li><strong>Name: </strong> Deployment</li><li><strong>Description: </strong> Deployment configuration for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;Deployment&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Deployment</li></ul>
            </details></li><li><details><summary>timeouts (Object reference to &ldquo;Timeouts&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
                <ul><li><strong>Name: </strong> Timeouts</li><li><strong>Description: </strong> Timeouts for the Docker connection.</li><li><strong>Type:</strong> Object reference to &ldquo;Timeouts&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Timeouts</li></ul>
            </details></li></ul></li>
<li><details><summary><strong>Objects</strong></summary><details><summary>Config (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>connection (Object reference to &ldquo;Connection&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Connection</li><li><strong>Description: </strong> Docker connection information.</li><li><strong>Type:</strong> Object reference to &ldquo;Connection&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Connection</li></ul>
            </details></li><li><details><summary>deployment (Object reference to &ldquo;Deployment&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Deployment</li><li><strong>Description: </strong> Deployment configuration for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;Deployment&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Deployment</li></ul>
            </details></li><li><details><summary>timeouts (Object reference to &ldquo;Timeouts&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Timeouts</li><li><strong>Description: </strong> Timeouts for the Docker connection.</li><li><strong>Type:</strong> Object reference to &ldquo;Timeouts&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Timeouts</li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Connection (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>cacert (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> CA certificate</li><li><strong>Description: </strong> CA certificate in PEM format to verify the Dockerd server certificate against.</li><li><strong>Required if the following fields are set:</strong>cert, key</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;-----BEGIN CERTIFICATE-----\nMIIB4TCCAYugAwIBAgIUCHhhffY1lzezGatYMR02gpEJChkwDQYJKoZIhvcNAQEL\nBQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM\nGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMjA5MjgwNTI4MTJaFw0yMzA5\nMjgwNTI4MTJaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw\nHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwXDANBgkqhkiG9w0BAQEF\nAANLADBIAkEArr89f2kggSO/yaCB6EwIQeT6ZptBoX0ZvCMI&#43;DpkCwqOS5fwRbj1\nnEiPnLbzDDgMU8KCPAMhI7JpYRlHnipxWwIDAQABo1MwUTAdBgNVHQ4EFgQUiZ6J\nDwuF9QCh1vwQGXs2MutuQ9EwHwYDVR0jBBgwFoAUiZ6JDwuF9QCh1vwQGXs2Mutu\nQ9EwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAANBAFYIFM27BDiG725d\nVkhRblkvZzeRHhcwtDOQTC9d8M/LymN2y0nHSlJCZm/Lo/aH8viSY1vi1GSHfDz7\nTlfe8gs=\n-----END CERTIFICATE-----\n&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^\s*-----BEGIN CERTIFICATE-----(\s*.*\s*)*-----END CERTIFICATE-----\s*$</code></li></ul>
            </details></li><li><details><summary>cert (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Client certificate</li><li><strong>Description: </strong> Client certificate in PEM format to authenticate against the Dockerd with.</li><li><strong>Required if the following fields are set:</strong>key</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;-----BEGIN CERTIFICATE-----\nMIIB4TCCAYugAwIBAgIUCHhhffY1lzezGatYMR02gpEJChkwDQYJKoZIhvcNAQEL\nBQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM\nGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMjA5MjgwNTI4MTJaFw0yMzA5\nMjgwNTI4MTJaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw\nHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwXDANBgkqhkiG9w0BAQEF\nAANLADBIAkEArr89f2kggSO/yaCB6EwIQeT6ZptBoX0ZvCMI&#43;DpkCwqOS5fwRbj1\nnEiPnLbzDDgMU8KCPAMhI7JpYRlHnipxWwIDAQABo1MwUTAdBgNVHQ4EFgQUiZ6J\nDwuF9QCh1vwQGXs2MutuQ9EwHwYDVR0jBBgwFoAUiZ6JDwuF9QCh1vwQGXs2Mutu\nQ9EwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAANBAFYIFM27BDiG725d\nVkhRblkvZzeRHhcwtDOQTC9d8M/LymN2y0nHSlJCZm/Lo/aH8viSY1vi1GSHfDz7\nTlfe8gs=\n-----END CERTIFICATE-----\n&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^\s*-----BEGIN CERTIFICATE-----(\s*.*\s*)*-----END CERTIFICATE-----\s*$</code></li></ul>
            </details></li><li><details><summary>host (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Host</li><li><strong>Description: </strong> Host name for Dockerd.</li><li><strong>Default (JSON encoded)</strong>: &#34;unix:///var/run/docker.sock&#34;</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#39;unix:///var/run/docker.sock&#39;</code></li><li><code>&#39;npipe:////./pipe/docker_engine&#39;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[a-z0-9./:_-]&#43;$</code></li></ul>
            </details></li><li><details><summary>key (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Client key</li><li><strong>Description: </strong> Client private key in PEM format to authenticate against the Dockerd with.</li><li><strong>Required if the following fields are set:</strong>cert</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;-----BEGIN PRIVATE KEY-----\nMIIBVAIBADANBgkqhkiG9w0BAQEFAASCAT4wggE6AgEAAkEArr89f2kggSO/yaCB\n6EwIQeT6ZptBoX0ZvCMI&#43;DpkCwqOS5fwRbj1nEiPnLbzDDgMU8KCPAMhI7JpYRlH\nnipxWwIDAQABAkBybu/x0MElcGi2u/J2UdwScsV7je5Tt12z82l7TJmZFFJ8RLmc\nrh00Gveb4VpGhd1&#43;c3lZbO1mIT6v3vHM9A0hAiEA14EW6b&#43;99XYza7&#43;5uwIDuiM&#43;\nBz3pkK&#43;9tlfVXE7JyKsCIQDPlYJ5xtbuT&#43;VvB3XOdD/VWiEqEmvE3flV0417Rqha\nEQIgbyxwNpwtEgEtW8untBrA83iU2kWNRY/z7ap4LkuS&#43;0sCIGe2E&#43;0RmfqQsllp\nicMvM2E92YnykCNYn6TwwCQSJjRxAiEAo9MmaVlK7YdhSMPo52uJYzd9MQZJqhq&#43;\nlB1ZGDx/ARE=\n-----END PRIVATE KEY-----\n&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^\s*-----BEGIN ([A-Z]&#43;) PRIVATE KEY-----(\s*.*\s*)*-----END ([A-Z]&#43;) PRIVATE KEY-----\s*$</code></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>ContainerConfig (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>Domainname (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Domain name</li><li><strong>Description: </strong> Domain name for the plugin container.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[a-zA-Z0-9-_.]&#43;$</code></li></ul>
            </details></li><li><details><summary>Env (Map ofString <span title="Strings hold a list of printable characters.">💡</span>&rarr;String <span title="Strings hold a list of printable characters.">💡</span><span title="Maps hold a set of keys associated with values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Environment variables</li><li><strong>Description: </strong> Environment variables to set on the plugin container.</li><li><strong>Type:</strong> Map ofString <span title="Strings hold a list of printable characters.">💡</span>&rarr;String <span title="Strings hold a list of printable characters.">💡</span><span title="Maps hold a set of keys associated with values.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[A-Z0-9_]&#43;$</code></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Maximum length:</strong> 32760</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>Hostname (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Hostname</li><li><strong>Description: </strong> Hostname for the plugin container.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[a-zA-Z0-9-_.]&#43;$</code></li></ul>
            </details></li><li><details><summary>MacAddress (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> MAC address</li><li><strong>Description: </strong> Media Access Control address for the container.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^[a-fA-F0-9]{2}(:[a-fA-F0-9]{2}){5}$</code></li></ul>
            </details></li><li><details><summary>NetworkDisabled (Boolean <span title="Booleans hold true or false values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Disable network</li><li><strong>Description: </strong> Disable container networking completely.</li><li><strong>Type:</strong> Boolean <span title="Booleans hold true or false values.">💡</span></li></ul>
            </details></li><li><details><summary>User (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Username</li><li><strong>Description: </strong> User that will run the command inside the container. Optionally, a group can be specified in the user:group format.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[a-z_][a-z0-9_-]*[$]?(:[a-z_][a-z0-9_-]*[$]?)$</code></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Deployment (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>container (Object reference to &ldquo;ContainerConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Container configuration</li><li><strong>Description: </strong> Provides information about the container for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;ContainerConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> ContainerConfig</li></ul>
            </details></li><li><details><summary>host (Object reference to &ldquo;HostConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Host configuration</li><li><strong>Description: </strong> Provides information about the container host for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;HostConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> HostConfig</li></ul>
            </details></li><li><details><summary>imagePullPolicy (Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Image pull policy</li><li><strong>Description: </strong> When to pull the plugin image.</li><li><strong>Default (JSON encoded)</strong>: &#34;IfNotPresent&#34;</li><li><strong>Type:</strong> Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span></li><li>
    <details><summary>Values</summary>
        <ul><li><strong><code>Always</code>:</strong> Always</li><li><strong><code>IfNotPresent</code>:</strong> If not present</li><li><strong><code>Never</code>:</strong> Never</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>network (Object reference to &ldquo;NetworkConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Network configuration</li><li><strong>Description: </strong> Provides information about the container networking for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;NetworkConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> NetworkConfig</li></ul>
            </details></li><li><details><summary>platform (Object reference to &ldquo;PlatformConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Platform configuration</li><li><strong>Description: </strong> Provides information about the container host platform for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;PlatformConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> PlatformConfig</li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>HostConfig (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>CapAdd (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Add capabilities</li><li><strong>Description: </strong> Add capabilities to the container.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>CapDrop (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Drop capabilities</li><li><strong>Description: </strong> Drop capabilities from the container.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>CgroupnsMode (Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> CGroup namespace mode</li><li><strong>Description: </strong> CGroup namespace mode to use for the container.</li><li><strong>Type:</strong> Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span></li><li>
    <details><summary>Values</summary>
        <ul><li><strong><code></code>:</strong> Empty</li><li><strong><code>host</code>:</strong> Host</li><li><strong><code>private</code>:</strong> Private</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>Dns (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> DNS servers</li><li><strong>Description: </strong> DNS servers to use for lookup.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>DnsOptions (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> DNS options</li><li><strong>Description: </strong> DNS options to look for.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>DnsSearch (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> DNS search</li><li><strong>Description: </strong> DNS search domain.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>ExtraHosts (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Extra hosts</li><li><strong>Description: </strong> Extra hosts entries to add</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>NetworkMode (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Network mode</li><li><strong>Description: </strong> Specifies either the network mode, the container network to attach to, or a name of a Docker network to use.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;none&#34;</code></li><li><code>&#34;bridge&#34;</code></li><li><code>&#34;host&#34;</code></li><li><code>&#34;container:container-name&#34;</code></li><li><code>&#34;network-name&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^(none|bridge|host|container:[a-zA-Z0-9][a-zA-Z0-9_.-]&#43;|[a-zA-Z0-9][a-zA-Z0-9_.-]&#43;)$</code></li></ul>
            </details></li><li><details><summary>PortBindings (Map ofString <span title="Strings hold a list of printable characters.">💡</span>&rarr;String <span title="Strings hold a list of printable characters.">💡</span><span title="Maps hold a set of keys associated with values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Port bindings</li><li><strong>Description: </strong> Ports to expose on the host machine. Ports are specified in the format of portnumber/protocol.</li><li><strong>Type:</strong> Map ofString <span title="Strings hold a list of printable characters.">💡</span>&rarr;String <span title="Strings hold a list of printable characters.">💡</span><span title="Maps hold a set of keys associated with values.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^[0-9]&#43;(/[a-zA-Z0-9]&#43;)$</code></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> List ofObject reference to &ldquo;PortBinding&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;PortBinding&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> PortBinding</li></ul>
    </details>
</li>
</ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>NetworkConfig (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>PlatformConfig (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>PortBinding (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>HostIP (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Host IP</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>HostPort (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Host port</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^0-9&#43;$</code></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Timeouts (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>http (Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> HTTP</li><li><strong>Description: </strong> HTTP timeout for the Docker API.</li><li><strong>Default (JSON encoded)</strong>: &#34;15s&#34;</li><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum:</strong> 100000000</li><li><strong>Units:</strong> nanoseconds</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details></details></li>
</ul>

#### Kubernetes deployer

<ul><li><strong>Type:</strong> Scope <span title="Scopes hold one or more objects that can be referenced inside the properties of those objects by ref types. Ref types always reference the closest scope.">💡</span></li><li><strong>Root object:</strong> Config</li>
<li><strong>Properties</strong><ul><li><details><summary>connection (Object reference to &ldquo;Connection&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
                <ul><li><strong>Name: </strong> Connection</li><li><strong>Description: </strong> Docker connection information.</li><li><strong>Type:</strong> Object reference to &ldquo;Connection&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Connection</li></ul>
            </details></li><li><details><summary>pod (Object reference to &ldquo;Pod&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
                <ul><li><strong>Name: </strong> Pod</li><li><strong>Description: </strong> Pod configuration for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;Pod&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Pod</li></ul>
            </details></li><li><details><summary>timeouts (Object reference to &ldquo;Timeouts&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
                <ul><li><strong>Name: </strong> Timeouts</li><li><strong>Description: </strong> Timeouts for the Docker connection.</li><li><strong>Type:</strong> Object reference to &ldquo;Timeouts&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Timeouts</li></ul>
            </details></li></ul></li>
<li><details><summary><strong>Objects</strong></summary><details><summary>AWSElasticBlockStoreVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>AzureDiskVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>AzureFileVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>CSIVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>CephFSVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>CinderVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>Config (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>connection (Object reference to &ldquo;Connection&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Connection</li><li><strong>Description: </strong> Docker connection information.</li><li><strong>Type:</strong> Object reference to &ldquo;Connection&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Connection</li></ul>
            </details></li><li><details><summary>pod (Object reference to &ldquo;Pod&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Pod</li><li><strong>Description: </strong> Pod configuration for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;Pod&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Pod</li></ul>
            </details></li><li><details><summary>timeouts (Object reference to &ldquo;Timeouts&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Timeouts</li><li><strong>Description: </strong> Timeouts for the Docker connection.</li><li><strong>Type:</strong> Object reference to &ldquo;Timeouts&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Timeouts</li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>ConfigMapVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>Connection (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>bearerToken (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Bearer token</li><li><strong>Description: </strong> Bearer token to authenticate against the Kubernetes API with.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>burst (Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Burst</li><li><strong>Description: </strong> Burst value for query throttling.</li><li><strong>Default (JSON encoded)</strong>: 10</li><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum:</strong> 0</li>
</ul>
            </details></li><li><details><summary>cacert (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> CA certificate</li><li><strong>Description: </strong> CA certificate in PEM format to verify Kubernetes server certificate against.</li><li><strong>Required if the following fields are set:</strong>cert, key</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;-----BEGIN CERTIFICATE-----\nMIIB4TCCAYugAwIBAgIUCHhhffY1lzezGatYMR02gpEJChkwDQYJKoZIhvcNAQEL\nBQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM\nGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMjA5MjgwNTI4MTJaFw0yMzA5\nMjgwNTI4MTJaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw\nHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwXDANBgkqhkiG9w0BAQEF\nAANLADBIAkEArr89f2kggSO/yaCB6EwIQeT6ZptBoX0ZvCMI&#43;DpkCwqOS5fwRbj1\nnEiPnLbzDDgMU8KCPAMhI7JpYRlHnipxWwIDAQABo1MwUTAdBgNVHQ4EFgQUiZ6J\nDwuF9QCh1vwQGXs2MutuQ9EwHwYDVR0jBBgwFoAUiZ6JDwuF9QCh1vwQGXs2Mutu\nQ9EwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAANBAFYIFM27BDiG725d\nVkhRblkvZzeRHhcwtDOQTC9d8M/LymN2y0nHSlJCZm/Lo/aH8viSY1vi1GSHfDz7\nTlfe8gs=\n-----END CERTIFICATE-----\n&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^\s*-----BEGIN CERTIFICATE-----(\s*.*\s*)*-----END CERTIFICATE-----\s*$</code></li></ul>
            </details></li><li><details><summary>cert (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Client certificate</li><li><strong>Description: </strong> Client certificate in PEM format to authenticate against Kubernetes with.</li><li><strong>Required if the following fields are set:</strong>key</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;-----BEGIN CERTIFICATE-----\nMIIB4TCCAYugAwIBAgIUCHhhffY1lzezGatYMR02gpEJChkwDQYJKoZIhvcNAQEL\nBQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM\nGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMjA5MjgwNTI4MTJaFw0yMzA5\nMjgwNTI4MTJaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw\nHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwXDANBgkqhkiG9w0BAQEF\nAANLADBIAkEArr89f2kggSO/yaCB6EwIQeT6ZptBoX0ZvCMI&#43;DpkCwqOS5fwRbj1\nnEiPnLbzDDgMU8KCPAMhI7JpYRlHnipxWwIDAQABo1MwUTAdBgNVHQ4EFgQUiZ6J\nDwuF9QCh1vwQGXs2MutuQ9EwHwYDVR0jBBgwFoAUiZ6JDwuF9QCh1vwQGXs2Mutu\nQ9EwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAANBAFYIFM27BDiG725d\nVkhRblkvZzeRHhcwtDOQTC9d8M/LymN2y0nHSlJCZm/Lo/aH8viSY1vi1GSHfDz7\nTlfe8gs=\n-----END CERTIFICATE-----\n&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^\s*-----BEGIN CERTIFICATE-----(\s*.*\s*)*-----END CERTIFICATE-----\s*$</code></li></ul>
            </details></li><li><details><summary>host (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Host</li><li><strong>Description: </strong> Host name and port of the Kubernetes server</li><li><strong>Default (JSON encoded)</strong>: &#34;kubernetes.default.svc&#34;</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>key (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Client key</li><li><strong>Description: </strong> Client private key in PEM format to authenticate against Kubernetes with.</li><li><strong>Required if the following fields are set:</strong>cert</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;-----BEGIN PRIVATE KEY-----\nMIIBVAIBADANBgkqhkiG9w0BAQEFAASCAT4wggE6AgEAAkEArr89f2kggSO/yaCB\n6EwIQeT6ZptBoX0ZvCMI&#43;DpkCwqOS5fwRbj1nEiPnLbzDDgMU8KCPAMhI7JpYRlH\nnipxWwIDAQABAkBybu/x0MElcGi2u/J2UdwScsV7je5Tt12z82l7TJmZFFJ8RLmc\nrh00Gveb4VpGhd1&#43;c3lZbO1mIT6v3vHM9A0hAiEA14EW6b&#43;99XYza7&#43;5uwIDuiM&#43;\nBz3pkK&#43;9tlfVXE7JyKsCIQDPlYJ5xtbuT&#43;VvB3XOdD/VWiEqEmvE3flV0417Rqha\nEQIgbyxwNpwtEgEtW8untBrA83iU2kWNRY/z7ap4LkuS&#43;0sCIGe2E&#43;0RmfqQsllp\nicMvM2E92YnykCNYn6TwwCQSJjRxAiEAo9MmaVlK7YdhSMPo52uJYzd9MQZJqhq&#43;\nlB1ZGDx/ARE=\n-----END PRIVATE KEY-----\n&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^\s*-----BEGIN ([A-Z]&#43;) PRIVATE KEY-----(\s*.*\s*)*-----END ([A-Z]&#43;) PRIVATE KEY-----\s*$</code></li></ul>
            </details></li><li><details><summary>password (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Password</li><li><strong>Description: </strong> Password for basic authentication.</li><li><strong>Required if the following fields are set:</strong>username</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>path (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Path</li><li><strong>Description: </strong> Path to the API server.</li><li><strong>Default (JSON encoded)</strong>: &#34;/api&#34;</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>qps (Floating point number (64 bits, signed) <span title="Floats hold fractional numbers. They are imprecise due to their internal representation.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> QPS</li><li><strong>Description: </strong> Queries Per Second allowed against the API.</li><li><strong>Default (JSON encoded)</strong>: 5.0</li><li><strong>Type:</strong> Floating point number (64 bits, signed) <span title="Floats hold fractional numbers. They are imprecise due to their internal representation.">💡</span></li><li><strong>Minimum:</strong> 0</li><li><strong>Units:</strong> queries</li>
</ul>
            </details></li><li><details><summary>serverName (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> TLS server name</li><li><strong>Description: </strong> Expected TLS server name to verify in the certificate.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>username (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Username</li><li><strong>Description: </strong> Username for basic authentication.</li><li><strong>Required if the following fields are set:</strong>password</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Container (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>args (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Arguments</li><li><strong>Description: </strong> Arguments to the entypoint (command).</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>command (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Command</li><li><strong>Description: </strong> Override container entry point. Not executed with a shell.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li><strong>Minimum items:</strong> 1</li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>env (List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Environment</li><li><strong>Description: </strong> Environment variables for this container.</li><li><strong>Type:</strong> List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name</li><li><strong>Description: </strong> Environment variables name.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^[a-zA-Z0-9-._]&#43;$</code></li></ul>
            </details></li><li><details><summary>value (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Value</li><li><strong>Description: </strong> Value for the environment variable.</li><li><strong>Required if the following fields are not set:</strong>valueFrom</li><li><strong>Conflicts the following fields:</strong>valueFrom</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>valueFrom (Object reference to &ldquo;EnvFromSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Value source</li><li><strong>Description: </strong> Load the environment variable from a secret or config map.</li><li><strong>Required if the following fields are not set:</strong>value</li><li><strong>Conflicts the following fields:</strong>value</li><li><strong>Type:</strong> Object reference to &ldquo;EnvFromSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> EnvFromSource</li></ul>
            </details></li></ul>
</li>
</ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>envFrom (List ofObject reference to &ldquo;EnvFromSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Environment sources</li><li><strong>Description: </strong> List of sources to populate the environment variables from.</li><li><strong>Type:</strong> List ofObject reference to &ldquo;EnvFromSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;EnvFromSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> EnvFromSource</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>image (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Image</li><li><strong>Description: </strong> Container image to use for this container.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^[a-zA-Z0-9_\-:./]&#43;$</code></li></ul>
            </details></li><li><details><summary>imagePullPolicy (Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volume device</li><li><strong>Description: </strong> Mount a raw block device within the container.</li><li><strong>Default (JSON encoded)</strong>: &#34;IfNotPresent&#34;</li><li><strong>Type:</strong> Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span></li><li>
    <details><summary>Values</summary>
        <ul><li><strong><code>Always</code>:</strong> Always</li><li><strong><code>IfNotPresent</code>:</strong> If not present</li><li><strong><code>Never</code>:</strong> Never</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name</li><li><strong>Description: </strong> Name for the container. Each container in a pod must have a unique name.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Maximum length:</strong> 253</li><li><strong>Must match pattern:</strong> <code>^[a-z0-9]($|[a-z0-9\-_]*[a-z0-9])$</code></li></ul>
            </details></li><li><details><summary>securityContext (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volume device</li><li><strong>Description: </strong> Mount a raw block device within the container.</li><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>capabilities (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Capabilities</li><li><strong>Description: </strong> Add or drop POSIX capabilities.</li><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>add (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Add</li><li><strong>Description: </strong> Add POSIX capabilities.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^[A-Z_]&#43;$</code></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>drop (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Drop</li><li><strong>Description: </strong> Drop POSIX capabilities.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^[A-Z_]&#43;$</code></li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
            </details></li><li><details><summary>privileged (Boolean <span title="Booleans hold true or false values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Privileged</li><li><strong>Description: </strong> Run the container in privileged mode.</li><li><strong>Type:</strong> Boolean <span title="Booleans hold true or false values.">💡</span></li></ul>
            </details></li></ul>
</li>
</ul>
            </details></li><li><details><summary>volumeDevices (List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volume device</li><li><strong>Description: </strong> Mount a raw block device within the container.</li><li><strong>Type:</strong> List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>devicePath (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Device path</li><li><strong>Description: </strong> Path inside the container the device will be mapped to.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name</li><li><strong>Description: </strong> Must match the persistent volume claim in the pod.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li></ul>
</li>
</ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>volumeMounts (List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volume mounts</li><li><strong>Description: </strong> Pod volumes to mount on this container.</li><li><strong>Type:</strong> List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>mountPath (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Mount path</li><li><strong>Description: </strong> Path to mount the volume on inside the container.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volume name</li><li><strong>Description: </strong> Must match the pod volume to mount.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li><li><details><summary>readOnly (Boolean <span title="Booleans hold true or false values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Read only</li><li><strong>Description: </strong> Mount volume as read-only.</li><li><strong>Default (JSON encoded)</strong>: false</li><li><strong>Type:</strong> Boolean <span title="Booleans hold true or false values.">💡</span></li></ul>
            </details></li><li><details><summary>subPath (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Subpath</li><li><strong>Description: </strong> Path from the volume to mount.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li></ul>
</li>
</ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>workingDir (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Working directory</li><li><strong>Description: </strong> Override the container working directory.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>DownwardAPIVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>EmptyDirVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>medium (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Medium</li><li><strong>Description: </strong> How to store the empty directory</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^(|Memory|HugePages|HugePages-.*)$</code></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>EnvFromSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>configMapRef (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Config map source</li><li><strong>Description: </strong> Populates the source from a config map.</li><li><strong>Required if the following fields are not set:</strong>secretRef</li><li><strong>Conflicts the following fields:</strong>secretRef</li><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name</li><li><strong>Description: </strong> Name of the referenced config map.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li><li><details><summary>optional (Boolean <span title="Booleans hold true or false values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Optional</li><li><strong>Description: </strong> Specify whether the config map must be defined.</li><li><strong>Type:</strong> Boolean <span title="Booleans hold true or false values.">💡</span></li></ul>
            </details></li></ul>
</li>
</ul>
            </details></li><li><details><summary>prefix (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Prefix</li><li><strong>Description: </strong> An optional identifier to prepend to each key in the ConfigMap.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^[a-zA-Z0-9-._]&#43;$</code></li></ul>
            </details></li><li><details><summary>secretRef (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Secret source</li><li><strong>Description: </strong> Populates the source from a secret.</li><li><strong>Required if the following fields are not set:</strong>configMapRef</li><li><strong>Conflicts the following fields:</strong>configMapRef</li><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name</li><li><strong>Description: </strong> Name of the referenced secret.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li><li><details><summary>optional (Boolean <span title="Booleans hold true or false values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Optional</li><li><strong>Description: </strong> Specify whether the secret must be defined.</li><li><strong>Type:</strong> Boolean <span title="Booleans hold true or false values.">💡</span></li></ul>
            </details></li></ul>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>EphemeralVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>FCVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>FlexVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>FlockerVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>GCEPersistentDiskVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>GlusterfsVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>HostPathVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>path (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Path</li><li><strong>Description: </strong> Path to the directory on the host.</li><li><strong>Required</strong></li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;/srv/volume1&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li><li><details><summary>type (Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Type</li><li><strong>Description: </strong> Type of the host path.</li><li><strong>Type:</strong> Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span></li><li>
    <details><summary>Values</summary>
        <ul><li><strong><code></code>:</strong> Unset</li><li><strong><code>BlockDevice</code>:</strong> Block device</li><li><strong><code>CharDevice</code>:</strong> Character device</li><li><strong><code>Directory</code>:</strong> Directory</li><li><strong><code>DirectoryOrCreate</code>:</strong> Create directory if not found</li><li><strong><code>File</code>:</strong> File</li><li><strong><code>FileOrCreate</code>:</strong> Create file if not found</li><li><strong><code>Socket</code>:</strong> Socket</li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>ISCSIVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>NFSVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>ObjectMeta (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>annotations (Map ofString <span title="Strings hold a list of printable characters.">💡</span>&rarr;String <span title="Strings hold a list of printable characters.">💡</span><span title="Maps hold a set of keys associated with values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Annotations</li><li><strong>Description: </strong> Kubernetes annotations to appy. See https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ for details.</li><li><strong>Type:</strong> Map ofString <span title="Strings hold a list of printable characters.">💡</span>&rarr;String <span title="Strings hold a list of printable characters.">💡</span><span title="Maps hold a set of keys associated with values.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^(|([a-zA-Z](|[a-zA-Z\-.]{0,251}[a-zA-Z0-9]))/)([a-zA-Z](|[a-zA-Z\\-]{0,61}[a-zA-Z0-9]))$</code></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Maximum length:</strong> 63</li><li><strong>Must match pattern:</strong> <code>^(|[a-zA-Z0-9]&#43;(|[-_.][a-zA-Z0-9]&#43;)*[a-zA-Z0-9])$</code></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>generateName (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name prefix</li><li><strong>Description: </strong> Name prefix to generate pod names from.</li><li><strong>Conflicts the following fields:</strong>name</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>labels (Map ofString <span title="Strings hold a list of printable characters.">💡</span>&rarr;String <span title="Strings hold a list of printable characters.">💡</span><span title="Maps hold a set of keys associated with values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Labels</li><li><strong>Description: </strong> Kubernetes labels to appy. See https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ for details.</li><li><strong>Type:</strong> Map ofString <span title="Strings hold a list of printable characters.">💡</span>&rarr;String <span title="Strings hold a list of printable characters.">💡</span><span title="Maps hold a set of keys associated with values.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^(|([a-zA-Z](|[a-zA-Z\-.]{0,251}[a-zA-Z0-9]))/)([a-zA-Z](|[a-zA-Z\\-]{0,61}[a-zA-Z0-9]))$</code></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Maximum length:</strong> 63</li><li><strong>Must match pattern:</strong> <code>^(|[a-zA-Z0-9]&#43;(|[-_.][a-zA-Z0-9]&#43;)*[a-zA-Z0-9])$</code></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name</li><li><strong>Description: </strong> Pod name.</li><li><strong>Conflicts the following fields:</strong>generateName</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>namespace (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Namespace</li><li><strong>Description: </strong> Kubernetes namespace to deploy in.</li><li><strong>Default (JSON encoded)</strong>: &#34;default&#34;</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Maximum length:</strong> 253</li><li><strong>Must match pattern:</strong> <code>^[a-z0-9]($|[a-z0-9\-_]*[a-z0-9])$</code></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>PersistentVolumeClaimVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>PhotonPersistentDiskVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>Pod (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>metadata (Object reference to &ldquo;ObjectMeta&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Metadata</li><li><strong>Description: </strong> Pod metadata.</li><li><strong>Type:</strong> Object reference to &ldquo;ObjectMeta&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> ObjectMeta</li></ul>
            </details></li><li><details><summary>spec (Object reference to &ldquo;PodSpec&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Specification</li><li><strong>Description: </strong> Pod specification.</li><li><strong>Type:</strong> Object reference to &ldquo;PodSpec&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> PodSpec</li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>PodSpec (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>containers (List ofObject reference to &ldquo;Container&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Containers</li><li><strong>Description: </strong> A list of containers belonging to the pod.</li><li><strong>Type:</strong> List ofObject reference to &ldquo;Container&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;Container&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Container</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>initContainers (List ofObject reference to &ldquo;Container&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Init containers</li><li><strong>Description: </strong> A list of initialization containers belonging to the pod.</li><li><strong>Type:</strong> List ofObject reference to &ldquo;Container&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;Container&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Container</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>pluginContainer (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Plugin container</li><li><strong>Description: </strong> The container to run the plugin in.</li><li><strong>Required</strong></li><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>env (List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Environment</li><li><strong>Description: </strong> Environment variables for this container.</li><li><strong>Type:</strong> List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name</li><li><strong>Description: </strong> Environment variables name.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^[a-zA-Z0-9-._]&#43;$</code></li></ul>
            </details></li><li><details><summary>value (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Value</li><li><strong>Description: </strong> Value for the environment variable.</li><li><strong>Required if the following fields are not set:</strong>valueFrom</li><li><strong>Conflicts the following fields:</strong>valueFrom</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>valueFrom (Object reference to &ldquo;EnvFromSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Value source</li><li><strong>Description: </strong> Load the environment variable from a secret or config map.</li><li><strong>Required if the following fields are not set:</strong>value</li><li><strong>Conflicts the following fields:</strong>value</li><li><strong>Type:</strong> Object reference to &ldquo;EnvFromSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> EnvFromSource</li></ul>
            </details></li></ul>
</li>
</ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>envFrom (List ofObject reference to &ldquo;EnvFromSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Environment sources</li><li><strong>Description: </strong> List of sources to populate the environment variables from.</li><li><strong>Type:</strong> List ofObject reference to &ldquo;EnvFromSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;EnvFromSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> EnvFromSource</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>imagePullPolicy (Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volume device</li><li><strong>Description: </strong> Mount a raw block device within the container.</li><li><strong>Default (JSON encoded)</strong>: &#34;IfNotPresent&#34;</li><li><strong>Type:</strong> Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span></li><li>
    <details><summary>Values</summary>
        <ul><li><strong><code>Always</code>:</strong> Always</li><li><strong><code>IfNotPresent</code>:</strong> If not present</li><li><strong><code>Never</code>:</strong> Never</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name</li><li><strong>Description: </strong> Name for the container. Each container in a pod must have a unique name.</li><li><strong>Default (JSON encoded)</strong>: &#34;arcaflow-plugin-container&#34;</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Maximum length:</strong> 253</li><li><strong>Must match pattern:</strong> <code>^[a-z0-9]($|[a-z0-9\-_]*[a-z0-9])$</code></li></ul>
            </details></li><li><details><summary>securityContext (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volume device</li><li><strong>Description: </strong> Mount a raw block device within the container.</li><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>capabilities (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Capabilities</li><li><strong>Description: </strong> Add or drop POSIX capabilities.</li><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>add (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Add</li><li><strong>Description: </strong> Add POSIX capabilities.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^[A-Z_]&#43;$</code></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>drop (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Drop</li><li><strong>Description: </strong> Drop POSIX capabilities.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Must match pattern:</strong> <code>^[A-Z_]&#43;$</code></li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
            </details></li><li><details><summary>privileged (Boolean <span title="Booleans hold true or false values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Privileged</li><li><strong>Description: </strong> Run the container in privileged mode.</li><li><strong>Type:</strong> Boolean <span title="Booleans hold true or false values.">💡</span></li></ul>
            </details></li></ul>
</li>
</ul>
            </details></li><li><details><summary>volumeDevices (List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volume device</li><li><strong>Description: </strong> Mount a raw block device within the container.</li><li><strong>Type:</strong> List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>devicePath (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Device path</li><li><strong>Description: </strong> Path inside the container the device will be mapped to.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name</li><li><strong>Description: </strong> Must match the persistent volume claim in the pod.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li></ul>
</li>
</ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>volumeMounts (List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volume mounts</li><li><strong>Description: </strong> Pod volumes to mount on this container.</li><li><strong>Type:</strong> List ofObject <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>mountPath (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Mount path</li><li><strong>Description: </strong> Path to mount the volume on inside the container.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volume name</li><li><strong>Description: </strong> Must match the pod volume to mount.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li><li><details><summary>readOnly (Boolean <span title="Booleans hold true or false values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Read only</li><li><strong>Description: </strong> Mount volume as read-only.</li><li><strong>Default (JSON encoded)</strong>: false</li><li><strong>Type:</strong> Boolean <span title="Booleans hold true or false values.">💡</span></li></ul>
            </details></li><li><details><summary>subPath (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Subpath</li><li><strong>Description: </strong> Path from the volume to mount.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li></ul>
</li>
</ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
            </details></li><li><details><summary>volumes (List ofObject reference to &ldquo;Volume&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volumes</li><li><strong>Description: </strong> A list of volumes that can be mounted by containers belonging to the pod.</li><li><strong>Type:</strong> List ofObject reference to &ldquo;Volume&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;Volume&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Volume</li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>PortworxVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>ProjectedVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>QuobyteVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>RBDVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>ScaleIOVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>SecretVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>StorageOSVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>Timeouts (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>http (Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> HTTP</li><li><strong>Description: </strong> HTTP timeout for the Docker API.</li><li><strong>Default (JSON encoded)</strong>: &#34;15s&#34;</li><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum:</strong> 100000000</li><li><strong>Units:</strong> nanoseconds</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Volume (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>awsElasticBlockStore (Object reference to &ldquo;AWSElasticBlockStoreVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> AWS EBS</li><li><strong>Description: </strong> AWS Elastic Block Storage.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;AWSElasticBlockStoreVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> AWSElasticBlockStoreVolumeSource</li></ul>
            </details></li><li><details><summary>azureDisk (Object reference to &ldquo;AzureDiskVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Azure Data Disk</li><li><strong>Description: </strong> Mount an Azure Data Disk as a volume.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;AzureDiskVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> AzureDiskVolumeSource</li></ul>
            </details></li><li><details><summary>azureFile (Object reference to &ldquo;AzureFileVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Azure File</li><li><strong>Description: </strong> Mount an Azure File Service mount.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;AzureFileVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> AzureFileVolumeSource</li></ul>
            </details></li><li><details><summary>cephfs (Object reference to &ldquo;CephFSVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> CephFS</li><li><strong>Description: </strong> Mount a CephFS volume.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;CephFSVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> CephFSVolumeSource</li></ul>
            </details></li><li><details><summary>cinder (Object reference to &ldquo;CinderVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Cinder</li><li><strong>Description: </strong> Mount a cinder volume attached and mounted on the host machine.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;CinderVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> CinderVolumeSource</li></ul>
            </details></li><li><details><summary>configMap (Object reference to &ldquo;ConfigMapVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> ConfigMap</li><li><strong>Description: </strong> Mount a ConfigMap as a volume.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;ConfigMapVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> ConfigMapVolumeSource</li></ul>
            </details></li><li><details><summary>csi (Object reference to &ldquo;CSIVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> CSI Volume</li><li><strong>Description: </strong> Mount a volume using a CSI driver.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;CSIVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> CSIVolumeSource</li></ul>
            </details></li><li><details><summary>downwardAPI (Object reference to &ldquo;DownwardAPIVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Downward API</li><li><strong>Description: </strong> Specify a volume that the pod should mount itself.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;DownwardAPIVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> DownwardAPIVolumeSource</li></ul>
            </details></li><li><details><summary>emptyDir (Object reference to &ldquo;EmptyDirVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Empty directory</li><li><strong>Description: </strong> Temporary empty directory.</li><li><strong>Required if the following fields are not set:</strong>hostPath, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;EmptyDirVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> EmptyDirVolumeSource</li></ul>
            </details></li><li><details><summary>ephemeral (Object reference to &ldquo;EphemeralVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Ephemeral</li><li><strong>Description: </strong> Mount a volume that is handled by a cluster storage driver.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi</li><li><strong>Type:</strong> Object reference to &ldquo;EphemeralVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> EphemeralVolumeSource</li></ul>
            </details></li><li><details><summary>fc (Object reference to &ldquo;FCVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Fibre Channel</li><li><strong>Description: </strong> Mount a Fibre Channel volume that&#39;s attached to the host machine.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;FCVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> FCVolumeSource</li></ul>
            </details></li><li><details><summary>flexVolume (Object reference to &ldquo;FlexVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Flex</li><li><strong>Description: </strong> Mount a generic volume provisioned/attached using an exec based plugin.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;FlexVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> FlexVolumeSource</li></ul>
            </details></li><li><details><summary>flocker (Object reference to &ldquo;FlockerVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Flocker</li><li><strong>Description: </strong> Mount a Flocker volume.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;FlockerVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> FlockerVolumeSource</li></ul>
            </details></li><li><details><summary>gcePersistentDisk (Object reference to &ldquo;GCEPersistentDiskVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> GCE disk</li><li><strong>Description: </strong> Google Cloud disk.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;GCEPersistentDiskVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> GCEPersistentDiskVolumeSource</li></ul>
            </details></li><li><details><summary>glusterfs (Object reference to &ldquo;GlusterfsVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> GlusterFS</li><li><strong>Description: </strong> Mount a Gluster volume.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;GlusterfsVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> GlusterfsVolumeSource</li></ul>
            </details></li><li><details><summary>hostPath (Object reference to &ldquo;HostPathVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Host path</li><li><strong>Description: </strong> Mount volume from the host.</li><li><strong>Required if the following fields are not set:</strong>emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;HostPathVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> HostPathVolumeSource</li></ul>
            </details></li><li><details><summary>iscsi (Object reference to &ldquo;ISCSIVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> iSCSI</li><li><strong>Description: </strong> Mount an iSCSI volume.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;ISCSIVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> ISCSIVolumeSource</li></ul>
            </details></li><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name</li><li><strong>Description: </strong> The name this volume can be referenced by.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Maximum length:</strong> 253</li><li><strong>Must match pattern:</strong> <code>^[a-z0-9]($|[a-z0-9\-_]*[a-z0-9])$</code></li></ul>
            </details></li><li><details><summary>nfs (Object reference to &ldquo;NFSVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> NFS</li><li><strong>Description: </strong> Mount an NFS share.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;NFSVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> NFSVolumeSource</li></ul>
            </details></li><li><details><summary>persistentVolumeClaim (Object reference to &ldquo;PersistentVolumeClaimVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Persistent Volume Claim</li><li><strong>Description: </strong> Mount a Persistent Volume Claim.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;PersistentVolumeClaimVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> PersistentVolumeClaimVolumeSource</li></ul>
            </details></li><li><details><summary>photonPersistentDisk (Object reference to &ldquo;PhotonPersistentDiskVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> PhotonController persistent disk</li><li><strong>Description: </strong> Mount a PhotonController persistent disk as a volume.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;PhotonPersistentDiskVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> PhotonPersistentDiskVolumeSource</li></ul>
            </details></li><li><details><summary>portworxVolume (Object reference to &ldquo;PortworxVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Portworx Volume</li><li><strong>Description: </strong> Mount a Portworx volume.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;PortworxVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> PortworxVolumeSource</li></ul>
            </details></li><li><details><summary>projected (Object reference to &ldquo;ProjectedVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Projected</li><li><strong>Description: </strong> Projected items for all in one resources secrets, configmaps, and downward API.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;ProjectedVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> ProjectedVolumeSource</li></ul>
            </details></li><li><details><summary>quobyte (Object reference to &ldquo;QuobyteVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> quobyte</li><li><strong>Description: </strong> Mount Quobyte volume from the host.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;QuobyteVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> QuobyteVolumeSource</li></ul>
            </details></li><li><details><summary>rbd (Object reference to &ldquo;RBDVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Rados Block Device</li><li><strong>Description: </strong> Mount a Rados Block Device.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;RBDVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> RBDVolumeSource</li></ul>
            </details></li><li><details><summary>scaleIO (Object reference to &ldquo;ScaleIOVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> ScaleIO Persistent Volume</li><li><strong>Description: </strong> Mount a ScaleIO persistent volume.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;ScaleIOVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> ScaleIOVolumeSource</li></ul>
            </details></li><li><details><summary>secret (Object reference to &ldquo;SecretVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Secret</li><li><strong>Description: </strong> Mount a Kubernetes secret.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;SecretVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> SecretVolumeSource</li></ul>
            </details></li><li><details><summary>storageos (Object reference to &ldquo;StorageOSVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> StorageOS Volume</li><li><strong>Description: </strong> Mount a StorageOS volume.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, vsphereVolume, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;StorageOSVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> StorageOSVolumeSource</li></ul>
            </details></li><li><details><summary>vsphereVolume (Object reference to &ldquo;VsphereVirtualDiskVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> vSphere Virtual Disk</li><li><strong>Description: </strong> Mount a vSphere Virtual Disk as a volume.</li><li><strong>Required if the following fields are not set:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Conflicts the following fields:</strong>hostPath, emptyDir, gcePersistentDisk, awsElasticBlockStore, secret, nfs, iscsi, glusterfs, persistentVolumeClaim, rbd, flexVolume, cinder, cephfs, flocker, downwardAPI, fc, azureFile, configMap, quobyte, azureDisk, photonPersistentDisk, projected, portworxVolume, scaleIO, storageos, csi, ephemeral</li><li><strong>Type:</strong> Object reference to &ldquo;VsphereVirtualDiskVolumeSource&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> VsphereVirtualDiskVolumeSource</li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>VsphereVirtualDiskVolumeSource (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details></details></li>
</ul>

#### Podman deployer

<ul><li><strong>Type:</strong> Scope <span title="Scopes hold one or more objects that can be referenced inside the properties of those objects by ref types. Ref types always reference the closest scope.">💡</span></li><li><strong>Root object:</strong> Config</li>
<li><strong>Properties</strong><ul><li><details><summary>deployment (Object reference to &ldquo;Deployment&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
                <ul><li><strong>Name: </strong> Deployment</li><li><strong>Description: </strong> Deployment configuration for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;Deployment&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Deployment</li></ul>
            </details></li><li><details><summary>podman (Object reference to &ldquo;Podman&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
                <ul><li><strong>Name: </strong> Podman</li><li><strong>Description: </strong> Podman CLI configuration</li><li><strong>Type:</strong> Object reference to &ldquo;Podman&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Podman</li></ul>
            </details></li></ul></li>
<li><details><summary><strong>Objects</strong></summary><details><summary>Config (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>deployment (Object reference to &ldquo;Deployment&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Deployment</li><li><strong>Description: </strong> Deployment configuration for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;Deployment&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Deployment</li></ul>
            </details></li><li><details><summary>podman (Object reference to &ldquo;Podman&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Podman</li><li><strong>Description: </strong> Podman CLI configuration</li><li><strong>Type:</strong> Object reference to &ldquo;Podman&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Podman</li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>ContainerConfig (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>Domainname (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Domain name</li><li><strong>Description: </strong> Domain name for the plugin container.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[a-zA-Z0-9-_.]&#43;$</code></li></ul>
            </details></li><li><details><summary>Env (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Environment variables</li><li><strong>Description: </strong> Environment variables to set on the plugin container.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 32760</li><li><strong>Must match pattern:</strong> <code>^.&#43;=.&#43;$</code></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>Hostname (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Hostname</li><li><strong>Description: </strong> Hostname for the plugin container.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[a-zA-Z0-9-_.]&#43;$</code></li></ul>
            </details></li><li><details><summary>MacAddress (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> MAC address</li><li><strong>Description: </strong> Media Access Control address for the container.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^[a-fA-F0-9]{2}(:[a-fA-F0-9]{2}){5}$</code></li></ul>
            </details></li><li><details><summary>NetworkDisabled (Boolean <span title="Booleans hold true or false values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Disable network</li><li><strong>Description: </strong> Disable container networking completely.</li><li><strong>Type:</strong> Boolean <span title="Booleans hold true or false values.">💡</span></li></ul>
            </details></li><li><details><summary>User (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Username</li><li><strong>Description: </strong> User that will run the command inside the container. Optionally, a group can be specified in the user:group format.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[a-z_][a-z0-9_-]*[$]?(:[a-z_][a-z0-9_-]*[$]?)$</code></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Deployment (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>container (Object reference to &ldquo;ContainerConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Container configuration</li><li><strong>Description: </strong> Provides information about the container for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;ContainerConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> ContainerConfig</li></ul>
            </details></li><li><details><summary>host (Object reference to &ldquo;HostConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Host configuration</li><li><strong>Description: </strong> Provides information about the container host for the plugin.</li><li><strong>Type:</strong> Object reference to &ldquo;HostConfig&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> HostConfig</li></ul>
            </details></li><li><details><summary>imagePullPolicy (Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Image pull policy</li><li><strong>Description: </strong> When to pull the plugin image.</li><li><strong>Default (JSON encoded)</strong>: &#34;IfNotPresent&#34;</li><li><strong>Type:</strong> Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span></li><li>
    <details><summary>Values</summary>
        <ul><li><strong><code>Always</code>:</strong> Always</li><li><strong><code>IfNotPresent</code>:</strong> If not present</li><li><strong><code>Never</code>:</strong> Never</li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>HostConfig (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>Binds (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Volume Bindings</li><li><strong>Description: </strong> Volumes</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 32760</li><li><strong>Must match pattern:</strong> <code>^.&#43;:.&#43;$</code></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>CapAdd (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Add capabilities</li><li><strong>Description: </strong> Add capabilities to the container.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>CapDrop (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Drop capabilities</li><li><strong>Description: </strong> Drop capabilities from the container.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>CgroupnsMode (Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> CGroup namespace mode</li><li><strong>Description: </strong> CGroup namespace mode to use for the container.</li><li><strong>Type:</strong> Enum (string keys) <span title="Enums only allow a limited list of values.">💡</span></li><li>
    <details><summary>Values</summary>
        <ul><li><strong><code></code>:</strong> Empty</li><li><strong><code>host</code>:</strong> Host</li><li><strong><code>private</code>:</strong> Private</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>Dns (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> DNS servers</li><li><strong>Description: </strong> DNS servers to use for lookup.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>DnsOptions (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> DNS options</li><li><strong>Description: </strong> DNS options to look for.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>DnsSearch (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> DNS search</li><li><strong>Description: </strong> DNS search domain.</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>ExtraHosts (List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Extra hosts</li><li><strong>Description: </strong> Extra hosts entries to add</li><li><strong>Type:</strong> List ofString <span title="Strings hold a list of printable characters.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>NetworkMode (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Network mode</li><li><strong>Description: </strong> Specifies either the network mode, the container network to attach to, or a name of a Docker network to use.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;none&#34;</code></li><li><code>&#34;bridge&#34;</code></li><li><code>&#34;host&#34;</code></li><li><code>&#34;container:container-name&#34;</code></li><li><code>&#34;network-name&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^(none|bridge|host|container:[a-zA-Z0-9][a-zA-Z0-9_.-]&#43;|[a-zA-Z0-9][a-zA-Z0-9_.-]&#43;)$</code></li></ul>
            </details></li><li><details><summary>PortBindings (Map ofString <span title="Strings hold a list of printable characters.">💡</span>&rarr;String <span title="Strings hold a list of printable characters.">💡</span><span title="Maps hold a set of keys associated with values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Port bindings</li><li><strong>Description: </strong> Ports to expose on the host machine. Ports are specified in the format of portnumber/protocol.</li><li><strong>Type:</strong> Map ofString <span title="Strings hold a list of printable characters.">💡</span>&rarr;String <span title="Strings hold a list of printable characters.">💡</span><span title="Maps hold a set of keys associated with values.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^[0-9]&#43;(/[a-zA-Z0-9]&#43;)$</code></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> List ofObject reference to &ldquo;PortBinding&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span><span title="Lists hold zero or more items of the specified type.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;PortBinding&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> PortBinding</li></ul>
    </details>
</li>
</ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Podman (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>cgroupNs (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> CGroup namespace</li><li><strong>Description: </strong> Provides the Cgroup Namespace settings for the container</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^host|ns:/proc/\d&#43;/ns/cgroup|container:.&#43;|private$</code></li></ul>
            </details></li><li><details><summary>containerName (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Container Name</li><li><strong>Description: </strong> Provides name of the container</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^.*$</code></li></ul>
            </details></li><li><details><summary>imageArchitecture (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Podman image Architecture</li><li><strong>Description: </strong> Provides Podman Image Architecture</li><li><strong>Default (JSON encoded)</strong>: &#34;amd64&#34;</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^.*$</code></li></ul>
            </details></li><li><details><summary>imageOS (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Podman Image OS</li><li><strong>Description: </strong> Provides Podman Image Operating System</li><li><strong>Default (JSON encoded)</strong>: &#34;linux&#34;</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^.*$</code></li></ul>
            </details></li><li><details><summary>networkMode (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Network Mode</li><li><strong>Description: </strong> Provides network settings for the container</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^bridge:.*|host|none$</code></li></ul>
            </details></li><li><details><summary>path (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Podman path</li><li><strong>Description: </strong> Provides the path of podman executable</li><li><strong>Default (JSON encoded)</strong>: &#34;/usr/bin/podman&#34;</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^.*$</code></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>PortBinding (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>HostIP (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Host IP</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>HostPort (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Host port</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Must match pattern:</strong> <code>^0-9&#43;$</code></li></ul>
            </details></li></ul>
</li>
</ul>
        </details></details></li>
</ul>
