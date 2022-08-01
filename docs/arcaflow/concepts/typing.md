# The Arcaflow type system

Arcaflow takes a departure from the classic run-and-pray approach of running workloads and validates workflows for validity before executing them. To do this, Arcaflow starts the plugins as needed before the workflow is run and queries them for their **schema**. This schema will contain information about what kind of input a plugin requests and what kind of outputs it can produce.

A plugin can support multiple **workflow steps** and must provide information about the data types in its **input and output** for each step. A step can have exactly one input format, but may declare more than one output.

The typesystem is inspired by [JSON schema](https://json-schema.org/) and [OpenAPI](https://swagger.io/specification/), but it is more restrictive due to the need to efficiently serialize workloads over various formats.

## Types

The typing system supports the following data types.

- **Objects** are key-value pairs where the keys are always a fixed set of strings and values are of various types declared for each key. They are similar to classes in most programming languages. Fields in objects can be *optional*, which means they will have no value (commonly known as `null`, `nil`, or `None`), or a default value.
- **OneOf** are a special type that is a union of multiple objects, distinguished by a special field called the discriminator. 
- **Lists** are a sequence of values of the same type. The value type can be any of the other types described in this section. List items must always have a value and cannot be empty (`null`, `nil`, or `None`).
- **Maps** are key-value pairs that always have fixed types for both keys and values. Maps with mixed keys or values are not supported. Map keys can only be strings, integers, or enums. Map keys and values must always have a value and cannot be empty (`null`, `nil`, or `None`).
- **Enums** are either strings or integers that can take only a fixed set of values. Enums with mixed value types are not supported.
- **Strings** are a sequence of bytes.
- **Patterns** are regular expressions.
- **Integers** are 64-bit numbers that can take both positive and negative values.
- **Floats** are 64-bit floating point numbers that can take both positive and negative values.
- **Booleans** are values of `true` or `false` and cannot take any other values.

### Planned future types

- **Timestamps** are nanosecond-scale timestamp values for a fixed time in UTC. They are stored and transported as integers, but may be unserialized from strings too.
- **Dates** are calendar dates without timezone information.
- **Times** are the time of a day denominated as hours, minutes, seconds, etc. on a nanosecond scale.
- **Datetimes** are date and times together in one field.
- **Durations** are nanosecond-scale timespan values.
- **UUIDs** are UUID-formatted strings.
- **Sets** are an unordered collection of items that can only contain unique items.

## Validation

The typing system also contains more in-depth validation than just simple types:

### Strings

Strings can have a minimum or maximum length, as well as validation against a regular expression.

### Ints, floats

Number types can have a minimum and maximum value (inclusive).

## Booleans

Boolean types can take a value of either `true` or `false`, but when unserializing from YAML or JSON formats, strings or int values of `true`, `yes`, `on`, `enable`, `enabled`, `1`, `false`, `no`, `off`, `disable`, `disabled` or `0` are also accepted.

### Lists, maps

Lists and maps can have constraints on the minimum or maximum number of items in them (inclusive).

### Objects

Object fields can have several constraints:

- `required_if` has a list of other fields that, if set, make the current field required.
- `required_if_not` has a list of other fields that, if none are set, make the current field required.
- `conflicts` has a list of other fields that cannot be set together with the current field.

### OneOf

When you need to create a list of multiple object types, or simply have an either-or choice between two object types, you can use the OneOf type. This field uses an already existing field of the underlying objects, or adds an extra field to the schema to distinguish between the different types. Translated to JSON, you might see something like this:

```json
{
  "_type": "Greeter",
  "message": "Hello world!"
}
```

## Metadata

Object fields can also declare metadata that will help with creating user interfaces for the object. These fields are:

- **name**: A user-readable name for the field.
- **description**: A user-readable description for the field. It may contain newlines, but no other formatting is allowed.
- **icon**: SVG icon

## Intent inference

For display purposes, the type system is designed so that it can infer the intent of the data. We wish to communicate the following intents:

- Graphs are x-y values of timestamps mapped to one or more values.
- Log lines are timestamps associated with text.
- Events are timestamps associated with other structured data.

We explicitly document the following inference rules, which will probably change in the future.

- A map with keys of timestamps and values of integers or floats is rendered as a graph.
- A map with keys of timestamps and values of objects consisting only of integers and floats is rendered as a graph.
- A map with keys of timestamps and values of strings is considered a log line.
- A map with keys of timestamps and objects that don't match the rules above are considered an event.
- A map with keys of short strings and integer or float values is considered a pie chart.
- A list of objects consisting of a single timestamp and otherwise only integers and floats is rendered as a graph.
- A list of objects with a single timestamp and a single string are considered a log line.
- A list of objects with a single short string and a single integer or float is considered a pie chart.
- A list of objects consisting of no more than one timestamp and multiple other fields not matching the rules above is considered an event.
- If an object has a field called "title", "name", or "label", it will be used as a label for the current data set in a chart, or as a title for the wrapping box for the user interface elements.
