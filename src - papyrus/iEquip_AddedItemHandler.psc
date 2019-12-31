
Scriptname iEquip_AddedItemHandler extends ReferenceAlias

Import iEquip_AmmoExt
Import iEquip_FormExt

iEquip_WidgetCore Property WC Auto
iEquip_AmmoMode Property AM Auto
iEquip_PotionScript Property PO Auto
iEquip_TorchScript Property TO Auto

Actor Property PlayerRef Auto

light property iEquipDroppedTorch auto
MiscObject property iEquipBurntOutTorch auto

FormList Property iEquip_RemovedItemsFLST Auto
FormList Property iEquip_ItemsToAddFLST Auto

bool bSwitchingTorches

function initialise(bool bEnabled)
	;debug.trace("iEquip_AddedItemHandler initialise start")
	if bEnabled
		GoToState("")
	else
		GoToState("DISABLED")
	endIf
	;debug.trace("iEquip_AddedItemHandler initialise end")
endFunction

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	if akBaseItem as weapon || akBaseItem as ammo || akBaseItem as potion || akBaseItem as light || akBaseItem == iEquipDroppedTorch || akBaseItem == iEquipBurntOutTorch || (akBaseItem as armor && (akBaseItem as armor).IsShield()) || akBaseItem as scroll
		;debug.trace("iEquip_AddedItemHandler OnItemAdded start - akBaseItem: " + akBaseItem + " - " + akBaseItem.GetName() + ", aiItemCount: " + aiItemCount + ", akItemReference: " + akItemReference + ", bSwitchingTorches: " + bSwitchingTorches)
		if bSwitchingTorches && akBaseItem == TO.realTorchForm
			bSwitchingTorches = false
		elseIf !(akBaseItem == iEquipDroppedTorch as form && TO.bSettingLightRadius)
			iEquip_ItemsToAddFLST.AddForm(akBaseItem)
			registerForSingleUpdate(0.5)
		endIf
		if akItemReference && (akBaseItem == iEquipDroppedTorch || akBaseItem == iEquipBurntOutTorch)
			akItemReference.Delete()
			akItemReference.Disable()
			TO.aDroppedTorches[TO.aDroppedTorches.Find(akItemReference)] = none
		endIf
		;debug.trace("iEquip_AddedItemHandler OnItemAdded end")
	endIf
endEvent

;/Int index = Math.RightShift(form.GetFormID(), 24)
index = Math.LogicalAnd(index, 0xFF)/;

;/if Game.GetModName(Math.LogicalAnd(Math.RightShift(formToAdd.GetFormID(), 24), 0xFF) == "JZBai_ThrowingWpnsLite.esp"/;

event OnUpdate()
	;debug.trace("iEquip_AddedItemHandler OnUpdate start")
	int i
	int j
	int numForms = iEquip_ItemsToAddFLST.GetSize()
	;debug.trace("iEquip_AddedItemHandler OnUpdate - number of forms to process: " + numForms)
	form formToAdd
	while i < numForms
		formToAdd = iEquip_ItemsToAddFLST.GetAt(i)
																											; Handle Potions, Ammo and bound ammo first
		if formToAdd
			if formToAdd as potion
				PO.onPotionAdded(formToAdd)
			;/elseIf formToAdd as ammo && (Game.GetModName(formToAdd.GetFormID() / 0x1000000) != "JZBai_ThrowingWpnsLite.esp")/;
			elseIf formToAdd as ammo && Game.GetModName(Math.LogicalAnd(Math.RightShift(formToAdd.GetFormID(), 24), 0xFF)) != "JZBai_ThrowingWpnsLite.esp"
				if WC.BW.bIsBoundSpellEquipped && iEquip_AmmoExt.IsAmmoBound(formToAdd as ammo)
					AM.addBoundAmmoToQueue(formToAdd, formToAdd.GetName())
				else
					AM.onAmmoAdded(formToAdd)
				endIf
		    																								; Next check if the item just added is currently in the removed items cache then re-add it to the queue it was removed from
		    elseIf WC.bEnableRemovedItemCaching && iEquip_RemovedItemsFLST.HasForm(formToAdd)
		    	WC.addBackCachedItem(formToAdd)

			else
				if formToAdd as weapon || formToAdd as armor 												; If we've picked up a weapon or shield and we have auto-add/equip weapons and shields enabled run that now
					WC.onWeaponOrShieldAdded(formToAdd)

				elseIf formToAdd == iEquipDroppedTorch as form || formToAdd == iEquipBurntOutTorch as form	; If we've just picked up a torch which was dropped during the final 30s with burn out enabled substitute it for...
					bSwitchingTorches = true
					PlayerRef.RemoveItem(formToAdd, 1, true)
					if Game.GetModByName("RealisticTorches.esp") != 255
						formToAdd = Game.GetFormFromFile(0x00002DC5, "RealisticTorches.esp") as form 		; RT_TorchOut - Burnt Out Torch (if Realistic Torches detected)
					else
						formToAdd = TO.realTorchForm 														; Or a real torch
					endIf
					PlayerRef.AddItem(formToAdd, 1, true)
				endIf
		    																								; Finally check if we've just added one of a currently equipped item which requires a counter update
				j = 0
				int itemType = formToAdd.GetType()
				while j < 2
					if WC.asCurrentlyEquipped[j] == formToAdd.GetName()
						;Ammo, scrolls, torch or other throwing weapons
						if itemType == 42 || itemType == 23 || itemType == 31 || (itemType == 41 && iEquip_FormExt.IsGrenade(formToAdd))	
			    			WC.setSlotCount(j, PlayerRef.GetItemCount(formToAdd))
			    		endIf
		        	endIf
		        	j += 1
		        endWhile
			endIf
		endIf
		i += 1
	endWhile
	iEquip_ItemsToAddFLST.Revert()
	;debug.trace("iEquip_AddedItemHandler OnUpdate end - all added forms processed, iEquip_ItemsToAddFLST count: " + iEquip_ItemsToAddFLST.GetSize() + " (should be 0)")
endEvent

auto state DISABLED
	event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
		;Do nothing
	endEvent
endState
