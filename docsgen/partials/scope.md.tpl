{{- /*gotype: go.flow.arcalot.io/pluginsdk.schema.Scope */ -}}
| Root object: | {{ .Root }} |
???+ note "Properties"{{ range $propertyID, $property := .Properties }}
    ??? info "{{ $propertyID }} (`{{- partial "typename" $property.Type -}}`)"
        {{ prefix (partial "header" .) "        " -}}
        {{ prefix (partial "property" $property) "        " -}}
        {{ prefix (partial "type" $property.Type) "        " -}}
        {{ prefix (partial "defaults" $property) "        " -}}
{{ else }}
    *None*
{{ end }}
???+ note "Objects"{{- range $objectID, $object := .Objects }}
    ??? info "**{{ $objectID }}** (`{{- partial "typename" $object -}}`)"
        {{ prefix (partial "type_with_header" $object) "        " -}}
{{ else }}
    *None*
{{ end -}}
