# Arcaflow Engine Development Guide

!!! warning
    The engine is currently undergoing a [major refactor](https://github.com/arcalot/arcaflow-engine/pull/32). This page describes the engine post-refactor.

The Arcaflow engine is responsible for parsing a YAML workflow and executing it. It goes through several phases during execution.

## YAML loading phase

During the YAML loading phase, the engine loads the workflow YAML as raw data containing YAML nodes. We need the raw YAML nodes to access the YAML tags, which we use to turn the structure into expressions. The resulting data structure of this phase is a structure consisting of maps, lists, strings, and expression objects.

!!! info "YAML"
    YAML, at its core, only knows three data types: maps, lists, and strings. Additionally, each entry can have a tag in the form of `!foo` or `!!foo`.

## Basic workflow parsing

Once the YAML is loaded, we can take the data created and parse the workflow. This will validate the input definition and the basic step definitions and provide a more structured data. However, at this point the plugin schemas are not known yet, so any data structure related to steps is accepted as-is. 

## Schema loading

The engine has an API to provide step types. These step types have the ability to provide a lifecycle and load their schema. In case of plugins, this means that the plugin is fired up briefly and its schema is queried. (See [Deployers](deployers.md).)

## DAG construction

Once the schema is loaded, the Directed Acyclic Graph can be constructed from the expressions. Each lifecycle stage input is combed for expressions and a DAG is built.

## Static code analysis (future)

The expression library already has the facilities to inspect types, which will, in the future, provide us the ability to perform a static code analysis on the workflow. This will guarantee users that a workflow can be executed without typing problems.

## Workflow execution

When the DAG is complete and contains no cycles, the workflow execution can proceed. The execution cycle queries lifecycle nodes that have no more inbound dependencies and runs the lifecycle. When a lifecycle stage finishes, the corresponding nodes are removed from the DAG, freeing up other nodes for execution.
