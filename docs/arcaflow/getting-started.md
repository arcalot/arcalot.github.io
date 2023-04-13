# Arcaflow Getting Started Guide

## Step 1: Get a container engine

In order to use Arcaflow, you will need a container engine on your computer. For the purposes of this guide, we'll assume you are using Docker or Podman.

## Step 2: Get the engine

Head on over to the [GitHub releases page](https://github.com/arcalot/arcaflow-engine/releases) and download the latest release.

## Step 3: Create your first plugin

Let's create a simple hello-world plugin in Python. We'll publish the code here, you can find the details in the [Python plugin guide](plugins/python/first.md).

```python title="plugin.py"
#!/usr/local/bin/python3
import dataclasses
import sys
from arcaflow_plugin_sdk import plugin


@dataclasses.dataclass
class InputParams:
    name: str
    
    
@dataclasses.dataclass
class SuccessOutput:
    message: str


@plugin.step(
    id="hello-world",
    name="Hello world!",
    description="Says hello :)",
    outputs={"success": SuccessOutput},
)
def hello_world(params: InputParams):
    return "success", SuccessOutput(f"Hello, {params.name}")


if __name__ == "__main__":
    sys.exit(
        plugin.run(
            plugin.build_schema(
                hello_world,
            )
        )
    )
```

!!! tip
    Further reading: [Creating your first Python plugin](plugins/python/first.md)

## Step 4: Build the plugin

Next, let's create a `Dockerfile` and build a container image:

```Dockerfile title="Dockerfile"
FROM python:alpine

ADD plugin.py /
RUN chmod +x /plugin.py && pip install arcaflow_plugin_sdk

ENTRYPOINT ["/plugin.py"]
CMD []
```
You can now build the plugin container.

=== "Docker"
    ```
    docker build -t example-plugin .
    ```

=== "Podman"
    ```
    podman build -t example-plugin .
    ```

!!! tip
    Further reading: [Packaging plugins](plugins/packaging.md)

!!! tip "Did you know?"
    While Arcaflow is a workflow engine, plugins can be run independentily via the command line. Try running your containerized helo-world plugin directly.

    === "Docker"
        ```
        echo "name: Arca Lot" | docker run -i --rm example-plugin -f -
        ```
    
    === "Podman"
        ```
        echo "name: Arca Lot" | podman run -i --rm example-plugin -f -
        ```

## Step 5: Create a simple workflow

Let's start with something simple: we'll incorporate the plugin above into a workflow. Let's create a `workflow.yaml` in an empty directory

```yaml title="workflow.yaml"
input:
  root: RootObject
  objects:
    RootObject:
      id: RootObject
      properties:
        name:
          type:
            type_id: string
steps:
  greet:
    plugin: example-plugin
    input:
      name: !expr $.input.name
output:
  message: !expr $.steps.greet.outputs.success.message
```

!!! tip
    Further reading: [Creating workflows](workflows/index.md)

## Step 6: Create an input file

Now, let's create an input file for our workflow named `input.yaml`:

```yaml title="input.yaml"
name: Arca Lot
```

## Step 7: Create an engine configuration

You will need an Arcaflow `config.yaml` file to prevent Arcaflow from trying to pull the container image.

!!! tip
    Without a config file, the default behavior of Arcaflow is to run with docker and to always pull plugin container images for the workflow.

=== "Docker"

    ```yaml title="config.yaml"
    deployer:
      type: docker
      deployment:
        # Make sure we don't try to pull the image we have locally
        imagePullPolicy: Never
    ```

=== "Podman"
    
    ```yaml title="config.yaml"
    deployer:
      type: podman
      deployment:
        # Make sure we don't try to pull the image we have locally
        imagePullPolicy: Never
    ```

!!! tip
    Further reading: [Setting up Arcaflow](running/setup.md)

## Step 7: Run the workflow

Finally, let's run our workflow. Make sure you are in the directory where the workflow is located.

=== "Linux/MacOS"

    ```
    /path/to/arcaflow -input input.yaml -config config.yaml
    ```

=== "Windows"

    ```
    C:\path\to\arcaflow.exe -input input.yaml -config config.yaml
    ```

If everything went well, after a few seconds you should see logs messages similar to the ones shown below:

```
2023-03-22T11:25:58+01:00       info            Loading plugins locally to determine schemas...
2023-03-22T11:25:58+01:00       info            Deploying example-plugin...
2023-03-22T11:25:58+01:00       info            Creating container from image example-plugin...
2023-03-22T11:25:59+01:00       info            Container started.
2023-03-22T11:25:59+01:00       info            Schema for example-plugin obtained.
2023-03-22T11:25:59+01:00       info            Schema loading complete.
2023-03-22T11:25:59+01:00       info            Building dependency tree...
2023-03-22T11:25:59+01:00       info            Dependency tree complete.
2023-03-22T11:25:59+01:00       info            Dependency tree Mermaid:
flowchart TD
subgraph input
input.name
end
input.name-->steps.greet
steps.greet-->steps.greet.outputs.success
steps.greet.outputs.success-->output
2023-03-22T11:25:59+01:00       info            Starting step greet...
2023-03-22T11:25:59+01:00       info            Creating container from image example-plugin...
2023-03-22T11:26:00+01:00       info            Container started.
2023-03-22T11:26:00+01:00       info            Step greet is now running...
2023-03-22T11:26:00+01:00       info            Step greet is now executing ATP...
2023-03-22T11:26:00+01:00       info            Step "greet" has finished with output success.
message: Hello, Arca Lot
```

As you can see, the last line of the output is the output data from the workflow.

!!! tip "Did you know?"
    Arcaflow provides [Mermaid](https://mermaid.js.org/) markdown in the workflow output that allows you to quickly visualize the workflow in a graphic format. You can grab the Mermaid graph you see in the output and put it into [the Mermaid editor](https://mermaid.live/edit#pako:eNpdjz0OwjAMha8SeaY5QAem3gDGLCZxf6TGiRJHCFW9OxYwtEy2v_ee9LyBT4Ggh3FNTz9jEXMfHNf2mArm2Sycmzj-DMsYyTFxOIKuu1ahXO1UiNR6OM6STU00VG1t3lOtJ-u_qNEvgQtEKhGXoCU3x8Y4kJm0CPS6BhqxreLA8a5WbJJuL_bQj7hWukDLAYWGBfWd-KP7Gz-1Wos).

    === "Mermaid markdown"
        ```
        flowchart TD
        subgraph input
        input.name
        end
        input.name-->steps.greet
        steps.greet-->steps.greet.outputs.success
        steps.greet.outputs.success-->output
        ```

    === "Mermaid rendered flowchart"
        ```mermaid
        flowchart TD
        subgraph input
        input.name
        end
        input.name-->steps.greet
        steps.greet-->steps.greet.outputs.success
        steps.greet.outputs.success-->output
        ```

!!! tip
    Further reading: [Running Arcaflow](running/running.md)

## Next steps

Congratulations, you are now an Arcaflow user! Here are some things you can do next to start working with plugins and workflows:

- [See our repostories of community-supported plugins &raquo;](https://github.com/orgs/arcalot/repositories?q=arcaflow-plugin&type=all&language=&sort=)
- [Get our latest plugin container builds from quay.io &raquo;](https://quay.io/arcalot)
- [Experiment with more advanced example workflows &raquo;](https://github.com/arcalot/arcaflow-workflows)

## Keep learning

Hungry for more? Keep digging into our docs::

- [Learn more about the concepts behind Arcaflow &raquo;](concepts/index.md)
- [Learn how to set up Arcaflow &raquo;](running/setup.md)
- [Learn how to create plugins &raquo;](plugins/index.md)
- [Learn how to create workflows &raquo;](workflows/index.md)

[Contribute to Arcaflow &raquo;](contributing/index.md){ .md-button }