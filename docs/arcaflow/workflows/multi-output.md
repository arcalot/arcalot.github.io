# Writing multiple outputs

A common example of two mutually exclusive events could be the availability of your data storage service. Let's assume the service is either available, or unavailable (the unavailble state also includes any states where an error is thrown during data insertion). Multiple workflow outputs allows you to plan for these two events.

In this example, the `success` output collects the data from the specified steps and inserts it into data storage. The `no-indexing` output collects the data, the error logs, and does not store the data.

```yaml
{!https://raw.githubusercontent.com/arcalot/arcaflow-workflows/multiple-outputs-example/example-workflow/workflow.yaml [ln:90-100]!}
```