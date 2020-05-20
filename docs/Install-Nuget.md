---
external help file: Pipeline.Tools-help.xml
Module Name: Pipeline.Tools
online version:
schema: 2.0.0
---

# Install-Nuget

## SYNOPSIS
Installs latest version of nuget

## SYNTAX

```
Install-Nuget [[-fallbackNugetPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
If not installed will download the latest copy of nuget and put it in the folder

## EXAMPLES

### EXAMPLE 1
```
Install-Nuget
```

## PARAMETERS

### -fallbackNugetPath
Location to store nuget

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: C:\Programdata\Nuget\Nuget.exe
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
FunctionName    : Install-Nuget

Created by      : Sabin.io

## RELATED LINKS
