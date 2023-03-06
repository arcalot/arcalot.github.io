{{- /*gotype: go.flow.arcalot.io/pluginsdk.schema.IntEnum */ -}}
??? info "Values"
{{ range $value, $display := .ValidValues }}
    - **{{ $value }}:** {{ $display.Name }}{{ end }}
