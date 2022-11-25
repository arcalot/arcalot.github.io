# Creating plugins with Python

If you want to create an Arcaflow plugin in Python, you will need three things:

1. A container engine that can build images
2. Python 3.9+ ([PyPy](https://www.pypy.org/) is supported)
3. The [Python SDK for Arcaflow plugins](https://github.com/arcalot/arcaflow-plugin-sdk-python)

The easiest way is to start from the [template repository for Python plugins](https://github.com/arcalot/arcaflow-plugin-template-python), but starting from scratch is also fully supported.

Before you start please familiarize yourself with the [Arcaflow type system](../concepts/typing.md).

## Setting up your environment

First, you will have to set up your environment.


=== "From the template repository"

    1. Fork, then clone the [template repository](https://github.com/arcalot/arcaflow-plugin-template-python)
    2. Figure out what the right command to call your Python version is:
           ```
           python3.10 --version
           python3.9 --version
           python3 --version
           python --version
           ```
       Make sure you have at least Python 3.9.
    3. Create a [virtualenv](https://virtualenv.pypa.io/en/latest/) in your project directory using the following command, replacing your Python call:
           ```
           python -m venv venv
           ```
    4. Activate the venv:
           ```
           source venv/bin/activate
           ```
    5. Install the dependencies:
           ```
           pip install -r requirements.txt
           ```
    6. Run the test plugin:
           ```
           ./example_plugin.py -f example.yaml
           ```
    7. Run the unit tests:
           ```
           ./test_example_plugin.py
           ```
    8. Generate a JSON schema:
           ```
           ./example_plugin.py --json-schema input >example.schema.json
           ```
      If you are using the [YAML plugin for VSCode](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml), add the following line to the top of your config file for code completion:
           ```
           # yaml-language-server: $schema=example.schema.json
           ```

=== "Using pip"

    1. Create an empty folder.
    2. Create a `requirements.txt` with the following content:
           ```
           arcaflow-plugin-sdk
           ```
    3. Figure out what the right command to call your Python version is:
           ```
           python3.10 --version
           python3.9 --version
           python3 --version
           python --version
           ```
       Make sure you have at least Python 3.9.
    4. Create a [virtualenv](https://virtualenv.pypa.io/en/latest/) in your project directory using the following command, replacing your Python call:
           ```
           python -m venv venv
           ```
    5. Activate the venv:
           ```
           source venv/bin/activate
           ```
    6. Install the dependencies:
           ```
           pip install -r requirements.txt
           ```
    7. Copy the [example plugin](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/example_plugin.py), [example config](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/example.yaml) and the [tests](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/test_example_plugin.py) to your directory.
    8. Run the test plugin:
           ```
           ./example_plugin.py -f example.yaml
           ```
    9. Run the unit tests:
           ```
           ./test_example_plugin.py
           ```
    10. Generate a JSON schema:
           ```
           ./example_plugin.py --json-schema input >example.schema.json
           ```
      If you are using the [YAML plugin for VSCode](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml), add the following line to the top of your config file for code completion:
           ```
           # yaml-language-server: $schema=example.schema.json
           ```    
    11. Copy and customize the [Dockerfile](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/Dockerfile) from the example repository.
    12. Set up your CI/CD system as you see fit.

=== "Using Poetry"

    1. Assuming you have [Poetry](https://python-poetry.org) installed, run the following command:
           ```
           poetry new your-plugin
           ```
       Then change the current directory to `your-plugin`.
    2. Figure out what the right command to call your Python version is:
           ```
           which python3.10
           which python3.9
           which python3
           which python
           ```
       Make sure you have at least Python 3.9.
    3. Set Poetry to Python 3.9:
           ```
           poetry env use /path/to/your/python3.9
           ```
    4. Check that your `pyproject.toml` file has the following lines:
           ```toml
           [tool.poetry.dependencies]
           python = "^3.9"
           ```
    4. Add the SDK as a dependency:
           ```
           poetry add arcaflow-plugin-sdk
           ```
    5. Copy the [example plugin](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/example_plugin.py), [example config](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/example.yaml) and the [tests](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/test_example_plugin.py) to your directory.
    6. Activate the venv:
           ```
           poetry shell
           ```
    7. Run the test plugin:
           ```
           ./example_plugin.py -f example.yaml
           ```
    8. Run the unit tests:
           ```
           ./test_example_plugin.py
           ```
    9. Generate a JSON schema:
           ```
           ./example_plugin.py --json-schema input >example.schema.json
           ```
      If you are using the [YAML plugin for VSCode](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml), add the following line to the top of your config file for code completion:
           ```
           # yaml-language-server: $schema=example.schema.json
           ```
    10. Copy and customize the [Dockerfile](https://github.com/arcalot/arcaflow-plugin-template-python/blob/main/Dockerfile) from the example repository.
    11. Set up your CI/CD system as you see fit.

Now you are ready to start hacking away at your plugin!

## Creating your plugin the easy way

A plugin is nothing but a list of functions with type-annotated parameters and decorators. For example, let's create a function:

```python
def pod_scenario(input_parameter):
    # Do pod scenario magic here
```

However, this SDK uses [Python type hints](https://docs.python.org/3/library/typing.html) and [decorators](https://peps.python.org/pep-0318/) to automatically generate the schema required for Arcaflow. Alternatively, you can also [build a schema by hand](#building-a-schema-by-hand). The current section describes the automated way, the [section below](#building-a-schema-by-hand) describes the manual way.

### Input parameters

Your step function must take exactly one input parameter. This parameter must be a [dataclass](https://docs.python.org/3/library/dataclasses.html). For example:

```python
import dataclasses
import re

@dataclasses.dataclass
class PodScenarioParams:
    namespace_pattern: re.Pattern = re.compile(".*")
    pod_name_pattern: re.Pattern = re.compile(".*")
```

As you can see, our dataclass has two fields, each of which is a `re.Pattern`. This SDK automatically reads the types of the fields to construct the schema. See the [Types](#types) section below for supported type patterns.

### Output parameters

Now that you have your input parameter class, you must create one or more output classes in a similar fashion:

```python
import dataclasses
import typing

@dataclasses.dataclass
class Pod:
    namespace: str
    name: str

@dataclasses.dataclass
class PodScenarioResults:
    pods_killed: typing.List[Pod]
```

As you can see, your input may incorporate other classes, which themselves have to be dataclasses. Read on for [more information on types](#types).

### Creating a step function

Now that we have both our input and output(s), let's go back to our initial `pod_scenario` function. Here we need to add a decorator to tell the SDK about metadata, and more importantly, what the return types are. (This is needed because Python does not support reading return types to an adequate level.)

```python
from arcaflow_plugin_sdk import plugin


@plugin.step(
    id="pod",
    name="Pod scenario",
    description="Kill one or more pods matching the criteria",
    outputs={"success": PodScenarioResults, "error": PodScenarioError},
)
def pod_scenario(params: PodScenarioParams):
    # Fail for now
    return "error", PodScenarioError("Not implemented")
```

As you can see, apart from the metadata, we also declare the type of the parameter object so the SDK can read it.

Let's go through the `@plugin.step` decorator parameters one by one:

- `id` indicates the identifier of this step. This must be globally unique
- `name` indicates a human-readable name for this step
- `description` indicates a longer description for this step
- `outputs` indicates which possible outputs the step can have, with their output identifiers as keys

The function must return the output identifier, along with the output object.

### Running the plugin

Finally, we need to call `plugin.run()` in order to actually run the plugin:

```python
if __name__ == "__main__":
    sys.exit(plugin.run(plugin.build_schema(
        # Pass one or more scenario functions here
        pod_scenario,
    )))
```

You can now call your plugin using `./yourscript.py -f path-to-parameters.yaml`. If you have defined more than one step, you also need to pass the `-s step-id` parameter.

**Keep in mind, you should always test your plugin.** See [Testing your plugin](#testing-your-plugin) below for details.

!!! tip
    To prevent output from breaking the functionality when attached to the Arcaflow Engine, the SDK hides any output your step function writes to the standard output or standard error. You can use the `--debug` flag to show any output on the standard error in standalone mode.

### Types

The SDK supports a wide range of types. Let's start with the basics:

- `str`
- `int`
- `float`
- `bool`
- Enums
- `re.Pattern`
- `typing.List[othertype]` (you must specify the type for the contents of the list)
- `typing.Dict[keytype, valuetype]` (you must specify the type for the keys and values)
- Any dataclass

#### Optional parameters

You can also declare any parameter as optional like this:

```python
@dataclasses.dataclass
class MyClass:
    param: typing.Optional[int] = None
```

Note that adding `typing.Optional` is not enough, you *must* specify the default value.

#### Union types

Union types are supported as long as all members are dataclasses. For example:

```python
@dataclasses.dataclass
class A:
    a: str

@dataclasses.dataclass
class B:
    b: str

@dataclasses.dataclass
class MyParams:
    items: typing.List[typing.Union[A, B]]
```

In the underlying transport a field name `_type` will be added to act as a serialization discriminator. You can also customize the discriminator field:

```python
@dataclasses.dataclass
class A:
    a: str

@dataclasses.dataclass
class B:
    b: str

@dataclasses.dataclass
class MyParams:
    items: typing.List[
        typing.Annotated[
            typing.Union[A, B],
            annotations.discriminator("foo")
        ]
    ]
```

If you intend to use a non-string descriminator field, or you want to manually specify the discriminator value, you can
do so by adding a `discriminator_value` annotation:

```python
@dataclasses.dataclass
class MyParams:
    items: typing.List[
        typing.Annotated[
            typing.Union[
                typing.Annotated[A, annotations.discriminator_value("first")],
                typing.Annotated[B, annotations.discriminator_value("second")]
            ],
            annotations.discriminator("foo")
        ]
    ]
```

!!! tip
    You can add the discriminator field to your underlying dataclasses, but when present, their schema must match *exactly*.

#### Validation

You can also validate the values by using [`typing.Annotated`](https://docs.python.org/3/library/typing.html#typing.Annotated), such as this:

```python
class MyClass:
    param: typing.Annotated[int, schema.min(5)]
```

This will create a minimum-value validation for the parameter of 5. The following annotations are supported for validation:

- `schema.min()` for strings, ints, floats, lists, and maps
- `schema.max()` for strings, ints, floats, lists, and maps
- `schema.pattern()` for strings
- `schema.required_if()` for any field on an object
- `schema.required_if_not()` for any field on an object
- `schema.conflicts()` for any field on an object

#### Metadata

You can add metadata to your schema by using annotations

```python
@dataclasses.dataclass
class MyClass:
    param: typing.Annotated[
           str,
           schema.id("my-param"),
           schema.name("Parameter 1"),
           schema.description("This is a parameter"),
           schema.icon("<svg...>Add a 64x64 SVG here</svg>")
    ]
```

### Default values

You can add default values for your dataclass members like this:

```python
@dataclasses.dataclass
class MyClass:
    param: str = "this is the default value"
```

### Units

You can also include unit information in your schema. This will allow a user interface to treat your values accordingly:

```python
@dataclasses.dataclass
class MyClass:
    param: typing.Annotated[
        int,
        schema.units(schema.UNIT_BYTE),
    ]
```

You can also define your own unit. For that, you have to define your base unit (e.g. "bytes") and then the multipliers:

```python
UNIT_BYTE = schema.Units(
    schema.Unit(
        # Short, singular form:
        "B",
        # Short, plural form:
        "B",
        # Long, singular form:
        "byte",
        # Long, plural form:
        "bytes"
    ),
    {
        1024: schema.Unit(
            "kB",
            "kB",
            "kilobyte",
            "kilobytes"
        ),
        1048576: schema.Unit(
            "MB",
            "MB",
            "megabyte",
            "megabytes"
        ),
    }
)
```

This also allows you to parse strings like `5MB 4kB`:

```python
parsed_unit: int = UNIT_BYTE.parse("5MB 4 kB")
```

Conversely, you can also render the units:

```python
print(UNIT_BYTE.format_short(5246976))
```

Check the code completion for your units for more options.

### Examples

You can also provide example values for your fields to help people providing the data:

```python
@dataclasses.dataclass
class MyClass:
    param: typing.Annotated[
        int,
        schema.example(1024),
    ]
```

You can, of course, provide multiple examples too. Note, the example must be provided in its raw form (as dicts,
lists, and scalars), not as dataclasses!

## Creating your plugin the hard way (not recommended)

For performance reasons, or for the purposes of separation of concerns, you may want to create a schema by hand. This section walks you through declaring a schema by hand and then using it to call a function. Keep in mind, the SDK still primarily operates with dataclasses to transport structured data.

However, we do not recommend this approach because it results in a lot of boilerplate code, and the real-world benefits are marginal at best. Also keep in mind, that your plugin will need more frequent updates if Arcaflow is extending the schema system and you want to switch to new versions.

We start by defining a schema:

```python
from arcaflow_plugin_sdk import schema
from typing import Dict

steps: Dict[str, schema.StepSchema]

s = schema.Schema(
    steps,
)
```

The `steps` parameter here must be a dict, where the key is the step ID and the value is the step schema. So, let's create a step schema:

```python
from arcaflow_plugin_sdk import schema

step_schema = schema.StepSchema(
    id = "pod",
    name = "Pod scenario",
    description = "Kills pods",
    input = input_schema,
    outputs = outputs,
    handler = my_handler_func
)
```

Let's go in order:

- The `input` must be a schema of the type `schema.ObjectType`. This describes the single parameter that will be passed to `my_handler_func`.
- The `outputs` describe a `Dict[str, schema.ObjectType]`, where the key is the ID for the returned output type, while the value describes the output schema.
- The `handler` function takes one parameter, the object described in `input` and must return a tuple of a string and the output object. Here the ID uniquely identifies which output is intended, for example `success` and `error`, while  the second parameter in the tuple must match the `outputs` declaration.

That's it! Now all that's left is to define the `ObjectType` and any subobjects.

### ObjectType

The ObjectType is intended as a backing type for [dataclasses](https://docs.python.org/3/library/dataclasses.html). For example:

```python
t = schema.ObjectType(
    TestClass,
    {
        "a": schema.Field(
            type=schema.StringType(),
            required=True,
        ),
        "b": schema.Field(
            type=schema.IntType(),
            required=True,
        )
    }
)
```

The fields support the following parameters:

- `type`: underlying type schema for the field (required)
- `name`: name for the current field
- `description`: description for the current field
- `required`: marks the field as required
- `required_if`: a list of other fields that, if filled, will also cause the current field to be required
- `required_if_not`: a list of other fields that, if not set, will cause the current field to be required
- `conflicts`: a list of other fields that cannot be set together with the current field

### ScopeType and RefType

Sometimes it is necessary to create circular references. This is where the `ScopeType` and the `RefType` comes into play. Scopes contain a list of objects that can be referenced by their ID, but one object is special: the root object of the scope. The RefType, on the other hand, is there to reference objects in a scope.

Currently, the Python implementation passes the scope to the ref type directly, but the important rule is that ref types **always** reference their nearest scope up the tree. Do not create references that aim at scopes not directly above the ref!

For example:

```python
@dataclasses.dataclass
class OneOfData1:
    a: str

@dataclasses.dataclass
class OneOfData2:
    b: OneOfData1

scope = schema.ScopeType(
    {
        "OneOfData1": schema.ObjectType(
            OneOfData1,
            {
                "a": schema.Field(
                    schema.StringType()
                )
            }
        ),
    },
    # Root object of scopes
    "OneOfData2",
)

scope.objects["OneOfData2"] = schema.ObjectType(
    OneOfData2,
    {
        "b": schema.Field(
            schema.RefType("OneOfData1", scope)
        )
    }
)
```

As you can see, this API is not easy to use and is likely to change in the future.

### OneOfType

The OneOfType allows you to create a type that is a combination of other ObjectTypes. When a value is deserialized, a special discriminator field is consulted to figure out which type is actually being sent.

This discriminator field may be present in the underlying type. If it is, the type must match the declaration in the AnyOfType.

For example:

```python
@dataclasses.dataclass
class OneOfData1:
    type: str
    a: str

@dataclasses.dataclass
class OneOfData2:
    b: int

scope = schema.ScopeType(
    {
        "OneOfData1": schema.ObjectType(
            OneOfData1,
            {
                # Here the discriminator field is also present in the underlying type
                "type": schema.Field(
                    schema.StringType(),
                ),
                "a": schema.Field(
                    schema.StringType()
                )
            }
        ),
        "OneOfData2": schema.ObjectType(
            OneOfData2,
            {
                "b": schema.Field(
                    schema.IntType()
                )
            }
        )
    },
    # Root object of scopes
    "OneOfData1",
)
    
s = schema.OneOfStringType(
    {
        # Option 1
        "a": schema.RefType(
            # The RefType resolves against the scope.
            "OneOfData1",
            scope
        ),
        # Option 2
        "b": schema.RefType(
            "OneOfData2",
            scope
        ),
    },
    # Pass the scope this type belongs do
    scope,
    # Discriminator field
    "type",
)

serialized_data = s.serialize(OneOfData1(
    "a",
    "Hello world!"
))
pprint.pprint(serialized_data)
```

Note, that the OneOfTypes take all object-like elements, such as refs, objects, or scopes.

### StringType

String types indicate that the underlying type is a string. 

```python
t = schema.StringType()
```

The string type supports the following parameters:

- `min_length`: minimum length for the string (inclusive)
- `max_length`: maximum length for the string (inclusive)
- `pattern`: regular expression the string must match

### PatternType

The pattern type indicates that the field must contain a regular expression. It will be decoded as `re.Pattern`.

```python
t = schema.PatternType()
```

The pattern type has no parameters.

### IntType

The int type indicates that the underlying type is an integer.

```python
t = schema.IntType()
```

The int type supports the following parameters:

- `min`: minimum value for the number (inclusive).
- `max`: minimum value for the number (inclusive).

### FloatType

The float type indicates that the underlying type is a floating point number.

```python
t = schema.FloatType()
```

The float type supports the following parameters:

- `min`: minimum value for the number (inclusive).
- `max`: minimum value for the number (inclusive).

### BoolType

The bool type indicates that the underlying value is a boolean. When unserializing, this type also supports string and integer values of `true`, `yes`, `on`, `enable`, `enabled`, `1`, `false`, `no`, `off`, `disable`, `disabled` or `0`.

### EnumType

The enum type creates a type from an existing enum:

```python
class MyEnum(Enum):
    A = "a"
    B = "b"

t = schema.EnumType(MyEnum)
```

The enum type has no further parameters.

### ListType

The list type describes a list of items. The item type must be described:

```python
t = schema.ListType(
    schema.StringType()
)
```

The list type supports the following extra parameters:

- `min`: The minimum number of items in the list (inclusive)
- `max`: The maximum number of items in the list (inclusive)

### MapType

The map type describes a key-value type (dict). You must specify both the key and the value type:

```python
t = schema.MapType(
    schema.StringType(),
    schema.StringType()
)
```

The map type supports the following extra parameters:

- `min`: The minimum number of items in the map (inclusive)
- `max`: The maximum number of items in the map (inclusive)

### Running the plugin

If you create the schema by hand, you can add the following code to your plugin: 

```python
if __name__ == "__main__":
    sys.exit(plugin.run(your_schema))
```

You can then run your plugin as described before.

## Testing your plugin

You should always make sure you have enough test coverage to prevent your plugin from breaking. To help you with testing, this SDK provides some tools for testing:

1. Serialization tests for your input and output to make sure your classes can be serialized for transport
2. Functional tests that call your plugin and make sure it works correctly

### Writing a serialization test

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

### Functional tests

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

## Embedding your plugin

Instead of using your plugin as a standalone tool or in conjunction with Arcaflow, you can also embed your plugin into your existing Python application. To do that you simply build a schema using one of the methods described above and then call the schema yourself. You can pass raw data as an input, and you'll get the benefit of schema validation.

```python
# Build your schema using the schema builder from above with the step functions passed.
schema = plugin.build_schema(pod_scenario)

# Which step we want to execute
step_id = "pod"
# Input parameters. Note, these must be a dict, not a dataclass
step_params = {
    "pod_name_pattern": ".*",
    "pod_namespace_pattern": ".*",
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


## FAQ

### How can I add a field with dashes, such as `my-field`?

Dataclasses don't support dashes in parameters. You can work around this by defining the `id` annotation:

```python
@dataclasses.dataclass
class MyData:
    my_field: typing.Annotated[
        str,
        schema.id("my-field"),
    ]
```

### How can I write a dataclass from a schema to a YAML or JSON file?

You can [extend Pythons JSON encoder](https://stackoverflow.com/questions/51286748/make-the-python-json-encoder-support-pythons-new-dataclasses) to support dataclasses. If that doesn't suit your needs, you can use this SDK to convert the dataclasses to their basic representations and then write that to your JSON or YAML file. First, add this outside of your step:

```python
my_object_schema = plugin.build_object_schema(YourDataclass)
```

Inside your step function you can then dump the data from your input

```python
def your_step(params: YourParams)
    yaml_contents = yaml.dump(my_object_schema.serialize(params.some_param))
```

### How can I easily load a list from a YAML or JSON into a list of dataclasses?

This requires a bit of trickery. First, we build a schema from the dataclass representing the row or entry in the list:

```python
my_row_schema = plugin.build_object_schema(MyRow)
```

Then you can create a list schema:

```python
my_list_schema = schema.ListType(my_row_schema)
```

You can now unserialize a list obtained from the YAML or JSON file:

```python
my_data = my_list_schema.unserialize(json.loads(...))
```

