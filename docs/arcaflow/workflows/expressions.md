# Arcaflow expressions

Arcaflow expressions were inspired by JSONPath but have diverged from the syntax. You can use expressions in a workflow YAML like this:

```yaml
some_value: !expr $.your.expresion.here
```

This page explains the language elements of expressions.

!!! warning
    Expressions in workflow definitions **must** be prefixed with `!expr`, otherwise their literal value will be taken as a string.

## Literals

Literals represent values described in an expression, as opposed to values referenced from other sources.

### String values

Normal string literals start and end with a matched pair of either single quotes `'` or double quotes `"` and have zero or more characters between the quotes.

Strings may have escaped values. The most important ones are for backslashes (`\\` for `\`) or for embedded newlines `\n`.

You do not need to escape double quotes in a single-quote string, or single-quotes in a double quote string. However, 

Here is the list of supported escape characters:
| Escape | Result |
| ------ | ------ |
| `\\` | `\` backslash character |
| `\t` | tab character |
| `\n` | newline character |
| `\r` | carriage return character |
| `\b` | backspace character |
| `\"` | `"` double quote character |
| `\'` | `'` single quote character |
| `\0` | null character |

For example, to have the following text represented in a single string:
> test
> test2/\

You would need the expression `"test\ntest2/\\"`

#### String-expressions in YAML

If an expression has a string literal in it, then you must account for it in the YAML.

For example, to include a double-quoted string in an expression, you must either add single quotes around expression, or use block flow scalars. A single apostrophe within an expression needs to be added twice in a row to count as one while in an inlined string.

Here is an example of the following value represented in a few of the various ways:
> just a string with sub-quotes "hello" and an apostrophe '

Inlined:
```
some_value: !expr '"just a string with sub-quotes \"hello\" and an apostrophe \'' "'
```

With Block Flow Scalar:
```
some_value_1: !expr |-
  'just a string with sub-quotes "hello" and an apostrophe \' '
some_value_2: !expr |-
  "just a string with sub-quotes \"hello\" and an apostrophe ' "
```

See [Raw String](#raw-string) to see how to do this without escaping.

### Raw String values

Raw string literals start and end with back-tick characters "`".

The main point of a raw string is that it does not escape characters. This means that you can put `'` and `"` characters in withine escaping them.

Here is an example of the following value represented using raw strings:
> just a string with sub-quotes "hello" and an apostrophe '

Inlined:
```
some_value: !expr '`just a string with sub-quotes "hello" and an apostrophe \'' `'
```

With Block Flow Scalar:
```
some_value: !expr |-
  `just a string with sub-quotes "hello" and an apostrophe ' `
```

### Integer numbers

Integers are whole non-negative base-10 numbers. They may not start with `0`, unless the value is `0`. For example, `001` is not a valid integer literal.

Examples:
- `0`
- `1`
- `503`

Negative values are constructed by applying the [negation operator `-`](#negation) to a literal numeric value.

### Floating point numbers

Floating point literals are non-negative double-precision floating point numbers.

Supported formats include:
- number characters followed by a period followed by zero or more number characters: `1.1` or `1.`
- base-10 exponential scientific notation formats like `5.0e5` and `5.0E-5`

Negative values are constructed by applying the [negation operator `-`](#negation) to a literal numeric value.

### Boolean values

Boolean literals have two valid values:
- `true`
- `false`

No other values are valid boolean literals. The values are case sensitive.

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

The dot notation allows you to reference fields of an object.

For example, if you have an object on the root data structure named "a" with the field "b" in it, you can access it with:

```
$.a.b
```

## Bracket accessor

The bracket accessor is used for referencing values in maps or lists.


#### List access
For list access, you specify the index of the value you want to access. The index should be an expression yielding a non-negative integer value, where zero corresponds to the first value in the list.

If you have a list named `foo`:

```yaml
foo:
  - Hello world!
```

You can access the first value with the expression:
```JavaScript
$.foo[0]
```

Giving the output `"Hello world!"`

#### Map access

Maps, also known as dictionaries in some languages, are key-value pair data structures.

To use a map in an expression, the expression to the left of the brackets must be a reference to a map. That is then followed by a pair of brackets with a sub-expression between them. That sub-expression must evaluate to a valid key in the map.

Here is an example of a map with string keys and integer values. The map is stored in a field called `foo` in the root-level object:

```yml
foo:
  a: 1
  b: 2
```

Given the map shown above, the following expression would yield a value of `2`:
```JavaScript
$.foo["b"]
```

## Functions

Functions are built-in tasks with pre-defined behavior and a known input and output schema.

Functions are defined by the engine.

Functions:
| function definition          | return type | description                                          |
| ---------------------------- | ----------- | ---------------------------------------------------- |
| `intToFloat(integer)`        | float       | Converts an integer type into a floating point type. |
| `floatToInt(float)`          | integer     | Converts a float type into an integer type by discarding the fraction. In other words, it is rounded to the nearest integer towards zero. <br>Special cases:<br>&nbsp; +Inf outputs the maximum 64-bit integer (9223372036854775807)<br>&nbsp; -Inf and NaN output the minimum 64-bit integer (-9223372036854775808)\n\n"<br><br> For example, `5.5` becomes `5`, and `-1.9` becomes `-1`" |
| `intToString(integer)`       | string      | Converts an integer to a string whose characters represent that integer in base-10. <br> For example, an input of `55` will output `"55"` |
| `floatToString(float)`       | string      | Converts a floating point number to a string whose characters represent that number in base-10 as as simple decimal. <br> For example, an input of `5000.5` will output `"5000.5"` |
| `boolToString(boolean)`      | string      | Returns `"true"` for `true`, and `"false"` for `false`. |
| `stringToInt(string)`        | integer     | Interprets the string as a base-10 integer. Will fail if the input is not a valid integer. |
| `stringToFloat(string)`      | float       | Converts the input string to a 64-bit floating-point number<br><br>Accepts decimal and hexadecimal floating-point numbers as defined by the [Go syntax for floating point literals](https://go.dev/ref/spec#Floating-point_literals).<br> If the input is well-formed and near a valid floating-point number, stringToFloat returns the nearest floating-point number rounded using IEEE754 unbiased rounding. <br> Returns an error when an invalid input is received. |
| `stringToBool(string)`       | boolean      | Interprets the input as a boolean. <br> Case insensitively accepts `"1"`, `"t"`, and `"true"` for `true`.\n <br>Case insensitively accepts `"0"`, '"f"', and '"false"' for `false`.<br>Returns an error for any other input. |
| `ceil(float)`                | float       | Returns the least integer value greater than or equal to the input.<br>For example `ceil(1.5)` outputs `2.0`, and `ceil(-1.5)` outputs `-1.0`<br>Special cases are:<br>&nbsp; ceil(±0) = ±0<br>&nbsp; ceil(±Inf) = ±Inf<br>&nbsp; ceil(NaN) = NaN" |
| `floor(float)`               | float       | Returns the greatest integer value less than or equal to the input.<br>For example `floor(1.5)` outputs `1.0`, and `floor(-1.5)` outputs `-2.0`<br>Special cases are:<br>&nbsp; floor(±0) = ±0<br>&nbsp; floor(±Inf) = ±Inf<br>&nbsp; floor(NaN) = NaN |
| `round(float)`               | float       | Returns the nearest integer to the input, rounding half away from zero.<br>For example `round(1.5)` outputs `2.0`, and `round(-1.5)` outputs `-2.0`<br>Special cases are:<br>&nbsp; round(±0) = ±0<br>&nbsp; round(±Inf) = ±Inf<br>&nbsp; round(NaN) = NaN" |
| `abs(float)`                 | float       | Returns the absolute value of x.<br>Special cases are:<br>&nbsp; abs(±Inf) = +Inf<br>&nbsp; abs(NaN) = NaN |
| `toLower(string)`            | string      | Outputs the input with Unicode letters mapped to their lower case. |
| `toUpper(string)`            | string      | Outputs the input with Unicode letters mapped to their upper case. |
| `splitString(string, string)`| list[string]| Splits the given string with the given separator.<br>&nbsp; Param 1: The string to split.<br>&nbsp; Param 2: The separator." |

The syntax for a function has multiple parts. First, you have the function's identifying name, followed by `(`, followed by 0 or more comma-separated expressions, followed by `)`.

Example:
```JavaScript
thisIsAFunction("this is a string literal for the first parameter", $.a.b)
```

## Binary Operations

Binary Operations have an expression to the left and right, with an operator in between.
The order of operations determines which operators run first. See [Order of Operations](#order-of-operations)

The left and right types **must** match. To convert types, see the list of [available functions](#functions).

| Operator| Description        |
| --------|--------------------|
| `+`     | [Addition/Concatenation](#additionconcatenation) |
| `-`     | [Subtraction](#subtraction) |
| `*`     | [Multiplication](#multiplication)|
| `/`     | [Division](#division)|
| `%`     | [Modulus](#modulus)|
| `^`     | [Exponentiation](#exponentiation)|
| `==`    | [Equal To](#equal-to)|
| `!=`    | [Not Equal To](#not-equal-to)|
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

When the `+` operator is used with numerical operands, it adds them together. The operator requires numerical operands with the same type. You cannot mix float and integer operands.
For example, the expression `2 + 2` would output the integer `4`.


### Subtraction

When the `-` operator is applied to numerical operands, the result is the value of the right operand subtracted from the value of the left. The operator requires numerical operands with the same type. You cannot mix float and integer operands.

For example, the expression `6 - 4` would output the integer `2`.
The expression `$.a - $.b` would evaluate the values of `a` and `b` within the root, and subtract the value of `$.b` from `$.a`.

### Multiplication

When the `*` operator is used with a numerical operands, it multiplies them. The operator requires numerical operands with the same type.

For example, the expression `3 * 3` would output the integer `9`.

### Division

When the `/` operator is used with a numerical operands, it outputs the value of the right expression divided by the value of the left. The operator requires numerical operands with the same type.

The output type matches the input type. Integer division results in the value being rounded towards zero. If a non-whole number output is required, or if different rounding logic is required, convert the inputs into floating point number with the [`intToFloat` function](#functions), or back into integers with the [`floatToInt` function](#functions). Different types of rounding can be achieved for floating point numbers with the [functions `ceil`, `floor`, and `round`](#functions).

For example, the expression `-3 / 2` would output the integer `-1`.

### Modulus

When the `%` operator is used with a numerical operands, it outputs the remainder of value of the right expression divided by the value of the left. The operator requires numerical operands with the same type.

For example, the expression `5 % 3` would output the integer `2`.

### Exponentiation

The `^` operator outputs the result of the left side raised to the power of the right side. The operator requires numerical operands with the same type.

The mathematical expression 2<sup>3</sup> is represented in the expression language as `2^3`, which would output the integer `8`.

### Equal To

The `==` operator checks for equality between the left and right type. It returns true when the left and right match. The type must be the same for both operands, so the expression `1 == 1.0` would produce a type error. You may use functions to convert types. For example, `intToFloat(1) == 1.0`. See [functions](#functions) for more type conversions.

The operator currently supports the types `integer`, `float`, `string`, and `boolean`. If another type is required, please create an issue with the expected behavior of the operator with the needed type.

For example, `2 == 2` results in `true`, and `"a" == "b"` results in `false`.

### Not Equal To

The `!=` operator is the inverse of the [==](#equals ) operator. It returns true when the values do not match. The type must be the same for both operands, so the expression `1 != 1.0` would produce a type error. You may use functions to convert types. For example, `intToFloat(1) != 1.0`. See [functions](#functions) for more type conversions.

The operator currently supports the types `integer`, `float`, `string`, and `boolean`. If another type is required, please create an issue with the expected behavior of the operator with the needed type.

For example, `2 != 2` results in `false`, and `"a" != "b"` results in `true`.

### Greater Than

The `>` operator outputs `true` if the left side is greater than the right side, and `false` otherwise. The operator requires numerical or string operands. The type must be the same for both operands.
String operands are compared using the lexicographical order of the charset.

For an integer example, the expression `3 > 3` would output the boolean `false`, and `4 > 3` would output `true`.
For a string example, the expression `"a" > "b"` would output `false`.

### Less Than

The `<` operator outputs `true` if the left side is less than the right side, and `false` otherwise. The operator requires numerical or string operands. The type must be the same for both operands.
String operands are compared using the lexicographical order of the charset.

For an integer example, the expression `3 < 3` would output the boolean `false`, and `1 < 2` would output `true`.
For a string example, the expression `"a" < "b"` would output `true`.

### Greater Than or Equal To

The `>=` operator outputs `true` if the left side is greater than or equal to (not less than) the right side, and `false` otherwise. The operator requires numerical or string operands. The type must be the same for both operands.
String operands are compared using the lexicographical order of the charset.

For an integer example, the expression `3 >= 3` would output the boolean `true`, `3 >= 4` would output `false`, and `4 >= 3` would output `true`.

### Less Than or Equal To

The `<=` operator outputs `true` if the left side is less than or equal to (not greater than) the right side, and `false` otherwise. The operator requires numerical or string operands. The type must be the same for both operands.
String operands are compared using the lexicographical order of the charset.

For example, the expression `3 <= 3` would output the boolean `true`, `3 <= 4` would output `true`, and `4 <= 3` would output `false`.

### Logical AND

The `&&` operator returns `true` if both the left and right sides are `true`, and `false` otherwise. This operator requires boolean operands.
Note: There is no short-circuiting as it's currently implemented. Both the left and right are evaluated before the comparison takes place.

All cases:
| Left    | Right   | `&&`    |
| ------- | ------- | ------- |
| `true`  | `true`  | `true`  |
| `true`  | `false` | `false` |
| `false` | `true`  | `false` |
| `false` | `false` | `false` |

### Logical OR

The `||` operator returns `true` if **either or both** of the left and right sides are `true`, and `false` otherwise. This operator requires boolean operands.
Note: There is no short-circuiting as it's currently implemented. Both the left and right are evaluated before the comparison takes place.

All cases:
| Left    | Right   | `\|\|`  |
| ------- | ------- | ------- |
| `true`  | `true`  | `true`  |
| `true`  | `false` | `true`  |
| `false` | `true`  | `true`  |
| `false` | `false` | `false` |

## Unary Operations

Unary operations are operations that have one input. They are formatted as one operator to the left of the operand expression.

| Operator | Description        |
| ---------|--------------------|
| -        | [Negation](#Negation)           |
| !        | [Logical complement](#logical-complement) |

### Negation

The negation operator negates the numeric value from the input expression.
The required format is a dash `-` before the expression.

This operation requires numeric input.

Examples with integer literals: `-5`, `- 5`
Example with a float literal: `-50.0`
Example with a reference: `-$.foo`
Example with parentheses and a sub-expression: `-(5 + 5)`

### Logical complement

The logical complement unary operator logically inverts the boolean input.
The required format is an exclamation point `!` before the expression.

This operation requires boolean input.

Example with a boolean literal: `!true`
Example with a reference: `!$.foo`

## Parentheses

Parentheses are used to force precedence in the expression. They do not do anything implicitly (for example, there is no implied multiplication).

For example, the expression `5 + 5 * 5` evaluates the `5 * 5` before the `+`, resulting in `5 + 25`, and finally `30`.
If you want the 5 + 5 to be run first, you must use parentheses. That gives you the expression `(5 + 5) * 5`, resulting in `10 * 5`, and finally `50`.

## Order of Operations

The order of operations is designed to match mathematics and most programming languages.

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