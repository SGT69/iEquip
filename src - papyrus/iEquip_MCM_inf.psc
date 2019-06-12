Scriptname iEquip_MCM_inf extends iEquip_MCM_Page

import iEquip_StringExt
import StringUtil

iEquip_KeyHandler Property KH Auto
iEquip_EditMode Property EM Auto

string[] saPresets

; #############
; ### SETUP ###

function initData()                  ; Initialize page specific data
endFunction

int function saveData()             ; Save page data and return jObject
    return jArray.object()
endFunction

function loadData(int jPageObj)     ; Load page data from jPageObj
endFunction

function drawPage()
    MCM.AddHeaderOption("<font color='#C1A57A'>$iEquip_MCM_lbl_Info</font>")
	MCM.AddTextOptionST("inf_txt_iEquipVersion", "$iEquip_MCM_inf_lbl_version", MCM.GetVersion() as string)
    ;+++Dependency checks
    ;+++Supported mods detected

	MCM.SetCursorPosition(1)
	MCM.AddHeaderOption("<font color='#C1A57A'>$iEquip_MCM_inf_lbl_presets</font>")
	MCM.AddInputOptionST("inf_inp_savepreset", "$iEquip_MCM_inf_lbl_savepreset", "")
	if jMap.count(JValue.readFromDirectory(MCM.MCMSettingsPath, MCM.FileExtMCM)) > 0
		MCM.AddMenuOptionST("inf_men_loadpreset", "$iEquip_MCM_inf_lbl_loadpreset", "")
		MCM.AddMenuOptionST("inf_men_deletepreset", "$iEquip_MCM_inf_lbl_deletepreset", "")
	endIf
	MCM.AddEmptyOption()
	
	MCM.AddHeaderOption("<font color='#C1A57A'>$iEquip_MCM_inf_lbl_maintenance</font>")
	MCM.AddTextOptionST("inf_txt_dumpJcontainer", "$iEquip_MCM_inf_lbl_dumpJcontainer", "")
	MCM.AddTextOptionST("inf_txt_rstLayout", "$iEquip_MCM_inf_lbl_rstLayout", "")
endFunction

; ########################
; ### Information Page ###
; ########################

; ---------------
; - Information -
; ---------------

State inf_inp_savepreset
    event OnBeginState()
        if currentEvent == "Highlight"
            MCM.SetInfoText("$iEquip_MCM_inf_txt_savepreset")
        elseIf currentEvent == "Open"
			MCM.SetInputDialogStartText(iEquip_StringExt.LocalizeString("$iEquip_MCM_inf_lbl_PresetName"))
        elseIf currentEvent == "Accept"
			MCM.savePreset(currentStrVar)
			MCM.ForcePageReset()
        endIf 
    endEvent
endState

State inf_men_loadpreset
    event OnBeginState()
        if currentEvent == "Highlight"
            MCM.SetInfoText("$iEquip_MCM_inf_txt_loadpreset")
        elseIf currentEvent == "Open"
			MCM.getPresets(saPresets, "$iEquip_MCM_inf_lbl_noLoad")
			MCM.fillMenu(0, saPresets, 0)
        elseIf currentEvent == "Accept"
			if (currentVar as int != 0)
				MCM.loadPreset(saPresets[currentVar as int])
			endIf
        endIf 
    endEvent
endState

State inf_men_deletepreset
    event OnBeginState()
        if currentEvent == "Highlight"
            MCM.SetInfoText("$iEquip_MCM_inf_txt_deletepreset")
        elseIf currentEvent == "Open"
			MCM.getPresets(saPresets, "$iEquip_MCM_inf_lbl_noDelete")
			MCM.fillMenu(0, saPresets, 0)
        elseIf currentEvent == "Accept"
			if (currentVar as int != 0)
				MCM.deletePreset(saPresets[currentVar as int])
				MCM.ForcePageReset()
			endIf
        endIf 
    endEvent
endState

; ---------------
; - Maintenance -
; ---------------

State inf_txt_dumpJcontainer
    event OnBeginState()
        if currentEvent == "Highlight"
            MCM.SetInfoText("$iEquip_MCM_inf_txt_dumpJcontainer")
        elseIf currentEvent == "Select"
			jValue.writeTofile(WC.iEquipQHolderObj, "Data/iEquip/Debug/JCDebug.json")
        endIf 
    endEvent
endState

State inf_txt_rstLayout
    event OnBeginState()
        if currentEvent == "Highlight"
            MCM.SetInfoText("$iEquip_MCM_inf_txt_rstLayout")
        elseIf currentEvent == "Select"
            if MCM.ShowMessage("$iEquip_MCM_inf_msg_rstLayout", true, "$iEquip_MCM_common_reset", "$iEquip_MCM_common_cancel")
				int jObj = JValue.readFromDirectory(MCM.MCMSettingsPath, MCM.FileExtMCMDef)
				string[] tmpStrArr = jMap.allKeysPArray(jObj)
				jValue.zeroLifetime(jObj)
				MCM.loadPreset(saPresets[0], true)
            endIf
        endIf 
    endEvent
endState
