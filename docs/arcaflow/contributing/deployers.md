# Arcaflow Deployers Development Guide

The Arcaflow Engine relies on deployers to execute containers. Deployers provide a binary-safe transparent tunnel of communication between a plugin and the engine. (Typically, this will be done via standard input/output, but other deployers are possible.)

The Engine and the plugin communicate via the [Arcaflow Transport Protocol](plugin-protocol.md) over this tunnel, but the deployer is unaware of the method of this communication.

Deployers are written in Go and must implement the [deployer interface](https://github.com/arcalot/arcaflow-engine-deployer). Deployers are not dynamically pluggable, they must also be added to the [engine code](https://github.com/arcalot/arcaflow-engine) to be usable.