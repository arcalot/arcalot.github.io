# Using Flow Control Mechanics

Flow control allows the workflow author to build a workflow with a decision tree based on supported flow logic. These flow control operations are not implemented by plugins, but are part of the workflow engine itself.

## Foreach Loops

Foreach loops allow for running a sub-workflow with iterative inputs from a parent workflow. A sub-workflow is a complete Arcaflow workflow file with it's own input and output schemas as described in this section. The inputs for the sub-workflow are provided as a list, where each list item is an object that matches the sub-workflow input schema.

!!! tip
    A complete functional example is available in the [arcaflow-workflows](https://github.com/arcalot/arcaflow-workflows/tree/main/example-foreach-loop) repository.

In the parent workflow file, the author can define an input schema with the list that will contain the input object that will be passed to the sub-workflow. For example:

```yaml title="workflow.yaml"
input:
  root: RootObject
  objects:
    RootObject:
      id: RootObject
      properties:
        loop:
          type:
            type_id: list
            items:
              type_id: object
              id: loop_id
              properties:
                loop_id:
                  type:
                    type_id: integer
                param_1:
                  type:
                    type_id: integer
                param_2:
                  type:
                    type_id: string
```

Then in the `steps` secton of the workflow, the sub-workflow can be defined as a step with the `loop` list object from above passed to its input.

The parameters for the sub-workflow step are:

  - `kind` - The type of loop (currently only foreach is supported)
  - `items` - A list of objects to pass to the sub-workflow (the [expression language](expressions.md) allows to pass this from the input schema per the above example)
  - `workflow` - The file name for the sub-workflow (this should be in the same directory as the parent workflow)
  - `parallelism` - The number of sub-workflow loop iterations that will run in parallel

```yaml title="workflow.yaml"
steps:
  sub_workflow_loop:
    kind: foreach
    items: !expr $.input.loop
    workflow: sub-workflow.yaml
    parallelism: 1
```

The input yaml file for the above parent workflow would provide the list of objects to loop over as in this example:

```yaml title="input.yaml"
loop:
  - loop_id: 1
    param_1: 10
    param_2: "a"
  - loop_id: 2
    param_1: 20
    param_2: "b"
  - loop_id: 3
    param_1: 30
    param_2: "c"
```

The sub-workflow file then has its complete schema and set of steps as in this example:

```yaml title="sub-workflow.yaml"
input:
  root: RootObject
  objects:
    RootObject:
      id: RootObject
      properties:
        loop_id:
          type:
            type_id: integer
        param_1:
          type:
            type_id: integer
        param_2:
          type:
            type_id: string
steps:
  my_plugin:
    plugin: path/to/my_plugin:1
    input:
      param_1: !expr $.input.param_1
  my_other_plugin:
    plugin: path/to/my_other_plugin:1
    input:
      param_2: !expr $.input.param_2
outputs:
  success:
    loop_id: !expr $.input.loop_id
    my_plugin: !expr $.steps.my_plugin.outputs.success
    my_other_plugin: !expr $.steps.my_other_plugin.outputs.success
```