# Arcaflow Expressions Development Guide

The [expressions library](https://github.com/arcalot/arcaflow-expressions/) provides the engine and other potential users with a simple way to compile expressions and provide typing information about an expression result.

The library consists of two parts: the internal [parser/AST](https://github.com/arcalot/arcaflow-expressions/tree/main/internal/ast) and the [API layer](https://github.com/arcalot/arcaflow-expressions).

## The parser / AST

The expressions parser constructs an [Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) from the expression which can then be walked by the API layer. The AST consists of the following node types:

### Dot notation

Let's say you have an expression `foo.bar`. The dot notation node is the dot in the middle. The left subtree of the dot will be the entire expression left of the dot, while the right subtree will be everything to the right.

### Map accessor

Map accessors are expressions in the form of `foo[bar]`. The left subtree will be the expression to the left, while the right subtree will be the tree representing subexpression within the brackets.

### Binary Operations

Binary operations include all of the operations that have a left and right component.
They are represented as a node that has a left and right subtree, and an operator that describes which binary operation type is being applied.


### Unary Operations

Unary operations include logical complement `!` and negation `-`.
They are represented as a node that has one child (the tree it's applied to), and the operator being applied to the child node.


### Identifiers

Identifiers come in two forms:

1. `$` references the root of the data structure.
2. Any other value accesses object fields.

## The API layer

The API layer provides three functions:

1. Evaluate an expression against a data structure without type checking
2. Provide dependency information of an expression
3. Return the resulting type info of an expression when given a schema

All three functions walk the AST above and construct the required data.