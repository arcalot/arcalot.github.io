{{- with .Default }}
 ```json title="Default"
 {{ prefix . "     " | safeMD }}
 ```
{{ end -}}
{{- with .Examples }}

??? example "Examples{{ range . }}"
    ```json
    {{ prefix . "    " | safeMD }}
    ```
{{ end }}{{ end }}
