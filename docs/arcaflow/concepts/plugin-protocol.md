# Plugin protocol specification

!!! warning "Work in Progress"
    This document is work in progress and may change until the final release!

Arcaflow runs plugins locally in a container using Docker or Podman, or remotely in Kubernetes. Each plugin must be
containerized and communicates with the engine over standard input/output. This document outlines the protocol the
engine and the plugins use to communicate.

!!! hint
    You do not need this page if you only intend to implement a plugin with the SDK!

## Execution model

A single plugin execution is intended to run a single task and not more. This simplifies the code since there is no need
to try and clean up after each task. Each plugin is executed in a container and must communicate with the engine over
standard input/output. Furthermore, the plugin must add a handler for `SIGTERM` and properly clean up if there are
services running in the background.

Each plugin is executed at the start of the workflow, or workflow block, and is terminated only at the end of the
current workflow or workflow block. The plugin can safely rely on being able to start a service in the background and
then keeping it running until the SIGTERM comes to shut down the container.

However, the plugin must, under no circumstances, start doing work until the engine sends the command to do so. This
includes starting any services inside the container or outside. This restriction is necessary to be able to launch the
plugin with minimal resource consumption locally on the engine host to fetch the schema.

The plugin execution is divided into three major steps.

1. When the plugin is started, it must output the current plugin protocol version and its schema to the standard output.
The engine will read this output from the container logs.
2. When it is time to start the work, the engine will send the desired step ID with its input parameters over the
standard input. The plugin acknowledges this and starts to work. When the work is complete, the plugin must
automatically output the results to the standard output.
3. When a shutdown is desired, the engine will send a `SIGTERM` to the plugin. The plugin has up to 30 seconds to shut
down. The SIGTERM may come at any time, even while the work is still running, and the plugin must appropriately shut
down. If the work is not complete, the plugin may attempt to output an error output data to the standard out, but
must not do so. If the plugin fails to stop by itself within 30 seconds, the plugin container is forcefully stopped.

## Protocol

As a data transport protocol, we
use [CBOR messages](https://cbor.io/) [RFC 8949](https://www.rfc-editor.org/rfc/rfc8949.html) back to back due to their
self-delimiting nature. This section provides the entire protocol as [JSON schema](https://json-schema.org/) below.

## Step 0: The "start output" message

Because Kubernetes has no clean way of capturing an output right at the start, the initial step of the plugin execution involves the engine sending an empty CBOR message (`None` or `Nil`) to the plugin. This indicates, that the plugin may start its output now.

## Step 1: Hello message

The "Hello" message is a way for the plugin to introduce itself and present its steps and schema. Transcribed to JSON, a
message of this kind would look as follows:

```json
{
  "version": 1,
  "steps": {
    "step-id-1": {
      "name": "Step 1",
      "description": "This is the first step",
      "input": {
        "schema": {
          // Input schema
        }
      },
      "outputs": {
        "output-id-1": {
          "name": "Name for this output kind",
          "description": "Description for this output",
          "schema": {
            // Output schema
          }
        }
      }
    }
  }
}
```

The schemas must describe the data structure the plugin expects. For a simple hello world input would look as follows:

```json
{
  "type": "object",
  "properties": {
    "name": {
      "type": "string"
    }
  }
}
```

The full schema is described below in the [Schema](#schema) section.

## Step 2: Start work message

The "start work" message has the following parameters in CBOR:

```json
{
  "id": "id-of-the-step-to-execute",
  "config": {
    // Input parameters according to schema here
  }
}
```

The plugin must respond with a CBOR message of the following format:

```json
{
  "status": "started"
}
```

## Step 3/a: Crash

If the plugin execution ended unexpectedly, the plugin should crash and output a reasonable error message to the standard error. The plugin must exit with a non-zero exit status to notify the engine that the execution failed.

## Step 3/b: Output

When the plugin has executed successfully, it must emit a CBOR message to the standard output:

```json
{
  "output_id": "id-of-the-declared-output",
  "output_data": {
    // Result data of the plugin
  },
  "debug_logs": "Unstructured logs here for debugging as a string."
}
```

## Schema

This section contains the exact schema that the plugin sends to the engine.

<ul><li><strong>Type:</strong> Scope <span title="Scopes hold one or more objects that can be referenced inside the properties of those objects by ref types. Ref types always reference the closest scope.">💡</span></li><li><strong>Root object:</strong> Schema</li>
<li><strong>Properties</strong><ul><li><details><summary>steps (Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
                <ul><li><strong>Name: </strong> Steps</li><li><strong>Description: </strong> Steps this schema supports.</li><li><strong>Required</strong></li><li><strong>Type:</strong> Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[$@a-zA-Z0-9-_]&#43;$</code></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;Step&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Step</li></ul>
    </details>
</li>
</ul>
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
        </details><details><summary>Schema (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>steps (Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Steps</li><li><strong>Description: </strong> Steps this schema supports.</li><li><strong>Required</strong></li><li><strong>Type:</strong> Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[$@a-zA-Z0-9-_]&#43;$</code></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;Step&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Step</li></ul>
    </details>
</li>
</ul>
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
        </details><details><summary>Step (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>display (Object reference to &ldquo;Display&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Display</li><li><strong>Description: </strong> Name, description and icon.</li><li><strong>Type:</strong> Object reference to &ldquo;Display&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Display</li></ul>
            </details></li><li><details><summary>id (String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> ID</li><li><strong>Description: </strong> Machine identifier for this step.</li><li><strong>Required</strong></li><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[$@a-zA-Z0-9-_]&#43;$</code></li></ul>
            </details></li><li><details><summary>input (Object reference to &ldquo;Scope&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Input</li><li><strong>Description: </strong> Input data schema.</li><li><strong>Required</strong></li><li><strong>Type:</strong> Object reference to &ldquo;Scope&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Scope</li></ul>
            </details></li><li><details><summary>outputs (Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Input</li><li><strong>Description: </strong> Input data schema.</li><li><strong>Required</strong></li><li><strong>Type:</strong> Map <span title="Maps hold a set of keys associated with values.">💡</span> of String <span title="Strings hold a list of printable characters.">💡</span> &rarr; String <span title="Strings hold a list of printable characters.">💡</span></li><li>
    <details>
        <summary>Key type</summary>
        <ul><li><strong>Type:</strong> String <span title="Strings hold a list of printable characters.">💡</span></li><li><strong>Minimum length:</strong> 1</li><li><strong>Maximum length:</strong> 255</li><li><strong>Must match pattern:</strong> <code>^[$@a-zA-Z0-9-_]&#43;$</code></li></ul>
    </details>
</li>
<li>
    <details>
        <summary>Value type</summary>
        <ul><li><strong>Type:</strong> Object reference to &ldquo;StepOutput&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> StepOutput</li></ul>
    </details>
</li>
</ul>
            </details></li></ul>
</li>
</ul>
        </details><details><summary>StepOutput (Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span>)</summary>
            <ul><li><strong>Type:</strong> Object <span title="Objects have a fixed set of fields. Each field has a specified type and can have extra validation applied to them, e.g. making the field required or conflicting another field.">💡</span></li><li>
    <strong>Properties</strong>
    <ul><li><details><summary>display (Object reference to &ldquo;Display&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Display</li><li><strong>Description: </strong> Name, description and icon.</li><li><strong>Type:</strong> Object reference to &ldquo;Display&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Display</li></ul>
            </details></li><li><details><summary>error (Boolean <span title="Booleans hold true or false values.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Error</li><li><strong>Description: </strong> If set to true, this output will be treated as an error output.</li><li><strong>Default (JSON encoded)</strong>: false</li><li><strong>Type:</strong> Boolean <span title="Booleans hold true or false values.">💡</span></li></ul>
            </details></li><li><details><summary>schema (Object reference to &ldquo;Scope&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span>)</summary>
            <ul><li><strong>Name: </strong> Schema</li><li><strong>Description: </strong> Data schema for this particular output.</li><li><strong>Required</strong></li><li><strong>Type:</strong> Object reference to &ldquo;Scope&rdquo; <span title="Object references (refs) reference an object in their closest scope up the typing tree.">💡</span></li><li><strong>Referenced object:</strong> Scope</li></ul>
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
