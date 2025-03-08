#include-once
#include <WinAPISysWin.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <GuiTreeView.au3>
#include <File.au3>
#include <WindowsConstants.au3>

; #INDEX# =======================================================================================================================
; Title .........: TreeListExplorer
; AutoIt Version : 3.3.16.1
; Language ......: English
; Description ...: UDF to use a Listview or Treeview as a File/Folder Explorer
; Author(s) .....: Kanashius
; Version .......: 2.2.0
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; __TreeListExplorer_StartUp
; __TreeListExplorer_Shutdown
; __TreeListExplorer_CreateSystem
; __TreeListExplorer_DeleteSystem
; __TreeListExplorer_AddView
; __TreeListExplorer_RemoveView
; __TreeListExplorer_OpenPath
; __TreeListExplorer_GetPath
; __TreeListExplorer_GetRoot
; __TreeListExplorer_SetRoot
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __TreeListExplorer__DeleteSystem
; __TreeListExplorer__OpenPath
; __TreeListExplorer__IsPathOpen
; __TreeListExplorer__GetCurrentPath
; __TreeListExplorer__GetCurrentRoot
; __TreeListExplorer__GetSystemKeyFromID
; __TreeListExplorer__GetIDFromSystemKey
; __TreeListExplorer__UpdateSystemViews
; __TreeListExplorer__UpdateView
; __TreeListExplorer__GetSizeString
; __TreeListExplorer__GetTimeString
; __TreeListExplorer__ExpandTreeitem
; __TreeListExplorer__LoadTreeItemContent
; __TreeListExplorer__RemoveLastFolderFromPath
; __TreeListExplorer__GetDrives
; __TreeListExplorer__UpdateTreeViewSelection
; __TreeListExplorer__TreeViewGetRelPath
; __TreeListExplorer__TreeViewItemIsExpanded
; __TreeListExplorer__PathIsFolder
; __TreeListExplorer__RelPathIsFolder
; __TreeListExplorer__WinProc
; __TreeListExplorer__ConsoleWriteCallbackError
; ===============================================================================================================================

; #GLOBAL CONSTANTS# ============================================================================================================
Global $__TreeListExplorer_Lang_EN = 0, $__TreeListExplorer_Lang_DE = 1
; ===============================================================================================================================

; #INTERNAL_USE_ONLY GLOBAL CONSTANTS # =========================================================================================
Global $__TreeListExplorer__Type_TreeView = 1, $__TreeListExplorer__Type_ListView = 2
; ===============================================================================================================================

; #INTERNAL_USE_ONLY GLOBAL VARIABLES # =========================================================================================
Global $__TreeListExplorer__Data[]
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer_StartUp
; Description ...: StartUp of the TLE UDF initializing required variables. Must be called before using other UDF functions.
; Syntax ........: __TreeListExplorer_StartUp([$iLang = $__TreeListExplorer_Lang_EN])
; Parameters ....: $iLang               - [optional] an integer to set the language ($__TreeListExplorer_Lang_EN, $__TreeListExplorer_Lang_DE). Default is $__TreeListExplorer_Lang_EN.
; Return values .: True on success.
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
;                 The following languages are currently awailable: $__TreeListExplorer_Lang_EN, $__TreeListExplorer_Lang_DE
;                 To add other languages, add them to the array at the beginning of this function
;                 and create the $__TreeListExplorer_Lang_?? variable.
;
;                 Errors:
;                 1 - $iLang not valid
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_StartUp($iLang = $__TreeListExplorer_Lang_EN)
	Local $arLangData = [["Filename", "Size", "Date created"], _
						 ["Dateiname", "Größe", "Erstelldatum"]]

	If $iLang<0 Or $iLang>UBound($arLangData)-1 Then Return SetError(1, 0, False)
	Local $hImageList = _GUIImageList_Create($TV_Icons, $TV_Icons, 5, 1)

	_GUIImageList_AddIcon($hImageList, 'shell32.dll', 3) ; Folder-Icon
	_GUIImageList_AddIcon($hImageList, 'shell32.dll', 110) ; Folder-Icon checked
	_GUIImageList_AddIcon($hImageList, 'shell32.dll', 0) ; File-Icon
	_GUIImageList_AddIcon($hImageList, 'shell32.dll', 5) ; Disc-Icon
	_GUIImageList_AddIcon($hImageList, 'shell32.dll', 7) ; Changeableinput-Icon
	_GUIImageList_AddIcon($hImageList, 'shell32.dll', 8) ; Harddrive-Icon
	_GUIImageList_AddIcon($hImageList, 'shell32.dll', 11) ; CDROM-Icon
	_GUIImageList_AddIcon($hImageList, 'shell32.dll', 12) ; Networkdrive-Icon
	_GUIImageList_AddIcon($hImageList, 'shell32.dll', 53) ; Unknown-Icon
#cs	
	If $isDarkMode = True Then
		If @Compiled = 0 Then
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 3) ; Folder-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 110) ; Folder-Icon checked
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 0) ; File-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 5) ; Disc-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 7) ; Changeableinput-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 8) ; Harddrive-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 11) ; CDROM-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 12) ; Networkdrive-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 53) ; Unknown-Icon
		Else
			_GUIImageList_AddIcon($hImageList, @ScriptFullPath, 3) ; Folder-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 110) ; Folder-Icon checked
			_GUIImageList_AddIcon($hImageList, @ScriptFullPath, 5) ; File-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 5) ; Disc-Icon
			_GUIImageList_AddIcon($hImageList, @ScriptFullPath, 6) ; Changeableinput-Icon - this one for usb drive?
			_GUIImageList_AddIcon($hImageList, @ScriptFullPath, 4) ; Harddrive-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 11) ; CDROM-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 12) ; Networkdrive-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 53) ; Unknown-Icon
		EndIf
	Else
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 3) ; Folder-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 110) ; Folder-Icon checked
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 0) ; File-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 5) ; Disc-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 7) ; Changeableinput-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 8) ; Harddrive-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 11) ; CDROM-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 12) ; Networkdrive-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 53) ; Unknown-Icon
	EndIf
#ce
	$__TreeListExplorer__Data.hIconList = $hImageList
	Local $mSystems[]
	$__TreeListExplorer__Data.mSystems = $mSystems
	Local $mViews[]
	$__TreeListExplorer__Data.mViews = $mViews
	$__TreeListExplorer__Data.iLang = $iLang
	Local $mGuis[]
	$__TreeListExplorer__Data.mGuis = $mGuis
	$__TreeListExplorer__Data.hProc = DllCallbackRegister('__TreeListExplorer__WinProc', 'ptr', 'hwnd;uint;wparam;lparam')
	$__TreeListExplorer__Data.arLangData = $arLangData
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer_Shutdown
; Description ...: Shutdown of the TLE UDF. Must be called before closing the program. If not called, the program may not exit.
; Syntax ........: __TreeListExplorer_Shutdown()
; Parameters ....:
; Return values .: True on success.
; Author ........: Kanashius
; Modified ......:
; Remarks .......: This includes deleting all TLE systems (__TreeListExplorer_DeleteSystem).
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_Shutdown()
	Local $arSystems = MapKeys($__TreeListExplorer__Data.mSystems)
	For $i=0 To UBound($arSystems)-1 Step 1
		__TreeListExplorer__DeleteSystem($arSystems[$i])
	Next
	Local $mMap[]
	$__TreeListExplorer__Data = $mMap
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer_CreateSystem
; Description ...: Create a new TLE System. This is used to manage the views by settings the root folder, the current folder,...
;                  Multiple views (TreeView/ListView) can be added, all managed by this system.
; Syntax ........: __TreeListExplorer_CreateSystem($hGui[, $sRootFolder = ""[, $sCallbackFolder = Default[, $iLineNumber = @ScriptLineNumber]]])
; Parameters ....: $hGui                - the window handle for all views used by this system.
;                  $sRootFolder         - [optional] the root folder as string. Default is "", making the drive overview the root
;                  $sCallbackFolder     - [optional] callback function as string. Using Default will not call any function.
;                  $iLineNumber         - [optional] linenumber of the function call. Default is @ScriptLineNumber.
;                                         (Automatic, no need to change; only used for error messages)
; Return values .: The system handle $hSystem, used by the other functions
; Author ........: Kanashius
; Modified ......:
; Remarks .......: When $sRootFolder = "", there is no root directory, enabling all drives to be accessed. Otherwise the User can
;                  only select child folders of the root folder.
;                  The $sCallbackFolder calls the provided function, which must have 3 parameters ($hSystem, $sRoot, $sFolder) and
;                  is called, when the root folder or the current folder changes. If the parameter number is wrong an error
;                  message will be written to the console at runtime (using $iLineNumber to find it better).
;
;                  Errors:
;                  1 - Parameter is invalid (@extended 1 - $hGui, 3 - $sCallbackFolder, 4 - $iLineNumber)
;                  2 - Setting WinProc for $hGui failed
;                  3 - TLE system could not be added to map
;                  4 - TLE system ID could not be converted to TLE system handle
;                  5 - $sRootFolder is invalid and could not be set (try __TreeListExplorer_SetRoot for details)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_CreateSystem($hGui, $sRootFolder = "", $sCallbackFolder = Default, $iLineNumber = @ScriptLineNumber)
	If Not IsHWnd($hGui) Then Return SetError(1, 1, -1)
	If $sCallbackFolder <> Default And Not IsFunc(Execute($sCallbackFolder)) Then Return SetError(1, 3, -1)
	If Not IsInt($iLineNumber) Then Return SetError(1, 4, False)
	Local $mSystem[], $mViews[]
	$mSystem.mViews = $mViews
	$mSystem.sRootOld = -1
	$mSystem.sRoot = ""
	$mSystem.sFolderOld = -1
	$mSystem.sFolder = ""
	$mSystem.hGui = $hGui
	$mSystem.sCallbackFolder = $sCallbackFolder
	$mSystem.iLineNumber = $iLineNumber
	If MapExists($__TreeListExplorer__Data.mGuis, $hGui) Then
		$__TreeListExplorer__Data["mGuis"][$hGui]["count"] += 1
	Else
		Local $mGui[]
		$mGui["count"] = 1
		$mGui["hPrevProc"] = _WinAPI_SetWindowLong($hGui, -4, DllCallbackGetPtr($__TreeListExplorer__Data.hProc))
		If @error Then Return SetError(2, 0, -1)
		$__TreeListExplorer__Data["mGuis"][$hGui] = $mGui
	EndIf
	Local $iSystem = MapAppend($__TreeListExplorer__Data.mSystems, $mSystem)
	If @error Then ; Revert gui changes and return error
		$__TreeListExplorer__Data["mGuis"][$hGui]["count"] -= 1
		If $__TreeListExplorer__Data.mGuis[$hGui].count = 0 Then _WinAPI_SetWindowLong($hGui, -4, $__TreeListExplorer__Data.mGuis[$hGui].hPrevProc)
		MapRemove($__TreeListExplorer__Data.mGuis, $hGui)
		Return SetError(3, 0, -1)
	EndIf
	Local $hSystem = __TreeListExplorer__GetIDFromSystemKey($iSystem)
	If @error Then
		__TreeListExplorer__DeleteSystem($iSystem)
		Return SetError(4, 0, -1)
	EndIf
	If $sRootFolder<>"" Then
		__TreeListExplorer_SetRoot($hSystem, $sRootFolder)
		If @error Then
			__TreeListExplorer_DeleteSystem($hSystem)
			Return SetError(5, 0, -1)
		EndIf
	EndIf
	Return $hSystem
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer_DeleteSystem
; Description ...: Delete the TLE System connected to the $hSystem handle and cleans up the system resources
; Syntax ........: __TreeListExplorer_DeleteSystem($hSystem)
; Parameters ....: $hSystem             - the system handle.
; Return values .: None
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - $hSystem is not a valid TLE system
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_DeleteSystem($hSystem)
	Local $iSystem = __TreeListExplorer__GetSystemKeyFromID($hSystem)
	If @error Then Return SetError(1, @error, 0) ; $iSystem not valid/startup not called
	Return __TreeListExplorer__DeleteSystem($iSystem)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer_AddView
; Description ...: Add a view (TreeView/ListView) to a TLE system.
; Syntax ........: __TreeListExplorer_AddView($hSystem, $hView[, $bShowFolders = Default[, $bShowFiles = Default[, $sCallbackOnSelect = Default[,
;                  $sCallbackOnDoubleClick = Default[, $sCallbackLoading = Default[, $sCallbackOnSelectionChange = Default[,
;                   $iLineNumber = @ScriptLineNumber]]]]]}])
; Parameters ....: $hSystem             - the system handle.
;                  $hView               - the view to add (must be a TreeView or ListView).
;                  $bShowFolders        - [optional] a boolean defining, if folders will be shown in the view. Default is Default.
;                  $bShowFiles          - [optional] a boolean defining, if files will be shown in the view. Default is Default.
;                  $sCallbackOnClick    - [optional] callback function as string. Using Default will not call any function.
;                  $sCallbackOnDoubleClick - [optional] callback function as string. Using Default will not call any function.
;                  $sCallbackLoading    - [optional] callback function as string. Using Default will not call any function.
;                  $sCallbackOnSelectionChange - [optional] callback function as string. Using Default will not call any function.
;                  $iLineNumber         - [optional] an integer value. Default is @ScriptLineNumber.
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Default for $bShowFolders is True for TreeViews and ListViews.
;                  Default for $bShowFiles is True for ListViews and False for TreeViews.
;                  $sCallbackOnClick must be a function with 4 parameters ($hSystem, $hView, $sRoot, $sFolder)
;                  and is called, when an element in the view is clicked once.
;                  The $sCallbackOnDoubleClick must be a function with 4 parameters ($hSystem, $hView, $sRoot, $sFolder)
;                  and is called, when an element in the view is double clicked.
;                  The $sCallbackLoading must be a function with 5 parameters ($hSystem, $hView, $sRoot, $sFolder, $bLoading)
;                  and is called, when a some folders or files are loading (when root/folder changes or an element in a
;                  TreeView is extended). $bLoading is True if loading starts and False, when it is done.
;                  $sCallbackOnSelectionChange must be a function with 4 parameters ($hSystem, $hView, $sRoot, $sFolder)
;                  and is called, when an item in the Tree-/ListView is selected (Mouse/Keyboard)
;
;                  Errors:
;                  1 - $hSystem is not a valid TLE system
;                  2 - $hView is not a (valid) control handle (@extended 50: Not a TreeView/ListView)
;                  3 - $hView is already part of a TLE system
;                  4 - Parameter is invalid (@extended 1 - $bShowFolders, 2 - $bShowFiles, 3 - $sCallbackOnSelect,
;                      4 - $sCallbackOnDoubleClick, 5 - $sCallbackLoading, 6 - $sCallbackOnSelectionChange, 7 - $iLineNumber)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_AddView($hSystem, $hView, $bShowFolders = Default, $bShowFiles = Default, $sCallbackOnClick = Default, $sCallbackOnDoubleClick = Default, $sCallbackLoading = Default, $sCallbackOnSelectionChange = Default, $iLineNumber = @ScriptLineNumber)
	Local $iSystem = __TreeListExplorer__GetSystemKeyFromID($hSystem)
	If @error Then Return SetError(1, @error, False) ; $iSystem not valid/startup not called
	If Not IsHWnd($hView) Then
		$hView = GUICtrlGetHandle($hView)
		If @error Then Return SetError(2, @error, False) ; $hView is not a control
	EndIf
	If MapExists($__TreeListExplorer__Data.mViews, $hView) Then Return SetError(3, @error, False) ; $hView is already part of a system
	Local $sClass = _WinAPI_GetClassName($hView)
	Local $iType = 0
	If StringInStr($sClass, "TreeView") Then
		$iType = $__TreeListExplorer__Type_TreeView
	ElseIf StringInStr($sClass, "ListView") Then
		$iType = $__TreeListExplorer__Type_ListView
	Else
		Return SetError(2, 50, False) ; $hView is not a valid control (wrong control type)
	EndIf
	If $bShowFolders <> Default And Not IsBool($bShowFolders) Then Return SetError(4, 1, False)
	If $bShowFiles <> Default And Not IsBool($bShowFiles) Then Return SetError(4, 2, False)
	If $sCallbackOnClick <> Default And Not IsFunc(Execute($sCallbackOnClick)) Then Return SetError(4, 3, False)
	If $sCallbackOnDoubleClick <> Default And Not IsFunc(Execute($sCallbackOnDoubleClick)) Then Return SetError(4, 4, False)
	If $sCallbackLoading <> Default And Not IsFunc(Execute($sCallbackLoading)) Then Return SetError(4, 5, False)
	If $sCallbackOnSelectionChange <> Default And Not IsFunc(Execute($sCallbackOnSelectionChange)) Then Return SetError(4, 6, False)
	If Not IsInt($iLineNumber) Then Return SetError(4, 7, False)
	Switch $iType
		Case $__TreeListExplorer__Type_TreeView
			If $bShowFolders = Default Then $bShowFolders=True
			If $bShowFiles = Default Then $bShowFiles=False
			_GUICtrlTreeView_SetNormalImageList($hView, $__TreeListExplorer__Data.hIconList)
		Case $__TreeListExplorer__Type_ListView
			If $bShowFolders = Default Then $bShowFolders=True
			If $bShowFiles = Default Then $bShowFiles=True
			_GUICtrlListView_SetImageList($hView, $__TreeListExplorer__Data.hIconList, 1)
			_GUICtrlListView_SetExtendedListViewStyle($hView, BitOR( $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES))
			GUICtrlSetStyle($hView, BitOR($LVS_SHOWSELALWAYS, $LVS_NOSORTHEADER, $LVS_REPORT))
			For $i=0 To _GUICtrlListView_GetColumnCount($hView)+1 Step 1
				_GUICtrlListView_DeleteColumn($hView, 0)
			Next
			Local $iListWidth = _WinAPI_GetWindowWidth($hView)
			Local $iColWidth = $iListWidth*0.3
			If $iColWidth>140 Then $iColWidth = 140
			_GUICtrlListView_AddColumn($hView, $__TreeListExplorer__Data.arLangData[$__TreeListExplorer__Data.iLang][0], $iListWidth-$iColWidth*2-5) ; filename
			_GUICtrlListView_AddColumn($hView, $__TreeListExplorer__Data.arLangData[$__TreeListExplorer__Data.iLang][1], $iColWidth, 1) ; size
			_GUICtrlListView_AddColumn($hView, $__TreeListExplorer__Data.arLangData[$__TreeListExplorer__Data.iLang][2], $iColWidth) ; date created
	EndSwitch
	Local $mView[]
	$mView.hWnd = $hView
	$mView.iType = $iType
	$mView.iSystem = $iSystem
	$mView.bShowFolders = $bShowFolders
	$mView.bShowFiles = $bShowFiles
	$mView.sRoot = -1
	$mView.sFolder = -1
	$mView.hCurrentExpand = -1
	$mView.sCallbackLoading = $sCallbackLoading
	$mView.sCallbackSelect = $sCallbackOnSelectionChange
	$mView.sCallbackClick = $sCallbackOnClick
	$mView.sCallbackDBClick = $sCallbackOnDoubleClick
	$mView.iLineNumber = $iLineNumber
	$__TreeListExplorer__Data["mViews"][$hView] = $mView
	$__TreeListExplorer__Data["mSystems"][$iSystem]["mViews"][$hView] = 1
	__TreeListExplorer__UpdateView($hView)
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer_RemoveView
; Description ...: Remove a view from its TLE system
; Syntax ........: __TreeListExplorer_RemoveView($hView)
; Parameters ....: $hView               - the TreeView/ListView handle.
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_RemoveView($hView)
	If Not IsHWnd($hView) Then
		$hView = GUICtrlGetHandle($hView)
		If @error Then Return SetError(2, @error, False) ; $hView is not a control
	EndIf
	If Not IsHWnd($hView) Or Not MapExists($__TreeListExplorer__Data.mViews, $hView) Then Return SetError(1, 0, False)
	Local $mView = $__TreeListExplorer__Data.mViews[$hView]
	Local $iSystem = $mView.iSystem
	Switch $mView.iType
		Case $__TreeListExplorer__Type_TreeView
			_GUICtrlTreeView_DeleteAll($hView)
			_GUICtrlTreeView_SetNormalImageList($hView, 0)
		Case $__TreeListExplorer__Type_ListView
			_GUICtrlListView_DeleteAllItems($hView)
			While _GUICtrlListView_GetColumnCount($hView)>0
				_GUICtrlListView_DeleteColumn($hView, 0)
			WEnd
			_GUICtrlListView_SetImageList($hView, 0)
	EndSwitch
	MapRemove($__TreeListExplorer__Data.mViews, $hView)
	MapRemove($__TreeListExplorer__Data["mSystems"][$iSystem]["mViews"], $hView)
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer_OpenPath
; Description ...: Set the current folder for the TLE system
; Syntax ........: __TreeListExplorer_OpenPath($hSystem[, $sPath = ""[, $bForceRefresh = False]])
; Parameters ....: $hSystem             - the system handle.
;                  $sPath               - [optional] a folder relative to root as string value. Default is "".
;                                         If the begin of $sPath is equal to the root directory, that part is removed.
;                  $bForceRefresh       - [optional] a boolean to force an update, even if the folder did not change.
;                                         Can be used to refresh the view, e.g. when new folders/files were created
;                                         Default is False.
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - $hSystem is not a valid TLE system
;                  2 - Normalizing $sPath with _PathFull failed (@extended contains the error from _PathFull)
;                  3 - $sPath does not point to a valid existing folder
;                  Others: See __TreeListExplorer__OpenPath
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_OpenPath($hSystem, $sPath = "", $bForceRefresh = False)
	Local $iSystem = __TreeListExplorer__GetSystemKeyFromID($hSystem)
	If @error Then Return SetError(1, @error, False)
	If $sPath <> "" Then
		$sPath = _PathFull($sPath)
		If @error Then Return SetError(2, @error, False)
		; Remove root folder, if its at the beginning of $sPath
		Local $sRoot = __TreeListExplorer__GetCurrentRoot($iSystem)
		If $sRoot <> "" And StringInStr($sPath, $sRoot)=1 Then $sPath = StringTrimLeft($sPath, StringLen($sRoot))
	EndIf
	Local $bRes = __TreeListExplorer__OpenPath($iSystem, $sPath, $bForceRefresh)
	If @error Then Return SetError(@error, @extended, False)
	Return $bRes
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer_GetPath
; Description ...: Get the current folder, relative to the root folder.
; Syntax ........: __TreeListExplorer_GetPath($hSystem)
; Parameters ....: $hSystem             - the system handle.
; Return values .: The folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - $hSystem is not a valid TLE system
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_GetPath($hSystem)
	Local $iSystem = __TreeListExplorer__GetSystemKeyFromID($hSystem)
	If @error Then Return SetError(1, @error, 0)
	Return __TreeListExplorer__GetCurrentPath($iSystem)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer_GetRoot
; Description ...: Get the current root folder.
; Syntax ........: __TreeListExplorer_GetRoot($hSystem)
; Parameters ....: $hSystem             - the system handle.
; Return values .: The root folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - $hSystem is not a valid TLE system
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_GetRoot($hSystem)
	Local $iSystem = __TreeListExplorer__GetSystemKeyFromID($hSystem)
	If @error Then Return SetError(1, @error, 0)
	Return __TreeListExplorer__GetCurrentRoot($iSystem)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer_SetRoot
; Description ...: Set the current root folder.
; Syntax ........: __TreeListExplorer_SetRoot($hSystem[, $sPath = ""])
; Parameters ....: $hSystem             - the system handle.
;                  $sPath               - [optional] a path as string. Default is "" (All Drives).
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - $hSystem is not a valid TLE system
;                  2 - Normalizing $sPath with _PathFull failed (@extended contains the error from _PathFull)
;                  3 - $sPath does not point to a valid existing folder
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_SetRoot($hSystem, $sPath = "")
	Local $iSystem = __TreeListExplorer__GetSystemKeyFromID($hSystem)
	If @error Then Return SetError(1, @error, False)
	If $sPath <> "" Then
		$sPath = _PathFull($sPath)
		If @error Then Return SetError(2, @error, False)
	EndIf
	If Not ($sPath = "" Or __TreeListExplorer__PathIsFolder($sPath)) Then Return SetError(3, @error, False)
	If $sPath<>"" And StringRight($sPath, 1)<>"\" Then $sPath&="\" ; Making sure, sFolder always ends with \
	$__TreeListExplorer__Data["mSystems"][$iSystem]["sRoot"] = $sPath
	__TreeListExplorer__UpdateSystemViews($iSystem)
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__DeleteSystem
; Description ...: Delete the TLE system and release all resources.
; Syntax ........: __TreeListExplorer__DeleteSystem($iSystem)
; Parameters ....: $iSystem             - the system ID.
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__DeleteSystem($iSystem)
	Local $hGui = $__TreeListExplorer__Data["mSystems"][$iSystem]["hGui"]
	$__TreeListExplorer__Data["mGuis"][$hGui]["count"] -= 1
	If $__TreeListExplorer__Data.mGuis[$hGui].count=0 Then
		_WinAPI_SetWindowLong($hGui, -4, $__TreeListExplorer__Data.mGuis[$hGui].hPrevProc)
		If @error Then ConsoleWrite('Error restoring the previous WinProc callback for gui "'&$hGui&'". This may be the reason for the program not exiting.'&@crlf)
		MapRemove($__TreeListExplorer__Data.mGuis, $hGui)
	EndIf
	Local $arViews = MapKeys($__TreeListExplorer__Data.mSystems[$iSystem].mViews)
	For $i=0 To UBound($arViews)-1 Step 1
		__TreeListExplorer_RemoveView(HWnd($arViews[$i]))
	Next
	MapRemove($__TreeListExplorer__Data.mSystems, $iSystem)
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__OpenPath
; Description ...: Open the provided path.
; Syntax ........: __TreeListExplorer__OpenPath($iSystem[, $sPath = ""[, $bForceRefresh = False[, $bExpand = True]]])
; Parameters ....: $iSystem             - the system ID.
;                  $sPath               - [optional] a folder relative to root as string value. Default is "".
;                  $bForceRefresh       - [optional] a boolean to force an update, even if the folder did not change.
;                                         Can be used to refresh the view, e.g. when new folders/files were created
;                                         Default is False.
;                  $bExpand             - [optional] if true the items on the path are expanded, if false only the path is updated
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  3 - $sPath does not point to a valid existing folder
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__OpenPath($iSystem, $sPath = "", $bForceRefresh = False, $bExpand = True)
	If $sPath<>"" And Not __TreeListExplorer__RelPathIsFolder($iSystem, $sPath) Then Return SetError(3, 0, False)
	If $sPath<>"" And StringRight($sPath, 1)<>"\" Then $sPath&="\" ; Making sure, sFolder always ends with \
	Local $mSystem = $__TreeListExplorer__Data.mSystems[$iSystem]
	$__TreeListExplorer__Data["mSystems"][$iSystem]["sFolder"] = $sPath
	__TreeListExplorer__UpdateSystemViews($iSystem, $bForceRefresh, $bExpand)
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__IsPathOpen
; Description ...: Check if a path is currently open
; Syntax ........: __TreeListExplorer__IsPathOpen($iSystem, $sPath)
; Parameters ....: $iSystem             - the system ID.
;                  $sPath               - the path to test.
; Return values .: True if $sPath equals the current TLE system folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__IsPathOpen($iSystem, $sPath)
	Return (__TreeListExplorer__GetCurrentPath($iSystem) = $sPath)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetCurrentPath
; Description ...: Get the current TLE system folder
; Syntax ........: __TreeListExplorer__GetCurrentPath($iSystem)
; Parameters ....: $iSystem             - the system ID.
; Return values .: The folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetCurrentPath($iSystem)
	Return $__TreeListExplorer__Data.mSystems[$iSystem].sFolder
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetCurrentRoot
; Description ...: Get the current TLE system root folder
; Syntax ........: __TreeListExplorer__GetCurrentRoot($iSystem)
; Parameters ....: $iSystem             - the system ID.
; Return values .: The root folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetCurrentRoot($iSystem)
	Return $__TreeListExplorer__Data.mSystems[$iSystem].sRoot
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetSystemKeyFromID
; Description ...: Convert a TLE system handle to a TLE system ID
; Syntax ........: __TreeListExplorer__GetSystemKeyFromID($hSystem)
; Parameters ....: $hSystem             - the system handle.
; Return values .: The system ID.
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - mSystems Map does not exists. Make sure to call __TreeListExplorer_StartUp.
;                  2 - No TLE system with the handle $hSystem exists
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetSystemKeyFromID($hSystem)
	If Not MapExists($__TreeListExplorer__Data, "mSystems") Then Return SetError(1, 0, False)
	Local $iSystem = $hSystem-1
	If $iSystem<0 Then Return SetError(2, 0, False) ; negative key crashes autoit for some reason (and is not valid anyway)
	If Not MapExists($__TreeListExplorer__Data.mSystems, $iSystem) Then Return SetError(2, 0, False)
	Return $iSystem
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetIDFromSystemKey
; Description ...: Convert a TLE system ID to a TLE system handle
; Syntax ........: __TreeListExplorer__GetIDFromSystemKey($iSystem)
; Parameters ....: $iSystem             - the system ID.
; Return values .: The system handle.
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetIDFromSystemKey($iSystem)
	return $iSystem+1
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__UpdateSystemViews
; Description ...: Update all views of the given TLE system
; Syntax ........: __TreeListExplorer__UpdateSystemViews($iSystem[, $bForceRefresh = False[, $bExpand = True]])
; Parameters ....: $iSystem             - the system ID.
;                  $bForceRefresh       - [optional] a boolean to force an update, even if the folder did not change.
;                                         Can be used to refresh the view, e.g. when new folders/files were created
;                                         Default is False.
;                  $bExpand             - [optional] if true the items on the path are expanded, if false only the path is updated
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__UpdateSystemViews($iSystem, $bForceRefresh = False, $bExpand = True)
	Local $arViews = MapKeys($__TreeListExplorer__Data["mSystems"][$iSystem]["mViews"])
	For $i=0 To UBound($arViews)-1 Step 1
		__TreeListExplorer__UpdateView(HWnd($arViews[$i]), $bForceRefresh, $bExpand)
	Next
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__UpdateView
; Description ...: Update a view to match a TLE systems root folder and current folder
; Syntax ........: __TreeListExplorer__UpdateView($hView[, $bRefresh = False[, $bExpand = True]])
; Parameters ....: $hView               - the control handle.
;                  $bRefresh            - [optional] a boolean to force an update, even if the folder did not change.
;                                         Can be used to refresh the view, e.g. when new folders/files were created
;                                         Default is False.
;                  $bExpand             - [optional] if true the items on the path are expanded, if false only the path is updated
; Return values .: None
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Main function to handle all updates. Changes to the view mainly happen here. Only exceptions are the
;                  initialization (__TreeListExplorer_AddView) and the user expanding a folder (__TreeListExplorer__WinProc)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__UpdateView($hView, $bRefresh = False, $bExpand = True)
	Local $mView = $__TreeListExplorer__Data.mViews[$hView]
	Local $mSystem = $__TreeListExplorer__Data.mSystems[$mView.iSystem]
	If $mView.sCallbackLoading<>Default Then
		Call($mView.sCallbackLoading, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $hView, $mSystem.sRoot, $mSystem.sFolder, True)
		If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mView.sCallbackLoading, "$sCallbackLoading", $mView.iLineNumber)
	EndIf
	Switch $mView.iType
		Case $__TreeListExplorer__Type_TreeView
			_GUICtrlTreeView_BeginUpdate($hView)
		Case $__TreeListExplorer__Type_ListView
			_GUICtrlListView_BeginUpdate($hView)
	EndSwitch
	; Root different
	If $mView.sRoot<>$mSystem.sRoot Then
		If $mSystem.sRoot <> $mSystem.sRootOld Then
			$__TreeListExplorer__Data["mSystems"][$mView.iSystem]["sRootOld"] = $mSystem.sRoot
			If $mSystem.sCallbackFolder <> Default Then
				Call($mSystem.sCallbackFolder, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $mSystem.sRoot, $mSystem.sFolder)
				If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mSystem.sCallbackFolder, "$sCallbackFolder", $mSystem.iLineNumber, "__TreeListExplorer_CreateSystem")
			EndIf
		EndIf
		$__TreeListExplorer__Data["mViews"][$hView]["sRoot"] = $mSystem.sRoot
		Switch $mView.iType
			Case $__TreeListExplorer__Type_TreeView
				_GUICtrlTreeView_DeleteAll($hView)
				If $mSystem.sRoot = "" Then
					Local $arDrives = __TreeListExplorer__GetDrives()
					For $i=0 To UBound($arDrives)-1 Step 1
						Local $hRoot =  _GUICtrlTreeView_Add($hView, 0, StringUpper($arDrives[$i][0]), $arDrives[$i][1], $arDrives[$i][1])
						__TreeListExplorer__LoadTreeItemContent($hView, $hRoot)
					Next
				Else
					Local $arFolder = StringRegExp($mSystem.sRoot, "([^\\]*)\\$", 1) ; get the last folder/drive name
					If UBound($arFolder)>0 Then ; Should always be true
						Local $hRoot = _GUICtrlTreeView_Add($hView, 0, $arFolder[0], 0, 0)
						__TreeListExplorer__LoadTreeItemContent($hView, $hRoot)
					EndIf
				EndIf
				$bRefresh = True
			Case $__TreeListExplorer__Type_ListView
				 ; (edge case) do not display ".." at root folder => remove if its there and its not fixed in the "folder different" code below (Cannot be a normal folder, because ".." is not allowed as folder name in windows)
				If $mView.sFolder=$mSystem.sFolder And $mSystem.sFolder="" And _GUICtrlListView_GetItemCount($hView)>0 And _GUICtrlListView_GetItemText($hView, 0, 1)=".." Then _GUICtrlListView_DeleteItem($hView, 0)
				$bRefresh = True
		EndSwitch
	EndIf
	; Folder different
	If $mView.sFolder<>$mSystem.sFolder Or $bRefresh Then
		If $mSystem.sFolder <> $mSystem.sFolderOld Then
			$__TreeListExplorer__Data["mSystems"][$mView.iSystem]["sFolderOld"] = $mSystem.sFolder
			If $mSystem.sCallbackFolder <> Default Then
				Call($mSystem.sCallbackFolder, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $mSystem.sRoot, $mSystem.sFolder)
				If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mSystem.sCallbackFolder, "$sCallbackFolder", $mSystem.iLineNumber, "__TreeListExplorer_CreateSystem")
			EndIf
		EndIf
		$__TreeListExplorer__Data["mViews"][$hView]["sFolder"] = $mSystem.sFolder
		Switch $mView.iType
			Case $__TreeListExplorer__Type_TreeView
				Local $arFolders = StringSplit($mSystem.sFolder, "\", BitOR(1, 2))
				Local $hItem = _GUICtrlTreeView_GetFirstItem($hView)
				If $mSystem.sRoot <> "" Then $hItem = _GUICtrlTreeView_GetFirstChild($hView, $hItem) ; Ignore the root item, that is not in the sFolder path
				For $i=0 To UBound($arFolders)-2 Step 1 ; last field is always empty
					While _GUICtrlTreeView_GetText($hView, $hItem)<>$arFolders[$i]
						$hItem = _GUICtrlTreeView_GetNextSibling($hView, $hItem)
						If $hItem=0 Then ExitLoop
					WEnd
					If $hItem<>0 Then
						__TreeListExplorer__ExpandTreeitem($hView, $hItem, $bExpand)
						If $i<>UBound($arFolders)-2 Then $hItem = _GUICtrlTreeView_GetFirstChild($hView, $hItem)
					EndIf
				Next
				If $mSystem.sRoot <> "" And $mSystem.sFolder = "" Then
					_GUICtrlTreeView_SelectItem($hView, _GUICtrlTreeView_GetFirstItem($hView)) ; select root item, if current directory is root
					__TreeListExplorer__ExpandTreeitem($hView, _GUICtrlTreeView_GetFirstItem($hView), $bExpand)
				ElseIf $mSystem.sFolder <> "" And $hItem<>0 Then
					_GUICtrlTreeView_SelectItem($hView, $hItem)
				EndIf
			Case $__TreeListExplorer__Type_ListView
				_GUICtrlListView_DeleteAllItems($hView)
				; do not display .. folder in root directory
				If $mSystem.sFolder<>"" Then
					_GUICtrlListView_AddItem($hView, "..", 0, 0)
				EndIf
				Local $sPath = $mSystem.sRoot & $mSystem.sFolder
				If $sPath = "" Then ; list drives at root level
					Local $arDrives = __TreeListExplorer__GetDrives()
					For $i=0 To UBound($arDrives)-1 Step 1
						_GUICtrlListView_AddItem($hView, StringUpper($arDrives[$i][0]), $arDrives[$i][1], $arDrives[$i][1])
					Next
				Else
					If $mView.bShowFolders Then
						Local $arFolders = _FileListToArray($sPath, "*", 2)
						For $i=1 To UBound($arFolders)-1 Step 1
							Local $iIndex = _GUICtrlListView_AddItem($hView, $arFolders[$i], 0, 0)
							_GUICtrlListView_SetItemText($hView, $iIndex, __TreeListExplorer__GetTimeString($sPath & $arFolders[$i]), 2)
						Next
					EndIf
					If $mView.bShowFiles Then
						Local $arFiles = _FileListToArray($sPath, "*", 1)
						For $i=1 To UBound($arFiles)-1 Step 1
							Local $sFilePath = $sPath & $arFiles[$i]
							Local $iIndex = _GUICtrlListView_AddItem($hView, $arFiles[$i], 2, 2) ; todo check if icon from filetype can be used
							_GUICtrlListView_SetItemText($hView, $iIndex, __TreeListExplorer__GetSizeString($sFilePath), 1)
							_GUICtrlListView_SetItemText($hView, $iIndex, __TreeListExplorer__GetTimeString($sFilePath), 2)
						Next
					EndIf
				EndIf
		EndSwitch
	EndIf
	Switch $mView.iType
		Case $__TreeListExplorer__Type_TreeView
			_GUICtrlTreeView_EndUpdate($hView)
		Case $__TreeListExplorer__Type_ListView
			_GUICtrlListView_EndUpdate($hView)
	EndSwitch
	If $mView.sCallbackLoading<>Default Then
		Call($mView.sCallbackLoading, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $hView, $mSystem.sRoot, $mSystem.sFolder, False)
		If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mView.sCallbackLoading, "$sCallbackLoading", $mView.iLineNumber)
	EndIf
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetSizeString
; Description ...: Get the size of a file formatted to the nearest magnitude (B, KB, MB, GB, TB, PB, EB).
; Syntax ........: __TreeListExplorer__GetSizeString($sPath)
; Parameters ....: $sPath               - the path of the file.
; Return values .: The file size.
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetSizeString($sPath)
    Local Static $arSizeName = [" B", "KB", "MB", "GB", "TB", "PB", "EB"]

	Local $iSize = FileGetSize($sPath)
    For $i = UBound($arSizeName) To 1 Step -1
        If $iSize >= 1024 ^ $i Then Return Round($iSize/(1024^$i), 2) & " " & $arSizeName[$i]
    Next
    Return $iSize & " " & $arSizeName[0]
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetTimeString
; Description ...: Get the formatted file creation date (YYYY/MM/DD HH:MM:SS)
; Syntax ........: __TreeListExplorer__GetTimeString($sPath)
; Parameters ....: $sPath               - the path of the file.
; Return values .: The creation date
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - Error calling FileGetTime (@extended contains the error from FileGetTime)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetTimeString($sPath)
	Local $arTime = FileGetTime($sPath, 1)
	If @error Then Return SetError(1, @error, "")
	Return StringFormat("%u/%02u/%02u %02u:%02u:%02u", $arTime[0], $arTime[1], $arTime[2], $arTime[3], $arTime[4], $arTime[5])
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__ExpandTreeitem
; Description ...: Expand a TreeItem and load the content of all childs (Show the extend button, if they have childs)
; Syntax ........: __TreeListExplorer__ExpandTreeitem($hView, $hItem[, $bExpand = True])
; Parameters ....: $hView               - the TreeView handle.
;                  $hItem               - the item handle.
;                  $bExpand             - [optional] if true the items on the path are expanded, if false only the path is updated
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__ExpandTreeitem($hView, $hItem, $bExpand = True)
	If __TreeListExplorer__TreeViewItemIsExpanded($hView, $hItem) Then Return True
	__TreeListExplorer__LoadTreeItemContent($hView, $hItem)
	; DO NOT USE _GUICtrlTreeView_Expand IT EXPANDS ALL CHILDREN
	If $bExpand Then _SendMessage($hView, $TVM_EXPAND, $TVE_EXPAND, $hItem, 0, "wparam", "handle")
	Local $mView = $__TreeListExplorer__Data.mViews[$hView]
	Local $sRoot = __TreeListExplorer__GetCurrentRoot($mView.iSystem)
	Local $hChildItem = _GUICtrlTreeView_GetFirstChild($hView, $hItem)
	While $hChildItem<>0
		Local $sChildPath = $sRoot & __TreeListExplorer__TreeViewGetRelPath($mView.iSystem, $hView, $hChildItem)
		If __TreeListExplorer__PathIsFolder($sChildPath) Then
			Local $hSearch = FileFindFirstFile($sChildPath & "\" & "*")
			If $hSearch<>-1 Then
				FileClose($hSearch)
				_GUICtrlTreeView_AddChild($hView, $hChildItem, "HasChilds")
			EndIf
		EndIf
		$hChildItem=_GUICtrlTreeView_GetNextChild($hView, $hChildItem)
	WEnd
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__LoadTreeItemContent
; Description ...: Load the children of the TreeView item.
; Syntax ........: __TreeListExplorer__LoadTreeItemContent($hView, $hItem)
; Parameters ....: $hView               - the TreeView handle.
;                  $hItem               - the item handle.
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__LoadTreeItemContent($hView, $hItem)
	Local $mView = $__TreeListExplorer__Data.mViews[$hView]
	Local $mSystem = $__TreeListExplorer__Data.mSystems[$mView.iSystem]
	Local $sRoot = __TreeListExplorer__RemoveLastFolderFromPath($mSystem.sRoot)
	Local $sPath = $sRoot & StringReplace(_GUICtrlTreeView_GetTree($hView, $hItem), "|", "\") & "\"
	_GUICtrlTreeView_DeleteChildren($hView, $hItem)
	If $mView.bShowFolders Then
		Local $arFolders = _FileListToArray($sPath, "*", 2)
		For $i=1 To UBound($arFolders)-1 Step 1
			_GUICtrlTreeView_AddChild($hView, $hItem, $arFolders[$i], 0, 0)
		Next
	EndIf
	If $mView.bShowFiles Then
		Local $arFiles = _FileListToArray($sPath, "*", 1)
		For $i=1 To UBound($arFiles)-1 Step 1
			_GUICtrlTreeView_AddChild($hView, $hItem, $arFiles[$i], 2, 2)
		Next
	EndIf
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__RemoveLastFolderFromPath
; Description ...: Get the path without the last folder, e.g. C:\Users\User\ => C:\Users\
; Syntax ........: __TreeListExplorer__RemoveLastFolderFromPath($sPath)
; Parameters ....: $sPath               - the path to change.
; Return values .: The shortened path
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__RemoveLastFolderFromPath($sPath)
	Local $arFolder = StringRegExp($sPath, "^(.*?\\?)[^\\]*\\$", 1) ; remove last folder (it is already as root in the treeview)
	If Not @error And UBound($arFolder)>0 Then Return $arFolder[0]
	Return ""
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetDrives
; Description ...: Get all drives and their type
; Syntax ........: __TreeListExplorer__GetDrives()
; Parameters ....:
; Return values .: An Array with all drives. $arDrives[N][0] = Drive name, $arDrives[N][1] = Id of the type
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetDrives()
	Local $arDrives = DriveGetDrive('ALL'), $iType
	Local $arResult[UBound($arDrives)-1][2]
	For $i = 1 To UBound($arDrives)-1
		$arResult[$i-1][0] = $arDrives[$i]
		Switch DriveGetType($arDrives[$i])
			Case 'Fixed'
				$arResult[$i-1][1] = 5
			Case 'CDROM'
				$arResult[$i-1][1] = 6
			Case 'RAMDisk'
				$arResult[$i-1][1] = 7
			Case 'Removable'
				$arResult[$i-1][1] = 4
				If StringLower(StringLeft($arDrives[$i], 2)) = "a:" Or StringLower(StringLeft($arDrives[$i], 2)) = "b:" Then $arResult[$i-1][1] = 3
			Case Else
				$arResult[$i-1][1] = 8
		EndSwitch
	Next
	Return $arResult
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__UpdateTreeViewSelection
; Description ...: Handle the selection of a TreeView item (extending/collapsing the item)
; Syntax ........: __TreeListExplorer__UpdateTreeViewSelection($hView, $hItem[, $bExpandOrCollapse = True])
; Parameters ....: $hView               - the TreeView handle.
;                  $hItem               - the item handle.
;                  $bExpandOrCollapse   - [optional] if true the item is expanded/collapsed, if false only the path is updated
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__UpdateTreeViewSelection($hView, $hItem, $bExpandOrCollapse = True)
	If MapExists($__TreeListExplorer__Data.mViews, $hView) Then
		Local $iSystem = $__TreeListExplorer__Data.mViews[$hView].iSystem
		Local $sPath = __TreeListExplorer__TreeViewGetRelPath($iSystem, $hView, $hItem)
		If __TreeListExplorer__RelPathIsFolder($iSystem, $sPath) Then
			If Not __TreeListExplorer__TreeViewItemIsExpanded($hView, $hItem) Or Not __TreeListExplorer__IsPathOpen($iSystem, $sPath) Then
				__TreeListExplorer__OpenPath($iSystem, $sPath, True, $bExpandOrCollapse)
			Else
				If $bExpandOrCollapse Then _SendMessage($hView, $TVM_EXPAND, $TVE_COLLAPSE, $hItem, 0, "wparam", "handle")
			EndIf
		EndIf
	EndIf
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__TreeViewGetRelPath
; Description ...: Get the path of the TreeView item, relative to the TLE system root
; Syntax ........: __TreeListExplorer__TreeViewGetRelPath($iSystem, $hView, $hItem)
; Parameters ....: $iSystem             - the system ID.
;                  $hView               - the TreeView handle.
;                  $hItem               - the item handle.
; Return values .: The path
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__TreeViewGetRelPath($iSystem, $hView, $hItem)
	Local $sPath = StringReplace(_GUICtrlTreeView_GetTree($hView, $hItem), "|", "\")
	If __TreeListExplorer__RelPathIsFolder($iSystem, $sPath) Then $sPath &= "\"
	If $__TreeListExplorer__Data.mSystems[$iSystem].sRoot <> "" Then
		$arPath = StringRegExp($sPath, "[^\\]*\\?(.*)$", 1) ; remove first element (root)
		If UBound($arPath)>0 Then $sPath = $arPath[0]
	EndIf
	Return $sPath
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__TreeViewItemIsExpanded
; Description ...: Check if a TreeView item is expanded
; Syntax ........: __TreeListExplorer__TreeViewItemIsExpanded($hView, $hItem)
; Parameters ....: $hView               - the TreeView handle.
;                  $hItem               - the item handle.
; Return values .: True if expanded, False otherwise
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__TreeViewItemIsExpanded($hView, $hItem)
	Return BitAND(_GUICtrlTreeView_GetState($hView, $hItem), $TVIS_EXPANDED)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__PathIsFolder
; Description ...: Check if the provided path is a folder
; Syntax ........: __TreeListExplorer__PathIsFolder($sPath)
; Parameters ....: $sPath               - the path to check.
; Return values .: True if $sPath is a folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__PathIsFolder($sPath)
	Return StringInStr(FileGetAttrib($sPath), "D")
EndFunc
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__RelPathIsFolder
; Description ...: Check if the provided relative path is a folder
; Syntax ........: __TreeListExplorer__RelPathIsFolder($iSystem, $sPath)
; Parameters ....: $iSystem             - the system ID.
;                  $sPath               - the path to check.
; Return values .: True if $sPath is a folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__RelPathIsFolder($iSystem, $sPath)
	Return __TreeListExplorer__PathIsFolder($__TreeListExplorer__Data.mSystems[$iSystem].sRoot & $sPath)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__WinProc
; Description ...: WinProc gui message handler
; Syntax ........: __TreeListExplorer__WinProc($hWnd, $iMsg, $iwParam, $ilParam)
; Parameters ....: $hWnd                - the gui handle.
;                  $iMsg                - iMsg.
;                  $iwParam             - iwParam.
;                  $ilParam             - ilParam.
; Return values .: Result of the message processing
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__WinProc($hWnd, $iMsg, $iwParam, $ilParam)
    If $iMsg=$WM_NOTIFY Then ; maybe later: $WM_COMMAND, $WM_HOTKEY
		Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $tInfo
		$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
		$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
		$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
		$iCode = DllStructGetData($tNMHDR, "Code")
		Local $arHwnds = MapKeys($__TreeListExplorer__Data.mViews)
		For $i=0 To UBound($arHwnds)-1 Step 1
			If $arHwnds[$i]=$hWndFrom Then
				Switch $__TreeListExplorer__Data.mViews[$hWndFrom].iType
					Case $__TreeListExplorer__Type_TreeView
						Switch $iCode
							Case $TVN_ITEMEXPANDINGA, $TVN_ITEMEXPANDINGW
								Local $tNMTREEVIEW = DllStructCreate($tagNMTREEVIEW, $ilParam)
								Switch DllStructGetData($tNMTREEVIEW, 'Action')
									Case $TVE_EXPAND
										 ; maybe in adblibregister
										Local $hItem = DllStructGetData($tNMTREEVIEW, 'NewhItem')
										Local $mView = $__TreeListExplorer__Data.mViews[$hWndFrom]
										If $mView.hCurrentExpand = -1 Then
											$__TreeListExplorer__Data["mViews"][$hWndFrom]["hCurrentExpand"] = $hItem
											Local $sPath = __TreeListExplorer__TreeViewGetRelPath($mView.iSystem, $hWndFrom, $hItem)
											If $mView.sCallbackLoading<>Default Then
												Call($mView.sCallbackLoading, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $hWndFrom, $__TreeListExplorer__Data.mSystems[$mView.iSystem].sRoot, $sPath, True)
												If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mView.sCallbackLoading, "$sCallbackLoading", $mView.iLineNumber)
											EndIf
											_GUICtrlTreeView_BeginUpdate($hWndFrom)
											__TreeListExplorer__ExpandTreeitem($hWndFrom, $hItem)
											_GUICtrlTreeView_EndUpdate($hWndFrom)
											If $mView.sCallbackLoading<>Default Then
												Call($mView.sCallbackLoading, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $hWndFrom, $__TreeListExplorer__Data.mSystems[$mView.iSystem].sRoot, $sPath, False)
												If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mView.sCallbackLoading, "$sCallbackLoading", $mView.iLineNumber)
											EndIf
											$__TreeListExplorer__Data["mViews"][$hWndFrom]["hCurrentExpand"] = -1
										EndIf
								EndSwitch
							Case $NM_CLICK
								Local $mView = $__TreeListExplorer__Data["mViews"][$hWndFrom]
								If $mView.hCurrentExpand = -1 Then
									Local $iX =_WinAPI_GetMousePosX(True, $hWndFrom)
									Local $iY =_WinAPI_GetMousePosY(True, $hWndFrom)
									Local $hItem =_GUICtrlTreeView_HitTestItem($hWndFrom, $iX, $iY)
									Local $iHitStat =_GUICtrlTreeView_HitTest($hWndFrom, $iX, $iY)
									If $hItem<>0 And BitAND($iHitStat, 4) Then
										$__TreeListExplorer__Data["mViews"][$hWndFrom]["hCurrentExpand"] = $hItem
										;__TreeListExplorer__UpdateTreeViewSelection($hWndFrom, $hItem)
										Local $sPath = __TreeListExplorer__TreeViewGetRelPath($mView.iSystem, $hWndFrom, $hItem)
										If $mView.sCallbackClick <> Default Then
											Call($mView.sCallbackClick, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $hWndFrom, $__TreeListExplorer__Data.mSystems[$mView.iSystem].sRoot, $sPath)
											If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mView.sCallbackClick, "$sCallbackOnClick", $mView.iLineNumber)
										EndIf
										$__TreeListExplorer__Data["mViews"][$hWndFrom]["hCurrentExpand"] = -1
									EndIf
								EndIf
							Case $NM_DBLCLK
								Local $iX =_WinAPI_GetMousePosX(True, $hWndFrom)
								Local $iY =_WinAPI_GetMousePosY(True, $hWndFrom)
								Local $hItem =_GUICtrlTreeView_HitTestItem($hWndFrom, $iX, $iY)
								Local $iHitStat =_GUICtrlTreeView_HitTest($hWndFrom, $iX, $iY)
								If $hItem<>0 And BitAND($iHitStat, 4) Then
									Local $mView = $__TreeListExplorer__Data["mViews"][$hWndFrom]
									Local $sPath = __TreeListExplorer__TreeViewGetRelPath($mView.iSystem, $hWndFrom, $hItem)
									If $mView.sCallbackDBClick <> Default Then
										Call($mView.sCallbackDBClick, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $hWndFrom, $__TreeListExplorer__Data.mSystems[$mView.iSystem].sRoot, $sPath)
										If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mView.sCallbackDBClick, "$sCallbackOnDoubleClick", $mView.iLineNumber)
									EndIf
								EndIf
							Case $TVN_SELCHANGEDA, $TVN_SELCHANGEDW
								Local $mView = $__TreeListExplorer__Data["mViews"][$hWndFrom]
								If $mView.hCurrentExpand = -1 Then
									Local $hItem = _GUICtrlTreeView_GetSelection($hWndFrom)
									$__TreeListExplorer__Data["mViews"][$hWndFrom]["hCurrentExpand"] = $hItem
									If $mView.sCallbackSelect <> Default Then
										If $hItem<>0 Then
											Local $sPath = __TreeListExplorer__TreeViewGetRelPath($mView.iSystem, $hWndFrom, $hItem)
											;__TreeListExplorer__UpdateTreeViewSelection($hWndFrom, $hItem, False)
											Call($mView.sCallbackSelect, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $hWndFrom, $__TreeListExplorer__Data.mSystems[$mView.iSystem].sRoot, $sPath)
											If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mView.sCallbackSelect, "$sCallbackOnSelectionChange", $mView.iLineNumber)
										EndIf
									EndIf
									$__TreeListExplorer__Data["mViews"][$hWndFrom]["hCurrentExpand"] = -1
								EndIf
						EndSwitch
					Case $__TreeListExplorer__Type_ListView
						Switch $iCode
							Case $LVN_ITEMCHANGED
								Local $mView = $__TreeListExplorer__Data["mViews"][$hWndFrom]
								If $mView.sCallbackSelect <> Default Then
									Local $iIndex = _GUICtrlListView_GetSelectionMark($hWndFrom)
									If $iIndex>=0 Then
										Local $sRelPath = $__TreeListExplorer__Data["mSystems"][$mView.iSystem]["sFolder"] & _GUICtrlListView_GetItemText($hWndFrom, $iIndex, 0)
										Call($mView.sCallbackSelect, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $hWndFrom, $__TreeListExplorer__Data.mSystems[$mView.iSystem].sRoot, $sRelPath)
										If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mView.sCallbackSelect, "$sCallbackOnSelectionChange", $mView.iLineNumber)
									EndIf
								EndIf
							Case $NM_CLICK
								Local $iIndex = _GUICtrlListView_GetSelectionMark($hWndFrom)
								If $iIndex<>-1 Then
									Local $iSystem = $__TreeListExplorer__Data.mViews[$hWndFrom].iSystem
									Local $sRelPath = $__TreeListExplorer__Data["mSystems"][$iSystem]["sFolder"] & _GUICtrlListView_GetItemText($hWndFrom, $iIndex, 0)
									Local $mView = $__TreeListExplorer__Data.mViews[$hWndFrom]
									If $mView.sCallbackClick <> Default Then
										Call($mView.sCallbackClick, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $hWndFrom, $__TreeListExplorer__Data.mSystems[$iSystem].sRoot, $sRelPath)
										If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mView.sCallbackClick, "$sCallbackOnClick", $mView.iLineNumber)
									EndIf
								EndIf
							Case $NM_DBLCLK
								Local $iIndex = _GUICtrlListView_GetSelectionMark($hWndFrom)
								Local $mView = $__TreeListExplorer__Data.mViews[$hWndFrom]
								Local $iSystem = $mView.iSystem
								If $iIndex=0 And _GUICtrlListView_GetItemText($hWndFrom, $iIndex, 0) = ".." Then
									Local $sPath = __TreeListExplorer__GetCurrentPath($iSystem)
									If $sPath <> "" Then
										$sPath = __TreeListExplorer__RemoveLastFolderFromPath($sPath)
										__TreeListExplorer__OpenPath($iSystem, $sPath)
									EndIf
								ElseIf $iIndex<>-1 Then
									Local $sPath = __TreeListExplorer__GetCurrentPath($iSystem) & _GUICtrlListView_GetItemText($hWndFrom, $iIndex, 0)
									__TreeListExplorer__OpenPath($iSystem, $sPath)
									If $mView.sCallbackDBClick Then
										Call($mView.sCallbackDBClick, __TreeListExplorer__GetIDFromSystemKey($mView.iSystem), $hWndFrom, $__TreeListExplorer__Data.mSystems[$iSystem].sRoot, $sPath)
										If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mView.sCallbackDBClick, "$sCallbackOnDoubleClick", $mView.iLineNumber)
									EndIf
								EndIf
						EndSwitch
				EndSwitch
			EndIf
		Next
	EndIf
	If MapExists($__TreeListExplorer__Data.mGuis, $hWnd) Then Return _WinAPI_CallWindowProc($__TreeListExplorer__Data.mGuis[$hWnd].hPrevProc, $hWnd, $iMsg, $iwParam, $ilParam)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__ConsoleWriteCallbackError
; Description ...: Write an error to the console, providing information about a wrong callback function
; Syntax ........: __TreeListExplorer__ConsoleWriteCallbackError($sFunc, $sVarName, $iLineNumber[, $sLineFunc = "__TreeListExplorer_AddView"])
; Parameters ....: $sFunc               - the function that should be called.
;                  $sVarName            - the parameter name, where the function was provided to the UDF.
;                  $iLineNumber         - the line number, where the function was provided to the UDF.
;                  $sLineFunc           - [optional] the function name, of the function, where the callback function was provided
;                                         to the UDF. Default is "__TreeListExplorer_AddView".
; Return values .: None
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__ConsoleWriteCallbackError($sFunc, $sVarName, $iLineNumber, $sLineFunc = "__TreeListExplorer_AddView")
	ConsoleWrite('Error calling callback function "'&$sFunc&'" provided as '&$sVarName&' to "'&$sLineFunc&'" in Line: '&$iLineNumber& _
	". The function probably has the wrong number of parameters."&@crlf)
EndFunc
