# Localization

## How to add to brick globally ?

### First remove the brick if it already exists

```shell
mason remove -g core_localizations
```

### Add the brick

```shell
cd path/to/your/component/core_localizations
mason add -g core_localizations --path .
```

## How to create the brick ?

```shell
mason make core_localizations -c project_metadata.json
```
