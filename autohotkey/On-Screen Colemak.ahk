; On-Screen Keyboard (requires XP/2k/NT) -- by Jon
; http://www.autohotkey.com
; This script creates a mock keyboard at the bottom of your screen that shows
; the keys you are pressing in real time. I made it to help me to learn to
; touch-type (to get used to not looking at the keyboard).  The size of the
; on-screen keyboard can be customized at the top of the script. Also, you
; can double-click the tray icon to show or hide the keyboard.

; Modified to the Colemak layout by ÿystein Bech Gadmar, 07-03.
; See http://colemak.com for more info.
; (Also added hotkey functionality, menu resizing and some other stuff.)

#SingleInstance force
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode 3  ; Exact matching to avoid confusing T/B with Tab/Backspace.

;---- Configuration: Customize the on-screen keyboard in this section.

k_FontSize = 8	; Changing this will grow/shrink the entire on-screen keyboard!
k_FontName = Verdana  ; This can be blank to use the system's default font.
k_FontStyle = Bold    ; Example of an alternative: Italic Underline

; Names for the tray menu items:
k_MenuItemHide = Hide on-screen &keyboard (Ctrl+Alt+PgUp)
k_MenuItemShow = Show on-screen &keyboard (Ctrl+Alt+PgUp)

; To have the keyboard appear on a monitor other than the primary, specify
; a number such as 2 for the following variable (blank entry = primary):
k_Monitor = 

;---- Alter the tray icon menu:
Menu Tray, Add, %k_MenuItemHide%, k_ShowHide
Menu Tray, Add, &Resize keyboard, k_Resize
Menu Tray, Add, &Exit (Ctrl+Alt+PgDn), k_MenuExit
Menu Tray, Default, %k_MenuItemHide%
Menu Tray, NoStandard

;---- End of configuration section.

;---- Implement command-line parameters in the future:
k_Parameters := ""
Loop, %0%  ; For each parameter passed:
{
	k_Parameters := k_Parameters . %A_Index% . " "  ; Add to the parameter string
}

DrawKeyboard:
;---- Calculate object dimensions based on chosen font size:
k_KeyWidth = %k_FontSize%
k_KeyWidth *= 3
k_KeyHeight = %k_FontSize%
k_KeyHeight *= 3
k_KeyMargin = %k_FontSize%
k_KeyMargin /= 6
k_KeyWidthHalf = %k_KeyWidth%
k_KeyWidthHalf /= 2
k_KeySize = w%k_KeyWidth% h%k_KeyHeight%
k_Position = x+%k_KeyMargin% %k_KeySize%

;---- Create a GUI window for the on-screen keyboard:
IfWinExist ahk_id %k_ID%	; Clean up any old keyboards first
	Gui destroy		; Would it be better to use WinHide/WinShow instead?
Gui Font, s%k_FontSize% %k_FontStyle%, %k_FontName%
Gui -Caption +E0x200 +ToolWindow	; Need -Caption +ToolWindow for transparency!
TransColor = F1ECED
Gui Color, %TransColor%  ; This color will be made transparent later below.

;---- Add a button for each key. Position the first button with absolute
; coordinates so that all other buttons can be positioned relative to it.

; In the future, make a Loop with kS from 1 to 4 for the Shift states!
kS = 1	; Shift state (1 = normal, 2 = Shift, 3 = AltGr, 4 = Shift+AltGr)

B%kS%_R1 := "``"			; The beginning of the row
M%kS%_R1 := "1234567890-="	; The middle part of row
E%kS%_R1 := "    BkSpc"		; The end of the row

B%kS%_R2 := "Tab "		; Adding Spc widens the key to look more real
M%kS%_R2 := "QWFPGJLUY«¥["
E%kS%_R2 := "  Enter"

B%kS%_R3 := "Caps "		; Adding Spc widens the key to look more real
M%kS%_R3 := "ARSTDHNEIO~]"
E%kS%_R3 := "Enter"

B%kS%_R4 := "L.Sft"		; Adding Spc widens the key to look more real
M%kS%_R4 := "\ZXCVBKM`,.;/"
E%kS%_R4 := "  R.Sft"

Loop 4 {
k_AddRow(B%kS%_R%A_Index%,M%kS%_R%A_Index%,E%kS%_R%A_Index%)
}

;---- The last row is currently commented out for compactness - feel free to uncomment it!
;Gui Add, Button, xm y+%k_KeyMargin% h%k_KeyHeight%, Ctrl  ; Auto-width.
;Gui Add, Button, h%k_KeyHeight% x+%k_KeyMargin%, Win      ; Auto-width.
;Gui Add, Button, h%k_KeyHeight% x+%k_KeyMargin%, Alt      ; Auto-width.
;k_SpacebarWidth := k_FontSize * 24	; 25 originally
;Gui Add, Button, h%k_KeyHeight% x+%k_KeyMargin% w%k_SpacebarWidth%, Space

;---- Show the window:
Gui Show
k_IsVisible = y
WinGet k_ID, ID, A   ; Get its window ID.
WinGetPos ,,, k_WindowWidth, k_WindowHeight, A

;---- Position the keyboard at the bottom of the screen (taking into account
; the position of the taskbar):
SysGet k_WorkArea, MonitorWorkArea, %k_Monitor%

; Calculate window position:
k_WindowX = %k_WorkAreaRight%
k_WindowX -= %k_WorkAreaLeft%  ; Now k_WindowX contains the width of this monitor.
k_WindowX -= %k_WindowWidth%
k_WindowX /= 2  ; Calculate position to center it horizontally.
; The following is done in case the window will be on a non-primary monitor
; or if the taskbar is anchored on the left side of the screen:
k_WindowX += %k_WorkAreaLeft%
k_WindowY = %k_WorkAreaBottom%
k_WindowY -= %k_WindowHeight%

WinMove A,, %k_WindowX%, %k_WindowY%
WinSet AlwaysOnTop, On, ahk_id %k_ID%
WinSet TransColor, %TransColor% 210, ahk_id %k_ID%	; 220


;---- Set all keys as hotkeys. See www.asciitable.com
k_n = 1
k_ASCII = 42	; 45

Loop {
	Transform k_char, Chr, %k_ASCII%
	StringUpper k_char, k_char
	if k_char not in <,>,^,~,Å,`,
		Hotkey ~*%k_char%, k_KeyPress
	if k_ASCII = 93
		break
	k_ASCII++
}

return	;---- End of auto-execute section.


;---- Utility hotkeys for stopping and hiding the keyboard (same as the menu options)
^!PgDn::ExitApp
^!PgUp::Goto k_ShowHide


;---- When a key is pressed by the user, click the corresponding button on-screen:

~*'::		k_PressButton("'","'")
~*`::		k_PressButton("`","`")
~*Backspace::	k_PressButton("Back","BS")	; The "Back" button shows both BS keys
~*Enter::	k_PressButton("Enter","Enter")
~*Tab::		k_PressButton("Tab","Tab")
~*.::		k_PressButton(".",".")		; Problem: The ,.- keys aren't working!
~*LShift::	k_PressButton("Shift   ","Shift")
~*RShift::	k_PressButton("Shift   ","Shift")
~*RAlt::	k_PressButton("    AltGr","RAlt")
~*<^Alt::	k_PressButton("    AltGr","<^Alt")	; AltGr equals LCtrl+Alt
;---- Since I'm not using the bottom row of control keys now, this is commented out.
;~*Space::	k_PressButton("Space","Space")
;~*LCtrl::
;~*RCtrl::	; Must match button names exactly (so don't use, e.g., "Control")
;~*LAlt::
;~*LWin::
;~*RWin::
;	StringTrimLeft k_ThisHotkey, A_ThisHotkey, 3	; R/L are the same for us
;	k_PressButton(k_ThisHotkey, k_ThisHotkey)
;return


;---- Subroutines and function definitions:
k_KeyPress:	; This is the main key capture routine
	StringTrimLeft k_ThisHotkey, A_ThisHotkey, 2	; Remove ~*
	k_PressButton(k_ThisHotkey, k_ThisHotkey)
Return

k_PressButton(k_KeyToPress, k_KeyPressed)
{
	global k_ID
	ControlClick %k_KeyToPress%, ahk_id %k_ID%, , LEFT, 1, D
	KeyWait %k_KeyPressed%
	ControlClick %k_KeyToPress%, ahk_id %k_ID%, , LEFT, 1, U
}

k_AddRow(k_RowLeft, k_RowMiddle, k_RowRight)
{
	global	; allows access to all the global vars defined outside the function
	If(A_Index = 1) {	; Special parameters for the 1st row
		Gui Add, Button, xm %k_KeySize%, %k_RowLeft%
	} else {
		Gui Add, Button, xm y+%k_KeyMargin% h%k_KeyHeight%, %k_RowLeft%
	}
	Loop Parse, k_RowMiddle	; The middle of each row is a series of single chars
	{
		Gui Add, Button, %k_Position%, %A_LoopField%
	}
	If(A_Index != 2)	; Row 2 has no special right-hand keys (here)
		Gui Add, Button, x+%k_KeyMargin% h%k_KeyHeight%, %k_RowRight%
}

k_ShowHide:
if(k_IsVisible = "y") {
	Gui Cancel
	Menu Tray, Rename, %k_MenuItemHide%, %k_MenuItemShow%
	k_IsVisible = n
} else {
	Gui Show
	Menu Tray, Rename, %k_MenuItemShow%, %k_MenuItemHide%
	k_IsVisible = y
}
return

k_Resize:
InputBox UserInput, OnScreen Keyboard, Enter the new onscreen keyboard size (5-45),,200,150,,,,,%k_FontSize%
if((UserInput >= 5) and (UserInput <= 45) and !ErrorLevel) {
	k_FontSize = %UserInput%
	Goto DrawKeyboard
}
return


GuiClose:
k_MenuExit:
ExitApp
