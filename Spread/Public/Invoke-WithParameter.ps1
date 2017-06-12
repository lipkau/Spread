function Invoke-WithParameter
{
    <#
    .SYNOPSIS
        Distribute intelligently parameters to the commands you want to run

    .DESCRIPTION
        Runs a script block where the parameters can be declared for all or individually.


    .EXAMPLE
        Invoke-WithParameter { Get-Verb | Format-Wide } Column 3 Verb "I*"
        ------
        Use the parameters `-Column 3` and `-Verb I*` in both commands.
        All parameters that cannot be used with a command will be ignored.

    .EXAMPLE
        Invoke-WithParameter { Get-Verb | Format-Wide } -Column:3 -"Get-verb:Verb" "I*"
        ------
        Use the parameter `-Column 3` for both commands and `-Verb I*` only for `Get-Verb`.

    .EXAMPLE
        PS C:\>$scriptblock = {Get-Verb | Format-Wide}
        PS C:\>$parameters = @{
            Column = 4
            "Get-Verb:Verb" = "S*"
            "*:Verbose" = $true
        }
        PS C:\>Invoke-WithParameter $scriptblock @parameters
        ------
        Use use splatting to pass the parameters.
        The parameters `-Column 3` and `-Verbose` will be used for both commands and `-Verb I*` will only be used for `Get-Verb`.
    #>
    [CmdletBinding()]
    param(
        # Specifies the commands to run. Enclose the commands in braces ( { } ) to create a script block. This parameter is
        # required.
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock,

        # Parameter and Values to use with the commands in the ScriptBlock.
        #
        # Parameters which can be mistaken as CommonParameters must be enclosed in quotes. E.g.:
        # PS> Invoke-WithParameter { Get-Verb } -Verb "I*"
        # ---------
        # PowerShell will interpret the `-Verb` as an abbriviation for `Invoke-WithParameter -Verbose`
        #
        # Parameters of type Switch (or boolean) must be declared with $true or $false. E.g.:
        # PS> Invoke-WithParameter { Get-ChildItem } -Recurse $true -Path ..\
        #
        # Parameters can be declared to be used for a single command. E.g.:
        # PS> Invoke-WithParameter { Get-Process ; Get-Service } -"Get-Process:Name" "po*sh*" -"Get-Service:Name" "net*"
        [Parameter(ValueFromRemainingArguments = $true)]
        $Parameter
    )

    End
    {
        # Initialize local instance
        $PSDefaultParameterValues = @{}

        while($Parameter)
        {
            # Spread & Shift
            $param, $value, $Parameter = $Parameter

            # Clean $param from `-` delim and support `Function:Param`
            $param = $param.trimStart("-").trimEnd(":")

            if($param -notmatch ":")
            {
                $param = "*:" + $param
            }

            $PSDefaultParameterValues[$param] = $value
        }
        if ($DebugPreference -ne "SilentlyContinue")
        {
            $PSDefaultParameterValues | Out-Default
        }

        # Run ScriptBlock in same scope
        . $ScriptBlock
    }
}

Set-Alias -Name demux -Value Invoke-WithParameter
Set-Alias -Name spread -Value Invoke-WithParameter
