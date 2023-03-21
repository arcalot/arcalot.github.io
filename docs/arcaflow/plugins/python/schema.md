# Writing a Python plugin schema by hand

If you want to skip the automatic schema generation described in previous chapters, you can also create a schema by hand.

!!! warning
    This process is complicated, requires providing redundant information and should be avoided if at all possible. We recommend creating a data model using dataclasses, decorators and annotations.

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

### AnyType

The "any" type allows any primitive type to pass through. However, this comes with severe limitations and the data cannot be validated, so its use is discouraged. You can create an `AnyType` by simply doing this:

```python
t = schema.AnyType()
```

### Running the plugin

If you create the schema by hand, you can add the following code to your plugin:

```python
if __name__ == "__main__":
    sys.exit(plugin.run(your_schema))
```

You can then run your plugin as described in the [writing your first plugin](first.md) section.
