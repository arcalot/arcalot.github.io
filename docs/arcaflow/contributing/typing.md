# The Arcaflow type system

Arcaflow takes a departure from the classic run-and-pray approach of running workloads and validates workflows before executing them. To do this, Arcaflow starts the plugins as needed before the workflow is run and queries them for their **schema**. This schema will contain information about what kind of input a plugin requests and what kind of outputs it can produce.

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
- **Scopes** and **Refs** are object-like types that allow you to create circular references (see below).
- **Any** accepts any primitive type (string, int, float, bool, map, list) but no patterns, objects, etc.

## Validation

The typing system also contains more in-depth validation than just simple types:

### Strings

Strings can have a minimum or maximum length, as well as validation against a regular expression.

### Ints, floats

Number types can have a minimum and maximum value (inclusive).

## Booleans

Boolean types can take a value of either `true` or `false`, but when unserializing from YAML or JSON formats, strings or int values of `true`, `yes`, `on`, `enable`, `enabled`, `1`, `false`, `no`, `off`, `disable`, `disabled` or `0` are also accepted.

### Lists, maps

Lists a7nd maps can have constraints on the minimum or maximum number of items in them (inclusive).

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

## Scopes and refs

Objects, on their own, cannot create circular references. It is not possible to create two objects that refer to each other. That's where scopes and refs come into play. Scopes hold a list of objects, identified by an ID. Refs inside the scope (for example, in an object property) can refer to these IDs. Every scope has a *root* object, which will be used to provide its "object-like" features, such as a list of fields.

For example:

```yaml
objects:
  my_root_object:
    id: my_root_object
    properties:
      ...
root: my_root_object
```

Multiple scopes can be nested into each other. The ref always refers to the closest scope up the tree. Multiple scopes can be used when combining objects from several sources (e.g. several plugins) into one schema to avoid conflicting ID assignments.

## Any

Any accepts any primitive type (string, int, float, bool, map, list) but no patterns, objects, etc. This type is severely limited in its ability to validate data and should only be used in exceptional cases when there is no other way to describe a schema.

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

## Reference Manual

This section explains how a scope object looks like. The [plugin protocol](plugin-protocol.md) contains a few more types that are used when communicating a schema.

|    |    |
|----|----|
| Type: | `scope` |
| Root object: | Scope |
???+ note "Properties"
    ??? info "objects (`map[string, reference[Object]]`)"
        |    |    |
        |----|----|
        | Name: | Objects |
        | Description: | A set of referencable objects. These objects may contain references themselves. |
        | Required: | Yes || Type: | `map[string, reference[Object]]` |
        
        ??? info "Key type"
            |    |    |
            |----|----|
            | Type: | `string` |
            | Minimum: | 1 |
            | Maximum: | 255 |
            | Must match pattern: | `^[$@a-zA-Z0-9-_]&#43;$` |
            
        ??? info "Value type"
            |    |    |
            |----|----|
            | Type: | `reference[Object]` |
            | Referenced object: | Object *(see in the Objects section below)* |
            
        
        
    ??? info "root (`string`)"
        |    |    |
        |----|----|
        | Name: | Root object |
        | Description: | ID of the root object of the scope. |
        | Required: | Yes || Type: | `string` |
        | Minimum: | 1 |
        | Maximum: | 255 |
        | Must match pattern: | `^[$@a-zA-Z0-9-_]&#43;$` |
        
        
???+ note "Objects"
    ??? info "**AnySchema** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            *None*
        
    ??? info "**BoolSchema** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            *None*
        
    ??? info "**Display** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "description (`string`)"
                |    |    |
                |----|----|
                | Name: | Description |
                | Description: | Description for this item if needed. |
                | Required: | No || Type: | `string` |
                | Minimum: | 1 |
                
                
                ??? example "Examples"
                    ```json
                    "Please select the fruit you would like."
                    ```
                
                
            ??? info "icon (`string`)"
                |    |    |
                |----|----|
                | Name: | Icon |
                | Description: | SVG icon for this item. Must have the declared size of 64x64, must not include additional namespaces, and must not reference external resources. |
                | Required: | No || Type: | `string` |
                | Minimum: | 1 |
                
                
                ??? example "Examples"
                    ```json
                    "<svg ...></svg>"
                    ```
                
                
            ??? info "name (`string`)"
                |    |    |
                |----|----|
                | Name: | Name |
                | Description: | Short text serving as a name or title for this item. |
                | Required: | No || Type: | `string` |
                | Minimum: | 1 |
                
                
                ??? example "Examples"
                    ```json
                    "Fruit"
                    ```
                
                
    ??? info "**Float** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "max (`float`)"
                |    |    |
                |----|----|
                | Name: | Maximum |
                | Description: | Maximum value for this float (inclusive). |
                | Required: | No || Type: | `float` |
                
                
                
                ??? example "Examples"
                    ```json
                    16.0
                    ```
                
                
            ??? info "min (`float`)"
                |    |    |
                |----|----|
                | Name: | Minimum |
                | Description: | Minimum value for this float (inclusive). |
                | Required: | No || Type: | `float` |
                
                
                
                ??? example "Examples"
                    ```json
                    5.0
                    ```
                
                
            ??? info "units (`reference[Units]`)"
                |    |    |
                |----|----|
                | Name: | Units |
                | Description: | Units this number represents. |
                | Required: | No || Type: | `reference[Units]` |
                | Referenced object: | Units *(see in the Objects section below)* |
                
                
                ??? example "Examples"
                    ```json
                    {   "base_unit": {       "name_short_singular": "%",       "name_short_plural": "%",       "name_long_singular": "percent",       "name_long_plural": "percent"   }}
                    ```
                
                
    ??? info "**Int** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "max (`int`)"
                |    |    |
                |----|----|
                | Name: | Maximum |
                | Description: | Maximum value for this int (inclusive). |
                | Required: | No || Type: | `int` |
                | Minimum: | 0 |
                
                
                ??? example "Examples"
                    ```json
                    16
                    ```
                
                
            ??? info "min (`int`)"
                |    |    |
                |----|----|
                | Name: | Minimum |
                | Description: | Minimum value for this int (inclusive). |
                | Required: | No || Type: | `int` |
                | Minimum: | 0 |
                
                
                ??? example "Examples"
                    ```json
                    5
                    ```
                
                
            ??? info "units (`reference[Units]`)"
                |    |    |
                |----|----|
                | Name: | Units |
                | Description: | Units this number represents. |
                | Required: | No || Type: | `reference[Units]` |
                | Referenced object: | Units *(see in the Objects section below)* |
                
                
                ??? example "Examples"
                    ```json
                    {   "base_unit": {       "name_short_singular": "%",       "name_short_plural": "%",       "name_long_singular": "percent",       "name_long_plural": "percent"   }}
                    ```
                
                
    ??? info "**IntEnum** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "units (`reference[Units]`)"
                |    |    |
                |----|----|
                | Name: | Units |
                | Description: | Units this number represents. |
                | Required: | No || Type: | `reference[Units]` |
                | Referenced object: | Units *(see in the Objects section below)* |
                
                
                ??? example "Examples"
                    ```json
                    {   "base_unit": {       "name_short_singular": "%",       "name_short_plural": "%",       "name_long_singular": "percent",       "name_long_plural": "percent"   }}
                    ```
                
                
            ??? info "values (`map[int, reference[Display]]`)"
                |    |    |
                |----|----|
                | Name: | Values |
                | Description: | Possible values for this field. |
                | Required: | Yes || Type: | `map[int, reference[Display]]` |
                
                    | Minimum items: | 1 |
                ??? info "Key type"
                    |    |    |
                    |----|----|
                    | Type: | `int` |
                    
                ??? info "Value type"
                    |    |    |
                    |----|----|
                    | Type: | `reference[Display]` |
                    | Referenced object: | Display *(see in the Objects section below)* |
                    
                
                
                ??? example "Examples"
                    ```json
                    {"1024": {"name": "kB"}, "1048576": {"name": "MB"}}
                    ```
                
                
    ??? info "**List** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "items (`one of[string]`)"
                |    |    |
                |----|----|
                | Name: | Items |
                | Description: | ReflectedType definition for items in this list. |
                | Required: | No || Type: | `one of[string]` |
                
                
            ??? info "max (`int`)"
                |    |    |
                |----|----|
                | Name: | Maximum |
                | Description: | Maximum value for this int (inclusive). |
                | Required: | No || Type: | `int` |
                | Minimum: | 0 |
                
                
                ??? example "Examples"
                    ```json
                    16
                    ```
                
                
            ??? info "min (`int`)"
                |    |    |
                |----|----|
                | Name: | Minimum |
                | Description: | Minimum number of items in this list.. |
                | Required: | No || Type: | `int` |
                | Minimum: | 0 |
                
                
                ??? example "Examples"
                    ```json
                    5
                    ```
                
                
    ??? info "**Map** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "keys (`one of[string]`)"
                |    |    |
                |----|----|
                | Name: | Keys |
                | Description: | ReflectedType definition for keys in this map. |
                | Required: | No || Type: | `one of[string]` |
                
                
            ??? info "max (`int`)"
                |    |    |
                |----|----|
                | Name: | Maximum |
                | Description: | Maximum value for this int (inclusive). |
                | Required: | No || Type: | `int` |
                | Minimum: | 0 |
                
                
                ??? example "Examples"
                    ```json
                    16
                    ```
                
                
            ??? info "min (`int`)"
                |    |    |
                |----|----|
                | Name: | Minimum |
                | Description: | Minimum number of items in this list.. |
                | Required: | No || Type: | `int` |
                | Minimum: | 0 |
                
                
                ??? example "Examples"
                    ```json
                    5
                    ```
                
                
            ??? info "values (`one of[string]`)"
                |    |    |
                |----|----|
                | Name: | Values |
                | Description: | ReflectedType definition for values in this map. |
                | Required: | No || Type: | `one of[string]` |
                
                
    ??? info "**Object** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "id (`string`)"
                |    |    |
                |----|----|
                | Name: | ID |
                | Description: | Unique identifier for this object within the current scope. |
                | Required: | Yes || Type: | `string` |
                | Minimum: | 1 |
                | Maximum: | 255 |
                | Must match pattern: | `^[$@a-zA-Z0-9-_]&#43;$` |
                
                
            ??? info "properties (`map[string, reference[Property]]`)"
                |    |    |
                |----|----|
                | Name: | Properties |
                | Description: | Properties of this object. |
                | Required: | Yes || Type: | `map[string, reference[Property]]` |
                
                ??? info "Key type"
                    |    |    |
                    |----|----|
                    | Type: | `string` |
                    | Minimum: | 1 |
                    
                ??? info "Value type"
                    |    |    |
                    |----|----|
                    | Type: | `reference[Property]` |
                    | Referenced object: | Property *(see in the Objects section below)* |
                    
                
                
    ??? info "**OneOfIntSchema** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "discriminator_field_name (`string`)"
                |    |    |
                |----|----|
                | Name: | Discriminator field name |
                | Description: | Name of the field used to discriminate between possible values. If this field is present on any of the component objects it must also be an int. |
                | Required: | No || Type: | `string` |
                
                
                ??? example "Examples"
                    ```json
                    "_type"
                    ```
                
                
            ??? info "types (`map[int, one of[string]]`)"
                |    |    |
                |----|----|
                | Name: | Types |
                | Required: | No || Type: | `map[int, one of[string]]` |
                
                ??? info "Key type"
                    |    |    |
                    |----|----|
                    | Type: | `int` |
                    
                ??? info "Value type"
                    |    |    |
                    |----|----|
                    | Type: | `one of[string]` |
                    
                
                
    ??? info "**OneOfStringSchema** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "discriminator_field_name (`string`)"
                |    |    |
                |----|----|
                | Name: | Discriminator field name |
                | Description: | Name of the field used to discriminate between possible values. If this field is present on any of the component objects it must also be an int. |
                | Required: | No || Type: | `string` |
                
                
                ??? example "Examples"
                    ```json
                    "_type"
                    ```
                
                
            ??? info "types (`map[string, one of[string]]`)"
                |    |    |
                |----|----|
                | Name: | Types |
                | Required: | No || Type: | `map[string, one of[string]]` |
                
                ??? info "Key type"
                    |    |    |
                    |----|----|
                    | Type: | `string` |
                    
                ??? info "Value type"
                    |    |    |
                    |----|----|
                    | Type: | `one of[string]` |
                    
                
                
    ??? info "**Pattern** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            *None*
        
    ??? info "**Property** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "conflicts (`list[string]`)"
                |    |    |
                |----|----|
                | Name: | Conflicts |
                | Description: | The current property cannot be set if any of the listed properties are set. |
                | Required: | No || Type: | `list[string]` |
                
                ??? info "List Items"
                    |    |    |
                    |----|----|
                    | Type: | `string` |
                    
                
            ??? info "default (`string`)"
                |    |    |
                |----|----|
                | Name: | Default |
                | Description: | Default value for this property in JSON encoding. The value must be unserializable by the type specified in the type field. |
                | Required: | No || Type: | `string` |
                
                
            ??? info "display (`reference[Display]`)"
                |    |    |
                |----|----|
                | Name: | Display |
                | Description: | Name, description and icon. |
                | Required: | No || Type: | `reference[Display]` |
                | Referenced object: | Display *(see in the Objects section below)* |
                
                
            ??? info "examples (`list[string]`)"
                |    |    |
                |----|----|
                | Name: | Examples |
                | Description: | Example values for this property, encoded as JSON. |
                | Required: | No || Type: | `list[string]` |
                
                ??? info "List Items"
                    |    |    |
                    |----|----|
                    | Type: | `string` |
                    
                
            ??? info "required (`bool`)"
                |    |    |
                |----|----|
                | Name: | Required |
                | Description: | When set to true, the value for this field must be provided under all circumstances. |
                | Required: | No || Type: | `bool` |
                
                 ```json title="Default"
                 true
                 ```
                
                
            ??? info "required_if (`list[string]`)"
                |    |    |
                |----|----|
                | Name: | Required if |
                | Description: | Sets the current property to required if any of the properties in this list are set. |
                | Required: | No || Type: | `list[string]` |
                
                ??? info "List Items"
                    |    |    |
                    |----|----|
                    | Type: | `string` |
                    
                
            ??? info "required_if_not (`list[string]`)"
                |    |    |
                |----|----|
                | Name: | Required if not |
                | Description: | Sets the current property to be required if none of the properties in this list are set. |
                | Required: | No || Type: | `list[string]` |
                
                ??? info "List Items"
                    |    |    |
                    |----|----|
                    | Type: | `string` |
                    
                
            ??? info "type (`one of[string]`)"
                |    |    |
                |----|----|
                | Name: | Type |
                | Description: | Type definition for this field. |
                | Required: | Yes || Type: | `one of[string]` |
                
                
    ??? info "**Ref** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "display (`reference[Display]`)"
                |    |    |
                |----|----|
                | Name: | Display |
                | Description: | Name, description and icon. |
                | Required: | No || Type: | `reference[Display]` |
                | Referenced object: | Display *(see in the Objects section below)* |
                
                
            ??? info "id (`string`)"
                |    |    |
                |----|----|
                | Name: | ID |
                | Description: | Referenced object ID. |
                | Required: | No || Type: | `string` |
                | Minimum: | 1 |
                | Maximum: | 255 |
                | Must match pattern: | `^[$@a-zA-Z0-9-_]&#43;$` |
                
                
    ??? info "**Scope** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "objects (`map[string, reference[Object]]`)"
                |    |    |
                |----|----|
                | Name: | Objects |
                | Description: | A set of referencable objects. These objects may contain references themselves. |
                | Required: | Yes || Type: | `map[string, reference[Object]]` |
                
                ??? info "Key type"
                    |    |    |
                    |----|----|
                    | Type: | `string` |
                    | Minimum: | 1 |
                    | Maximum: | 255 |
                    | Must match pattern: | `^[$@a-zA-Z0-9-_]&#43;$` |
                    
                ??? info "Value type"
                    |    |    |
                    |----|----|
                    | Type: | `reference[Object]` |
                    | Referenced object: | Object *(see in the Objects section below)* |
                    
                
                
            ??? info "root (`string`)"
                |    |    |
                |----|----|
                | Name: | Root object |
                | Description: | ID of the root object of the scope. |
                | Required: | Yes || Type: | `string` |
                | Minimum: | 1 |
                | Maximum: | 255 |
                | Must match pattern: | `^[$@a-zA-Z0-9-_]&#43;$` |
                
                
    ??? info "**String** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "max (`int`)"
                |    |    |
                |----|----|
                | Name: | Maximum |
                | Description: | Maximum length for this string (inclusive). |
                | Required: | No || Type: | `int` |
                | Minimum: | 0 |
                | Units: | characters |
                
                
                ??? example "Examples"
                    ```json
                    16
                    ```
                
                
            ??? info "min (`int`)"
                |    |    |
                |----|----|
                | Name: | Minimum |
                | Description: | Minimum length for this string (inclusive). |
                | Required: | No || Type: | `int` |
                | Minimum: | 0 |
                | Units: | characters |
                
                
                ??? example "Examples"
                    ```json
                    5
                    ```
                
                
            ??? info "pattern (`pattern`)"
                |    |    |
                |----|----|
                | Name: | Pattern |
                | Description: | Regular expression this string must match. |
                | Required: | No || Type: | `pattern` |
                
                
                ??? example "Examples"
                    ```json
                    "^[a-zA-Z]+$"
                    ```
                
                
    ??? info "**StringEnum** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "values (`map[string, reference[Display]]`)"
                |    |    |
                |----|----|
                | Name: | Values |
                | Description: | Mapping where the left side of the map holds the possible value and the right side holds the display value for forms, etc. |
                | Required: | Yes || Type: | `map[string, reference[Display]]` |
                
                    | Minimum items: | 1 |
                ??? info "Key type"
                    |    |    |
                    |----|----|
                    | Type: | `string` |
                    
                ??? info "Value type"
                    |    |    |
                    |----|----|
                    | Type: | `reference[Display]` |
                    | Referenced object: | Display *(see in the Objects section below)* |
                    
                
                
                ??? example "Examples"
                    ```json
                    {
                      "apple": {
                        "name": "Apple"
                      },
                      "orange": {
                        "name": "Orange"
                      }
                    }
                    ```
                
                
    ??? info "**Unit** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "name_long_plural (`string`)"
                |    |    |
                |----|----|
                | Name: | Name long (plural) |
                | Description: | Longer name for this UnitDefinition in plural form. |
                | Required: | Yes || Type: | `string` |
                
                
                ??? example "Examples"
                    ```json
                    "bytes","characters"
                    ```
                
                
            ??? info "name_long_singular (`string`)"
                |    |    |
                |----|----|
                | Name: | Name long (singular) |
                | Description: | Longer name for this UnitDefinition in singular form. |
                | Required: | Yes || Type: | `string` |
                
                
                ??? example "Examples"
                    ```json
                    "byte","character"
                    ```
                
                
            ??? info "name_short_plural (`string`)"
                |    |    |
                |----|----|
                | Name: | Name short (plural) |
                | Description: | Shorter name for this UnitDefinition in plural form. |
                | Required: | Yes || Type: | `string` |
                
                
                ??? example "Examples"
                    ```json
                    "B","chars"
                    ```
                
                
            ??? info "name_short_singular (`string`)"
                |    |    |
                |----|----|
                | Name: | Name short (singular) |
                | Description: | Shorter name for this UnitDefinition in singular form. |
                | Required: | Yes || Type: | `string` |
                
                
                ??? example "Examples"
                    ```json
                    "B","char"
                    ```
                
                
    ??? info "**Units** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "base_unit (`reference[Unit]`)"
                |    |    |
                |----|----|
                | Name: | Base UnitDefinition |
                | Description: | The base UnitDefinition is the smallest UnitDefinition of scale for this set of UnitsDefinition. |
                | Required: | Yes || Type: | `reference[Unit]` |
                | Referenced object: | Unit *(see in the Objects section below)* |
                
                
                ??? example "Examples"
                    ```json
                    {
                      "name_short_singular": "B",
                      "name_short_plural": "B",
                      "name_long_singular": "byte",
                      "name_long_plural": "bytes"
                    }
                    ```
                
                
            ??? info "multipliers (`map[int, reference[Unit]]`)"
                |    |    |
                |----|----|
                | Name: | Base UnitDefinition |
                | Description: | The base UnitDefinition is the smallest UnitDefinition of scale for this set of UnitsDefinition. |
                | Required: | No || Type: | `map[int, reference[Unit]]` |
                
                ??? info "Key type"
                    |    |    |
                    |----|----|
                    | Type: | `int` |
                    
                ??? info "Value type"
                    |    |    |
                    |----|----|
                    | Type: | `reference[Unit]` |
                    | Referenced object: | Unit *(see in the Objects section below)* |
                    
                
                
                ??? example "Examples"
                    ```json
                    {
                      "1024": {
                        "name_short_singular": "kB",
                        "name_short_plural": "kB",
                        "name_long_singular": "kilobyte",
                        "name_long_plural": "kilobytes"
                      },
                      "1048576": {
                        "name_short_singular": "MB",
                        "name_short_plural": "MB",
                        "name_long_singular": "megabyte",
                        "name_long_plural": "megabytes"
                      }
                    }
                    ```
                
                
