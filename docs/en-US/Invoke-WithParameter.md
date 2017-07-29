---
external help file: Spread-help.xml
online version:
locale: en-US
schema: 2.0.0
---

# Invoke-WithParameter

## SYNOPSIS
Distribute intelligently parameters to the commands you want to run

## SYNTAX

```powershell
Invoke-WithParameter [-ScriptBlock] <ScriptBlock> [[-Parameter] <Object>]
```

## DESCRIPTION
Runs a script block where the parameters can be declared for all or individually.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```powershell
Invoke-WithParameter { Get-Verb | Format-Wide } Column 3 Verb "I*"
```

Description  
 -----------  
Use the parameters \`-Column 3\` and \`-Verb I*\` in both commands.  
All parameters that cannot be used with a command will be ignored.

### -------------------------- EXAMPLE 2 --------------------------
```powershell
Invoke-WithParameter { Get-Verb | Format-Wide } -Column:3 -"Get-verb:Verb" "I*"
```

Description  
 -----------  
Use the parameter \`-Column 3\` for both commands and \`-Verb I*\` only for \`Get-Verb\`.

### -------------------------- EXAMPLE 3 --------------------------
```powershell
$scriptblock = {Get-Verb | Format-Wide}
PS C:\\\>$parameters = @{
    Column = 4
    "Get-Verb:Verb" = "S*"
    "*:Verbose" = $true
}
PS C:\\\>Invoke-WithParameter $scriptblock @parameters
```

Description  
 -----------  
Use use splatting to pass the parameters.  
The parameters \`-Column 3\` and \`-Verbose\` will be used for both commands and \`-Verb I*\` will only be used for \`Get-Verb\`.

## PARAMETERS

### -ScriptBlock
Specifies the commands to run.
Enclose the commands in braces ( { } ) to create a script block.
This parameter is required.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Parameter
Parameter and Values to use with the commands in the ScriptBlock.  

Parameters which can be mistaken as CommonParameters must be enclosed in quotes.  
PowerShell will interpret the \`-Verb\` as an abbreviation for \`Invoke-WithParameter -Verbose\`  
E.g.:

```powershell
Invoke-WithParameter { Get-Verb } -Verb "I*"
```

Parameters of type Switch (or boolean) must be declared with $true or $false.  
E.g.:

```powershell
Invoke-WithParameter { Get-ChildItem } -Recurse $true -Path ..\
```

Parameters can be declared to be used for a single command.  
E.g.:

```powershell
Invoke-WithParameter { Get-Process ; Get-Service } -"Get-Process:Name" "po*sh*" -"Get-Service:Name" "net*"
```

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

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
