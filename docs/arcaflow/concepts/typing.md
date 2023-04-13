# Typing system

Let's say you are creating a system that measures performance. But, uh-oh! A bug has struck! Instead of returning a number, a plugin returns an empty string. Would you want that converted to a numeric `0` for a metric? Or worse yet, would you want a negative number resulting from a bug to make it into your metrics? Would you want to collect metrics for years just to find out they are all wrong?

If the answer is no, then the typing system is here to help. Each plugin or workflow in Arcaflow is required to explicitly state what data types it accepts for its fields, and what their boundaries are. When a plugin then violates its own rules, the engine makes sure that corrupt data isn't used any further.

For example, let's look at the definition of an integer:

```yaml
type_id: integer
min: 10
max: 128
```

It's so simple, but it already prevents a lot of bugs: non-integers, numbers out of range.

But wait! A typing system can do more for you. For example, we can automatically generate a nice documentation from it. Let's take this object as an example:

```yaml
type_id: object
id: name
properties:
  name:
    type:
      type_id: string
      min: 1
      max: 256
    display:
      name: "Name"
      description: "The name of the user."
      icon: |
        <svg ...></svg>
```

That's all it takes to render a nice form field or automatic documentation. You can read more about creating types in the [plugins section](../plugins/index.md) or the [workflows section](../workflows/index.md), or see the complete [typing reference](/arcaflow/contributing/typing/) in the Contributing guide.
