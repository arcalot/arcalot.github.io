# Workflow Schemas

## Schema Names

### Scalar Names

Schemas that are not composed within an ObjectSchema do not have an 
`Object ID`. They use a stringified version of their `TypeID` for 
their schema name.

| schema      | name          |
|-------------|---------------|
| IntEnum     | enum_integer  |
| StringEnum  | enum_string   |
| String      | string        |
| Pattern     | pattern       |
| Int         | integer       |
| Float       | float         |
| Bool        | bool          |
| Map         | map           |
| OneOfString | one_of_string |
| OneOfInt    | one_of_int    |

The name of a `ListSchema` is the name of the schema of its element type 
prefixed with `list_`. For lists of lists, the schema name is the name of 
the inner list schema prefixed with an additional `list_`. These names are 
joined with a single underscore, `_`.

### List Names

| schema                   | name                  |
|--------------------------|-----------------------|
| List[String]             | list_string           |
| List[Pattern]            | list_pattern          |
| List[StringEnum]         | list_enum_string      |
| List[Map]                | list_map              |
| List[OneOfInt]           | list_one_of_int       |
| List[List[String]]       | list_list_string      |
| List[List[List[String]]] | list_list_list_string |

### Object Names

The name of an `ObjectSchema` is their `Object ID`. `ListSchema`s that 
have an `ObjectSchema` as their item value use the name of that `ObjectSchema`.

| schema                   | object id     | name                         |
|--------------------------|---------------|------------------------------|
| Object                   | MyFirstObject | MyFirstObject                |
| List[Object]             | MyFirstObject | list_MyFirstObject           |
| List[List[Object]]       | MyFirstObject | list_list_MyFirstObject      |
| List[List[List[Object]]] | MyFirstObject | list_list_list_MyFirstObject |
 
### Other Schemas

* `ScopeSchema`s do not use a schema name.
* `RefSchema`s use the schema name of the type to which they point.

## Generated Combined Schema Names

The name of the schema for the value returned by a given call to `bindConstants()` is generated from the names of the schemas of the parameters to the call.  Because the output of this function is always a list, the `list_` prefix is omitted from the schema name, and only the schema name of the list's items is used. The name is formed by concatenating the name of the schema of the first parameter's list items with the name of the schema of the second parameter, separated by a double underscore `__`.

| first schema                      | second schema                | name                     |
|-----------------------------------|------------------------------|--------------------------|
| List[Int]                         | Object(ID="MyFirstObject")   | integer__MyFirstObject       |
| List[Object(ID="MyFirstObject") ] | Object(ID="Constants")       | MyFirstObject__Constants |
| List[Object(ID="MyFirstObject") ] | String                       | MyFirstObject__string    |
| List[String]                      | Int                          | string__integer              |
| List[String]                      | List[Object(ID="Constants")] | string__list_Constants   |