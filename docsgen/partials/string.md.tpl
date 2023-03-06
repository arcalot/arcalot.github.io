{{- /*gotype: go.flow.arcalot.io/pluginsdk.schema.String */ -}}
{{- with .Min }}| Minimum: | {{ . }} |
{{ end -}}
{{- with .Max }}| Maximum: | {{ . }} |
{{ end -}}
{{- with .Pattern }}| Must match pattern: | `{{ .String }}` |
{{ end -}}