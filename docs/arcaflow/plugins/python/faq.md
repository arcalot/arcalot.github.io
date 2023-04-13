# Python SDK FAQ

## How can I add a field with dashes, such as `my-field`?

Dataclasses don't support dashes in parameters. You can work around this by defining the `id` annotation:

```python
@dataclasses.dataclass
class MyData:
    my_field: typing.Annotated[
        str,
        schema.id("my-field"),
    ]
```

## How can I write a dataclass from a schema to a YAML or JSON file?

You can [extend Python's JSON encoder](https://stackoverflow.com/questions/51286748/make-the-python-json-encoder-support-pythons-new-dataclasses) to support dataclasses. If that doesn't suit your needs, you can use this SDK to convert the dataclasses to their basic representations and then write that to your JSON or YAML file. First, add this outside of your step:

```python
my_object_schema = plugin.build_object_schema(MyDataclass)
```

Inside your step function you can then dump the data from your input

```python
def my_step(params: MyParams):
    yaml_contents = yaml.dump(my_object_schema.serialize(params.some_param))
```

## How can I easily load a list from a YAML or JSON into a list of dataclasses?

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

