# Path to SetupCompleteTemplate.cmd, default is $env:WINDIR\CCM\SetupCompleteTemplate.cmd
$SetupCompleteTemplate = "$env:WINDIR\CCM\SetupCompleteTemplate.cmd"

# String to search for in $SetupCompleteTemplate to find where we should put our customizations
# Escape backslash (\) with another backslash (\\)
$TemplateSearchString = "\\TSMBootstrap.exe"

# Get the content of $SetupCompleteTemplate
$TemplateContent = Get-Content $SetupCompleteTemplate

# Get row number of $TemplateSearchString
$SearchStringRow = ($TemplateContent | Select-String "$TemplateSearchString")[0].LineNumber

# Get number of total rows in $TemplateContent
$TotalRows = $TemplateContent.Count

# Get the part of $TemplateContent that is before $TemplateSearchString
$FirstPart = $TemplateContent | Select-Object -First $($SearchStringRow-1)

# Get the part of $TemplateContent that is after $TemplateSearchString, including $TemplateSearchString
$LastPart = $TemplateContent | Select-Object -Index ($($SearchStringRow-1)..$TotalRows)

# Define the customization part to insert into $SetupCompleteTemplate
$CustomPart = (
"echo --- Running 802.1x Fixes ---",
"echo %DATE%-%TIME% `"Custom Configuration`" >> %WINDIR%\setupcomplete.log",
"echo %DATE%-%TIME% `"Disabling NetAdapters for 5 seconds`" >> %windir%\setupcomplete.log",
"echo Disabling NetAdapters for 5 seconds",
"powershell.exe -command `"`$NetAdapters = Get-NetAdapter -Physical | where {`$_.PhysicalMediaType -eq 802.3}`"",
"powershell.exe -command `"Disable-NetAdapter `$NetAdapters -Confirm:`$false -PassThru -Verbose`" >> %WINDIR%\setupcomplete.log",
"powershell.exe -command `"Start-Sleep 5`"",

"echo %DATE%-%TIME% `"Enabling NetAdapters and sleeping for 15 seconds`" >> %windir%\setupcomplete.log",
"echo Enabling NetAdapters and waits 15 seconds",
"powershell.exe -command `"Enable-NetAdapter `$NetAdapters -Confirm:`$false -PassThru -Verbose`" >> %WINDIR%\setupcomplete.log",
"powershell.exe -command `"Start-Sleep 15`"",

"echo %DATE%-%TIME% `"Restarting Wired Autoconfig Services`" >> %WINDIR%\setupcomplete.log",
"echo Restarting dot3svc and waits 15 seconds",
"powershell.exe -command `"Restart-Service dot3svc -PassThru -verbose`" >> %WINDIR%\setupcomplete.log",
"powershell.exe -command `"Start-Sleep 15`"",

"ipconfig >> %WINDIR%\setupcomplete.log",
"netsh lan show interfaces >> %WINDIR%\setupcomplete.log",
"netsh lan show Profiles >> %WINDIR%\setupcomplete.log",
"echo --- Done running 802.1x Fixes ---",
"echo Resuming Task Sequence",
""
)

# Modify $SetupCompleteTemplate with new content
Set-Content $SetupCompleteTemplate -Value $FirstPart,$CustomPart,$LastPart
