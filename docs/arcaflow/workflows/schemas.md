# Workflow Schemas

## Schema Names

### Non-Object Names

Schemas that are not composed within an ObjectSchema do not have an `Object ID`. They use a stringified version of their `TypeID` for their schema name.

| schema        |     type id                 |
|---------------|-----------------------------|
| IntEnum       | enum_string                      |
| StringEnum    | enum_integer                      |
| String        | string                      |
| Pattern       | pattern                      |
| Int           | integer                     |
| Float         | float                    |
| Bool          | bool                      |
| Map           | map              |
| OneOfString   | one_of_string   |
| OneOfInt      | one_of_int      |

`ListSchema`s use the `ListSchema` `TypeID` with the schema name of their constituent element, or item value. `ListSchema` names are prepended with `list` until they reach a non-`ListSchema` item type. These names are joined with a single underscore, `_`.

| schema              |  name                 |
|---------------------|-----------------------|
| List[String]        |  list_string                      |
| List[Pattern]       |  list_pattern                      |
| List[StringEnum]    |  list_enum_string                      |
| List[Map]           |  list_map                      |
| List[OneOfInt]      |  list_one_of_int                      |
| List[List[String]]  |  list_list_string                      |
| List[List[List[String]]]  |  list_list_list_string                      |

### Object Names

`ObjectSchema`s use their `Object ID` as their schema name. `ListSchema`s that have an `ObjectSchema` as their item value use that `ObjectSchema`'s name.

| schema                    | object id     | name                          |
|---------------------------|---------------|-------------------------------|
| Object                    | MyFirstObject | MyFirstObject                 |
| List[Object]              | MyFirstObject | list_MyFirstObject            |
| List[List[String]]        | MyFirstObject | list_list_MyFirstObject       |
| List[List[List[String]]]  | MyFirstObject | list_list_list_MyFirstObject  |
 
### Remaining Schemas

* `ScopeSchema`s do not get a schema name.
* `RefSchema`s use the schema name of the type to which they point.


## Generated Combined Schema Names

`bindConstants(list[any], any)` generates a new schema name from the schemas provided as arguments. Because the output of this function is a schema name and ID for a single list element, only the scheme name of the list's items is used. It is concatenated with a double underscore `__` with the schema name of the second argument.

| first schema           | second schema              | new name                      |
|------------------------|----------------------------|-------------------------------|
| List[Int]                          | Object(ID="MyFirstObject")   | int__MyFirstObject        |
| List[Object(ID="MyFirstObject") ]  | Object(ID="Constants")       | MyFirstObject__Constants  |
| List[Object(ID="MyFirstObject") ]  | String                       | MyFirstObject__string     |
| List[String]                       | Int                          | string__int               |
| List[String]                       | List[Object(ID="Constants")] | string__list_Constants    |