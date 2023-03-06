{{- with .Display -}}
{{- with .Name }}| Name: | {{ . }} |
{{ end -}}
{{- with .Description -}}| Description: | {{ . }} |
{{ end -}}
{{- end -}}
| Required: | {{ with .Required }}Yes{{ else }}No{{ end }} |
{{- with .RequiredIf }}| Required if the following fields are set: |
{{- $first := true -}}
{{- range . -}}
    {{- if $first -}}
        {{- $first = false -}}
    {{- else -}}, {{ end -}}
    {{ . -}}
{{- end }} |{{ end -}}
{{- with .RequiredIfNot }}| Required if the following fields are not set: |
{{- $first := true -}}
{{- range . -}}
    {{- if $first -}}
        {{- $first = false -}}
    {{- else -}}, {{ end -}}
    {{ . -}}
{{- end }} |{{ end -}}
{{- with .Conflicts }}| Conflicts the following fields: |
{{- $first := true -}}
{{- range . -}}
    {{- if $first -}}
        {{- $first = false -}}
    {{- else -}}, {{ end -}}
    {{ . -}}
{{- end }} |{{ end -}}
