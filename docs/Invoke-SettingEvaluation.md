---
external help file: Pipeline.Config-help.xml
Module Name: Pipeline.Config
online version:
schema: 2.0.0
---

# Invoke-SettingEvaluation

## SYNOPSIS
Walks the settings to evaluate them and return an updated settings structure

## SYNTAX

```
Invoke-SettingEvaluation [[-settings] <Object>] [[-thisSettings] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Loops around all the properties in the settings (either hash keys or psobjects) and 
evaluates the values using Expand-String for strings or calling this function again for lists

## EXAMPLES

### EXAMPLE 1
```
<example usage>
Explanation of what the example does
```

## PARAMETERS

### -settings
{{ Fill settings Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -thisSettings
{{ Fill thisSettings Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### settings = the global settings used to allow expressions to refer to the settings i.e. databaseName = "{$Settings.environment & "-" & $settings.Project"
### thisSettings = the object to be evaluating the keys of.
## OUTPUTS

### Output (if any)
## NOTES
General notes

## RELATED LINKS
