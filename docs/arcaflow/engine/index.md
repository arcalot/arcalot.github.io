# Configuring the Arcaflow Engine

If you want to change the default deployer from Docker to Podman or Kubernetes, you will need to set up a configuration YAML file and pass it to the engine with the `-config your-arcaflow-config.yaml` flag.

You can then change the deployer type like this:

```yaml
deployer:
  type: podman
  # Deployer-specific options 
```

## Docker deployer

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

## Podman deployer

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

## Kubernetes deployer

The Kubernetes deployer deploys on top of Kubernetes. You can set up the deployer like this:

```yaml
deployer:
  type: kubernetes
  
```