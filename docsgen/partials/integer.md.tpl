{{- /*gotype: go.flow.arcalot.io/pluginsdk.schema.Int */ -}}
{{- with .Min }}| Minimum: | {{ . }} |
{{ end -}}
{{- with .Max }}| Maximum: | {{ . }} |
{{ end -}}
{{- with .Units }}| Units: | {{ .BaseUnit.NameLongPluralValue }} |
{{ end }}