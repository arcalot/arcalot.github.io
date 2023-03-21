# Arcaflow Expressions Development Guide

The [expressions library](https://github.com/arcalot/arcaflow-expressions/) provides the engine and other potential users with a simple way to compile expressions and provide typing information about an expression result.

The library consists of two parts: the internal [parser/AST](https://github.com/arcalot/arcaflow-expressions/tree/main/internal/ast) and the [API layer](https://github.com/arcalot/arcaflow-expressions).

## The parser / AST

The expressions parser constructs an [Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) from the expression which can then be walked by the API layer. The AST consists of the following node types:

### Dot notation

Let's say you have an expression `foo.bar`. The dot notation node is the dot in the middle. The left subtree of the dot will be the entire expression left of the dot, while the right subtree will be everything to the right.

### Map accessor

Map accessors are expressions in the form of `foo[bar]`. The left subtree will be the expression to the left, while the right subtree will be everything within the brackets.

### Key

Keys can have two kinds:

1. They can be literals, such as `foo` in the expression `foo.bar`,
2. or they can be subexpressions, which need to be evaluated as a full expression.

### Identifiers

Identifiers come in two forms:

1. `$` references the root of the data structure.
2. Any other value behaves like a key in a map accessor.

## The API layer

The API layer provides three functions:

1. Evaluate an expression against a data structure without type checking
2. Provide dependency information of an expression
3. Return the resulting type info of an expression when given a schema

All three functions walk the AST above and construct the required data.