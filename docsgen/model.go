package main

import (
    "go.flow.arcalot.io/pluginsdk/schema"
)

// TemplateData contains the data provided to docs templates.
type TemplateData struct {
    DockerDeployer     *schema.ScopeSchema
    KubernetesDeployer *schema.ScopeSchema
    PodmanDeployer     *schema.ScopeSchema
    Scope              *schema.ScopeSchema
    Schema             *schema.ScopeSchema
}
