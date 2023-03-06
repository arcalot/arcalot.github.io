{{- /*gotype: go.flow.arcalot.io/pluginsdk.schema.Map */ -}}
{{- with .Min }}
    | Minimum items: | {{ . }} |{{ end -}}
{{- with .Max }}
    | Maximum items: | {{ . }} |{{ end }}
??? info "Key type"
    {{ prefix (partial "header" .Keys) "    " -}}
    {{ prefix (partial "type" .Keys) "    " }}
??? info "Value type"
    {{ prefix (partial "header" .Values) "    " -}}
    {{ prefix (partial "type" .Values) "    " }}
