# Writing workflow inputs

The input section of a workflow is much like a plugin schema: it describes the data model of the workflow itself. This is useful because the input can be validated ahead of time. Any input data can then be referenced by the individual steps.

!!! tip
    The workflow input schema is analogous to the plugin input schema in that it defines the expected inputs and formats. But a workflow author has the freedom to define the schema independently of the plugin schema -- This means that objects can be named and documented differently, catering to the workflow user, and input validation can happen before a plugin is loaded.

The workflow inputs start with a scope object. As an overview, a scope looks like this:

```yaml title="workflow.yaml"
input:
  root: RootObject
  objects:
    RootObject:
      id: RootObject
      properties:
        name:
          type:
            type_id: string
        # Other properties of the root object
    # Other objects that can be referenced here
```

This corresponds to the following workflow input:

```yaml title="workflow_input.yaml"
name: Arca Lot
```

Admittedly, this looks complicated, but read on, it will become clear very quickly.

## Objects

Let's start with objects. Objects are like structs or classes in programming. They have two properties: an ID and a list of properties. The basic structure looks like this:

```yaml
some_object:
  id: some_object
  properties:
    # Properties here
```

### Properties

Now you need to define a property. Let's say, we want to define a string with the name of the user. You can do this as follows:

```yaml
type_id: object
id: some_object
properties:
name:
  type:
    type_id: string
```

Notice, that the `type_id` field is indented. That's because the `type` field describes a string type, which has additional parameters. For example:

```yaml
type_id: object
id: some_object
properties:
name:
  type:
    type_id: string
    min: 1 # Minimum length for the string
```

There are also additional attributes of the property itself. For example:

```yaml
type_id: object
id: some_object
properties:
name:
  type:
    type_id: string
    min: 1 # Minimum length for the string
  display:
    name: Name
    description: Name of the user.
  conflicts:
    - full_name
```

Properties have the following attributes:

| Attribute         | Type       | Description                                                                                |
|-------------------|------------|--------------------------------------------------------------------------------------------|
| `display`         | `Display`  | Display metadata of the property. See [Display values](#display-values).                   |
| `required`        | `bool`     | If set to true, the field must always be filled.                                           |
| `required_if`     | `[]string` | List of other properties that, if filled, lead to the current property being required.     |
| `required_if_not` | `[]string` | List of other properties that, if not filled, lead to the current property being required. |
| `conflicts`       | `[]string` | List of other properties that conflict the current property.                               |
| `default`         | `string`   | Default value for this property, JSON-encoded.                                             |
| `examples`        | `[]string` | Examples for the current property, JSON-encoded.                                           |

!!! note
    Unlike the plugin schema where an unassigned default value is set to `None`, for the workflow schema you simply omit the default to leave it unassigned.

## Scopes and refs

Scopes behave like objects, but they serve an additional purpose. Suppose, object `A` had a property of the object type `B`, but now you needed to reference back to object `A`. Without references, there would be no way to do this.

OpenAPI and JSON Schema have [a similar concept](https://json-schema.org/understanding-json-schema/structuring.html), but in those systems all references are global. This presents a problem when merging schemas. For example, both Docker and Kubernetes have an object called `Volume`. These objects would need to be renamed when both configurations are in one schema.

Arcaflow has a different solution: every plugin, every part of a workflow has its own scope. When a reference is found in a scope, it always relates to its own scope. This way, references don't get mixed.

Let's take a simple example: a scope with objects `A` and `B`, referencing each other.

```yaml
type_id: scope
root: A
objects:
  A:
    type_id: object
    id: A
    properties:
      b:
        type:
          type_id: ref
          id: B
        required: false
  B:
    type_id: object
    id: B
    properties:
      a:
        type:
          type_id: ref
          id: A
        required: false
```

This you can create a circular dependency between these objects without needing to copy-paste their properties.

Additionally, refs have an extra `display` property, which references a [Display value](#display-values) to provide context for the reference.

## Strings

Strings are, as the name suggests, strings of human-readable characters. They have the following properties:

```yaml
type_id: string
min: # Minimum number of characters. Optional.
max: # Maximum number of characters. Optional.
pattern: # Regular expression this string must match. Optional.
```

## Pattern

Patterns are special kinds of strings that hold regular expressions.

```yaml
type_id: pattern
```

## Integers

Integers are similar to strings, but they don't have a `pattern` field but have a `units` field. (See [Units](#units).)

```yaml
type_id: integer
min: # Minimum value. Optional.
max: # Maximum value. Optional.
units:
  # Units definition. Optional.
```

## Floats

Floating point numbers are similar to integers.

```yaml
type_id: float
min: # Minimum value. Optional.
max: # Maximum value. Optional.
units:
  # Units definition. Optional.
```

## String enums

Enums only allow a fixed set of values. String enums map string keys to a display value. (See [Display values](#display-values).)

```yaml
type_id: enum_string
values:
  red:
    name: Red
  yellow:
    name: Yellow
```

## Integer enums

Enums only allow a fixed set of values. Integer enums map integer keys to a display value. (See [Display values](#display-values).)

```yaml
type_id: enum_integer
values:
  1:
    name: Red
  2:
    name: Yellow
```

## Booleans

Booleans can hold a true or false value.

```yaml
type_id: bool
```

## Lists

Lists hold items of a specific type. You can also define their minimum and maximum size.

```yaml
type_id: list
items:
  type_id: type of the items
  # Other definitions for list items
min: 1 # Minimum number of items in the list (optional)
max: 2 # maximum number of items in the list (optional)
```

## Maps

Maps are key-value mappings. You must define both the key and value types, whereas keys can only be strings, integers, string enums, or integer enums.

```yaml
type_id: map
keys:
  type_id: string
values:
  type_id: string
min: 1 # Minimum number of items in the map (optional)
max: 2 # maximum number of items in the map (optional)
```

## One-of (string discriminator)

One-of types allow you to specify multiple alternative objects, scopes, or refs. However, these objects must contain a common field (discriminator) and each value for that field must correspond to exactly one object type.

!!! tip
    If the common field is not specified in the possible objects, it is implicitly added. If it is specified, however, it must match the discriminator type.

```yaml
type_id: one_of_string
discriminator_field_name: object_type # Defaults to: _type
types:
  a:
    type_id: object
    id: A
    properties:
      # Properties of object A.
  b:
    type_id: object
    id: B
    properties:
      # Properties of object B
```

We can now use the following value as an input:

```yaml
object_type: a
# Other values for object A
```

In contrast, you can specify `object_type` as `b` and that will cause the unserialization to run with the properties of object `B`.

## One-of (integer discriminator)

One-of types allow you to specify multiple alternative objects, scopes, or refs. However, these objects must contain a common field (discriminator) and each value for that field must correspond to exactly one object type.

!!! tip
    If the common field is not specified in the possible objects, it is implicitly added. If it is specified, however, it must match the discriminator type.

```yaml
type_id: one_of_int
discriminator_field_name: object_type # Defaults to: _type
types:
  1:
    type_id: object
    id: A
    properties:
      # Properties of object A.
  2:
    type_id: object
    id: B
    properties:
      # Properties of object B
```

We can now use the following value as an input:

```yaml
object_type: 1
# Other values for object A
```

In contrast, you can specify `object_type` as `2` and that will cause the unserialization to run with the properties of object `B`.

## Any types

Any types allow any data to pass through without validation. We recommend using the "any" type due to its lack of validation and the risk to cause runtime errors. Only use any types if you can truly handle **any** data that is passed.

```yaml
type_id: any
```

## Display values

Display values are all across the Arcaflow schema. They are useful to provide human-readable descriptions of properties, refs, etc. that can be used to generate nice, human-readable documentation, user interfaces, etc. They are **always optional** and consist of the following 3 fields:

```yaml
name: Short name
description: Longer description of what the item does, possibly in multiple lines.
icon: |
  <svg ...></svg> # SVG icon, 64x64 pixels, without doctype and external references.
```

## Units

Units make it easier to parse and display numeric values. For example, if you have an integer representing nanoseconds, you may want to parse strings like `5m30s`.

Units have two parameters: a base unit description and multipliers. For example:

```yaml
base_unit:
  name_short_singular: B
  name_short_plural: B
  name_long_singular: byte
  name_long_plural: bytes
multipliers:
  1024:
    name_short_singular: kB
    name_short_plural: kB
    name_long_singular: kilobyte
    name_long_plural: kilobytes
  # ...
```
