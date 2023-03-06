package main

import (
    "bytes"
    "embed"
    "fmt"
    "html/template"
    "log"
    "os"
    "path/filepath"
    "strings"

    docker "go.flow.arcalot.io/dockerdeployer"
    kubernetes "go.flow.arcalot.io/kubernetesdeployer"
    "go.flow.arcalot.io/pluginsdk/schema"
    podman "go.flow.arcalot.io/podmandeployer"
)

//go:embed partials/*
var partials embed.FS

func main() {
    currentDirectory, err := os.Getwd()
    if err != nil {
        log.Fatal(err)
    }
    if err := filepath.Walk(currentDirectory, func(path string, info os.FileInfo, err error) error {
        if err != nil {
            return err
        }
        if !strings.HasSuffix(path, ".tpl") || info.IsDir() {
            return nil
        }
        path = strings.TrimPrefix(path, currentDirectory+"/")
        log.Printf("Processing %s...", path)
        tpl := template.New(path)

        tpl = tpl.Funcs(template.FuncMap{
            "asObject": func(object any) *schema.ObjectSchema {
                r, ok := object.(*schema.ObjectSchema)
                if !ok {
                    p, ok := object.(*schema.PropertySchema)
                    if !ok {
                        panic(fmt.Errorf("failed to convert %T to ObjectSchema or PropertySchema", object))
                    }
                    r, ok = p.Type().(*schema.ObjectSchema)
                    if !ok {
                        panic(fmt.Errorf("failed to convert %T to ObjectSchema or PropertySchema", object))
                    }
                }
                return r
            },
            "asScope": func(object any) *schema.ScopeSchema {
                return object.(*schema.ScopeSchema)
            },
            "nl2br": func(input string) string {
                return strings.ReplaceAll(input, "\n", "<br />")
            },
            "prefix": func(input any, prefix string) any {
                switch i := input.(type) {
                case template.HTML:
                    return template.HTML(strings.ReplaceAll(string(i), "\n", "\n"+prefix))
                case string:
                    return strings.ReplaceAll(i, "\n", "\n"+prefix)
                case *string:
                    r := strings.ReplaceAll(*i, "\n", "\n"+prefix)
                    return &r
                default:
                    panic(fmt.Errorf("invalid input type for 'prefix': %T (%v)", input, input))
                }
            },
            "partial": func(partial string, data any) template.HTML {
                wr := &bytes.Buffer{}
                if err := tpl.ExecuteTemplate(wr, "partials/"+partial+".md.tpl", data); err != nil {
                    panic(fmt.Errorf("failed to parse partial %s (%w)", partial, err))
                }
                return template.HTML(wr.String())
            },
            "safeMD": func(input any) any {
                switch i := input.(type) {
                case template.HTML:
                    return i
                case string:
                    return template.HTML(i)
                case *string:
                    return template.HTML(*i)
                default:
                    panic(fmt.Errorf("invalid input type for 'saveMD': %T (%v)", input, input))
                }
            },
        })

        fileContents, err := os.ReadFile(path)
        if err != nil {
            return fmt.Errorf("failed to read %s (%w)", path, err)
        }
        if tpl, err = tpl.Parse(string(fileContents)); err != nil {
            return fmt.Errorf("failed to parse %s (%w)", path, err)
        }

        partialFiles, err := partials.ReadDir("partials")
        if err != nil {
            return fmt.Errorf("failed to read built-in partials (%w)", err)
        }
        for _, partial := range partialFiles {
            if partial.IsDir() {
                continue
            }
            fileContents, err = partials.ReadFile("partials/" + partial.Name())
            if err != nil {
                return fmt.Errorf("failed to read partial %s (%w)", partial.Name(), err)
            }
            partialTpl := tpl.New("partials/" + partial.Name())
            if _, err := partialTpl.Parse(string(fileContents)); err != nil {
                return fmt.Errorf("failed to parse partial %s (%w)", partial.Name(), err)
            }
        }

        data := TemplateData{
            DockerDeployer:     &docker.NewFactory().ConfigurationSchema().ScopeSchema,
            KubernetesDeployer: &kubernetes.NewFactory().ConfigurationSchema().ScopeSchema,
            PodmanDeployer:     &podman.NewFactory().ConfigurationSchema().ScopeSchema,
            Scope:              schema.DescribeScope(),
            Schema:             schema.DescribeSchema(),
        }

        buf := &bytes.Buffer{}
        if err := tpl.ExecuteTemplate(buf, path, data); err != nil {
            return fmt.Errorf("failed to execute template %s (%w)", path, err)
        }

        newFileName := strings.TrimSuffix(path, ".tpl")
        if err := os.WriteFile(newFileName, buf.Bytes(), 0644); err != nil {
            return fmt.Errorf("failed to write %s (%w)", newFileName, err)
        }
        return nil
    }); err != nil {
        log.Fatalf("%v", err)
    }
}
