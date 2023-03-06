| Type: | `{{ partial "typename" . }}` |
{{ if eq .TypeID "enum_string" -}}
    {{- partial "enum_string" . -}}
{{- else if eq .TypeID "enum_integer" -}}
    {{- partial "enum_integer" . -}}
{{- else if eq .TypeID "string" -}}
    {{- partial "string" . -}}
{{- else if eq .TypeID "pattern" -}}
    {{- partial "pattern" . -}}
{{- else if eq .TypeID "integer" -}}
    {{- partial "integer" . -}}
{{- else if eq .TypeID "float" -}}
    {{- partial "float" . -}}
{{- else if eq .TypeID "bool" -}}
    {{- partial "bool" . -}}
{{- else if eq .TypeID "list" -}}
    {{- partial "list" . -}}
{{- else if eq .TypeID "map" -}}
    {{- partial "map" . -}}
{{- else if eq .TypeID "scope" -}}
    {{- partial "scope" .  -}}
{{- else if eq .TypeID "object" -}}
    {{- partial "object" .  -}}
{{- else if eq .TypeID "one_of_string" -}}
    {{- partial "one_of_string" .  -}}
{{- else if eq .TypeID "one_of_int" -}}
    {{- partial "one_of_int" .  -}}
{{- else if eq .TypeID "ref" -}}
    {{- partial "ref" .  -}}
{{- end -}}