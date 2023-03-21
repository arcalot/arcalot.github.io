# Writing workflow outputs

Outputs in Arcaflow serve a dual purpose:

1. They provide you with the resulting data.
2. When a step fails that an output has a dependency on, the workflow will fail.

You can define an output simply with [expressions](expressions.md):

```yaml
output:
  some_key:
    some_other_key: !expr $.steps.some_step.outputs.success.some_value
```