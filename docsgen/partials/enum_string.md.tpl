{{- /*gotype: go.flow.arcalot.io/pluginsdk.schema.StringEnum */ -}}
??? info "Values"
{{- range $value, $display := .ValidValues }}{{ if $display }}
    - `{{ $value }}` {{ $display.Name }}
{{- else }}
    - `{{ $value }}`
{{- end -}}{{- end -}}
