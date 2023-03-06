{{- /*gotype: go.flow.arcalot.io/pluginsdk.schema.Float */ -}}
{{- with .Min }}| Minimum: | {{ . }} |
{{ end -}}
{{- with .Max }}| Maximum: | {{ . }} |
{{ end -}}
{{- with .Units }}| Units: | {{ .BaseUnit.NameLongPluralValue }} |
{{ end }}
