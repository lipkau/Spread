---
external help file: ConfluencePS-help.xml
online version:
locale: en-US
schema: 2.0.0
---

# About Spread
## about_Spread

# SHORT DESCRIPTION
This module implements helper functions that allow you to set parameters to a context. The parameters provided will be spread across the commands in the context.

# LONG DESCRIPTION
This module implements helper functions that allow you to set parameters to a context. The parameters provided will be spread across the commands in the context.


# EXAMPLES
```powershell
# Instead of:
Get-Service -ComputerName "srv1.corp.com"
Get-Process -ComputerName "srv1.corp.com"

# you can:
Invoke-WithParameter -ScriptBlock {
    Get-Service
    Get-Process
} -ComputerName "srv1.corp.com"
```

Description  
 -----------  
This enables the user to run a set of commands where common parameters only need to be provided once.

# NOTE


# TROUBLESHOOTING NOTE

# SEE ALSO

# KEYWORDS
