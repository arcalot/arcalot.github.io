# Writing your first Go plugin

In order to create a Go plugin, you will need to create a Go module project (`go mod init`) and install the Arcaflow SDK usin `go get go.flow.arcalot.io/pluginsdk`.

Writing a Go plugin consists of the following 4 parts:

1. The input data model
2. The output data model
3. The callable function
4. The calling scaffold

## The input data model

First, we define an input data model. This **must** be a struct.

```go
type Input struct {
    Name string `json:"name"`
}
```

!!! note
    The Arcaflow serialization does not use the built-in Go JSON marshaling, so any additional tags like `omitempty`, or `yaml` tags are ignored.

In addition to the struct above, we must also define a schema for the input data structure:

```go
// We define a separate scope, so we can add subobjects later.
var inputSchema = schema.NewScopeSchema(
    // Struct-mapped object schemas are object definitions that are mapped to a specific struct (Input)
    schema.NewStructMappedObjectSchema[Input](
        // ID for the object:
        "input",
        // Properties of the object:
        map[string]*schema.PropertySchema{
            "name": schema.NewPropertySchema(
                // Type properties:
                schema.NewStringSchema(nil, nil, nil),
                // Display metadata:
                schema.NewDisplayValue(
                    schema.PointerTo("Name"),
                    schema.PointerTo("Name of the person to greet."),
                    nil,
                ),
                // Required:
                true,
                // Required if:
                []string{},
                // Required if not:
                []string{},
                // Conflicts:
                []string{},
                // Default value, JSON encoded:
                nil,
                //Examples:
                nil,
            )
        },
    ),
)
```

## The output data model

The output data model is similar to the input. First, we define our output struct:

```go
type Output struct {
    Message string `json:"message"`
}
```

Then, we have to describe the schema for this output similar to the input:

```go
var outputSchema = schema.NewScopeSchema(
    schema.NewStructMappedObjectSchema[Output](
        "output",
        map[string]*schema.PropertySchema{
            "message": schema.NewPropertySchema(
                schema.NewStringSchema(nil, nil, nil),
                schema.NewDisplayValue(
                    schema.PointerTo("Message"),
                    schema.PointerTo("The resulting message."),
                    nil,
                ),
                true,
                nil,
                nil,
                nil,
                nil,
                nil,
            )
        },
    ),
)
```

## The callable function

Now we can create a callable function. This function will always take one input and produce an output ID (e.g. `"success"`) and an output data structure. This allows you to return one of multiple possible outputs.

```go
func greet(input Input) (string, any) {
    return "success", Output{
        fmt.Sprintf("Hello, %s!", input.Name),        
    }
}
```

Finally, we can incorporate this function into a step schema:

```go
var greetSchema = schema.NewCallableSchema(
    schema.NewCallableStep[Input](
        // ID of the function:
        "greet",
        // Add the input schema:
        inputSchema,
        map[string]*schema.StepOutputSchema{
            // Define possible outputs:
            "success": schema.NewStepOutputSchema(
                // Add the output schema:
                outputSchema,
                schema.NewDisplayValue(
                    schema.PointerTo("Success"),
                    schema.PointerTo("Successfully created message."),
                    nil,
                ),
                false,
            ),
        },
        // Metadata for the function:
        schema.NewDisplayValue(
            schema.PointerTo("Greet"),
            schema.PointerTo("Greets the user."),
            nil,
        ),
        // Reference the function
        greet,
    )
)
```

## The calling scaffold

Finally, we need to create our main function to run the plugin:

```go
package main

import (
    "go.flow.arcalot.io/pluginsdk/plugin"
)

func main() {
	plugin.Run(greetSchema)
}
```

## Running the plugin

Go plugins currently cannot run as CLI tools, so you will have to use this plugin in conjunction with the Arcaflow Engine. However, you can dump the schema by running:

```
go run yourplugin.go --schema
```

## Next steps

Once you are finished with your first plugin, you should read the [section about writing a schema](schema.md).