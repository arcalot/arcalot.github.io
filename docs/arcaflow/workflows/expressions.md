# Arcaflow expressions


Arcaflow expressions were inspired by JSONPath, but have diverged from the syntax. You can use expressions in a workflow YAML like this:

```yaml
some_value: !expr $.your.expresion.here
```

This page explains the language elements of expressions.

!!! warning
    Expressions in workflow definitions **must** be prefixed with `!expr`, otherwise their literal value will be taken as a string.

## Literals

Literals are a very important part of the language. It's required to access any value that's known.

### string

string literals start and end with a matched pair of either single quotes `'` or double quotes `"`, and have zero or more characters between the quotes.

Strings may have escaped values. The most important ones are for backslashes (`\\` for `\`), or for new lines `\n`.

For example, to have this in a string:
> test
> test2/\

You would need the expression `"test\ntest2/\\"`

### integer

Intergers are non-decimal numbers. They may not start with `0`, unless the value is `0`. For example, `001` is not a valid integer literal.

integer expressions may be made negative with a `-` before the number, as mentioned in the unary numbers section.

### float

float literals are floating point double precision decimal numbers.

Supported formats include:
- number characters followed by a period followed by more number characters `1.1` (the typical format)
- number characters followed by a period `1.`
- base-10 exponential scientific notation formats like `5.0e5` and `5.0E-5` for large numbers

float expressions may be made negative with a `-` before the number, as mentioned in the unary numbers section.

### boolean

boolean literals have two valid values:
- `true`
- `false`

No other values are valid booleans. They are case sensitive.

## Root reference

The `$` character always references the root of the data structure. Let's take this data structure:

```yaml
foo:
  bar: Hello world!
```

You can reference the text like this:

```
$.foo.bar
```

## Dot notation

The dot notation allows you to dive into an object.

For example, if you have an object on the root data structure named "a" with the field "b" in it, you can access it with:

```
$.a.b
```

## Bracket accessor

The bracket accessor is used for acessing values whose specifics are not known until runtime. This includes maps or lists.


#### List access
For list access, you specify the index of the value you want to access. If you have a list named `foo` with one value, `"Hello world!"`, as shown:

```yaml
foo:
  - Hello world!
```

You can access the first value with the expression:
```JavaScript
$.foo[0]
```

#### Map access

Maps, also known as dictionaries in some languages, are key-value pair data structures.

For map access in a bracket accessor expression, instead of an integer index, the value in the brackets must match the type of the map's keys.

Here is an example of a map with key type string, and value type integer, inside the main data structure in a field called foo:

```yml
foo:
  a: 1
  b: 2
```

The value at the key `"b"` can be accessed with the expression:
```JavaScript
$.foo["b"]
```

## Functions

A simpler alternative to steps for built-in helper operations.

There are currently no built-in functions. Functions are being added later.

The format for a function is the function's identifying name, followed by `(`, followed by 0 or more comma separated expressions, followed by `)`.

Example:
```JavaScript
thisIsAFunction("this is a string literal for the first parameter", $.a.b)
```

## Binary Operations

Binary Operations have an expression to the left and right, with an operator in between.
The order of operations determines which operators run first. See [Order of Operations](#order-of-operations)

| Operator| Description        |
| --------|--------------------|
| `+`     | [Addition/Concatenation](#additionconcatenation) |
| `-`     | [Subtraction](#subtraction) |
| `*`     | [Multiplication](#multiplication)|
| `/`     | [Division](#division)|
| `%`     | [Modulus](#modulus)|
| `^`     | [Exponentiation](#exponentiation)|
| `==`    | [Equals](#equals)|
| `!=`    | [Not Equals](#not-equals)|
| `>`     | [Greater Than](#greater-than)|
| `<`     | [Less Than](#less-than)|
| `>=`    | [Greater Than or Equal To](#greater-than-or-equal-to)|
| `<=`    | [Less Than or Equal To](#less-than-or-equal-to)|
| `&&`    | [Logical And](#logical-and)|
| `\|\|`  | [Logical Or](#logical-or)|


### Addition/Concatenation

This operator has different behavior depending on the type.

##### String Concatenation

When the `+` operator is used with two strings, it concatenates them together.
For example, the expression `"a" + "b"` would output the string `"ab"`.

##### Mathematical Addition

When the `+` operator is used with a numerical input, it adds them together.
For example, the expression `2 + 2` would output the integer `4`.

### Subtraction

When the `-` operator is used with a numerical input, it subtracts them. The operator requires numerical input.

For example, the expression `6 - 4` would output the integer `2`.
The expression `$.a + $.b` would evaluate the values of `a` and `b` within the root, and add them together.

### Multiplication

When the `*` operator is used with a numerical input, it multiplies them. The operator requires numerical input.

For example, the expression `3 * 3` would output the integer `9`.

### Division

When the `/` operator is used with a numerical input, it divides them. The operator requires numerical input.

For example, the expression `3 / 3` would output the integer `1`.

### Modulus

When the `%` operator is used with a numerical input, it outputs the remainder of the division of the operands. The operator requires numerical input.

For example, the expression `2 % 3` would output the integer `2`.

### Exponentiation

When the `^` operator is used with numerical input, it outputs the result of the left side raised to the power of the right side.

The mathematical expression 2<sup>3</sup> is represented in the expression language as `2^3`, which would output the integer `8`.

### Equals

The `==` equality operator checks for equality between the left and right type. It returns true when the left and right match.
The operator currently supports the types `integer`, `float`, `string`, and `boolean`. If another type is required, please create an issue with the expected behavior of the operator with the needed type.

For example, `2 == 2` results in `true`, and `"a" == "b"` results in `false`.

### Not Equals

The `!=` operator is the inverse of the [==](#equals ) operator. It returns true when the values do not match.
The operator currently supports the types `integer`, `float`, `string`, and `boolean`. If another type is required, please create an issue with the expected behavior of the operator with the needed type.

For example, `2 != 2` results in `false`, and `"a" != "b"` results in `true`.

### Greater Than

The `>` inequality operator outputs `true` if the left side is greater than the right side, and `false` otherwise. The operator requires numerical or string input.

For example, the expression `3 > 3` would output the boolean `false`, and `4 > 3` would output `true`.

### Less Than

The `<` inequality operator outputs `true` if the left side is less than the right side, and `false` otherwise. The operator requires numerical or string input.

For example, the expression `3 < 3` would output the boolean `false`, and `1 < 2` would output `true`.

### Greater Than or Equal To

The `>=` inequality operator outputs `true` if the left side is greater than or equal to the right side, and `false` otherwise. The operator requires numerical or string input.

For example, the expression `3 >= 3` would output the boolean `true`, `3 >= 4` would output `false`, and `4 >= 3` would output `true`.

### Less Than or Equal To

The `<=` inequality operator outputs `true` if the left side is less than or equal to the right side, and `false` otherwise. The operator requires numerical or string input.

For example, the expression `3 <= 3` would output the boolean `true`, `3 <= 4` would output `true`, and `4 <= 3` would output `false`.

### Logical AND

The `&&` operator returns `true` if both the left and right sides are `true`, and `false` otherwise. This operator requires boolean input.
Note: There is no short-circuiting as it's currently implemented. Both the left and right are evaluated before the comparison takes place.

All cases:
| Left    | Right   | `&&`    |
| ------- | ------- | ------- |
| `true`  | `true`  | `true`  |
| `true`  | `false` | `false` |
| `false` | `true`  | `false` |
| `false` | `false` | `false` |

### Logical OR

The `&&` operator returns `true` if either or both of the left and right sides are `true`, and `false` otherwise. It is a non-exclusive or operator. This operator requires boolean input.
Note: There is no short-circuiting as it's currently implemented. Both the left and right are evaluated before the comparison takes place.

All cases:
| Left    | Right   | `\|\|`  |
| ------- | ------- | ------- |
| `true`  | `true`  | `true`  |
| `true`  | `false` | `true`  |
| `false` | `true`  | `true`  |
| `false` | `false` | `false` |

## Unary Operations

These are operations that have one operator before the expressions.

| Operator | Description        |
| ---------|--------------------|
| -        | [Negation](#Negation)           |
| !        | [Logical complement](#logical-complement) |

### Negation

The negation operator negates the value from the input expression.
The required format is a dash `-` before the expression.

If the input is not numeric, there will be a type error.

Examples with integer literals: `-5`, `- 5`
Example with a float literal: `-50.0`
Example with a reference: `-$.foo`

### Logical complement

The logical complement unary operator logically inverts the boolean input.
The required format is an exclamation point `!` before the expression.

If the input expression is not boolean, there will be a type error.

Example with a boolean literal: `!true`
Example with a reference: `!$.foo`

## Parentheses

Parentheses are used to force precedence in the expression. They do not do anything implicitly (for example, there is no implied multiplication)

For example, the expression `5 + 5 * 5` evaluates the `5 * 5` before the `+`, resulting in `5 + 25`, and finally `30`.
If you want the 5 + 5 to be run first, you must use parentheses. That gives you the expression `(5 + 5) * 5`, resulting in `10 * 5`, and finally `50`

## Order of Operations

The order of operations is designed to match most programming languages, and the rules of math.

Order (highest to lowest):
 - [`- ` negation](#negation)
 - [`()` parentheses](#parentheses)
 - [`^ ` exponent](#exponentiation)
 - [`* ` multiplication](#multiplication) and [division `/`](#division)
 - [`+ ` addition/concatenation](#additionconcatenation) and [subtraction `-`](#subtraction)
 - binary equality and inequality (all equal)
   - [`==` equals](#equals)
   - [`!=` not equals](#not-equals)
   - [`> ` greater than](#greater-than)
   - [`< ` less than](#less-than)
   - [`>=` greater than or equal to](#greater-than-or-equal-to)
   - [`<=` less than or equal to](#less-than-or-equal-to)
 - [`! ` logical complement](#logical-complement)
 - [`&&` logical AND](#logical-and)
 - [`||` logical OR](#logical-or)
 - [literals](#literals), [identifiers](#root-reference), [dot notation](#dot-notation), and [bracket access](#bracket-accessor)

## Other information

More information on the expression language is available in the [development guide](/arcaflow/contributing/expressions).

## Examples

### Referencing inputs

Pass a workflow input directly to a plugin input

```yaml title="workflow.yaml"
input:
  root: RootObject
  objects:
    RootObject:
      id: RootObject
      properties:
        name:
          type:
            type_id: string

steps:
  step_a:
    plugin: quay.io/some/container/image
    input:
      some:
        key: !expr $.input.name
```

### Passing between steps

Pass output from one plugin to the input of another plugin

```yaml title="workflow.yaml"
steps:
  step_a:
    plugin: quay.io/some/container/image
    input: {}

  step_b:
    plugin: quay.io/some/container/image
    input:
      some:
        key: !expr $.steps.step_a.outputs.success.some_value
```