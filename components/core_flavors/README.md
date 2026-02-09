# Flavors

## How to add to brick globally ?

### First remove the brick if it already exists

```shell
mason remove -g fluf_flavors
```

### Add the brick

```shell
mason add -g fluf_flavors --path bricks/fluf_flavors
```

## How to create the brick ?

```shell
mason make fluf_flavors -c project_metadata.json
```
