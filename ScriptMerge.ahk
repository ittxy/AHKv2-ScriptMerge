; #NoTrayIcon
; Updated ScriptMerge.ahk script for AHKv2.
; Original script used is located @ https://github.com/fujimogn/dotfiles/blob/master/os/cygwin/AutoHotkey/AutoHotkey/Lib/ScriptMerge.ahk
; Thanks to majkinetor for originally making the v1 version of this script
; https://autohotkey.com/board/topic/17049-script-functions-scriptmerge-092/

; Change the two variables below.
; scriptFilePath: Path to your script file with the #Includes directives
; UnjoinedScriptFilePath: Path to the joined script file to unjoin into individual files.
ScriptFilePath := "main.ahk" ; script is located within the running Script's directory.
JoinedScriptFilePath := "main-NoIncludes.ahk" ; This is a script that is going to be or was previously joined.

; Use or remove these hotkeys
; If removing hotkeys, to Join script files, uncomment these lines.
		; res := Join(ScriptFilePath, included)
		; FileAppend res, JoinedScriptFilePath
		; ExitApp
		; return
; To Unjoin Script Files, uncomment these lines
		; Unjoin(JoinedScriptFilePath, created)
		; ExitApp
		; return

F6::
res := Join(ScriptFilePath, included)
FileAppend res, JoinedScriptFilePath
ExitApp
return

F7::
Unjoin(JoinedScriptFilePath, created)
ExitApp
return

;--------------------------------------------------------------------------------------
; Function:		Join
;				Join AHK script includes into the single script	with no includes
;
; Parameters:
;		pFileName	-	File name that is to be recursively resolved of its dependencies.
;						It will be treated the same way as if the .ahk file was
;						started by double clicking on it. Includes that reference
;						to non-existing file names will be removed.
;
;		pInluded	-	Output, list of files that are included. Files that do not
;						exist will have the sentence "! REMOVED" after the file name.
;
; Returns:
;		AHK source without includes
;
; Notes:
;		Function doesn't handle AHK variables in #include, for instance:
;>		%A_ScriptDir%\Library.ahk
;
; Example:
;>		res := Join("MyScript.ahk", included)
;>		FileAppend %res%, MyScript-NoIncludes.ahk
;
Join( pFileName, ByRef pIncluded, firstCall := 1)
{
	static line := ";==================== X :B1AD529B-BF4E-477F-8B9F-3080CAC55AE3`n"
	static sDir, sDrive
	static re := "`aim)^[ \t]*#include[\t ,][ \t]*(?:\*i[ \t]+)?(.+?)(?:[ \t]*|(?:[ \t]+;.+)?)$"	;must use `a for the same reason as *t bellow. Only this combination worked on all files... ??!

	;first call
	if (firstCall)
	{
		SplitPath pFileName,,sDir,,,sDrive
		if (sDrive = "")
		{
			pFileName := A_ScriptDir "\" pFileName			; pFileName was relative
		}
		SplitPath pFileName,,sDir,,,sDrive					; Do it again with absolute name
		pIncluded := ""										; Clear include list as function expects it to be empty on start
	}

	;check if file exists
	if !FileExist(pFileName)
	{
		pIncluded .= pFileName  "  ! REMOVED" "`n"
		return
	}
	text := FileRead(pFileName, "`n")							; must use *t becuase some files have problems with new lines ?!

	j := 1
	Loop
	{
		j := RegExMatch(text, re, out, j)					; Try to find next include
		if (!j)
		{
			break
		}
		incPath := out[1]

		;convert relative paths to absolute
		SplitPath incPath, ,,,,drive
		if (drive = "")
		{
			if (chr(&incPath)="\")
			{
				incPath := sDrive . incPath
			}
			else
			{
				incPath := sDir . "\" . incPath
			}
		}

	;check is it dir
	attrib := FileGetAttrib(incPath)
	if InStr(attrib, "D")
		{
			sDir := incPath
			SplitPath incPath ,,,,,sDrive
			rep  := RegExReplace(line,"X", "START DIR: " out[0]) . "`n" . RegExReplace(line, "X", "END DIR: " out[0])
			text := RegExReplace(text, re, rep, cnt, 1, j)	; Delete dir switch include
			j += StrLen(out[0])									; Don't delete it, but leave it, and skip it
			continue
		}

	;is it already included ?
	if !InStr( pIncluded, out[1])
	{
		pIncluded .= out[1] "`n"
		rep := RegExReplace(line,"X", "START: " out[0])
				. Join( incPath, pIncluded, false) . "`n"
				. RegExReplace(line,"X", "END: " out[0])
		}
		else
		{
			rep := ""
		}
		rep  := RegExReplace(rep, "[$]", "$$$$", dolarCount)	; Problem in replacement with $ replacement metachar
		text := RegExReplace(text, re, rep, cnt, 1, j)
		j += StrLen(rep) - dolarCount
	}
	return text
}

;--------------------------------------------------------------------------------------
; Function:		Unjoin
;				Recreate original file system heerarchy of Joined script file.
;
; Parameters:
;		pFileName	-	File name that is product of Join function.
;						It will be scanned for Join related data and original
;						file system hierarchy will be created, recursively.
;
;		pCreated	-   Output, list of files that are created.
;
; Returns:
;		AHK source with original includes.
;       Creates file system hierarchy of original source file
;
; Example:
;>      Unjoin("MyScript-NoInc.ahk", created, text)
;>		FileAppend %text%, MyScript.ahk
;--------------------------------------------------------------------------------------

Unjoin( pFileName, ByRef pCreated, firstCall := 1 )
{
	static reS := ";=+[ ]START([ ]DIR)?[:][ ]([ \t]*#include[\t ,][ \t]*(?:\*i[ \t]+)?(.+?)(?:[ \t]*|(?: [ \t]*;.+?)?)):B1AD529B-BF4E-477F-8B9F-3080CAC55AE3"
	static reE := ";=+[ ]END(?:\1)?[:][ ]\2:B1AD529B-BF4E-477F-8B9F-3080CAC55AE3`n"
	static sDir
	re := "`ais)" reS "\R(.+?)\R" reE

	if (firstCall)
	{
		SplitPath pFileName,,sDir,,,sDrive
		if (sDrive = "")
		{
			pFileName := A_ScriptDir . "\" . pFileName		; pFileName was relative
		}
		SplitPath pFileName,,sDir,,,sDrive
		text := FileRead(pFileName,"`n")
		firstCall := false
	}
	else
	{
		text := pFileName				; first parameter is used internaly after first call
	}

	j := 1
	Loop
	{
		j := RegExMatch(text, re, out, j)			; find file
		if (!j)
		{
			break
		}
		incPath := out[3]

	;is it the dir switch include
	if (out[1] = " DIR")
	{
		SplitPath incPath,,,,,drive
		if (drive = "")
		{
			if (chr(&incPath)="\")
			{
				SplitPath A_ScriptDir,,,,,drive
				sDir := drive . incPath
			}
			else
			{
				sDir := sDir . "\" . incPath
			}
			text := RegExReplace(text, re, "$2", cnt, 1, j)
			DirCreate sDir
			continue
		}
	}

	;create dir's
	SplitPath incPath,,incDir
	DirCreate sDir . "\" . incDir
	;create file
	FileAppend out[4], sDir . "\" . incPath
	pCreated .=  incPath . "`n"
	;remove from the source
	text := RegExReplace(text, re, "$2", cnt, 1, j)
	}
	return text
}
