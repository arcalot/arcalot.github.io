# Arcaflow Plugin protocol specification (ATP)

Arcaflow runs plugins locally in a container using Docker or Podman, or remotely in Kubernetes. Each plugin must be containerized and communicates with the engine over standard input/output. This document outlines the protocol the engine and the plugins use to communicate.

!!! hint
    You do not need this page if you only intend to implement a plugin with the SDK!

## Execution model

A single plugin execution is intended to run a single task and not more. This simplifies the code since there is no need to try and clean up after each task. Each plugin is executed in a container and must communicate with the engine over standard input/output. Furthermore, the plugin must add a handler for `SIGTERM` and properly clean up if there are services running in the background.

Each plugin is executed at the start of the workflow, or workflow block, and is terminated only at the end of the current workflow or workflow block. The plugin can safely rely on being able to start a service in the background and then keeping it running until the `SIGTERM` comes to shut down the container.

However, the plugin must, under no circumstances, start doing work until the engine sends the command to do so. This includes starting any services inside the container or outside. This restriction is necessary to be able to launch the plugin with minimal resource consumption locally on the engine host to fetch the schema.

The plugin execution is divided into three major steps.

1. When the plugin is started, it must output the current plugin protocol version and its schema to the standard output. The engine will read this output from the container logs.
2. When it is time to start the work, the engine will send the desired step ID with its input parameters over the standard input. The plugin acknowledges this and starts to work. When the work is complete, the plugin must automatically output the results to the standard output.
3. When a shutdown is desired, the engine will send a `SIGTERM` to the plugin. The plugin has up to 30 seconds to shut down. The `SIGTERM` may come at any time, even while the work is still running, and the plugin must appropriately shut down. If the work is not complete, it is important that the plugin does not send error output to STDOUT. If the plugin fails to stop by itself within 30 seconds, the plugin container is forcefully stopped.

## Protocol

As a data transport protocol, we use [CBOR messages](https://cbor.io/) [RFC 8949](https://www.rfc-editor.org/rfc/rfc8949.html) back to back due to their self-delimiting nature. This section provides the entire protocol as [JSON schema](https://json-schema.org/) below.

## Step 0: The "start output" message

Because Kubernetes has no clean way of capturing an output right at the start, the initial step of the plugin execution involves the engine sending an empty CBOR message (`None` or `Nil`) to the plugin. This indicates, that the plugin may start its output now.

## Step 1: Hello message

The "Hello" message is a way for the plugin to introduce itself and present its steps and schema. Transcribed to JSON, a message of this kind would look as follows:

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

|    |    |
|----|----|
| Type: | `scope` |
| Root object: | Schema |
???+ note "Properties"
    ??? info "steps (`map[string, reference[Step]]`)"
        |    |    |
        |----|----|
        | Name: | Steps |
        | Description: | Steps this schema supports. |
        | Required: | Yes || Type: | `map[string, reference[Step]]` |
        
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
            | Type: | `reference[Step]` |
            | Referenced object: | Step *(see in the Objects section below)* |
            
        
        
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
                
                
    ??? info "**Schema** (`object`)"
        |    |    |
        |----|----|
        | Type: | `object` |
        
        ???+ note "Properties"
            ??? info "steps (`map[string, reference[Step]]`)"
                |    |    |
                |----|----|
                | Name: | Steps |
                | Description: | Steps this schema supports. |
                | Required: | Yes || Type: | `map[string, reference[Step]]` |
                
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
                    | Type: | `reference[Step]` |
                    | Referenced object: | Step *(see in the Objects section below)* |
                    
                
                
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
                
                
    ??? info "**Step** (`object`)"
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
                | Description: | Machine identifier for this step. |
                | Required: | Yes || Type: | `string` |
                | Minimum: | 1 |
                | Maximum: | 255 |
                | Must match pattern: | `^[$@a-zA-Z0-9-_]&#43;$` |
                
                
            ??? info "input (`reference[Scope]`)"
                |    |    |
                |----|----|
                | Name: | Input |
                | Description: | Input data schema. |
                | Required: | Yes || Type: | `reference[Scope]` |
                | Referenced object: | Scope *(see in the Objects section below)* |
                
                
            ??? info "outputs (`map[string, reference[StepOutput]]`)"
                |    |    |
                |----|----|
                | Name: | Input |
                | Description: | Input data schema. |
                | Required: | Yes || Type: | `map[string, reference[StepOutput]]` |
                
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
                    | Type: | `reference[StepOutput]` |
                    | Referenced object: | StepOutput *(see in the Objects section below)* |
                    
                
                
    ??? info "**StepOutput** (`object`)"
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
                
                
            ??? info "error (`bool`)"
                |    |    |
                |----|----|
                | Name: | Error |
                | Description: | If set to true, this output will be treated as an error output. |
                | Required: | No || Type: | `bool` |
                
                 ```json title="Default"
                 false
                 ```
                
                
            ??? info "schema (`reference[Scope]`)"
                |    |    |
                |----|----|
                | Name: | Schema |
                | Description: | Data schema for this particular output. |
                | Required: | Yes || Type: | `reference[Scope]` |
                | Referenced object: | Scope *(see in the Objects section below)* |
                
                
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
                
                
