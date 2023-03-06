{{- /*gotype: go.flow.arcalot.io/pluginsdk.schema.List */ -}}
{{- with .Min }}| Minimum items: | {{ . }} |
{{ end -}}
{{- with .Max }}| Maximum items: | {{ . }} |
{{ end }}
??? info "List Items"
    {{ prefix (partial "header" .) "    " -}}
    {{ prefix (partial "type" .Items) "    " -}}