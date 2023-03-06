{{- /*gotype: go.flow.arcalot.io/pluginsdk.schema.Object */ -}}
{{- $object := asObject . }}
???+ note "Properties"{{ range $propertyID, $property := $object.Properties }}
    ??? info "{{ $propertyID }} (`{{- partial "typename" $property.Type -}}`)"
        {{ prefix (partial "header" .) "        " -}}
        {{ prefix (partial "property" $property) "        " -}}
        {{ prefix (partial "type" $property.Type) "        " -}}
        {{ prefix (partial "defaults" $property) "        " -}}
{{ else }}
    *None*
{{ end -}}
