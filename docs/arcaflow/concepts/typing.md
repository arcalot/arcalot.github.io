# The Arcaflow type system

!!! warning "Work in Progress"
    This document is work in progress and may change until the final release!

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
- **Scopes** and **Refs** are object-like types that allow you to create circular references (see below).

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

<ul><li><strong>Type:</strong> Scope <span title="Scopes hold one or more objects that can be referenced inside the properties of those objects by ref types. Ref types always reference the closest scope.">💡</span></li><li><strong>Root object:</strong> Scope</li>
<li><strong>Properties</strong><ul><li><details><summary>objects (Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
                <ul><li><strong>Name: </strong> Objects</li><li><strong>Description: </strong> A set of referencable objects. These objects may contain references themselves.</li><li><strong>Required</strong></li><li><strong>Type:</strong> Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[$@a-zA-Z0-9-_]&#43;$</code></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;Object&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Object</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>root (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
                <ul><li><strong>Name: </strong> Root object</li><li><strong>Description: </strong> ID of the root object of the scope.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[$@a-zA-Z0-9-_]&#43;$</code></li></ul>
            </details></li></ul></li>
<li><details><summary><strong>Objects</strong></summary><details><summary>AnySchema (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>BoolSchema (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>Display (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>description (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Description</li><li><strong>Description: </strong> Description for this item if needed.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;Please select the fruit you would like.&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li><li><details><summary>icon (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Icon</li><li><strong>Description: </strong> SVG icon for this item. Must have the declared size of 64x64, must not include additional namespaces, and must not reference external resources.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;&lt;svg ...&gt;&lt;/svg&gt;&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li><li><details><summary>name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name</li><li><strong>Description: </strong> Short text serving as a name or title for this item.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;Fruit&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Float (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>max (Floating point number (64 bits, signed) <span title="Floats hold fractional numbers. They are imprecise due to their internal representation.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Maximum</li><li><strong>Description: </strong> Maximum value for this float (inclusive).</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>16.0</code></li>
    </ul>
</li><li><strong>Type:</strong> Floating point number (64 bits, signed) <span title="Floats hold fractional numbers. They are imprecise due to their internal representation.">💡</span></li>
</ul>
            </details></li><li><details><summary>min (Floating point number (64 bits, signed) <span title="Floats hold fractional numbers. They are imprecise due to their internal representation.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Minimum</li><li><strong>Description: </strong> Minimum value for this float (inclusive).</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>5.0</code></li>
    </ul>
</li><li><strong>Type:</strong> Floating point number (64 bits, signed) <span title="Floats hold fractional numbers. They are imprecise due to their internal representation.">💡</span></li>
</ul>
            </details></li><li><details><summary>units (Object reference to &ldquo;Units&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Units</li><li><strong>Description: </strong> Units this number represents.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>{   &#34;base_unit&#34;: {       &#34;name_short_singular&#34;: &#34;%&#34;,       &#34;name_short_plural&#34;: &#34;%&#34;,       &#34;name_long_singular&#34;: &#34;percent&#34;,       &#34;name_long_plural&#34;: &#34;percent&#34;   }}</code></li>
    </ul>
</li><li><strong>Type:</strong> Object reference to &ldquo;Units&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Units</li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Int (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>max (Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Maximum</li><li><strong>Description: </strong> Maximum value for this int (inclusive).</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>16</code></li>
    </ul>
</li><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum:</strong> 0</li>
</ul>
            </details></li><li><details><summary>min (Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Minimum</li><li><strong>Description: </strong> Minimum value for this int (inclusive).</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>5</code></li>
    </ul>
</li><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum:</strong> 0</li>
</ul>
            </details></li><li><details><summary>units (Object reference to &ldquo;Units&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Units</li><li><strong>Description: </strong> Units this number represents.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>{   &#34;base_unit&#34;: {       &#34;name_short_singular&#34;: &#34;%&#34;,       &#34;name_short_plural&#34;: &#34;%&#34;,       &#34;name_long_singular&#34;: &#34;percent&#34;,       &#34;name_long_plural&#34;: &#34;percent&#34;   }}</code></li>
    </ul>
</li><li><strong>Type:</strong> Object reference to &ldquo;Units&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Units</li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>IntEnum (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>units (Object reference to &ldquo;Units&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Units</li><li><strong>Description: </strong> Units this number represents.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>{   &#34;base_unit&#34;: {       &#34;name_short_singular&#34;: &#34;%&#34;,       &#34;name_short_plural&#34;: &#34;%&#34;,       &#34;name_long_singular&#34;: &#34;percent&#34;,       &#34;name_long_plural&#34;: &#34;percent&#34;   }}</code></li>
    </ul>
</li><li><strong>Type:</strong> Object reference to &ldquo;Units&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Units</li></ul>
            </details></li><li><details><summary>values (Map <span title="Maps hold a set of keys associated with values.">💡</span> of Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span> &rarr; Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Values</li><li><strong>Description: </strong> Possible values for this field.</li><li><strong>Required</strong></li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>{&#34;1024&#34;: {&#34;name&#34;: &#34;kB&#34;}, &#34;1048576&#34;: {&#34;name&#34;: &#34;MB&#34;}}</code></li>
    </ul>
</li><li><strong>Type:</strong> Map <span title="Maps hold a set of keys associated with values.">💡</span> of Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span> &rarr; Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum items:</strong> 1</li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li>
</ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;Display&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Display</li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>List (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>items (One of (string discriminator) <span title="One of types can be one of a specified list of objects (polymorphism). The discriminator field holds the information which object it actually is.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Items</li><li><strong>Description: </strong> ReflectedType definition for items in this list.</li><li><strong>Type:</strong> One of (string discriminator) <span title="One of types can be one of a specified list of objects (polymorphism). The discriminator field holds the information which object it actually is.">💡</span></li></ul>
            </details></li><li><details><summary>max (Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Maximum</li><li><strong>Description: </strong> Maximum value for this int (inclusive).</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>16</code></li>
    </ul>
</li><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum:</strong> 0</li>
</ul>
            </details></li><li><details><summary>min (Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Minimum</li><li><strong>Description: </strong> Minimum number of items in this list..</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>5</code></li>
    </ul>
</li><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum:</strong> 0</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Map (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>keys (One of (string discriminator) <span title="One of types can be one of a specified list of objects (polymorphism). The discriminator field holds the information which object it actually is.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Keys</li><li><strong>Description: </strong> ReflectedType definition for keys in this map.</li><li><strong>Type:</strong> One of (string discriminator) <span title="One of types can be one of a specified list of objects (polymorphism). The discriminator field holds the information which object it actually is.">💡</span></li></ul>
            </details></li><li><details><summary>max (Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Maximum</li><li><strong>Description: </strong> Maximum value for this int (inclusive).</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>16</code></li>
    </ul>
</li><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum:</strong> 0</li>
</ul>
            </details></li><li><details><summary>min (Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Minimum</li><li><strong>Description: </strong> Minimum number of items in this list..</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>5</code></li>
    </ul>
</li><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum:</strong> 0</li>
</ul>
            </details></li><li><details><summary>values (One of (string discriminator) <span title="One of types can be one of a specified list of objects (polymorphism). The discriminator field holds the information which object it actually is.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Values</li><li><strong>Description: </strong> ReflectedType definition for values in this map.</li><li><strong>Type:</strong> One of (string discriminator) <span title="One of types can be one of a specified list of objects (polymorphism). The discriminator field holds the information which object it actually is.">💡</span></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Object (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>id (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> ID</li><li><strong>Description: </strong> Unique identifier for this object within the current scope.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[$@a-zA-Z0-9-_]&#43;$</code></li></ul>
            </details></li><li><details><summary>properties (Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Properties</li><li><strong>Description: </strong> Properties of this object.</li><li><strong>Required</strong></li><li><strong>Type:</strong> Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;Property&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Property</li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>OneOfIntSchema (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>discriminator_field_name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Discriminator field name</li><li><strong>Description: </strong> Name of the field used to discriminate between possible values. If this field is present on any of the component objects it must also be an int.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;_type&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>types (Map <span title="Maps hold a set of keys associated with values.">💡</span> of Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span> &rarr; Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Types</li><li><strong>Type:</strong> Map <span title="Maps hold a set of keys associated with values.">💡</span> of Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span> &rarr; Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li>
</ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> One of (string discriminator) <span title="One of types can be one of a specified list of objects (polymorphism). The discriminator field holds the information which object it actually is.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>OneOfStringSchema (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>discriminator_field_name (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Discriminator field name</li><li><strong>Description: </strong> Name of the field used to discriminate between possible values. If this field is present on any of the component objects it must also be an int.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;_type&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>types (Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Types</li><li><strong>Type:</strong> Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> One of (string discriminator) <span title="One of types can be one of a specified list of objects (polymorphism). The discriminator field holds the information which object it actually is.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Pattern (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul></ul>
</li>
</ul>
        </details><details><summary>Property (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>conflicts (List <span title="Lists hold zero or more items of the specified type.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Conflicts</li><li><strong>Description: </strong> The current property cannot be set if any of the listed properties are set.</li><li><strong>Type:</strong> List <span title="Lists hold zero or more items of the specified type.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>default (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Default</li><li><strong>Description: </strong> Default value for this property in JSON encoding. The value must be unserializable by the type specified in the type field.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>display (Object reference to &ldquo;Display&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Display</li><li><strong>Description: </strong> Name, description and icon.</li><li><strong>Type:</strong> Object reference to &ldquo;Display&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Display</li></ul>
            </details></li><li><details><summary>examples (List <span title="Lists hold zero or more items of the specified type.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Examples</li><li><strong>Description: </strong> Example values for this property, encoded as JSON.</li><li><strong>Type:</strong> List <span title="Lists hold zero or more items of the specified type.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>required (Boolean <span title="Booleans hold true or false values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Required</li><li><strong>Description: </strong> When set to true, the value for this field must be provided under all circumstances.</li><li><strong>Default (JSON encoded)</strong>: true</li><li><strong>Type:</strong> Boolean <span title="Booleans hold true or false values.">💡</span></li></ul>
            </details></li><li><details><summary>required_if (List <span title="Lists hold zero or more items of the specified type.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Required if</li><li><strong>Description: </strong> Sets the current property to required if any of the properties in this list are set.</li><li><strong>Type:</strong> List <span title="Lists hold zero or more items of the specified type.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>required_if_not (List <span title="Lists hold zero or more items of the specified type.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Required if not</li><li><strong>Description: </strong> Sets the current property to be required if none of the properties in this list are set.</li><li><strong>Type:</strong> List <span title="Lists hold zero or more items of the specified type.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span></li><li>
    <details>
        <summary>List items</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>type (One of (string discriminator) <span title="One of types can be one of a specified list of objects (polymorphism). The discriminator field holds the information which object it actually is.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Type</li><li><strong>Description: </strong> Type definition for this field.</li><li><strong>Required</strong></li><li><strong>Type:</strong> One of (string discriminator) <span title="One of types can be one of a specified list of objects (polymorphism). The discriminator field holds the information which object it actually is.">💡</span></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Ref (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>display (Object reference to &ldquo;Display&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Display</li><li><strong>Description: </strong> Name, description and icon.</li><li><strong>Type:</strong> Object reference to &ldquo;Display&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Display</li></ul>
            </details></li><li><details><summary>id (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> ID</li><li><strong>Description: </strong> Referenced object ID.</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[$@a-zA-Z0-9-_]&#43;$</code></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Scope (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>objects (Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Objects</li><li><strong>Description: </strong> A set of referencable objects. These objects may contain references themselves.</li><li><strong>Required</strong></li><li><strong>Type:</strong> Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[$@a-zA-Z0-9-_]&#43;$</code></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;Object&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Object</li></ul>
    </details>
</li>
</ul>
            </details></li><li><details><summary>root (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Root object</li><li><strong>Description: </strong> ID of the root object of the scope.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[$@a-zA-Z0-9-_]&#43;$</code></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>String (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>max (Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Maximum</li><li><strong>Description: </strong> Maximum length for this string (inclusive).</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>16</code></li>
    </ul>
</li><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum:</strong> 0</li><li><strong>Units:</strong> characters</li>
</ul>
            </details></li><li><details><summary>min (Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Minimum</li><li><strong>Description: </strong> Minimum length for this string (inclusive).</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>5</code></li>
    </ul>
</li><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li><strong>Minimum:</strong> 0</li><li><strong>Units:</strong> characters</li>
</ul>
            </details></li><li><details><summary>pattern (Pattern <span title="Patterns hold regular expressions.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Pattern</li><li><strong>Description: </strong> Regular expression this string must match.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;^[a-zA-Z]&#43;$&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> Pattern <span title="Patterns hold regular expressions.">💡</span></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>StringEnum (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>values (Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Values</li><li><strong>Description: </strong> Mapping where the left side of the map holds the possible value and the right side holds the display value for forms, etc.</li><li><strong>Required</strong></li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>{
  &#34;apple&#34;: {
    &#34;name&#34;: &#34;Apple&#34;
  },
  &#34;orange&#34;: {
    &#34;name&#34;: &#34;Orange&#34;
  }
}</code></li>
    </ul>
</li><li><strong>Type:</strong> Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum items:</strong> 1</li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;Display&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Display</li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Unit (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>name_long_plural (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name long (plural)</li><li><strong>Description: </strong> Longer name for this UnitDefinition in plural form.</li><li><strong>Required</strong></li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;bytes&#34;,&#34;characters&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>name_long_singular (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name long (singular)</li><li><strong>Description: </strong> Longer name for this UnitDefinition in singular form.</li><li><strong>Required</strong></li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;byte&#34;,&#34;character&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>name_short_plural (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name short (plural)</li><li><strong>Description: </strong> Shorter name for this UnitDefinition in plural form.</li><li><strong>Required</strong></li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;B&#34;,&#34;chars&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li><li><details><summary>name_short_singular (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Name short (singular)</li><li><strong>Description: </strong> Shorter name for this UnitDefinition in singular form.</li><li><strong>Required</strong></li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>&#34;B&#34;,&#34;char&#34;</code></li>
    </ul>
</li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li></ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>Units (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>base_unit (Object reference to &ldquo;Unit&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Base UnitDefinition</li><li><strong>Description: </strong> The base UnitDefinition is the smallest UnitDefinition of scale for this set of UnitsDefinition.</li><li><strong>Required</strong></li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>{
  &#34;name_short_singular&#34;: &#34;B&#34;,
  &#34;name_short_plural&#34;: &#34;B&#34;,
  &#34;name_long_singular&#34;: &#34;byte&#34;,
  &#34;name_long_plural&#34;: &#34;bytes&#34;
}</code></li>
    </ul>
</li><li><strong>Type:</strong> Object reference to &ldquo;Unit&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Unit</li></ul>
            </details></li><li><details><summary>multipliers (Map <span title="Maps hold a set of keys associated with values.">💡</span> of Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span> &rarr; Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Base UnitDefinition</li><li><strong>Description: </strong> The base UnitDefinition is the smallest UnitDefinition of scale for this set of UnitsDefinition.</li><li><strong>Examples (JSON encoded):</strong>
    <ul>
        <li><code>{
  &#34;1024&#34;: {
    &#34;name_short_singular&#34;: &#34;kB&#34;,
    &#34;name_short_plural&#34;: &#34;kB&#34;,
    &#34;name_long_singular&#34;: &#34;kilobyte&#34;,
    &#34;name_long_plural&#34;: &#34;kilobytes&#34;
  },
  &#34;1048576&#34;: {
    &#34;name_short_singular&#34;: &#34;MB&#34;,
    &#34;name_short_plural&#34;: &#34;MB&#34;,
    &#34;name_long_singular&#34;: &#34;megabyte&#34;,
    &#34;name_long_plural&#34;: &#34;megabytes&#34;
  }
}</code></li>
    </ul>
</li><li><strong>Type:</strong> Map <span title="Maps hold a set of keys associated with values.">💡</span> of Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span> &rarr; Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> Integer (64-bit, signed) <span title="Integers hold whole numbers.">💡</span></li>
</ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;Unit&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Unit</li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details></details></li>
</ul>
