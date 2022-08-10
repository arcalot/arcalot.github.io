# Plugin protocol specification

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

The entire "hello" message can be described by the following JSON schema:

```json
{
  "$id": "arcaflow-plugin-v1-hello-message",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Hello message",
  "description": "Initial 'Hello' message from plugin, describing the protocol version and schema of the plugin.",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "version": {
      "description": "Arcaflow plugin protocol version",
      "type": "integer",
      "minimum": 1
    },
    "steps": {
      "title": "Steps",
      "description": "Steps offered by the plugin",
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "name": {
            "title": "Name",
            "description": "Name of the step",
            "type": "string"
          },
          "description": {
            "title": "Description",
            "description": "Detailed description of this step.",
            "type": "string"
          },
          "input": {
            "$ref": "#/$defs/object"
          }
        },
        "required": [
          "input",
          "outputs"
        ],
        "additionalProperties": false
      }
    }
  },
  "required": [
    "version",
    "steps"
  ],
  "$defs": {
    "type": {
      "oneOf": [
        {
          "ref": "#/$defs/enum"
        },
        {
          "ref": "#/$defs/object"
        },
        {
          "ref": "#/$defs/string"
        },
        {
          "ref": "#/$defs/pattern"
        },
        {
          "ref": "#/$defs/boolean"
        },
        {
          "ref": "#/$defs/float"
        },
        {
          "ref": "#/$defs/integer"
        },
        {
          "ref": "#/$defs/list"
        },
        {
          "ref": "#/$defs/map"
        },
        {
          "ref": "#/$defs/oneof"
        }
      ]
    },
    "mapKeys": {
      "type": {
        "oneOf": [
          {
            "ref": "#/$defs/enum"
          },
          {
            "ref": "#/$defs/string"
          },
          {
            "ref": "#/$defs/integer"
          }
        ]
      }
    },
    "enum": {
      "title": "Enum",
      "description": "Enumeration of items",
      "additionalProperties": false,
      "required": [
        "type",
        "values"
      ],
      "properties": {
        "type": {
          "type": "string",
          "const": "enum"
        },
        "values": {
          "type": "array",
          "items": {
            "oneOf": [
              {
                "ref": "#/$defs/string"
              },
              {
                "ref": "#/$defs/integer"
              }
            ]
          }
        }
      }
    },
    "boolean": {
      "title": "Boolean",
      "description": "True or false.",
      "type": "object",
      "required": [
        "type"
      ],
      "properties": {
        "type": {
          "type": "string",
          "const": "boolean"
        }
      },
      "additionalProperties": false
    },
    "string": {
      "title": "String",
      "description": "A string of characters.",
      "type": "object",
      "required": [
        "type"
      ],
      "properties": {
        "type": {
          "type": "string",
          "const": "string"
        },
        "min_length": {
          "type": "integer",
          "minimum": 0
        },
        "max_length": {
          "type": "integer",
          "minimum": 0
        },
        "pattern": {
          "type": "string",
          "format": "regex"
        }
      },
      "additionalProperties": false
    },
    "pattern": {
      "title": "Pattern",
      "description": "A regular expression.",
      "type": "object",
      "required": [
        "type"
      ],
      "properties": {
        "type": {
          "type": "string",
          "const": "pattern"
        }
      },
      "additionalProperties": false
    },
    "integer": {
      "title": "Integer",
      "description": "64-bit integers",
      "type": "object",
      "required": [
        "type"
      ],
      "properties": {
        "type": {
          "type": "string",
          "const": "integer"
        },
        "min": {
          "type": "integer",
          "minimum": 0
        },
        "max": {
          "type": "integer",
          "minimum": 0
        }
      },
      "additionalProperties": false
    },
    "float": {
      "title": "Float",
      "description": "64-bit floating point numbers.",
      "type": "object",
      "required": {
        "type"
      },
      "properties": {
        "type": {
          "type": "string",
          "const": "float"
        },
        "min": {
          "type": "number",
          "minimum": 0
        },
        "max": {
          "type": "number",
          "minimum": 0
        }
      },
      "additionalProperties": false
    },
    "list": {
      "title": "List",
      "description": "A list of predefined types.",
      "type": "object",
      "required": [
        "items",
        "type"
      ],
      "properties": {
        "type": {
          "type": "string",
          "const": "list"
        },
        "min": {
          "title": "Minimum items",
          "description": "The minimum number of items.",
          "type": "number",
          "minimum": 0
        },
        "max": {
          "title": "Maximum items",
          "description": "The maximum number of items.",
          "type": "number",
          "minimum": 0
        },
        "items": {
          "title": "Items",
          "description": "Type definition for items in the list.",
          "$ref": "#/$defs/type"
        }
      },
      "additionalProperties": false
    },
    "map": {
      "title": "Map",
      "description": "A key-value map with defined types.",
      "type": "object",
      "required": [
        "keys",
        "values",
        "type"
      ],
      "properties": {
        "type": {
          "type": "string",
          "const": "map"
        },
        "min": {
          "title": "Minimum items",
          "description": "The minimum number of items.",
          "type": "number",
          "minimum": 0
        },
        "max": {
          "title": "Maximum items",
          "description": "The maximum number of items.",
          "type": "number",
          "minimum": 0
        },
        "keys": {
          "title": "Keys",
          "description": "Type definition for keys in the map.",
          "$ref": "#/$defs/mapKeys"
        },
        "values": {
          "title": "Values",
          "description": "Type definition for values in the map.",
          "$ref": "#/$defs/type"
        }
      },
      "additionalProperties": false
    },
    "oneof": {
      "oneOf": [
        {
          "title": "One Of",
          "description": "Multiple possible types. The discriminator field is used to determine what type is found.",
          "type": "object",
          "required": [
            "discriminator_field_name",
            "discriminator_field_schema",
            "one_of",
            "type"
          ],
          "properties": {
            "type": {
              "type": "string",
              "const": "oneof"
            },
            "discriminator_field_name": {
              "title": "Discriminator field name",
              "description": "Name for the field that distinguishes between the possible types.",
              "type": "string",
              "minimum_length": 1
            },
            "discriminator_field_schema": {
              "title": "Discriminator field schema",
              "description": "Schema for the field that distinguishes between the possible types.",
              "$ref": "#/$defs/integer"
            },
            "one_of": {
              "title": "One of",
              "description": "Possible variations.",
              "type": "object",
              "propertyNames": {
                "pattern": "^[0-9]+$"
              },
              "additionalProperties": {
                "$ref": "#/$defs/object"
              }
            }
          },
          "additionalProperties": false
        },
        {
          "title": "One Of",
          "description": "Multiple possible types. The discriminator field is used to determine what type is found.",
          "type": "object",
          "required": [
            "discriminator_field_name",
            "discriminator_field_schema",
            "one_of",
            "type"
          ],
          "properties": {
            "type": {
              "type": "string",
              "const": "oneof"
            },
            "discriminator_field_name": {
              "title": "Discriminator field name",
              "description": "Name for the field that distinguishes between the possible types.",
              "type": "string",
              "minimum_length": 1
            },
            "discriminator_field_schema": {
              "title": "Discriminator field schema",
              "description": "Schema for the field that distinguishes between the possible types.",
              "$ref": "#/$defs/string"
            },
            "one_of": {
              "title": "One of",
              "description": "Possible variations.",
              "type": "object",
              "additionalProperties": {
                "$ref": "#/$defs/object"
              }
            }
          },
          "additionalProperties": false
        }
      ]
    },
    "object": {
      "title": "Object",
      "description": "Object type consisting of predefined fields.",
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "type": {
          "type": "string",
          "const": "object"
        },
        "properties": {
          "title": "Properties",
          "description": "Properties of this object.",
          "type": "object",
          "additionalProperties": {
            "title": "Field",
            "description": "A property definition in the object.",
            "type": "object",
            "properties": {
              "name": {
                "title": "Name",
                "description": "Human-readable name of the property.",
                "type": "string"
              },
              "description": {
                "title": "Description",
                "description": "Human-readable description of the property.",
                "type": "string"
              },
              "required": {
                "title": "Required",
                "description": "Set this field to required.",
                "type": "boolean",
                "default": false
              },
              "required_if": {
                "title": "Required if",
                "description": "This property is required if any of the listed properties in this field are set.",
                "type": "array",
                "items": {
                  "type": "string"
                }
              },
              "required_if_not": {
                "title": "Required if not",
                "description": "This property is not required if any of the listed properties in this field are set.",
                "type": "array",
                "items": {
                  "type": "string"
                }
              },
              "conflicts": {
                "title": "Conflicts",
                "description": "This property must not be set if any of the listed properties in this field are set.",
                "type": "array",
                "items": {
                  "type": "string"
                }
              },
              "type": {
                "$ref": "#/$defs/type"
              }
            },
            "required": [
              "type"
            ],
            "additionalProperties": false
          }
        }
      },
      "required": [
        "type",
        "properties"
      ]
    }
  }
}
```

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
