{{- /*gotype: go.flow.arcalot.io/pluginsdk.schema.Ref */ -}}
| Referenced object: | {{ .ID }} |
{{ with .Display -}}{{- with .Name }}
| Name: | {{ . }} |
{{ end -}}{{- with .Description }}
| Description: | {{ . }} |
{{ end -}}{{- end -}}
