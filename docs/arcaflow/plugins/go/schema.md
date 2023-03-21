# Writing a schema in Go

In contrast to Python, the Go SDK does not have the ability to infer the schema from the code of a plugin. The Go language does not have enough information to provide enough information.

Therefore, schemas in Go need to be written by hand. This document will explain the details and intricacies of writing a Go schema by hand.

## Typed vs. untyped serialization

Since Go is a strongly and statically typed language, there are two ways to serialize and unserialize a type.

The **untyped** serialization functions (`Serialize`, `Unserialize`) always result in an `any` type (`interface{}` for pre-1.18 code) and you will have to perform a type assertion to get the type you can actually work with.

The **typed** serialization functions (`SerializeType`, `UnserializeType`) result in a specific type, but cannot be used in lists, maps, etc. due to the lack of language features, such as [covariance](https://go.dev/doc/faq#covariant_types).

In practice, you will always use **untyped** functions when writing a plugin, **typed** functions are only useful for writing Arcaflow Engine code.

## Strings

You can define a string by calling `schema.NewStringSchema()`. It has 3 parameters:

1. The minimum number of characters in the string. (`*int64`)
2. The maximum number of characters in the string. (`*int64`)
3. A regular expression the string must match. (`*regexp.Regexp`)

It will result in a `*StringSchema`, which also complies with the `schema.String` interface. It unserializes from a string, integer, float to a string and serializes back to a string.

!!! tip
    You can easily convert a value to a pointer by using the `schema.PointerTo()` function.

## Patterns

You can define a regular expression pattern by calling [`schema.NewPatternSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewPatternSchema). It has no parameters and will result in a `*PatternSchema`, which also complies with the `schema.Pattern` interface. It unserializes from a string to a `*regexp.Regexp` and serializes back to a string.

## Integer

Integers in Are always 64-bit signed integers. You can define an integer type with the [`schema.NewIntSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewIntSchema) function. It takes the following parameters:

1. The minimum value for the integer. (`*int64`)
2. The maximum value for the integer. (`*int64`)
3. The units of the integer. (`*UnitsDefinition`, see [Units](#units))

When unserializing from a string, or another int or float type, the SDK will attempt to parse it as an integer. When serializing, the integer type will always be serialized as an integer.

## Floating point numbers

Floating point numbers are always stored as 64-bit floating point numbers. You can define a float type with the [`schema.NewFloatSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewFloatSchema) function. It takes the following parameters:

1. The minimum value for the float. (`*float64`)
2. The maximum value for the float. (`*float64`)
3. The units of the float. ([`*UnitsDefinition`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#UnitsDefinition), see [Units](#units))

When unserializing from a string, or another int or float type, the SDK will attempt to parse it as a float. When serializing, the float type will always be serialized as a float.

## Booleans

You can define a boolean by calling [`schema.NewBoolSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewBoolSchema). It has no parameters and will result in a `*BoolSchema`, which also complies with the `schema.Bool` interface. 

It converts both integers and strings to boolean if possible. The following values are accepted as `true` or `false`, respectively:

- `1`
- `yes`
- `y`
- `on`
- `true`
- `enable`
- `enabled`
- `0`
- `no`
- `n`
- `off`
- `false`
- `disable`
- `disabled`

Boolean types will always serialize to `bool`.

## Enums

Go doesn't have any built-in enums, so Arcaflow supports `int64` and `string`-based enums. You can define an int enum by calling the [`schema.NewIntEnumSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewIntEnumSchema) function. It takes the following parameters:

1. A `map[int64]*DisplayValue` of values. The keys are the valid values in the enum. The values are [display values](#display-values), which can also be nil if no special display properties are desired.
2. The units of the enum. (`*UnitsDefinition`, see [Units](#units))

Strings can be defined by using the [`schema.NewStringEnumSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewStringEnumSchema) function, which only takes the first parameter with `string` keys.

Both functions return a [`*EnumSchema[string|int64]`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#EnumSchema), which also complies with the [`Enum[string|int64]`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#Enum) interface.

## Lists

Lists come in two variants: typed and untyped. (See [Typed vs. Untyped](#typed-vs-untyped-serialization).) You can create an untyped list by calling [`schema.NewListSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewListSchema) and a typed list by calling [`schema.NewTypedListSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewTypedListSchema). Both have the following parameters:

1. The type of item in the list. For untyped lists, this is a plain schema, for typed lists this must also be a typed schema.
2. The minimum number of items in the list. (`*int64`)
3. The maximum number of items in the list. (`*int64`)

The result is a [`*ListSchema`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#ListSchema) for untyped lists, and a [`*TypedListSchema`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#TypedListSchema) for typed lists, which also satisfy their corresponding interfaces.

## Maps

Maps, like lists, come in two variants: typed and untyped. (See [Typed vs. Untyped](#typed-vs-untyped-serialization).) You can create an untyped map by calling `schema.NewMapSchema()` and a typed map by calling [`schema.NewTypedMapSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewTypedMapSchema). They both have the following parameters:

1. The key type. This must be a schema of `string`, `int`, or an enum thereof.
2. The value type. This can be any schema.
3. The minimum number of items in the map. (`*int64`)
4. The maximum number of items in the map. (`*int64`)

The functions return a [`*schema.MapSchema`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#MapSchema) and [`*schema.TypedMapSchema`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#TypedMapSchema), respectively, which satisfy their corresponding interfaces.

## Objects

Objects come in not two, but three variants: untyped, struct-mapped, and typed. (See [Typed vs. Untyped](#typed-vs-untyped-serialization).) Untyped objects unserialize to a `map[string]any`, whereas struct-mapped objects are bound to a struct, but behave like untyped objects. Typed objects are bound to a struct and are typed. In plugins, you will always want to use struct-mapped object schemas.

You can create objects with the following functions:

- [`schema.NewObjectSchema`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewObjectSchema) for untyped objects.
- [`schema.NewStructMappedObjectSchema`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewStructMappedObjectSchema) for struct-mapped objects.
- [`schema.NewTypedObject`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewTypedObject) for typed objects.

They all have two parameters:

1. A unique object identifier in the current scope. (See [Scopes](#scopes).)
2. A map of string to PropertySchema objects describing the object properties.

### Properties

Properties of objects are always untyped. You can create a property by calling [`schema.NewPropertySchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewPropertySchema) and it has the following parameters:

1. The underlying type for the property.
2. The display options for this property. (See [Display values](#display-values).)
3. If the property is required. (`bool`)
4. The required-if fields. If any of these fields in the current object is set, the current property also becomes required. (`[]string`)
5. The required-if-not fields. If none of these fields are set in the current object, the current property becomes required. (`[]string`)
6. The fields the current field conflicts with. If any of these fields are set, the current field must not be set. (`[]string`)
7. The default value for the current property. (JSON-serialized `*string`)
8. Examples for the current property. (JSON-serialized `[]string`)

## Scopes

Sometimes, objects need to have circular references to each other. That's where scopes help. Scopes behave like objects, but act as a container for [Refs](#refs). They contain a root object and additional objects that can be referenced by ID.

You can create a scope by calling [`schema.NewScopeSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewScopeSchema). It takes the following parameters:

1. The root object.
2. A list of additional objects that can be referenced by ID.

!!! warning
    When using scopes, you **must** call [`ApplyScope`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#ScopeSchema.ApplyScope) on the outermost scope once you have constructed your type tree, otherwise references won't work.

## Refs

Refs are references to objects in the current scope. You can create a ref by calling [`schema.NewRefSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewRefSchema). It takes two parameters:

1. The ID of the object referenced.
2. The display properties of this reference. (See [Display values](#display-values).)

## One-of

Sometimes, a field must be able to hold more than one type of item. That's where one-of types come into play. They behave like objects, but have a special field called the discriminator which differentiates between the different possible types. This discriminator field can either be an integer or a string.

You can use [`schema.NewOneOfIntSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewOneOfIntSchema) to create an integer-based one-of type and [`schema.NewOneOfStringSchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewOneOfStringSchema) to create a string-based one. They both accept two parameters:

1. A `map[int64|string]Object`, which holds the discriminator values and their corresponding objects (these can be refs or scopes too).
2. A `string` holding the name of the discriminator field.

The objects in the map are allowed to skip the discriminator field, but if they use it, it must have the same type as listed here.

## Any

The "any" type allows any primitive type to pass through. However, this comes with severe limitations and the data cannot be validated, so its use is discouraged. You can create an `AnySchema` by calling [`schema.NewAnySchema()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewAnySchema). This function has no parameters. 

## Display values

Several types, for example properties, accept a display value. This is a value designed to be rendered as a form field. It has three parameters:

1. A short, human-readable name.
2. A longer, possibly multi-line description.
3. An embedded SVG icon. This icon should be 64x64 pixels and not contain any external references (e.g. CSS.)

Display types are always optional (can be `nil`) and you can create one by calling [`schema.NewDisplayValue()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewDisplayValue)

## Units

Units make it easier to parse and display numeric values. For example, if you have an integer representing nanoseconds, you may want to parse strings like `5m30s`. This is similar to the duration type in Go, but with the capabilities of defining your own units.

Units have two parameters: the base type and multipliers. You can define a unit type by calling [`schema.NewUnits()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewUnits) and provide the base unit and multipliers by calling [`schema.NewUnit()`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#NewUnit).

```go
var u = schema.NewUnits(
    // Base unit:
    NewUnit(
        // Short name, singular
        "B",
        // Short name, plural
        "B",
        // Long name, singular
        "byte",
        // Long name, plural
        "bytes",
    ),
    // Multipliers
    map[int64]*UnitDefinition{
        1024: NewUnit(
            "kB",
            "kB",
            "kilobyte",
            "kilobytes",
        ),
        //...
    },
)
```

You can use the built-in [`schema.UnitBytes`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#pkg-variables), [`schema.UnitDurationNanoseconds`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#pkg-variables), and [`schema.UnitDurationSeconds`](https://pkg.go.dev/go.flow.arcalot.io/pluginsdk/schema#pkg-variables) units for your plugins.