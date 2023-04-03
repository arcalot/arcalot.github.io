# Creating a Python data model

When creating a data model for Arcaflow plugins in Python, everything starts with [dataclasses](https://docs.python.org/3/library/dataclasses.html). They allow Arcaflow to get information about the data types of individual fields in your class:

```python
import dataclasses


@dataclasses.dataclass
class MyDataModel:
    some_field: str
    other_field: int
```

However, Arcaflow doesn't support all Python data types. You pick from the following list:

- [`str`](#strings)
- [`int`](#integers)
- [`float`](#floating-point-numbers)
- [`bool`](#booleans)
- [Enums](#enum)
- [`re.Pattern`](#patterns)
- [`typing.List[othertype]`](#lists)
- [`typing.Dict[keytype, valuetype]`](#dicts)
- [`typing.Union[onedataclass, anotherdataclass]`](#union-types)
- Dataclasses
- [`typing.Any`](#any-types)

You can read more about the individual types in the [data types](#data-types) section

## Optional parameters

You can also declare any parameter as optional like this:

```python
@dataclasses.dataclass
class MyClass:
    param: typing.Optional[int] = None
```

Note that adding `typing.Optional` is not enough, you *must* specify the default value.

## Annotations for validation and metadata

You can specify desired validations for each field like this:

```python
@dataclasses.dataclass
class MyClass:
    param: typing.Annotated[int, schema.name("Param")]
```

You can use the following annotations to add metadata to your fields:

- `schema.id` adds a serialized field name for the current field (e.g. one containing dashes, which is not valid in Python)
- `schema.name` adds a human-readable name to the parameter. This can be used to present a form field.
- `schema.description` adds a long-form description to the field.
- `schema.example` adds an example value to the field. You can repeat this annotation multiple times. The example must be provided as primitive types (no dataclasses).

You can also add validations to the fields. The following annotations are valid for all data types:

- `schema.required_if` specifies a list of fields that cause the current field to be required. If the other fields are empty, the current field is not required. (Make sure to use the optional annotation above.)
- `schema.required_if_not` specifies a list of fields that, if not filled, cause the current field to be required. (Make sure to use the optional annotation above.)
- `schema.conflicts` specifies a list of fields that cannot be used together with the current field.  (Make sure to use the optional annotation above.)

Additionally, some data types have their own validations and metadata, such as `schema.min`, `schema.max`, `schema.pattern`, or `schema.units`.

## Data types

### Strings

Strings are, as the name suggests, strings of human-readable characters. You can specify them in your dataclass like this:

```python
some_field: str
```

Additionally, you can apply the following validations:

- `schema.min()` specifies the minimum length of the string if the field is set.
- `schema.max()` specifies the maximum length of the string if the field is set.
- `schema.pattern()` specifies the regular expression the string must match if the field is set.

### Integers

Integers are 64-bit signed whole numbers. You can specify them in your dataclass like this:

```python
some_field: int
```

Additionally, you can apply the following validations and metadata:

- `schema.min()` specifies the minimum number if the field is set.
- `schema.max()` specifies the maximum number if the field is set.
- `schema.units()` specifies the units for this field (e.g. bytes). See [Units](#units).

### Floating point numbers

Floating point numbers are 64-bit signed fractions. You can specify them in your dataclass like this:

```python
some_field: float
```

!!! warning
    Floating point numbers are inaccurate! Make sure to transmit numbers requiring accuracy as integers!

Additionally, you can apply the following validations and metadata:

- `schema.min()` specifies the minimum number if the field is set.
- `schema.max()` specifies the maximum number if the field is set.
- `schema.units()` specifies the units for this field (e.g. bytes). See [Units](#units).

### Booleans

Booleans are `True` or `False` values. You can specify them in your dataclass like this:

```python
some_field: bool
```

Booleans have no additional validations or metadata.

### Enums

Sometimes, you need to specify a set of values that are valid for a field. In Arcaflow, this list of valid values can either be a list of strings, or a list of integers. You can specify an enum like this:

```python
import enum


class MyEnum(enum.Enum):
  Value1 = "value 1"
  Value2 = "value 2"

my_field: MyEnum
```

!!! tip
    Enums don't need to be dataclasses.

!!! warning
    Do not mix integers and strings in the same enum!

### Patterns

When you need to hold regular expressions, you can use a pattern field. This is tied to the [Python regular expressions library](https://docs.python.org/3/library/re.html). You can specify a pattern field like this:

```python
import re

my_field: re.Pattern
```

Pattern fields have no additional validations or metadata.

### Lists

When you want to make a list in Arcaflow, you always need to specify its contents. You can do that like this:

```python
my_field: typing.List[str]
```

Lists can have the following validations:

- `schema.min()` specifies the minimum number of items in the list.
- `schema.max()` specifies the maximum number of items in the list.

!!! tip
    Items in lists can also be annotated with validations.

### Dicts

Dicts (maps in Arcaflow) are key-value pairs. You need to specify both the key and the value type. You can do that as follows:

```python
my_field: typing.Dict[str, str]
```

Lists can have the following validations:

- `schema.min()` specifies the minimum number of items in the list.
- `schema.max()` specifies the maximum number of items in the list.

!!! tip
    Items in dicts can also be annotated with validations.

### Union types

Union types (one-of in Arcaflow) allow you to specify two or more possible objects (dataclasses) that can be in a specific place. The only requirement is that there must be a common field (discriminator) and each dataclass must have a unique value for this field. If you do not add this field to your dataclasses, it will be added automatically for you.

For example:

```python
import typing
import dataclasses


@dataclasses.dataclass
class FullName:
    first_name: str
    last_name: str


@dataclasses.dataclass
class Nickname:
    nickname: str


name: typing.Annotated[
    typing.Union[
        typing.Annotated[FullName, schema.discriminator_value("full")],
        typing.Annotated[Nickname, schema.discriminator_value("nick")]
    ], schema.discriminator("name_type")]
```

!!! tip
    The `schema.discriminator` and `schema.discriminator_value` annotations are optional. If you do not specify them, a discriminator will be generated for you.

## Any types

Any types allow you to pass through any primitive data (no dataclasses). However, this comes with severe limitations as far as validation and use in workflows is concerned, so this type should only be used in limited cases. For example, if you would like to create a plugin that inserts data into an ElasticSearch database the "any" type would be appropriate here.

You can define an "any" type like this:

```python
my_data: typing.Any
```

## Units

Integers and floats can have unit metadata associated with them. For example, a field may contain a unit description like this:

```python
time: typing.Annotated[int, schema.units(schema.UNIT_TIME)]
```

In this case, a string like `5m30s` will automatically be parsed into nanoseconds. Integers will pass through without conversion. You can also define your own unit types. At minimum, you need to specify the base type (nanoseconds in this case), and you can specify multipliers:

```python
my_units = schema.Units(
  schema.Unit(
    # Short, singular
    "ns",
    # Short, plural
    "ns",
    # Long, singular
    "nanosecond",
    # Long, plural
    "nanoseconds"
  ),
  {
    1000: schema.Unit(
      "ms",
      "ms",
      "microsecond",
      "microseconds"
    ),
    # ...
  }
)
```

You can then use this description in your `schema.units` annotations. Additionally, you can also use it to convert an integer or float into its string representation with the `my_units.format_short` or `my_units.format_long` functions. If you need to parse a string yourself, you can use `my_units.parse`.
