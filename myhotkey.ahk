;;TODO improve singleton process and support window title jump.

; lnk file's parameter can not be passed.
; replace delete key in file_manager group to use my trash script
; Plato Wu,2009/04/21: _ can not be used in group name.
GroupAdd file_manager, ahk_class TTOTAL_CMD ; total commander
GroupAdd file_manager, ahk_class ExploreWClass ; explorer
GroupAdd file_manager, ahk_class Progman ;desktop
GroupAdd file_manager, ahk_class TxUNCOM ; Unreal Commander

; Do not enable emacs-binding in no_emacs group for they have had emacs-binding
GroupAdd no_emacs, ahk_class PuTTY
GroupAdd no_emacs, ahk_class KiTTY
GroupAdd no_emacs, ahk_class TSSHELLWND ; Remote Desktop
GroupAdd no_emacs, ahk_class Emacs ; Emacs W32
; Plato Wu, 2009/4/28, try to not use firemace.
; GroupAdd no_emacs, ahk_class MozillaUIWindowClass ; Mozilla Firefox
GroupAdd no_emacs, ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8} ; foobar
; rxvt use different windows class in diffrent machine like 
GroupAdd no_emacs, MINGW32
GroupAdd no_emacs, DrScheme
GroupAdd no_emacs, ARM - Multi-ICE Server ; I need C-r shortkey of it.
GroupAdd no_emacs, ahk_class VNCMDI_Window ; UltraVNC
GroupAdd no_emacs, ahk_class mintty 
GroupAdd no_emacs, ahk_class VNCviewer ;TightVNC
GroupAdd no_emacs, ahk_class cygwin/xfree86 ; NX Client
GroupAdd no_emacs, ahk_class Emacs ;Emacs W32
GroupAdd no_emacs, NX ; NX Client

;GroupAdd no_emacs, ahk_class cygwin/x ; Xming

DetectHiddenWindows, On
AllowMulteInstance=Totalcmd.exe|cygwin.exe

; Plato Wu,2009/05/29: C_x keys are inputed into password edit of QQ with
; no reason, I don't know why.
C_x_prefix = 0
; Plato Wu,2009/05/22: This sentence is prerequisite!
Hotkey, IfWinActive

; Plato Wu,2009/05/22: the $ prefix is needed so that the hotkey can "send itself" 
; without activating itself (which would otherwise trigger a warning dialog 
; about an infinite loop;
Hotkey, $h, h_hotkey
Hotkey, $u, u_hotkey

clipboard_index = 0

CoordMode Caret, Screen ; Affects the built-in variables A_CaretX and A_CaretY
                        ; using screen coordinate. Caret is text insertion point
CoordMode Mouse, Screen ; Let MouseMove use screen coordinate

;;;;;;;;;;;;;;;;;;;;;;;; Merge from 320MPH
AutoTrim, Off

SetBatchLines, -1

MainWnd = Launchy & XKeymacs -- Rajat, Plato Wu

GroupAdd, 320MPH, ahk_class AutoHotkeyGUI
GroupAdd, 320MPH_no_emacs, ahk_group 320MPH
GroupAdd, 320MPH_no_emacs, ahk_group no_emacs

SetKeyDelay, 0

;___________________________________________

IniFile = %A_ScriptDir%\320MPH.ini
; Plato Wu,2009/05/20: detract UsedList from ini file to used list file
UsedListFile = %A_ScriptDir%\UsedList.txt

IfNotExist, %IniFile%

{

	MsgBox,, 320MPH, 320MPH.ini not found. Program will now exit

	ExitApp

}

;Reading Settings

IniRead, PathList, %IniFile%, Settings, PathList, %A_MyDocuments%|%A_ProgramFiles%

IniRead, TypeList, %IniFile%, Settings, TypeList, exe|lnk|ahk|url|mp3

IniRead, ExcludeList, %IniFile%, Settings, ExcludeList, about|history|readme|remove|uninstall|license

IniRead, AlwaysScan, %IniFile%, Settings, AlwaysScan, %UserProfile%\Recent|%A_StartMenuCommon%|%A_StartMenu%|%A_Desktop%

IniRead, MaxLastUsed, %IniFile%, Settings, MaxLastUsed, 50

IniRead, WaitTime, %IniFile%, Settings, WaitTime, 100

IniRead, ShowIcons, %IniFile%, Settings, ShowIcons, 1

IniRead, MinLen, %IniFile%, Settings, MinLen, 2

IniRead, ListFile, %IniFile%, Settings, ListFile, RunList.txt

IniRead, ShellIntegration, %IniFile%, Settings, ShellIntegration, 1

IniRead, GuiWMinus, %IniFile%, Settings, GuiWMinus, 20

IniRead, GuiHMinus, %IniFile%, Settings, GuiHMinus, 250

IniRead, Dict, %IniFile%, Settings, Dict, D:\Tools\GoldenDict\GoldenDict.exe

IniRead, DictClass, %IniFile%, Settings, DictClass, QWidget

IniRead, DictTitle, %IniFile%, Settings, DictTitle, GoldenDict

; Plato Wu,2009/05/20: it seems LastUsedList is useless

;IniRead, UsedList, %IniFile%, Settings, UsedList, |

;LastUsedList = %UsedList%

GuiW := A_ScreenWidth - GuiWMinus

GuiH := A_ScreenHeight - GuiHMinus

AlwaysScan := ExpandVars(AlwaysScan)

PathList := ExpandVars(PathList)

StringRight, ExtChk, A_ScriptFullPath, 4

IfEqual, ExtChk, .exe

IfEqual, ShellIntegration, 1

{

	RegWrite, REG_SZ, HKCR, *\Shell\320MPH\Command,, "%A_ScriptFullPath%" "`%1"

	RegWrite, REG_SZ, HKCR, Folder\shell\320MPH\command,, "%A_ScriptFullPath%" "`%1"

}

Else

{

	RegDelete, HKCR, *\Shell\320MPH,

	RegDelete, HKCR, Folder\Shell\320MPH,

}

RParam = %1%

;IniRead, UsedList, %IniFile%, Settings, UsedList
FileRead, UsedList, %UsedListFile%

IfEqual, UsedList, ERROR
	UsedList =

UsedList0 =

Loop, Parse, UsedList, |
{
	IfNotExist, %A_LoopField%, Continue
	UsedList0 = %UsedList0%|%A_LoopField%
}

UsedList = %UsedList0%

;___________________________________________

;create scanned result list on first run

IfExist, %A_ScriptDir%\%ListFile%
{
	ItemList =
	Loop, Read, %A_ScriptDir%\%ListFile%
	{
		IfEqual, A_LoopReadLine,, Continue
		ItemList = %ItemList%|%A_LoopReadLine%
	}
}
Else
	Gosub, ButtonScan

;scan always updated list

Loop, Parse, AlwaysScan, |
{
	Loop, %A_LoopField%\*.*, 0, 1
	{
		SplitPath, A_LoopFileFullPath, FName, FDir, FExt, FNameNoExt, FDrive
		;only filetypes defined are added
		IfNotInString, TypeList, %FExt%, Continue
		;excluding items based on ExcludeList
		Cont = 0
		Loop, Parse, ExcludeList, |
		{
			IfInString, FName, %A_LoopField%
			{
				Cont = 1
				Break
			}
		}
		IfEqual, Cont, 1
			Continue

		;reaching here means that file is not to be excluded and
		;has a desired extension
		RecentList = %RecentList%|%A_LoopFileFullPath%
	}
}

StringTrimLeft, RecentList, RecentList, 1

ItemList = %RecentList%%ItemList%

LVGuiW := GuiW - 12

LVGuiH := GuiH - 64

StatusY := GuiH - 25

;Plato Wu, 2009/5/8, Remarks for nice appearance for me and
; let it can be moved 
;Gui, -Caption +Border

Gui, Add, Text, x6 y7 w40 h20, Search:

Gui, Add, Edit, x46 y5 w100 h20 vCurrText gGetText,

Gui, Add, Text, x160 y7 w40 h20, Params:

Gui, Add, Edit, x210 y5 w100 h20 vRParam, %RParam%

Gui, Add, ListView, x6 y35 w%LVGuiW% h%LVGuiH% vSelItem HScroll gSelection AltSubmit, Name|Ext|Folder

Gui, Add, Button, 0x8000 x326 y5 w40 h20 Default, &Open

Gui, Add, Button, 0x8000 x376 y5 w40 h20, &Scan

Gui, Add, Text, x6 y%StatusY% w120 h20 vResults,

Gui, Font, S10 CDefault Italic Bold, Verdana

Gui, Add, Text, x450 y%StatusY% w150 h20 Right, %MainWnd%

LV_ModifyCol(1, 100)

LV_ModifyCol(2, 60)

LV_ModifyCol(3, 250)

;Plato Wu, 2009/5/7, It runs background now
;Gui, Show, h%GuiH% w%GuiW%, %MainWnd%

LastText = fadsfSDFDFasdFdfsadfsadFDSFDf

;SetTimer, GetText, 200

Gosub, GetText

;Sleep, 200

Control, Choose, 1, SysListView321, %MainWnd%

; Plato Wu,2009/05/31: Flag for up/down in file browser mode
FileBrowseUpDown =

;;;;;;;;;;;;;;;;;;;;;;;; 

;Plato Wu,2009/05/21: view-lookup-dict-mode
GroupAdd, dict, ahk_class %DictClass%

;#32770
lookup_mode = 0
lookup_hotkey = 0
alphabet="abcdefghijklmnopqrstuvwxyz"
;view_class =
view_title =
old_view_title =

return ; End of autoexecute section.

; Plato Wu,2009/12/08: Add IME control function
IME_ON(hWindow, IsON)
{
	; WM_IME_CONTROL    = 0x0283 
	; IMC_SETOPENSTATUS = 0x0006 
	bufCurrentDetectMode := A_DetectHiddenWindows
	DetectHiddenWindows, On 
	buf := DllCall("user32.dll\SendMessageA", "UInt", DllCall("imm32.dll\ImmGetDefaultIMEWnd", "Uint",hWindow), "UInt", 0x0283, "Int", 0x0006, "Int", IsON) 
	DetectHiddenWindows, %bufCurrentDetectMode%
	Return buf
}


#c::
Send ^c
Run Notepad
WinWait ahk_class Notepad ;
Send ^v
return

#IfWinActive ahk_group file_manager
^d::
Delete::
Send {AppsKey}M{Enter}
MouseMove A_CaretX,A_CaretY
MouseGetPos, , , , control
;ToolTip,Control %listitems%
; When Caret is in Edit of file_manager, Send Delete key still
if InStr(control, "Edit") or InStr(control, "TMyPanel9") or InStr(control, "TMyPanel5") 
{
  Send {Click}{Delete}
}
;else
;{
  ;call movetotrash function  
 ; Send M{Enter}
;}

return
#z::
WinGetTitle, Title, A
MsgBox, The active window is "%Title%".
;WinGetClass, class, A
;MsgBox, The active window's class is "%class%".
return

; Plato Wu,2009/05/31: ^p & ^n need special handle in 320MPH_no_emacs
#ifWinNotActive ahk_group 320MPH_no_emacs
^p:: Send {Up}
^n:: Send {Down}
#ifWinNotActive ahk_group no_emacs
^f:: Send {Right}
^b:: Send {Left}
^v:: Send {PgDn}
!v:: Send {PgUp}
^w:: 
Send ^x
ClipWait
if clipboard_index > 20
  clipboard_index = 0
Array%clipboard_index% := clipboard
;element := Array%clipboard_index%
clipboard_index ++
return
!w:: 
Send ^c
ClipWait
if clipboard_index > 20
  clipboard_index = 0
Array%clipboard_index% := clipboard
;;element := Array%clipboard_index%
clipboard_index ++
return
^y:: 
; Plato Wu,2009/12/31: add killed text into kill ring if it is not copyed by quick key.
if clipboard_index > 0
{
   clipboard_index --
   element := Array%clipboard_index%
   clipboard_index ++
 ;    MsgBox, %element%
  ;   MsgBox, %clipboard%
   IfNotInString, element, %clipboard% 
   {
;     MsgBox, %element%
;     MsgBox, %clipboard%
      Array%clipboard_index% := clipboard      
      clipboard_index ++
   }
}
Send ^v
return
!y::
If clipboard_index > 0
{
  ; discard previous paste result
  Send ^z
  clipboard_index --
  clipboard_index --
  ; Plato Wu,2009/04/21: Since %Array%clipboard_index%% is illegal
  element := Array%clipboard_index%
  clipboard = %element%
  Send ^v
}
return
^d:: Send {Delete}
^a:: Send {Home}
^e:: Send {End}
^g:: Send {Escape}
^k:: Send +{End}^x
^o:: Send {Return}{Left}
!<:: Send ^{Home}
!>:: Send ^{End}
^x:: C_x_prefix = 1
; Plato Wu,2012/12/10: there is 1 in QQ password and it is input initially and this script will cause send 1 again.
; 1::
; If C_x_prefix = 1
; {
; ;   WinRestore, A
; ;   WinMaximize, A
;   WinMove, A,,0,0,A_ScreenWidth, A_ScreenHeight
;    C_x_prefix = 0
; }Else
; {  
;    Send 1
; }
; return
2::
If C_x_prefix = 1
{
;   WinGetPos,,, Width, Height, A
;   MsgBox, %Width%,%Height%
   WinMove, A,,0,A_ScreenHeight/2,A_ScreenWidth, A_ScreenHeight/2

   C_x_prefix = 0
}Else
{  
   Send 2
}
return
; Plato Wu,2009/05/22: use hotkey function instead double colon label which can not
; be disable by hotkey function
h_hotkey:
If C_x_prefix = 1
{
   Send ^a
   C_x_prefix = 0
}Else
{  
   GetKeyState, state, CapsLock, T 
   if state = D
      Send H
   else
      Send h
}
return
u_hotkey:
If C_x_prefix = 1
{
   Send ^z
   C_x_prefix = 0
}Else
{
   GetKeyState, state, CapsLock, T 
   if state = D
      Send U
   else
      Send u
}
return
^r:: Send ^f!u!n 
^s::
If C_x_prefix = 1
{
   Send ^s
   C_x_prefix = 0
}Else
{
   Send ^f
   if WinActive ahk_class Notepad
     Send !d!n
}
return
;Suspend or Resume hotkeys 
^q::Suspend
;Reload script
^!r::Reload
;;;;;;;;;;;;;;;;;;;;;;;; Merge from 320MPH
#IfWinActive
;Plato Wu, 2009/5/7, Use Alt+Space to invoke GUI and hide GUI, just like launchy
!Space::
IfWinNotActive, %MainWnd%,
{

  Gui, Show, h%GuiH% w%GuiW%, %MainWnd%
  ; Plato Wu,2009/05/20: make edit initial as insertion mode
  ControlFocus, Edit1, %MainWnd%
  ; Plato Wu,2010/03/01: it does not work with AHKL,use shift down/up instead.
  ; Plato Wu,2010/03/05: now I don't use AHKL
  ControlSend Edit1, +^a, %MainWnd%
;  ControlSend Edit1, {Shift Down}{HOME}{Shift Up}, %MainWnd%
  ; Plato Wu,2009/06/30: Disable Chinese input method which can muss shift key state.
  ; Sleep, 1000
  ; ControlSend Edit1, ^+0, %MainWnd%
   ControlGet, hWindow, Hwnd 
   ; Plato Wu,2009/12/08: Disable IME
   IME_ON(%hWindow%, 0)
  return
}
;ToolTip
Gui, Submit, %MainWnd%
return
#IfWinActive ahk_group 320MPH
;Launchy & XKeymacs binding-- Rajat, Plato Wu
AutoComplete:
	; Plato Wu,2009/05/30: Auto complete input by first item
	IfInstring, CurrText, \
	{
	SelItem := LV_GetNext()
;        MsgBox %SelItem%	
   	LV_GetText(FName, SelItem, 1)
; ;	LV_GetText(FExt, SelItem, 2)
        LV_GetText(FPath, SelItem, 3)
;	MsgBox, %FName%
	FileBrowseUpDown = 1
        ControlSetText, Edit1, %FPath%\%FName%, %MainWnd%
	ControlSend, Edit1, {End}, %MainWnd%
	}

return
; Plato Wu,2009/07/01: \
\::
Send,{Left}{Right}\
;Send,
;Send,\
return
; Plato Wu,2009/06/23: Delete and BackSpace should enable FileBrowseUpDown
~Delete::
FileBrowseUpDown = 1
return
~Backspace::
FileBrowseUpDown = 1
return
^p::
Up::
	IfWinNotActive, %MainWnd%,
	{
		Send, {Up}
		Return
	}

	ControlGetFocus, CurrCtrl, %MainWnd%
	IfEqual, CurrCtrl, Edit1
	{
     	  ControlSend, SysListView321, {Up}, %MainWnd%
	  Goto, AutoComplete
	}
Return
^n::
Down::
	IfWinNotActive, %MainWnd%,
	{
		Send, {Down}
		Return
	}

	ControlGetFocus, CurrCtrl, %MainWnd%
	IfEqual, CurrCtrl, Edit1
	{
	  ControlSend, SysListView321, {Down}, %MainWnd%
          Goto, AutoComplete
        }

Return

^Del::

	IfWinNotActive, %MainWnd%,, Return

	ControlGetText, CurrText, Edit1, %MainWnd%

	IfNotEqual, CurrText,, Return

	SelItem := LV_GetNext()

	LV_GetText(FName, SelItem, 1)

	LV_GetText(FExt, SelItem, 2)

	LV_GetText(FDir, SelItem, 3)

	IfEqual, FExt,

		Pth = %FDir%\%FName%

	IfNotEqual, FExt,

		Pth = %FDir%\%FName%.%FExt%

	StringReplace, UsedList, UsedList, |%pth%,, A

	;IniWrite, %UsedList%, %IniFile%, Settings, UsedList
	FileAppend, %UsedList%, %UsedListFile%

	LastText = x

	Goto, GetText

Return

GetWindowsByStyle(p_style,p_delim="|")
{
  WinGet, l_array, List
  Loop, %l_array%
  {
    WinGet, l_tmp, Style, % "ahk_id " l_array%A_Index%
    If (l_tmp & p_style)
    {
      WinGetTitle, l_tmp, % "ahk_id " l_array%A_Index%
      IfEqual, l_tmp
         Continue
      l_out .= ( l_out="" ? "" : p_delim ) l_tmp
    }
  }
  Return l_out
}

;RetriveAllWindows(WinTitle)
; Plato Wu,2010/01/27
RetriveAllWindows:
{

WS_VISIBLE := 0x10000000
;delim := "`r`n"

;MsgBox % GetWindowsByStyle(WS_VISIBLE,delim)

; ControlGet, hwnd, hwnd, , ToolbarWindow322, ahk_class Shell_TrayWnd
; Acc := COM_AccessibleObjectFromWindow(hwnd)
; Loop, % Acc.accChildCount
; {
;         Title := Acc.accName(A_Index)
;         If CurrText !=
;         {
;               	; StringLen, Len, CurrText
;          	; StringLeft, LText, Title, %Len%
; 		;Matching leftmost text
; 		;;IfNotEqual, LText, %CurrText%
;                 IfNotInString, Title, %CurrText%
;                    Continue
;          }
;          IfWinNotExist, %Title%
;             Continue

;          Count ++
;     WinGet, wid, id, Title
; ;;    MsgBox, %wid%
;     SendMessage, 0x7F, 2, 0,, ahk_id %wid%
;     h_icon := ErrorLevel
;       If ( ! h_icon )
;         {
;         SendMessage, 0x7F, 0, 0,, ahk_id %wid%
;         h_icon := ErrorLevel
;         If ( ! h_icon )
;           {
;           ; If Use_Large_Icons_Current =1
;           ;   h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 ) ; GCL_HICON is -14
;           If ( ! h_icon )
;             {
;             h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 ) ; GCL_HICONSM is -34
;               If ( ! h_icon )
;                 h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 ) ; IDI_APPLICATION is 32512
;             }
;           }
;         }

;                     DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, h_icon)
;                     DllCall("DestroyIcon", Uint, h_icon)
;                    LV_Add("Icon" count, Title)

         
; ;        MsgBox, %Title%
; }
  ;  list .= WinExist(WinTitle:=Acc.accName(A_Index)) ? WinTitle "`n" : ""
  ; MsgBox, % SubStr( list, 1, -1 )

     WinGet, UsedList0, List
;     MsgBox, %CurrText%
;     Count = 1
     Loop, %UsedList0%
               {
                     wid := UsedList0%A_Index%

                     WinGetTitle, Title, ahk_id %wid%
                     If CurrText !=
                     {
                     	; StringLen, Len, CurrText
                                        
			; StringLeft, LText, Title, %Len%

			;Matching leftmost text
                        
			;;IfNotEqual, LText, %CurrText%
                        IfNotInString, Title, %CurrText%
                            Continue
   
                     }
                     If Title = ; skip windows with no title - e.g. popup windows
                       Continue
                     ; WinGetClass, Win_Class, ahk_id %wid%
                     ;   If ( ! ( Win_Class ="#32770" ) )
                     ;      Continue
                     WinGet, Style, Style, ahk_id %wid%
                     If Style & WS_VISIBLE = 0
                         Continue
;                      WinGet, MinMax, MinMax, ahk_id %wid%
;                      MsgBox, %MinMax%
;                      if MinMax =
;                         Continue
;
;                      if MinMax = 0
;                         Continue
                    Count ++
;                   hIcon := DllCall("Shell32\ExtractAssociatedIconA", UInt, 0, Str, A_LoopFileLongPath, UShortP, iIndex)
;                    SendMessage, 0x7F, 1, 0,, ahk_id %wid%
;                    MsgBox, %ErrorLevel%
;                    h_Icon := ErrorLevel
    SendMessage, 0x7F, 2, 0,, ahk_id %wid%
    h_icon := ErrorLevel
      If ( ! h_icon )
        {
        SendMessage, 0x7F, 0, 0,, ahk_id %wid%
        h_icon := ErrorLevel
        If ( ! h_icon )
          {
          ; If Use_Large_Icons_Current =1
          ;   h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 ) ; GCL_HICON is -14
          If ( ! h_icon )
            {
            h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 ) ; GCL_HICONSM is -34
              If ( ! h_icon )
                h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 ) ; IDI_APPLICATION is 32512
            }
          }
        }

                    DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, h_icon)
                    DllCall("DestroyIcon", Uint, h_icon)
                   LV_Add("Icon" count, Title)

               }

}
GetText:

	ControlGetText, CurrText, Edit1, %MainWnd%

	IfEqual, CurrText, %LastText%, Return

	StringLen, Check, CurrText

	IfGreater, Check, 0

	IfLess, Check, %MinLen%

		Return

	LastText = %CurrText%

	;from last used_____________________________

	IfEqual, CurrText,

	{

		IfEqual, ShowIcons, 1

		{

			IL_Destroy(ImageListID1)

			; Create an ImageList so that the ListView can display some icons:

			ImageListID1 := IL_Create(5, 10)		

			; Attach the ImageLists to the ListView so that it can later display the icons:

			LV_SetImageList(ImageListID1)

		}

		LV_Delete()

		Count =

;                RetriveAllWindows("")
;                 WinTitle =
                 Gosub, RetriveAllWindows

		 StringTrimLeft, UsedList0, UsedList, 1

		 Loop, Parse, UsedList0, |

		 {

		 	;check for change in search querry

		 	ControlGetText, CurrText, Edit1, %MainWnd%

		 	IfNotEqual, CurrText, %LastText%, Goto, GetText

		 	SplitPath, A_LoopField, FName, FDir, FExt, FNameNoExt

		 	Count ++

		 	IfGreater, Count, %MaxLastUsed%, Break

		 	IfEqual, ShowIcons, 1

		 	{

		 		hIcon := DllCall("Shell32\ExtractAssociatedIconA", UInt, 0, Str, A_LoopField, UShortP, iIndex)

		 		DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, hIcon)

		 		DllCall("DestroyIcon", Uint, hIcon)

		 	}

		 	LV_Add("Icon" Count, FNameNoExt, FExt, FDir )

		 	;select first item

		 	IfEqual, A_Index, 1

		 		ControlSend, SysListView321, {Down}, %MainWnd%

		 }

	}

	;from all items_____________________________
	; Plato Wu,2009/05/30: Add file browser function
        IfInstring, CurrText, \
	{
;	  MsgBox, %CurrText%
          ; Plato Wu,2009/06/30: sleep until CurrText is clear.
	  sleep, 500
	  IfEqual, FileBrowseUpDown,
          {
	    LV_Delete()
            IL_Destroy(ImageListID1)
            ; Create an ImageList so that the ListView can display some icons:
            ImageListID1 := IL_Create(10, 20)		
            ; Attach the ImageLists to the ListView so that it can later display the icons
	    LV_SetImageList(ImageListID1)

            Count =
            Loop, %CurrText%*.*, 1, 0
            {
	;     MsgBox %A_LoopFileAttrib%,%A_LoopFileName%,%A_LoopFileExt%
;	      IfNotInString, TypeList, %A_LoopFileExt%, Continue
              IfEqual, A_LoopFileExt,
	      {
	        IfNotInString, A_LoopFileAttrib, D
	        Continue
              }
  	      SplitPath, A_LoopFileName,,,,FileName
              hIcon := DllCall("Shell32\ExtractAssociatedIconA", UInt, 0, Str, A_LoopFileLongPath, UShortP, iIndex)
              DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, hIcon)
              DllCall("DestroyIcon", Uint, hIcon)
	      Count ++
	      LV_Add("Icon" Count, FileName, A_LoopFileExt, A_LoopFileDir)
    	    }

 	;  ControlSetText, Edit1, %CurrText%%FName%, %MainWnd%
   	LV_GetText(FName, 1, 1)
; ;	LV_GetText(FExt, SelItem, 2)
        LV_GetText(FPath, 1, 3)
        IfNotEqual, FName,
	{
	  Length := StrLen(CurrText)
          ControlSetText, Edit1, %FPath%\%FName%, %MainWnd%
	  ControlSend, Edit1, {Right %Length%}, %MainWnd%
	  ControlSend, Edit1, +{End}, %MainWnd%
;          ControlSend, Edit1, {End}, %MainWnd%
	}
	}else{
                FileBrowseUpDown =
	}
	}else IfNotEqual, CurrText,
	{
                FileBrowseUpDown =
               ; Plato Wu,2009/07/13: It seems this sentence is useless, for we actually
               ; use SearchList.
;		IfInString, ItemList, %CurrText%
			IfEqual, ShowIcons, 1
			{



				IL_Destroy(ImageListID1)

				; Create an ImageList so that the ListView can display some icons:

				ImageListID1 := IL_Create(20, 50)		

				; Attach the ImageLists to the ListView so that it can later display the icons:

				LV_SetImageList(ImageListID1)

			}

		LV_Delete()

		;___________________________________________

		; Advanced Search

		MatchPList1 =

		MatchPList2 =

		MatchPList3 =

		Count =		

;                RetriveAllWindows(CurrText)
                 Gosub, RetriveAllWindows


		;earliest in searh results are recently used items

		; Plato Wu,2009/07/13: The last item in UsedList does not has | separator
		SearchList = %UsedList%|%ItemList%

		Loop, Parse, SearchList, |

		{

			;check for change in search querry

			ControlGetText, CurrText, Edit1, %MainWnd%

			IfNotEqual, CurrText, %LastText%, Goto, GetText

			CurrItem = %A_LoopField%

			;remove duplicate entry that exists both in usedlist and itemlist

			CheckList = %MatchPList1%%MatchPList2%%MatchPList3%|

			IfInString, CheckList, |%CurrItem%|, Continue

			SplitPath, CurrItem, FName, FDir, FExt, FNameNoExt, FDrive

			StringLen, Len, CurrText

			StringLeft, LText, FName, %Len%

			;Matching leftmost text
                        
			IfEqual, LText, %CurrText%

			{
                                MatchPList1 = %MatchPList1%|%CurrItem%
				Continue

			}

			;Matching file name only

			;fuzzy search

			MatchFound = Y

			Loop, Parse, CurrText, %A_Space%

				IfNotInString, FName, %A_LoopField%

					MatchFound = N

			IfEqual, MatchFound, Y

			{

				MatchPList2 = %MatchPList2%|%CurrItem%
				Continue

			}

			;search everywhere

			;fuzzy search

			MatchFound = Y

			Loop, Parse, CurrText, %A_Space%

				IfNotInString, CurrItem, %A_LoopField%

					MatchFound = N

			IfEqual, MatchFound, Y

			{

				MatchPList3 = %MatchPList3%|%CurrItem%
				Continue

			}

		}

		MatchPList = %MatchPList1%%MatchPList2%%MatchPList3%

		StringTrimLeft, MatchPList, MatchPList, 1

		Loop, Parse, MatchPList, |

		{

			;check for change in search querry

			ControlGetText, CurrText, Edit1, %MainWnd%

			IfNotEqual, CurrText, %LastText%, Goto, GetText

			Count ++

			SplitPath, A_LoopField, FName, FDir, FExt, FNameNoExt, FDrive

			IfEqual, ShowIcons, 1

			{

				hIcon := DllCall("Shell32\ExtractAssociatedIconA", UInt, 0, Str, A_LoopField, UShortP, iIndex)

				DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, hIcon)

				DllCall("DestroyIcon", Uint, hIcon)

			}

			LV_Add("Icon" Count, FNameNoExt, FExt, FDir )

			;select first item

			IfEqual, A_Index, 1

				ControlSend, SysListView321, {Down}, %MainWnd%

		}

		IfEqual, Count,

			LV_Delete()

	}

	;post results		

	Results := LV_GetCount() 

	GuiControl,, Results, Results = %Results%

	LV_ModifyCol()


Return

ButtonScan:

	SplashImage,, W190 H30 B1,, Scanning..,

	FileDelete, %A_ScriptDir%\%ListFile%

	;generating file list	

	Loop, Parse, PathList, |

	{

		IfNotExist, %A_LoopField%, Continue

		Loop, %A_LoopField%\*.*, 0, 1

		{

			SplitPath, A_LoopFileFullPath, FName, FDir, FExt, FNameNoExt, FDrive

			;only filetypes defined are added

			IfNotInString, TypeList, %FExt%, Continue

			;excluding items based on ExcludeList

			Cont = 0

			Loop, Parse, ExcludeList, |

			{

				IfInString, FName, %A_LoopField%

				{

					Cont = 1

					Break

				}

			}

			IfEqual, Cont, 1

				Continue

			;reaching here means that file is not to be excluded and

			;has a desired extension

			FileAppend, %A_LoopFileFullPath%`n, %A_ScriptDir%\%ListFile%

		}

	}

	ItemList =

	Loop, Read, %A_ScriptDir%\%ListFile%

	{

		IfEqual, A_LoopReadLine,, Continue

		ItemList = %ItemList%|%A_LoopReadLine%

	}

	ItemList = %RecentList%%ItemList%

	LastText =

	SplashImage, Off

Return

ButtonOpen:

	Gui, Submit, NoHide

	GetKeyState, ShKey, Shift

	GetKeyState, CtKey, Control

	ControlFocus, SysListView321, %MainWnd%

	SelItem := LV_GetNext()

	IfEqual, SelItem, 0

		RunSearch = 1

	IfEqual, CtKey, D

		RunSearch = 1

        ; Plato Wu,2009/05/30: when input is empty, select the first item
        If CurrText=
        {
	        RunSearch = 0
		IfEqual, SelItem, 0
		  SelItem = 1
	}
           
	IfEqual, RunSearch, 1

	{

		RunItem = %CurrText%

		;run unrecognised cmd

		IfNotExist, %CurrText%

		{

			FileExist = 0

			Goto, AddToList

		}

	}

	;running a found file/folder

	IfNotEqual, RunSearch, 1

	Loop

	{

		LV_GetText(FName, SelItem, 1)

		LV_GetText(FExt, SelItem, 2)

		LV_GetText(FDir, SelItem, 3)
		
		IfEqual, FExt,
			RunItem = %FDir%\%FName%

		IfNotEqual, FExt,
			RunItem = %FDir%\%FName%.%FExt%

                ; Plato Wu,2010/01/28: Add for Windows case
                IfEqual, Fdir,
                {
                        RunItem = %FName%
                        FileExist = 0
                        Break
                }

		IfExist, %RunItem%

		{

			FileExist = 1

			Break

		}

	}

	;remove the last \ from a launched folder's name

	StringRight, check, RunItem, 1

	IfEqual, check, \

		StringTrimRight, RunItem, RunItem, 1

	;add the \ back if the target is a drive path

	StringLen, check, RunItem

	IfLess, check, 3

		RunItem = %RunItem%\

	Add2History = %RunItem%

	;Plato Wu,2009/5/8, some link file which contain parameter in itself
	;so we can not get its real file path for running.
	
	;get real file path from shortcut

;	StringRight, check, RunItem, 4
;	IfEqual, check, .lnk
;	{
;		FileGetShortcut, %RunItem%, LnkTarget
;    Msgbox %LnkTarget%		
;		IfNotInString, LnkTarget, {
;		IfNotInString, LnkTarget, }
;			RunItem = %LnkTarget%
;	}


	SplitPath, RunItem, FName, FDir, FExt, FNameNoExt, FDrive

	;shift key down opens host folder
;Plato Wu, 2009/5/15, use #WinActivateForce for skip program own tooltip 
   #WinActivateForce
	IfEqual, ShKey, D

	{

		Run, Explorer %FDir%,, UseErrorLevel
;Plato Wu,2009/5/7, It run background now
    Gui, Submit, %MainWnd%
;    ToolTip
    return
;		ExitApp

	}
 
	AddToList:



	
;Plato Wu,2009/5/7, It run background now
;Plato Wu,2009/5/13, Dismiss its own tooltip
  ;ToolTip
  Gui, Submit, %MainWnd%
  
	;simple run
	IfEqual, RParam,
        { 
                        ; Plato Wu,2010/01/28: Add for Windows case
                IfNotEqual, FileExist, 1
                {
;;                   MsgBox, %RunItem%
                    WinGet, wid_MinMax, MinMax, %RunItem%
                    If wid_MinMax =-1 ;minimised
                       WinRestore, %RunItem%

                   WinActivate, %RunItem%
                }

;          StringRight, check, RunItem, 4
                ;    {
          ;         FileGetShortcut, %RunItem%, Target
          ;    }else
          ;    {
          ;         Target = %RunItem%
          ;    }

          ; SplitPath,Target,ProcessName       

	  ; IfNotInstring, AllowMulteInstance, %ProcessName%
          ; {

	  ;    ; Plato Wu,2009/05/30: use jump or run strategy.
          ;    Process, Exist, %ProcessName%
          ;    pid = %ErrorLevel%
          ;    If pid != 0
          ;    {
          ;        WinGet, wid, ID, ahk_pid %pid%
          ;        WinGet, pid_MinMax, ID, ahk_id %wid%
          ;        If pid_MinMax =-1 ;minimised
          ;            WinRestore, ahk_id %wid%
          ;        WinActivate, ahk_id %wid%
          ;    }
          ;    else
          ;    {
          ;        Run, %RunItem%, %FDir%, UseErrorLevel
          ;    }
          ; }else
	  {
	        Run, %RunItem%, %FDir%, UseErrorLevel
	  }
        }


	;runtime param

	IfNotEqual, RParam,
		Run, %RunItem% "%RParam%", %FDir%, UseErrorLevel

	; Plato Wu,2009/05/30: UseErrorLevel will give the number occurrences replaced
        ; to ErrorLevel
	IfEqual, FileExist, 1
		StringReplace, UsedList, UsedList, |%Add2History%,, A,UseErrorLevel

	;leave only max items in list

	StringSplit, UsedItem, UsedList, |

	UsedList =

	Loop, %MaxLastUsed%

	{

		CurrItem := UsedItem%A_Index%

		IfEqual, CurrItem,, Continue

		UsedList = %UsedList%|%CurrItem%

	}

	; Plato Wu,2009/05/20: update usedlist intantly
        IfEqual, FileExist, 1
                UsedList=|%Add2History%%UsedList%

;	IniWrite, |%Add2History%%UsedList%, %IniFile%, Settings, UsedList
; Plato Wu,2009/05/30: I suppose it has little meaning to replace UsedListFile
; everytime, so I just append new item
 
        If ErrorLevel = 0
		FileAppend, |%Add2History%, %UsedListFile%

;	IniWrite, %LastUsedList%, %IniFile%, Settings, LastUsedList

	
;Plato Wu,2009/5/17, It run background now
   return
;ExitApp

Selection:

  SelItem := LV_GetNext()

	LV_GetText(0FName, SelItem, 1)

	LV_GetText(0FExt, SelItem, 2)

	LV_GetText(0FDir, SelItem, 3)

	Pth = %0FDir%\%0FName%.%0FExt%

;Plato Wu, 2009/5/15, I donot need this tooltip
;	IfEqual, FExt, lnk
;	{
;		WinGetPos, wX, wY, wW, wH, %MainWnd%
;		FileGetShortcut, %Pth%, FTarget
;		ToShow = %FTarget%
;		ToolTip, %ToShow%, 0, %wH%
;	}
;	Else
;		ToolTip

  IfEqual, A_GuiControlEvent, DoubleClick

    GoTo, ButtonOpen

Return


GuiEscape:
GuiClose:
;Plato Wu, 2009/5/7, It will run background always
;ToolTip 
Gui, Submit, %MainWnd%
Return
;	ExitApp

;Chris made this long ago!

ExpandVars(Var)

{

	var_new = %var%

	in_reference = n

	Loop, parse, var_new, `%

	{

		if in_reference = n

		{

			in_reference = y

			continue

		}

		; Otherwise, A_LoopField is a variable reference:

		StringTrimLeft, ref_contents, %A_LoopField%, 0

		StringReplace, var_new, var_new, `%%A_LoopField%`%, %ref_contents%, all

		in_reference = n

	}

	Return, var_new

}
;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive
; Plato Wu,2009/05/21: view-lookup-dict-mode
DoHotkey:
; Plato Wu,2011/11/01: try to use title instead class group to resolve same class application issue
   WinActivate, %DictTitle%
;ahk_group dict,
   ; Plato Wu,2009/05/22: strim $ prefix
   StringTrimLeft,Hotkey,A_ThisHotkey,1
   Send %Hotkey%      
   lookup_mode=1
return

; Plato Wu,2009/05/21: Now there is only one on/off indicator for all windows
; so it will be confuse when try to enable it for two or more window simultaneous. 
; been enable this mode, so it will be confuse when one window
^!z::
; Plato Wu,2009/05/21: get active/foremost window class
; Plato Wu,2009/06/23: use WinGetTitle replace WinGetClass, because
; there maybe more than one window have the same class.
;  WinGetClass, view_class, A
  old_view_title = %view_title%
  WinGetTitle, view_title, A

; Plato Wu,2009/06/24: Google Reader append unread count in its title, so trim them.
  StringLeft,view_title,view_title,10

; Plato Wu,2009/06/24:try to resolve the problem of enable it for two or more windows
; simultaneous. 
  If old_view_title <> %view_title%
  {
    IfNotEqual,old_view_title,
    {
;    MsgBox,%view_title%
;    MsgBox %old_view_title%
    Hotkey, IfWinActive, %old_view_title%
    Loop % StrLen(alphabet)
    {
	c1 := SubStr(alphabet, A_Index, 1)
  	Hotkey $%c1%, DoHotkey, Off
    }
    lookup_hotkey = 0
    lookup_mode = 0
    }
  }
  
  ifequal, lookup_hotkey, 0
  {
    IfWinNotExist, %DictTitle%
;ahk_group dict
         Run, %Dict%
;   Hotkey, IfWinActive, ahk_class %view_class%
    Hotkey, IfWinActive, %view_title%
    Loop % StrLen(alphabet)
    {
	c1 := SubStr(alphabet, A_Index, 1)
  	Hotkey $%c1%, DoHotkey,On
    }
    lookup_hotkey = 1
  }else{
    Loop % StrLen(alphabet)
    {
	c1 := SubStr(alphabet, A_Index, 1)
  	Hotkey $%c1%, DoHotkey, Off
    }
    lookup_hotkey = 0
    lookup_mode = 0
  
  }
return

; Plato Wu,2009/5/19 Variable references such as %Var% are not currently
; supported in #IfWinActive, use GroupAdd and ahk_group to work around this
; limitation
; Plato Wu,2011/11/01: disable this function
; #IfWinActive ahk_group dict
; ; Plato Wu,2009/5/19 The ~ prefix is needed so that when the hotkey fires,
; ; its key's native function will not be blocked (hidden from the system). 
; ~Enter::
;   ifequal, lookup_mode,1 
;   {
;     sleep 1500
; ;    WinActivate ahk_class %view_class%
;     WinActivate %view_title%
;     lookup_mode = 0
;   }
; return
