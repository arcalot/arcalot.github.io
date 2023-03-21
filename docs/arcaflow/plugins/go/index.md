# Creating plugins in Go

In contrast to Python, Go doesn't contain enough language elements to infer the types and validation from Go types. Therefore, in order to use Go you both need to create the data structures (e.g. `struct`) and write the schema by hand. Therefore, we **recommend Python for writing plugins**.

For writing Go plugins, you will need:

1. Go version 1.18 or higher.
2. The [Go SDK for Arcaflow plugins](https://github.com/arcalot/arcaflow-plugin-sdk-go) installed (preferably via go mod).
3. A container engine that can build images for [packaging](../packaging.md).

If you have these three, you can [get started with your first plugin](first.md).