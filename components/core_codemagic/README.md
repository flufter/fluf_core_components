# Codemagic

## How to add to brick globally ?

### First remove the brick if it already exists

```shell
mason remove -g fluf_codemagic
```

### Add the brick

```shell
mason add -g fluf_codemagic --path bricks/fluf_codemagic
```

## How to create the brick ?

```shell
mason make fluf_codemagic -c project_metadata.json
```
