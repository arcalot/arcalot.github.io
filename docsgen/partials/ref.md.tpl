{{- /*gotype: go.flow.arcalot.io/pluginsdk.schema.Ref */ -}}
| Referenced object: | {{ .ID }} *(see in the Objects section below)* |
{{ with .Display -}}{{- with .Name }}
| Name: | {{ . }} |
{{ end -}}{{- with .Description }}
| Description: | {{ . }} |
{{ end -}}{{- end -}}
