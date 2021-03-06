ScriptName iEquip_PosIndFadeUpdateScript Extends Quest Hidden

Import UI

iEquip_WidgetCore Property WC Auto

int property Q auto

String WidgetRoot

bool bWaitingForFadeoutUpdate

function registerForFadeoutUpdate()
	WidgetRoot = WC.WidgetRoot
	float delay
	if WC.bEquipOnPause
		delay = WC.fEquipOnPauseDelay
	else
		delay = 1.6
	endIf
	RegisterForSingleUpdate(delay)
	bWaitingForFadeoutUpdate = true
endFunction

event OnUpdate()
	if bWaitingForFadeoutUpdate ;Failsafe bool to block OnUpdate if triggered from another script on the quest
		bWaitingForFadeoutUpdate = false
		WC.abCyclingQueue[Q] = false
		if WC.iPosInd != 2
			UI.invokeInt("HUD Menu", WidgetRoot + ".hideQueuePositionIndicator", Q)
		endIf
	endIf
endEvent