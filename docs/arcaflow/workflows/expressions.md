# Arcaflow expressions

Arcaflow expressions were inspired by JSONPath but have diverged from the syntax. You can use expressions in a workflow YAML like this:

```yaml
some_value: !expr $.your.expression.here
```

This page explains the language elements of expressions.

!!! warning
    Expressions in workflow definitions **must** be prefixed with `!expr`, otherwise their literal value will be taken as a string.

## Literals

Literals represent constant values in an expression.

### String values

Normal string literals start and end with a matched pair of either single quotes (`'`) or double quotes (`"`) and have zero or more characters between the quotes.

Strings may contain special characters.  In normal strings, these characters are represented by "escape sequences" consisting of a
backslash followed by another character.  Since a backslash therefore has a special meaning, in order to represent a
literal backslash character, it must be preceded by another backslash.  Similarly, in a string delimited by double
quotes, a double quote occurring inside the string must be escaped to prevent it from marking the end of the string.
The same is true for single quotes occurring inside a string delimited by single quotes.  However, you do not need to escape
double quotes in a single-quoted string nor single-quotes in a double-quoted string.

Here is the list of supported escape characters:

| Escape | Result                     |
|--------|----------------------------|
| `\\`   | `\` backslash character    |
| `\t`   | tab character              |
| `\n`   | newline character          |
| `\r`   | carriage return character  |
| `\b`   | backspace character        |
| `\"`   | `"` double quote character |
| `\'`   | `'` single quote character |
| `\0`   | null character             |

For example, to have the following text represented in a single string:
> test
> test2/\

You would need the expression `"test\ntest2/\\"`

#### String Expressions in YAML

When expressing string literals in YAML, be aware that YAML has its own rules around the use of quotation marks.

For example, to include a double-quoted string in an expression, you must either add single quotes around the expression
or use block flow scalars. Inside a single-quoted string, an apostrophe needs to be preceded
by another apostrophe to indicate that it does not terminate the string.

Here is an example of the following value represented in a few of the various ways:
> Here's an apostrophe and "embedded quotes".

Inlined with single quotes:
```
some_value_1: !expr '"Here''s an apostrophe and \"embedded quotes\"."'
```
!!! tip
    - The `!expr` tag indicates to the YAML processor that the value is an Arca _expression_.
    - The single quotes cause the YAML processor to pass the contents of the string intact except for replacing the
      repeated apostrophe with a single one.  (They are not included in the expression value.)
    - The backslash-escapes are replaced by Arca's expression processing.  (The unescaped double quotes are not included
      in the expression value.)

Inlined with double quotes:
```
some_value_2: !expr "'Here\\'s an apostrophe and \"embedded quotes\".'"
```
!!! tip
    - The `!expr` tag indicates to the YAML processor that the value is an Arca expression.
    - The double quotes cause the YAML processor to interpret the contents of the string:
      <ul><li>the <code>\\\\</code> is replaced with a single backslash;
      <li>each <code>\\\"</code> is replaced with a literal `"`;
      <li>the surrounding double quotes are not included in the expression value.</ul>
    - The backslash-escapes are replaced by Arca's expression processing.  (The unescaped single quotes are not included
      in the expression value.)

With Block Flow Scalar:
```
some_value_1: !expr |-
  'Here\'s an apostrophe and "embedded quotes".'
some_value_2: !expr |-
  "Here's an apostrophe and \"embedded quotes\"."
```

!!! tip
    - The `!expr` tag indicates to the YAML processor that the value is an Arca _expression_.
    - The vertical bar (`|`) causes the YAML processor to pass the contents of the string without modification.
    - Newlines within the expression are included in the string; the hyphen (`-`) after the vertical bar causes the
    trailing newline to be omitted from the end of the string.
    - The backslash-escapes are replaced by Arca's expression processing.  The unescaped quotes are not included
    in the expression value; the other quotes are escaped to prevent them from ending the string prematurely; the
    double quotes in `some_value_1` do not need to be escaped nor do the single quotes in `some_value_2`.

See [Raw string values](#raw-string-values) to see how to do this without escaping.

### Raw string values

Raw string literals start and end with backtick characters "\`".

In a raw string, all characters are interpreted literally. This means that you can use `'` and `"` characters without
escaping them, and backslashes are treated like any other character.  However, backtick characters cannot appear in a
raw string.

Here is an example of the following value represented using raw strings:
> Here's an apostrophe and "embedded quotes".

Inlined:
```
some_value: !expr '`Here''s an apostrophe and "embedded quotes".`'
```
!!! tip
    - The `!expr` tag indicates to the YAML processor that the value is an Arca _expression_.
    - The single quotes cause the YAML processor to pass the contents of the string intact except for replacing the
      repeated apostrophe with a single one.  (They are not included in the expression value.)
    - The backticks cause Arca's expression processing to use the string verbatim.  (The backticks are not included
      in the expression value.)

With Block Flow Scalar:
```
some_value: !expr |-
  `Here's an apostrophe and "embedded quotes".`
```

!!! tip
    - The `!expr` tag indicates to the YAML processor that the value is an Arca _expression_.
    - The vertical bar (`|`) causes the YAML processor to pass the contents of the string without modification.
    - Newlines within the expression are included in the string; the hyphen (`-`) after the vertical bar causes the
      trailing newline to be omitted from the end of the string.
    - The backticks cause Arca's expression processing to use the string verbatim, thus the embedded quotes don't require
      escapes.  (The backticks are not included in the expression value.)

### Integer numbers

Integers are whole numbers expressed as sequences of base-10 digits.

Integer literals may not start with `0`, unless the value is `0`. For example, `001` is not a valid integer literal.

Examples:

- `0`
- `1`
- `503`

Negative values are constructed by applying the [negation operator (`-`)](#negation) to a literal numeric value.

### Floating point numbers

Floating point literals are non-negative double-precision floating point numbers.

Supported formats include:

- number characters followed by a period followed by zero or more number characters: `1.1` or `1.`
- base-10 exponential scientific notation formats like `5.0e5` and `5.0E-5`

Negative values are constructed by applying the [negation operator (`-`)](#negation) to a literal numeric value.

### Boolean values

Boolean literals have two valid values:

- `true`
- `false`

No other values are valid boolean literals. The values are case-sensitive.

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

The engine provides predefined functions for use in expressions.  These provide transformations beyond what is
available from operators.

Functions:

| function definition                              | return type  | description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
|--------------------------------------------------|--------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `intToFloat(integer)`                            | float        | Converts an integer value into the equivalent floating point value.                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `floatToInt(float)`                              | integer      | Converts a floating point value into an integer value by discarding the fraction, rounding toward zero to the nearest integer.<br><br>Special cases:<br>&nbsp; +Inf yields the maximum 64-bit integer (9223372036854775807)<br>&nbsp; -Inf and NaN yield the minimum 64-bit integer (-9223372036854775808)<br><br>For example, `5.5` yields `5`, and `-1.9` yields `-1`                                                                                                                        |
| `intToString(integer)`                           | string       | Returns a string containing the base-10 representation of the input.<br><br>For example, an input of `55` yields `"55"`                                                                                                                                                                                                                                                                                                                                                                        |
| `floatToString(float)`                           | string       | Returns a string containing the base-10 representation of the input.<br><br>For example, an input of `5000.5` yields `"5000.5"`                                                                                                                                                                                                                                                                                                                                                                |
| `floatToFormattedString(float, string, integer)` | string       | Returns a string containing the input in the specified format with the specified precision.<br>&nbsp; Param 1: the floating point input value<br>&nbsp; Param 2: the format specifier: `"e"`, `"E"`, `"f"`, `"g"`, `"G"`<br>&nbsp; Param 3: the number of digits<br><br>Specifying -1 for the precision will produce the minimum number of digits required to represent the value exactly.  (See the [Go runtime documentation](https://pkg.go.dev/strconv@go1.22.0#FormatFloat) for details.) |
| `boolToString(boolean)`                          | string       | Returns `"true"` for `true`, and `"false"` for `false`.                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `stringToInt(string)`                            | integer      | Interprets the string as a base-10 integer. Returns an error if the input is not a valid integer.                                                                                                                                                                                                                                                                                                                                                                                              |
| `stringToFloat(string)`                          | float        | Converts the input string to a double-precision floating-point number.<br><br>Accepts floating-point numbers as defined by the [Go syntax for floating point literals](https://go.dev/ref/spec#Floating-point_literals).  If the input is well-formed and near a valid floating-point number, returns the nearest floating-point number rounded using IEEE754 unbiased rounding. Returns an error when an invalid input is received.                                                           |
| `stringToBool(string)`                           | boolean      | Interprets the input as a boolean.<br><br>Accepts `"1"`, `"t"`, and `"true"` as `true` and `"0"`, `"f"`, and `"false"` as `false` (case is not significant). Returns an error for any other input.                                                                                                                                                                                                                                                                                             |
| `ceil(float)`                                    | float        | Returns the least integer value greater than or equal to the input.<br><br>Special cases are:<br>&nbsp; ceil(±0.0) = ±0.0<br>&nbsp; ceil(±Inf) = ±Inf<br>&nbsp; ceil(NaN) = NaN<br><br>For example `ceil(1.5)` yields `2.0`, and `ceil(-1.5)` yields `-1.0`                                                                                                                                                                                                                                    |
| `floor(float)`                                   | float        | Returns the greatest integer value less than or equal to the input.<br><br>Special cases are:<br>&nbsp; floor(±0.0) = ±0.0<br>&nbsp; floor(±Inf) = ±Inf<br>&nbsp; floor(NaN) = NaN<br><br>For example `floor(1.5)` yields `1.0`, and `floor(-1.5)` yields `-2.0`                                                                                                                                                                                                                               |
| `round(float)`                                   | float        | Returns the nearest integer to the input, rounding half away from zero.<br><br>Special cases are:<br>&nbsp; round(±0.0) = ±0.0<br>&nbsp; round(±Inf) = ±Inf<br>&nbsp; round(NaN) = NaN<br><br>For example `round(1.5)` yields `2.0`, and `round(-1.5)` yields `-2.0`                                                                                                                                                                                                                           |
| `abs(float)`                                     | float        | Returns the absolute value of the input.<br><br>Special cases are:<br>&nbsp; abs(±Inf) = +Inf<br>&nbsp; abs(NaN) = NaN                                                                                                                                                                                                                                                                                                                                                                         |
| `toLower(string)`                                | string       | Returns the input with Unicode letters mapped to their lower case.                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `toUpper(string)`                                | string       | Returns the input with Unicode letters mapped to their upper case.                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `splitString(string, string)`                    | list[string] | Returns a list of the substrings which appear between instances of the specified separator; the separator instances are not included in the resulting list elements; adjacent occurrences of separator instances as well as instances appearing at the beginning or ending of the input will produce empty string list elements.<br>&nbsp; Param 1: The string to split.<br>&nbsp; Param 2: The separator.                                                                                     |
| `readFile(string)`                               | string |  Returns the contents of a file as a UTF-8 character string, given a file path string. Relative file paths are resolved from the Arcaflow process working directory. Shell environment variables are not expanded.                                                                                     |

A function is used in an expression by referencing its name followed by a comma-separated list of zero or more argument
expressions enclosed in parentheses.

Example:
```JavaScript
thisIsAFunction("this is a string literal for the first parameter", $.a.b)
```

## Binary Operations

Binary Operations have an expression to the left and right, with an operator in between.
The order of operations determines which operators are evaluated first. See [Order of Operations](#order-of-operations)

The types of the left and right operand expressions **must** match. To convert between types, see the list of [available functions](#functions).
The type of the resulting expression is the same as the type of its operands.

| Operator | Description                                           |
|----------|-------------------------------------------------------|
| `+`      | [Addition/Concatenation](#additionconcatenation)      |
| `-`      | [Subtraction](#subtraction)                           |
| `*`      | [Multiplication](#multiplication)                     |
| `/`      | [Division](#division)                                 |
| `%`      | [Modulus](#modulus)                                   |
| `^`      | [Exponentiation](#exponentiation)                     |
| `==`     | [Equal To](#equal-to)                                 |
| `!=`     | [Not Equal To](#not-equal-to)                         |
| `>`      | [Greater Than](#greater-than)                         |
| `<`      | [Less Than](#less-than)                               |
| `>=`     | [Greater Than or Equal To](#greater-than-or-equal-to) |
| `<=`     | [Less Than or Equal To](#less-than-or-equal-to)       |
| `&&`     | [Logical And](#logical-and)                           |
| `\|\|`   | [Logical Or](#logical-or)                             |


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

When the `*` operator is used with numerical operands, it multiplies them. The operator requires numerical operands with the same type.

For example, the expression `3 * 3` would output the integer `9`.

### Division

When the `/` operator is used with numerical operands, it outputs the value of the left expression divided by the value of the right. The operator requires numerical operands with the same type.

The result of integer division is rounded towards zero. If a non-integral result is required, or if different rounding logic is required, convert the inputs into floating point numbers with the [`intToFloat` function](#functions). Different types of rounding can be performed on floating point numbers with the [functions](#functions) `ceil`, `floor`, and `round`.

For example, the expression `-3 / 2` would yield the integer value `-1`.

### Modulus

When the `%` operator is used with numerical operands, it evaluates to the remainder when the value of the left expression is divided by the value of the right. The operator requires numerical operands with the same type.

For example, the expression `5 % 3` would output the integer `2`.

### Exponentiation

The `^` operator outputs the result of the left side raised to the power of the right side. The operator requires numerical operands with the same type.

The mathematical expression 2<sup>3</sup> is represented in the expression language as `2^3`, which would output the integer `8`.

### Equal To

The `==` operator evaluates to true if the values of the left and right operands are the same. Both operands must have
the same type. You may use functions to convert between types -- see [functions](#functions) for more type conversions.
The operator supports the types `integer`, `float`, `string`, and `boolean`.

For example, `2 == 2` results in `true`, and `"a" == "b"` results in `false`.  `1 == 1.0` would result in a type error.

### Not Equal To

The `!=` operator is the inverse of the [`==`](#equal-to) operator. It evaluates to false if the values of the left and right operands are the same. Both operands must have
the same type. You may use functions to convert between types -- see [functions](#functions) for more type conversions.
The operator supports the types `integer`, `float`, `string`, and `boolean`.

For example, `2 != 2` results in `false`, and `"a" != "b"` results in `true`.  `1 != 1.0` would result in a type error.

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
Note: The operation does not "short-circuit" -- both the left and right expressions are evaluated before the comparison takes place.

All cases:

| Left    | Right   | `&&`    |
|---------|---------|---------|
| `true`  | `true`  | `true`  |
| `true`  | `false` | `false` |
| `false` | `true`  | `false` |
| `false` | `false` | `false` |

### Logical OR

The `||` operator returns `true` if **either or both** of the left and right sides are `true`, and `false` otherwise. This operator requires boolean operands.
Note: The operation does not "short-circuit" -- both the left and right expressions are evaluated before the comparison takes place.

All cases:

| Left    | Right   | `\|\|`  |
|---------|---------|---------|
| `true`  | `true`  | `true`  |
| `true`  | `false` | `true`  |
| `false` | `true`  | `true`  |
| `false` | `false` | `false` |

## Unary Operations

Unary operations are operations that have one input. The operator is applied to the expression which follows it.

| Operator | Description                               |
|----------|-------------------------------------------|
| -        | [Negation](#negation)                     |
| !        | [Logical complement](#logical-complement) |

### Negation

The `-` operator negates the value of the expression which follows it.

This operation requires numeric input.

Examples with integer literals: `-5`, `- 5`<br>
Example with a float literal: `-50.0`<br>
Example with a reference: `-$.foo`<br>
Example with parentheses and a sub-expression: `-(5 + 5)`

### Logical complement

The `!` operator logically inverts the value of the expression which follows it.

This operation requires boolean input.

Example with a boolean literal: `!true`<br>
Example with a reference: `!$.foo`

## Parentheses

Parentheses are used to force precedence in the expression. They do not do anything implicitly (for example, there is no implied multiplication).

For example, the expression `5 + 5 * 5` evaluates the `5 * 5` before the `+`, resulting in `5 + 25`, and finally `30`.
If you want the 5 + 5 to be run first, you must use parentheses. That gives you the expression `(5 + 5) * 5`, resulting in `10 * 5`, and finally `50`.

## Order of Operations

The order of operations is designed to match mathematics and most programming languages.

Order (highest to lowest; operators listed on the same line are evaluated in the order they appear in the expression):

- [negation (`-`)](#negation)
- [parentheses (`()`)](#parentheses)
- [exponent (`^`)](#exponentiation)
- [multiplication (`*`)](#multiplication) and [division (`/`)](#division)
- [addition/concatenation (`+`)](#additionconcatenation) and [subtraction (`-`)](#subtraction)
- binary equality and inequality (all equal)
  <ul><li><a href="#equal-to">equals (<code>==</code>)</a>
  <li><a href="#not-equal-to">not equals (<code>!=</code>)</a>
  <li><a href="#greater-than">greater than (<code>></code>)</a>
  <li><a href="#less-than">less than (<code><</code>)</a>
  <li><a href="#greater-than-or-equal-to">greater than or equal to (<code>>=</code>)</a>
  <li><a href="#less-than-or-equal-to">less than or equal to (<code><=</code>)</a></li></ul>
- [logical complement (`!`)](#logical-complement)
- [logical AND (`&&`)](#logical-and)
- [logical OR (`||`)](#logical-or)
- [dot notation (`.`)](#dot-notation) and [bracket access (`[]`)](#bracket-accessor)

## Other information

More information on the expression language is available in the [development guide](../contributing/expressions.md).

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