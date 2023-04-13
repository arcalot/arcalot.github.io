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