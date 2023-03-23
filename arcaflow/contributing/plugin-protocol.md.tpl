# Arcaflow Plugin protocol specification (ATP)

Arcaflow runs plugins locally in a container using Docker or Podman, or remotely in Kubernetes. Each plugin must be containerized and communicates with the engine over standard input/output. This document outlines the protocol the engine and the plugins use to communicate.

!!! hint
    You do not need this page if you only intend to implement a plugin with the SDK!

## Execution model

A single plugin execution is intended to run a single task and not more. This simplifies the code since there is no need to try and clean up after each task. Each plugin is executed in a container and must communicate with the engine over standard input/output. Furthermore, the plugin must add a handler for `SIGTERM` and properly clean up if there are services running in the background.

Each plugin is executed at the start of the workflow, or workflow block, and is terminated only at the end of the current workflow or workflow block. The plugin can safely rely on being able to start a service in the background and then keeping it running until the SIGTERM comes to shut down the container.

However, the plugin must, under no circumstances, start doing work until the engine sends the command to do so. This includes starting any services inside the container or outside. This restriction is necessary to be able to launch the plugin with minimal resource consumption locally on the engine host to fetch the schema.

The plugin execution is divided into three major steps.

1. When the plugin is started, it must output the current plugin protocol version and its schema to the standard output. The engine will read this output from the container logs.
2. When it is time to start the work, the engine will send the desired step ID with its input parameters over the standard input. The plugin acknowledges this and starts to work. When the work is complete, the plugin must automatically output the results to the standard output.
3. When a shutdown is desired, the engine will send a `SIGTERM` to the plugin. The plugin has up to 30 seconds to shut down. The SIGTERM may come at any time, even while the work is still running, and the plugin must appropriately shut down. If the work is not complete, the plugin may attempt to output an error output data to the standard out, but must not do so. If the plugin fails to stop by itself within 30 seconds, the plugin container is forcefully stopped.

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

{{ partial "type_with_header" .Schema }}
