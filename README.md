# AHKv2-ScriptMerge
Merge multiple AHKv1/v2 script files into one single script. Original script used to update is located here: https://github.com/fujimogn/dotfiles/blob/master/os/cygwin/AutoHotkey/AutoHotkey/Lib/ScriptMerge.ahk

Thanks to majkinetor for originally making the v1 version of this script: https://autohotkey.com/board/topic/17049-script-functions-scriptmerge-092/

# Script variables
`ScriptFilePath:` The script that contains your #Include directives.

`JoinedScriptFilePath:` This is a script that is going to be or was previously joined.

# To Join a script file
Add the `#Include PathToYourOtherScript.ahk` directives to your main script. Add one `#Include` line for each script file. Replace `ScriptFilePath` and `JoinedScriptFilePath` variable values with the path to your script and press the `F6` key to join the script. You can change the hotkey by simply typing in a different hotkey.

For example, to use the `j` key to join a script, change `F6`:
```
F6::
res := Join(ScriptFilePath, included)
FileAppend res, JoinedScriptFilePath
ExitApp
return
```

To `j`:

```
j::
res := Join(ScriptFilePath, included)
FileAppend res, JoinedScriptFilePath
ExitApp
return
```
A new joined script file without the #Include directives will be generated with the name you defined for `JoinedScriptFilePath` into the current directory of the running script.

# To Unjoin a script file
Replace `JoinedScriptFilePath` variable value with the path to your joined script and press the `F7` key to unjoin the script. You can change the hotkey by simply typing in a different hotkey.
```
F7::
Unjoin(JoinedScriptFilePath, created)
ExitApp
return
```
All #Include directive scripts will return to their original directories and single .ahk files. If you had your main script that had the lines:
```
#Include hotkeys\1.ahk
#Include hotkeys\2.ahk
```
running `Unjoin` will put them into their respective directory, `hotkeys\1.ahk` and `hotkeys\2.ahk`.
