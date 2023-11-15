# Workflow schema versions

All workflow schema versions conform to [semantic version 2.0.0](https://semver.org/#backusnaur-form-grammar-for-valid-semver-versions) with a major, minor, and patch version. In this document, since the prepended `v` is unnecessary it is not used. However, it is required as a value for the version key in your workflow file.

Invalid version string for `workflow.yaml`.

```yaml
version: 0.2.0
input:
steps:
outputs:
```

**Valid** version string for `workflow.yaml`.

```yaml
version: v0.2.0
input:
steps:
outputs:
```

## Supported versions

* 0.2.0

## Compatibility Matrix


| Workflow schema version | Arcaflow Engine release  |
|---|---|
| 0.2.0 | 0.9.0 |