# Creating a Python data model

Every plugin needs a schema to represent its expected inputs and outputs in a machine-readable format. The schema [strong typing](/arcaflow/concepts/typing) is a core design element of Arcaflow, enabling us to build portable workflows that compartmentalize failure conditions and avoid data errors.

When creating a data model for Arcaflow plugins in Python, everything starts with [dataclasses](https://docs.python.org/3/library/dataclasses.html). They allow Arcaflow to get information about the data types of individual fields in your class:

```python title="plugin.py"
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

```python title="plugin.py"
@dataclasses.dataclass
class MyClass:
    param: typing.Optional[int] = None
```

Note that adding `typing.Optional` is not enough, you *must* specify the default value.

## Annotations for validation and metadata

You can specify desired validations for each field like this:

```python title="plugin.py"
@dataclasses.dataclass
class MyClass:
    param: typing.Annotated[int, schema.name("Param")]
```

!!! Tip
    Annotated objects are preferred as a best practice for a documented schema, and are expected for any [officially-supported community plugins](/arcaflow/plugins/python/official/).

You can use the following annotations to add metadata to your fields:

- `schema.id` adds a serialized field name for the current field (e.g. one containing dashes, which is not valid in Python)
- `schema.name` adds a human-readable name to the parameter. This can be used to present a form field.
- `schema.description` adds a long-form description to the field.
- `schema.example` adds an example value to the field. You can repeat this annotation multiple times. The example must be provided as primitive types (no dataclasses).

You can also add validations to the fields. The following annotations are valid for all data types:

- `schema.required_if` specifies a field that causes the current field to be required. If the other field is empty, the current field is not required. You can repeat this annotation multiple times. (Make sure to use the optional annotation above.)
- `schema.required_if_not` specifies a field that, if not filled, causes the current field to be required. You can repeat this annotation multiple times.(Make sure to use the optional annotation above.)
- `schema.conflicts` specifies a field that cannot be used together with the current field. You can repeat this annotation multiple times. (Make sure to use the optional annotation above.)

Additionally, some data types have their own validations and metadata, such as `schema.min`, `schema.max`, `schema.pattern`, or `schema.units`.

!!! Note
    When combining `typing.Annotated` with `typing.Optional`, the default value is assigned to the `Annotated` object, **not** to the `Optional` object.

    ```python title="plugin.py"
    @dataclasses.dataclass
    class MyClass:
        param: typing.Annotated[
            typing.Optional[int],
            schema.name("Param")
        ] = None
    ```

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


Enums, short for enumerations, are used to define a set of named values as unique constants. They provide a way to represent a fixed number of possible values for a variable, parameter, or property.

By using enums, you can give meaningful names to distinct values, making the code more self-explanatory and provides a convenient way to work with fixed sets of named constants.

Sometimes, you need to specify a set of values that are valid for a field. In Arcaflow, this list of valid values can either be a list of strings, or a list of integers. You can specify an enum like this:

```python
import enum


class MyEnum(enum.Enum):
  Value1 = "value 1"
  Value2 = "value 2"

my_field: MyEnum
```
The MyEnum class above is defined as a subclass of enum.Enum, indicating that it represents an enumeration. It contains two members, Value1 and Value2, which are defined as class attributes. Each member is associated with a constant value, in this case, the strings "value 1" and "value 2" respectively.

The 'my_field' variable is a variable of type MyEnum. It can store one of the defined enumeration members (Value1 or Value2).

The members of the MyEnum enumeration are accessed using dot notation. 

```python
     value = MyEnum.Value1
```
In the above example, the Value1 member of MyEnum is accessed and assigned to the variable value.

!!! Note 
    The keys are the names of the enum elements, and the values are the corresponding values associated with those elements. The keys are used to refer to specific enum elements, while the values represent the actual values assigned to each element. The values can be of string or integer data types. The keys are used to reference specific enum elements, and the values represent the assigned values for comparison or other purposes.

    When checking parameters against enum items, it is the key (enum item name) that is used for comparison, not the value. The purpose of enum items is to provide a set of distinct named constants, and the key (name) serves as an identifier for each constant. The values associated with the enum items are typically used for other purposes, such as representation, comparison, or additional information associated with the enum item.

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

!!! Note
    If you are looking for a way to do pattern/regex matching for a string you will need to use the schema.pattern() validation which specifies the regular expression, to which the string must match.

    The below example declares that the first_name variable must only have uppercase and lowercase alphabets. 

    ```python title="plugin.py"
    @dataclasses.dataclass
    class MyClass:
        first_name: typing.Annotated[
            str,
            schema.min(2),
            schema.pattern(re.compile("^[a-zA-Z]+$")),
            schema.example("Arca"),
            schema.name("First name")
        ]
    ```

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

### Any types

Any types allow you to pass through any primitive data (no dataclasses). **However, this comes with severe limitations as far as validation and use in workflows is concerned, so this type should only be used in limited cases.** For example, if you would like to create a plugin that inserts data into an ElasticSearch database the "any" type would be appropriate here.

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

### Built-In Units

A number of unit types are built-in to the python SDK for convenience:

- `UNIT_BYTE` - Bytes and 2^10 multiples (kilo-, mega-, giga-, tera-, peta-)
- `UNIT_TIME` - Nanoseconds and human-friendly multiples (microseconds, seconds, minutes, hours, days)
- `UNIT_CHARACTER` - Character notations (char, chars, character, characters)
- `UNIT_PERCENT` - Percentage notations (%, percent)
