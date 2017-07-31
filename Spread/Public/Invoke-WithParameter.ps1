function Invoke-WithParameter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock,

        [Parameter(ValueFromRemainingArguments = $true)]
        $Parameter
    )

    End {
        # Initialize empty instance of PSDefaultParameterValues
        $PSDefaultParameterValues = @{}
        # Add global PSDefaultParameterValues to local instance
        foreach ($Key in $global:PSDefaultParameterValues.Keys) {
            $PSDefaultParameterValues[$Key] = $global:PSDefaultParameterValues[$Key]
        }

        while ($Parameter) {
            # Spread & Shift
            $param, $value, $Parameter = $Parameter

            # Clean $param from `-` delim and support `Function:Param`
            $param = $param.trimStart("-").trimEnd(":")

            if ($param -notmatch ":") {
                $param = "*:" + $param
            }

            $PSDefaultParameterValues[$param] = $value
        }
        if ($DebugPreference -ne "SilentlyContinue") {
            $PSDefaultParameterValues | Out-Default
        }

        # Run ScriptBlock in same scope
        . $ScriptBlock
    }
}

Set-Alias -Name demux -Value Invoke-WithParameter
Set-Alias -Name spread -Value Invoke-WithParameter
