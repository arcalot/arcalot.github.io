# Arcaflow Getting Started Guide

## Running Workflows
An Arcaflow workflow is a definition of steps structured together to perform complex actions. Workflows are defined as machine-readable YAML and therefore can be version-controlled and shared easily to run in different environments. A workflow is a way of encapsulating and sharing expertise and ensuring reproducible results.

Running a workflow only requires having the [Arcaflow engine binary](https://github.com/arcalot/arcaflow-engine/releases), the workflow definition file, and in most cases an input file. An optional config file also allows for setting workflow defaults, such as log levels. All of these files are typically defined in YAML. Additionally, the target of the workflow needs a compatible container platform, such as Podman, Docker, or Kubernetes.

!!! note
    The default container platform for the Arcaflow engine is Podman. To use another platform, a [configuration file](/arcaflow/running/setup/#configuration) is required.

A repository of [example workflows](https://github.com/arcalot/arcaflow-workflows) is available for reference and practice. Let's try running the [basic example](https://github.com/arcalot/arcaflow-workflows/basic-examples/basic).

First we will clone the example workflows repository:

```bash
git clone https://github.com/arcalot/arcaflow-workflows.git
```

Then we will run the workflow, setting the workflow directory as the context, and defining the workflow, configuration, and input files to use:

```bash
arcaflow --context arcaflow-workflows/basic-examples/basic/ \
--workflow workflow.yaml --config config.yaml --input input.yaml
```

Arcaflow will display logs, depending upon the configured verbosity, and then will return the machine-readable output of the workflow in YAML format:

```bash
output_data:
    example:
        message: Hello, Arcalot!
output_id: success
```

[Learn more about running workflows &raquo;](/arcaflow/running/){ .md-button }

## Writing Workflows
As a workflow author, you determine the steps of the workflow, how data will pass between the steps, what input is required from the workflow user, and what output will be returned. It is possible to build very complex workflows with data translations, sub-workflows, parallelisim and serialization, and multiple output paths.

Let's start with something simple. Our workflow will collect a `nickname` input from the user and will pass that input to an example "Hello world!" step. The workflow will also run a UUID generation step in parallel to the example step, and it will return both the UUID and a greeting.

In the first part of the `workflow.yaml` file we will define the workflow compatibility version and the input schema for the workflow. In the input schema, we are expecting only a single input called `nickname` with a type of `string`.

```yaml title="workflow.yaml (excerpt)"
version: v0.2.0
input:
  root: RootObject
  objects:
    RootObject:
      id: RootObject
      properties:
        nickname:   #<<== Input key name
          display:
            description: Just a name
            name: Name
          required: true
          type:
            type_id: string   #<<== Input value type
...
```

Next we will define the steps of the workflow. The steps are to be deployed as container images using the `src` paths for the image files. The `arcaflow-plugin-utilities` plugin has multiple steps available, so we indicate with the `step: uuid` parameter which step we want to run. The `arcaflow-plugin-example` plugin has only one step, so the parameter is not required. The `uuidgen` step requires no input, so we pass a blank object `{}` to it. The `example` plugin requires an input structure of `name` with `_type` and `nick` sub-parameters. We statically define `_type: nickname` as part of the step, and then we use the [Arcaflow expression language](/arcaflow/workflows/expressions/) to reference the workflow input value for `nickname` as the input to the plugin's `nick` parameter.

```yaml title="workflow.yaml (excerpt)"
...
steps:
  uuidgen:   #<<== Step name
    plugin:
      deployment_type: image
      src: quay.io/arcalot/arcaflow-plugin-utilities:0.6.0   #<<== Container image tag
    step: uuid   #<<== Specific plugin step
    input: {}   #<<== Step does not require input
  example:   #<<== Step name
    plugin:
      deployment_type: image
      src: quay.io/arcalot/arcaflow-plugin-example:0.5.0   #<<== Container image tag
    input:
      name:
        _type: nickname   #<<== Statically-defined input
        nick: !expr $.input.nickname   #<<== Referenced workflow input
...
```

Finally we define the outputs that we expect when the workflow succeeds. In order to satisfy the `success` state for the workflow, all of the defined output items must be available. Again we use the Arcaflow expression language, this time to reference the outputs of the individual steps as the output for the workflow.

```yaml title="workflow.yaml (excerpt)"
...
outputs:
 success:
   uuid: !expr $.steps.uuidgen.outputs.success
   example: !expr $.steps.example.outputs.success
```

Our final workflow looks like this:

```yaml title="workflow.yaml"
version: v0.2.0
input:
  root: RootObject
  objects:
    RootObject:
      id: RootObject
      properties:
        nickname:
          display:
            description: Just a name
            name: Name
          required: true
          type:
            type_id: string

steps:
  uuidgen:
    plugin:
      deployment_type: image
      src: quay.io/arcalot/arcaflow-plugin-utilities:0.6.0
    step: uuid
    input: {}
  example:
    plugin:
      deployment_type: image
      src: quay.io/arcalot/arcaflow-plugin-example:0.5.0
    input:
      name:
        _type: nickname
        nick: !expr $.input.nickname

outputs:
 success:
   uuid: !expr $.steps.uuidgen.outputs.success.uuid
   example: !expr $.steps.example.outputs.success.message
```

We will create an input file to satisfy the input schema of the workflow:

```yaml title="input.yaml"
nickname: Arcalot
```

We will also create a configuration file, setting the container deployer to Podman and the log levels to `error`:

```yaml title="config.yaml"
log:
  level: error
logged_outputs:
  error:
    level: error
deployers:
  image:
    deployer_name: podman
    deployment:
      imagePullPolicy: IfNotPresent
```

And now we can run our new workflow:

!!! tip
    The default workflow file is `workflow.yaml` so we don't need to specifiy it here explicitly.

```bash
$ arcaflow --config config.yaml --input input.yaml
output_data:
    example: Hello, Arcalot!
    uuid: b98909c2-4a25-4cc1-8222-3290b0621129
output_id: success
```

[Learn more about workflow concepts &raquo;](/arcaflow/concepts/workflows/){ .md-button }

[Learn more about writing workflows &raquo;](/arcaflow/workflows/){ .md-button }

[See more example workflows &raquo;](https://github.com/arcalot/arcaflow-workflows){ .md-button }

!!! tip "Did you know?"
    Arcaflow provides [Mermaid](https://mermaid.js.org/) markdown in the workflow debug output that allows you to quickly visualize the workflow in a graphic format. You can grab the Mermaid graph you see in the output and put it into [the Mermaid editor](https://mermaid.live/edit#pako:eNpdjz0OwjAMha8SeaY5QAem3gDGLCZxf6TGiRJHCFW9OxYwtEy2v_ee9LyBT4Ggh3FNTz9jEXMfHNf2mArm2Sycmzj-DMsYyTFxOIKuu1ahXO1UiNR6OM6STU00VG1t3lOtJ-u_qNEvgQtEKhGXoCU3x8Y4kJm0CPS6BhqxreLA8a5WbJJuL_bQj7hWukDLAYWGBfWd-KP7Gz-1Wos).

    === "Mermaid markdown"
        ```
        flowchart LR
        input.name
        input.name-->steps.greet
        steps.greet-->steps.greet.outputs.success
        steps.greet.outputs.success-->output
        ```

    === "Mermaid rendered flowchart"
        ```mermaid
        flowchart LR
        input.name
        input.name-->steps.greet
        steps.greet-->steps.greet.outputs.success
        steps.greet.outputs.success-->output
        ```


## Running Plugins
Workflow steps are run via plugins, which are delivered as containers. The Arcalot community maintains an ever-growing list of [official plugins](https://github.com/orgs/arcalot/repositories?q=%22arcaflow-plugin-%22), which are version-controlled and hosted in our [Quay.io repository](https://quay.io/arcalot).

Plugins are designed to run independent of an Arcaflow workflow. All plugins have schema definitions for their inputs and outputs, and they perform data validation against those schemas when run. Plugins also have one or more steps, and when there are multiple steps we always need to specify which step we want to run.

!!! tip
    Plugin **steps** are the fundamental building blocks for workflows.

Let's take a look at the schema for the example plugin. Passing the `--schema` parameter to the plugin will return the complete schema in YAML format.

=== "Podman"
    ```bash
    podman run --rm quay.io/arcalot/arcaflow-plugin-example --schema
    ```
=== "Docker"
    ```bash 
    docker run --rm quay.io/arcalot/arcaflow-plugin-example --schema
    ```

Here we see the example plugin has one step called `hello-world`, which has schemas for both its inputs and outputs.

```yaml title="example plugin schema YAML"
steps:
  hello-world:
    display:
      description: Says hello :)
      name: Hello world!
    id: hello-world
    input:
      objects:
        FullName:
          id: FullName
          properties:
            first_name:
              display:
                name: First name
              examples:
              - '"Arca"'
              required: true
              type:
                min: 1
                pattern: ^[a-zA-Z]+$
                type_id: string
            last_name:
              display:
                name: Last name
              examples:
              - '"Lot"'
              required: true
              type:
                min: 1
                pattern: ^[a-zA-Z]+$
                type_id: string
        InputParams:
          id: InputParams
          properties:
            name:
              display:
                description: Who do we say hello to?
                name: Name
              examples:
              - '{"_type": "fullname", "first_name": "Arca", "last_name": "Lot"}'
              - '{"_type": "nickname", "nick": "Arcalot"}'
              required: true
              type:
                discriminator_field_name: _type
                type_id: one_of_string
                types:
                  fullname:
                    display:
                      name: Full name
                    id: FullName
                    type_id: ref
                  nickname:
                    display:
                      name: Nick
                    id: Nickname
                    type_id: ref
        Nickname:
          id: Nickname
          properties:
            nick:
              display:
                name: Nickname
              examples:
              - '"Arcalot"'
              required: true
              type:
                min: 1
                pattern: ^[a-zA-Z]+$
                type_id: string
      root: InputParams
    outputs:
      error:
        error: false
        schema:
          objects:
            ErrorOutput:
              id: ErrorOutput
              properties:
                error:
                  display: {}
                  required: true
                  type:
                    type_id: string
          root: ErrorOutput
      success:
        error: false
        schema:
          objects:
            SuccessOutput:
              id: SuccessOutput
              properties:
                message:
                  display: {}
                  required: true
                  type:
                    type_id: string
          root: SuccessOutput
```

The plugin schema can also be returned in JSON format, in which case you must specify wheter to return either the `input` or `output` schema.

=== "Podman"
    ```bash
    podman run --rm quay.io/arcalot/arcaflow-plugin-example --json-schema output
    ```
=== "Docker"
    ```bash
    docker run --rm quay.io/arcalot/arcaflow-plugin-example --json-schema output
    ```

```json title="example plugin output schema JSON"
{
  "$id": "hello-world",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Hello world! outputs",
  "description": "Says hello :)",
  "oneof": [
    {
      "output_id": {
        "type": "string",
        "const": "success"
      },
      "output_data": {
        "type": "object",
        "properties": {
          "message": {
            "type": "string"
          }
        },
        "required": [
          "message"
        ],
        "additionalProperties": false,
        "dependentRequired": {}
      }
    },
    {
      "output_id": {
        "type": "string",
        "const": "error"
      },
      "output_data": {
        "type": "object",
        "properties": {
          "error": {
            "type": "string"
          }
        },
        "required": [
          "error"
        ],
        "additionalProperties": false,
        "dependentRequired": {}
      }
    }
  ],
  "$defs": {
    "SuccessOutput": {
      "type": "object",
      "properties": {
        "message": {
          "type": "string"
        }
      },
      "required": [
        "message"
      ],
      "additionalProperties": false,
      "dependentRequired": {}
    },
    "ErrorOutput": {
      "type": "object",
      "properties": {
        "error": {
          "type": "string"
        }
      },
      "required": [
        "error"
      ],
      "additionalProperties": false,
      "dependentRequired": {}
    }
  }
}
```

A plugin takes its input as a file, but because it runs as a container, it looks for the input file in the context of the container. This means you either need to bind-mount the input file to the container, or as in this example pipe the input value to the plugin's file input.

```yaml title="input.yaml"
name:
  _type: nickname
  nick: Arcalot
```

!!! tip
    In order to pipe the input to the container, you must pass the `-i, --interactive` parameter.

=== "Podman"
    ```bash
    cat input.yaml | podman run -i --rm quay.io/arcalot/arcaflow-plugin-example -f -
    ```
=== "Docker"
    ```bash
    cat input.yaml | docker run -i --rm quay.io/arcalot/arcaflow-plugin-example -f -
    ```

```yaml title="example plugin return YAML"
output_id: success
output_data:
  message: Hello, Arcalot!
debug_logs: ''
```

Now let's generate a UUID with the utilities plugin. This plugin has multiple steps, so we need to specify which step to run. The step also requires no input, so we pass it an empty object.

!!! note
    An input object is always required, even if a plugin step does not require input parameters.

=== "Podman"
    ```bash
    echo '{}' | podman run -i --rm quay.io/arcalot/arcaflow-plugin-utilities -s uuid -f -
    ```
=== "Docker"
    ```bash
    echo '{}' | docker run -i --rm quay.io/arcalot/arcaflow-plugin-utilities -s uuid -f -
    ```

```yaml title="utilities plugin UUID step return YAML"
output_id: success
output_data:
  uuid: bb08484f-6263-4317-9162-be2ae846b438
debug_logs: ''
```

[Learn more about plugin schemas &raquo;](/arcaflow/plugins/python/data-model/){ .md-button }

## Writing Plugins
 Of course you may have specific needs and want to author your own plugins. To aid with this, we provide [SDKs](/arcaflow/plugins/) in popular languages. Let's create a simple hello-world plugin using the Python SDK. We'll publish the code here, you can find the details in the [Python plugin guide](plugins/python/first.md).

```python title="plugin.py"
#!/usr/local/bin/python3
from dataclasses import dataclass
import sys
from arcaflow_plugin_sdk import plugin


@dataclass
class InputParams:
    name: str
    
    
@dataclass
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

[Learn more about writing Python plugins &raquo;](/arcaflow/plugins/python/first.md){ .md-button }


Next, let's create a `Dockerfile` and build a container image:

```Dockerfile title="Dockerfile"
FROM quay.io/arcalot/arcaflow-plugin-baseimage-python-osbase

ADD plugin.py /
RUN python -m pip install arcaflow_plugin_sdk

ENTRYPOINT ["python", "/plugin.py"]
CMD []
```
You can now build the plugin container.

=== "Podman"
    ```bash
    podman build -t example-plugin .
    ```
=== "Docker"
    ```bash
    docker build -t example-plugin .
    ```


[Learn more about Packaging plugins](/arcaflow/plugins/packaging.md){ .md-button }

!!! tip "Did you know?"
    While Arcaflow is a workflow engine, plugins can be run independently via the command line. Try running your containerized hello-world plugin directly.
    
    === "Podman"
        ```bash
        echo "name: Arca Lot" | podman run -i --rm example-plugin -f -
        ```
    === "Docker"
        ```bash
        echo "name: Arca Lot" | docker run -i --rm example-plugin -f -
        ```

## Next steps

Congratulations, you are now an Arcaflow user! Here are some things you can do next to start working with plugins and workflows:

- [See our repositories of community-supported plugins &raquo;](https://github.com/orgs/arcalot/repositories?q=%22arcaflow-plugin-%22)
- [Get our latest plugin container builds from quay.io &raquo;](https://quay.io/arcalot)
- [Experiment with more advanced example workflows &raquo;](https://github.com/arcalot/arcaflow-workflows/advanced-examples/)

## Keep learning

Hungry for more? Keep digging into our docs::

- [Learn more about the concepts behind Arcaflow &raquo;](concepts/index.md)
- [Learn how to set up Arcaflow &raquo;](running/setup.md)
- [Learn how to create plugins &raquo;](plugins/index.md)
- [Learn how to create workflows &raquo;](workflows/index.md)

[Contribute to Arcaflow &raquo;](contributing/index.md){ .md-button }