# Arcaflow Expressions Development Guide

The [expressions library](https://github.com/arcalot/arcaflow-expressions/) provides the engine and other potential users with a simple way to compile expressions and provide typing information about an expression result.

The library consists of two parts: the internal [parser/AST](https://github.com/arcalot/arcaflow-expressions/tree/main/internal/ast) and the [API layer](https://github.com/arcalot/arcaflow-expressions).

## The parser / AST

The expressions parser constructs an [Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) from the expression which can then be walked by the API layer. The AST consists of the following node types:

### Dot notation

Let's say you have an expression `foo.bar`. The dot notation node is the dot in the middle. The left subtree of the dot will be the entire expression left of the dot, while the right subtree will be everything to the right.

### Map accessor

Map accessors are expressions in the form of `foo[bar]`. The left subtree will represent the expression to the left of the brackets (`foo` in the example), while the right subtree will represent the subexpression within the brackets (`bar` in the example).

### Binary Operations

Binary operations include all of the operations that have a left and right sub-tree that do not have a special node representing them (dot notation is an example of a special case).
They are represented as a node that has a left and right subtree, and an operator that describes which binary operation type is being applied.

### Unary Operations

Unary operations include boolean complement `!` and numeric negation `-`.
Unary operations are represented as a node that has one child node (the tree it's applied to) and one operator that describes the operation being applied to the child node.


### Identifiers

Identifiers come in two forms:

1. `$` references the root of the data structure.
2. A plain string identifier from a token matching the regular expression `^\w+$`.
  a. This may be used for accessing object fields or as function identifiers.

## The API layer

The API layer provides three functions:

1. Evaluate an expression against a data structure without type checking
2. Provide dependency information of an expression
3. Return the resulting type info of an expression when given a schema

All three functions walk the AST above and construct the required data.