# Embedding your Python plugin

Instead of using your plugin as a standalone tool or in conjunction with Arcaflow, you can also embed your plugin into your existing Python application. To do that you simply [build a schema](/arcaflow/plugins/python/data-model/) and then call the schema yourself. You can pass raw data as an input, and you'll get the benefit of schema validation.

```python title="myapp.py"
from arcaflow_plugin_sdk import plugin
import my_arcaflow_plugin

# Build your schema with the step functions passed
schema = plugin.build_schema(my_arcaflow_plugin.hello_world)

# Which step from the plugin we want to execute
step_id = "hello_world"

# Input parameters. Note, these must be a dict, not a dataclass
step_params = {
    "name": "Arca Lot",
}

# Execute the step
output_id, output_data = schema(step_id, step_params)

# Print which kind of result we have
pprint.pprint(output_id)

# Print the result data
pprint.pprint(output_data)
```

However, the example above requires you to provide the data as a `dict`, not a `dataclass`, and it will also return a `dict` as an output object. Sometimes, you may want to use a partial approach, where you only use part of the SDK. In this case, you can change your code to run any of the following functions, in order:

- `serialization.load_from_file()` to load a YAML or JSON file into a dict
- `yourschema.unserialize_input()` to turn a `dict` into a `dataclass` needed for your steps
- `yourschema.call_step()` to run a step with the unserialized `dataclass`
- `yourschema.serialize_output()` to turn the output `dataclass` into a `dict`