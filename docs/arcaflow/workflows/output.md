# Writing workflow outputs

Outputs in Arcaflow serve a dual purpose:

1. They provide the desired resulting data from steps and inputs to STDOUT.
2. They allow for the conditional pass/fail state of the workflow (if any defined output is not available, the workflow reports a failure).

You can define an output simply with [expressions](expressions.md). Outputs generally include desired output parameters from individual steps, but may also include data from inputs or even static values.

```yaml
output:
  some_key:
    some_other_key: !expr $.steps.some_step.outputs.success.some_value
  foo: !expr $.inputs.bar
  arca: "flow"
```

## Writing multiple outputs

Arcaflow can produce multiple output groups for a workflow. These output groups are mutually exclusive to each other.

A common example of two mutually exclusive events could be the availability of your data storage service. Let's assume the service is either available, or unavailable (the unavailble state also includes any states where an error is thrown during data insertion). Multiple workflow outputs allows you to plan for these two events.

In this example taken from the [Arcaflow Workflows](https://github.com/arcalot/arcaflow-workflows/blob/main/example-workflow/workflow.yaml) project, the `success` output collects the data from the specified steps and inserts it into data storage. The `no-indexing` output collects the data, the error logs, and does not store the data.

```yaml
{!https://raw.githubusercontent.com/arcalot/arcaflow-workflows/main/example-workflow/workflow.yaml [ln:90-100]!}
```