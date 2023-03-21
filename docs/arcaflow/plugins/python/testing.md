# Testing your Python plugin

When writing your first plugin, you will probably want to test it manually. However, as development progresses, you should switch to automated testing. Automated testing makes sure your plugins don't break when you introduce changes.

This page describes the following test scenarios:

1. Manual testing helps 
2. Serialization tests for your input and output to make sure your classes can be serialized for transport
3. Functional tests that call your plugin and make sure it works correctly

## Manual testing

Manual testing is easy: prepare a test input file in YAML format, then run the plugin as a command line tool. For example, the hello world plugin would take this input:

```yaml
name: Arca Lot
```

You could then run the example plugin:

```
python example_plugin -f my-input-file.yaml
```

The plugin will run and present you with the output.

!!! tip 
    If you have more than one step, don't forget to pass the `-s step-id` parameter.

!!! tip
    To prevent output from breaking the functionality when attached to the Arcaflow Engine, the SDK hides any output your step function writes to the standard output or standard error. You can use the `--debug` flag to show any output on the standard error in standalone mode.


## Writing a serialization test

You can use any test framework you like for your serialization test, we'll demonstrate with [unittest](https://docs.python.org/3/library/unittest.html) as it is included directly in Python. The key to this test is to call `plugin.test_object_serialization()` with an instance of your dataclass that you want to test:

```python
class ExamplePluginTest(unittest.TestCase):
    def test_serialization(self):
        self.assertTrue(plugin.test_object_serialization(
            example_plugin.PodScenarioResults(
                [
                    example_plugin.Pod(
                        namespace="default",
                        name="nginx-asdf"
                    )
                ]
            )
        ))
```

Remember, you need to call this function with an **instance** containing actual data, not just the class name.

The test function will first serialize, then unserialize your data and check if it's the same. If you want to use a manually created schema, you can do so, too:


```python
class ExamplePluginTest(unittest.TestCase):
    def test_serialization(self):
        plugin.test_object_serialization(
            example_plugin.PodScenarioResults(
                #...
            ),
            schema.ObjectType(
                #...
            )
        )
```

## Functional tests

Functional tests don't have anything special about them. You can directly call your code with your dataclasses as parameters, and check the return. This works best on auto-generated schemas with the `@plugin.step` decorator. See below for manually created schemas.

```python
class ExamplePluginTest(unittest.TestCase):
    def test_functional(self):
        input = example_plugin.PodScenarioParams()

        output_id, output_data = example_plugin.pod_scenario(input)

        # Check if the output is always an error, as it is the case for the example plugin.
        self.assertEqual("error", output_id)
        self.assertEqual(
            output_data,
            example_plugin.PodScenarioError(
                "Cannot kill pod .* in namespace .*, function not implemented"
            )
        )
```

If you created your schema manually, the best way to write your tests is to include the schema in your test. This will automatically validate both the input and the output, making sure they conform to your schema. For example:

```python
class ExamplePluginTest(unittest.TestCase):
    def test_functional(self):
        step_schema = schema.StepSchema(
            #...
            handler = example_plugin.pod_scenario,
        )
        input = example_plugin.PodScenarioParams()

        output_id, output_data = step_schema(input)

        # Check if the output is always an error, as it is the case for the example plugin.
        self.assertEqual("error", output_id)
        self.assertEqual(
            output_data,
            example_plugin.PodScenarioError(
                "Cannot kill pod .* in namespace .*, function not implemented"
            )
        )
```
