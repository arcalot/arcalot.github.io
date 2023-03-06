{{- if eq .TypeID "enum_string" -}}
    enum[string]
{{- else if eq .TypeID "enum_integer" -}}
    enum[int]
{{- else if eq .TypeID "string" -}}
    string
{{- else if eq .TypeID "pattern" -}}
    pattern
{{- else if eq .TypeID "integer" -}}
    int
{{- else if eq .TypeID "float" -}}
    float
{{- else if eq .TypeID "bool" -}}
    bool
{{- else if eq .TypeID "list" -}}
    list[{{ partial "typename" .Items -}}]
{{- else if eq .TypeID "map" -}}
    map[{{ partial "typename" .Keys }}, {{ partial "typename" .Values -}}]
{{- else if eq .TypeID "scope" -}}
    scope
{{- else if eq .TypeID "object" -}}
    object
{{- else if eq .TypeID "one_of_string" -}}
    one of[string]
{{- else if eq .TypeID "one_of_int" -}}
    one of[int]
{{- else if eq .TypeID "ref" -}}
    reference[{{ .ID }}]
{{- else if eq .TypeID "any"}}
    any
{{- end -}}