﻿import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.controls.TextInput;
import Shared.GlobalFunc;

import skyui.components.ButtonPanel;
import skyui.defines.Input;

import skyui.util.Translator;


class iEquip_uilib.iEquipTextInputDialog extends MovieClip
{
	public var buttonPanel: ButtonPanel;
	public var textInput: TextInput;
	public var titleTextField: TextField;
	
	private var requestDataId_: Number;

	public function iEquipTextInputDialog()
	{
		super();
	}
	
	public function onLoad()
	{
		super.onLoad();
		
		// Initially hidden
		_visible = false;
		
		Mouse.addListener(this);
		Key.addListener(this);
		
		// SKSE functions not yet available and there's no InitExtensions...
		// This should do the trick.
		requestDataId_ = setInterval(this, "requestData", 1);
	}
	
	private function requestData(): Void
	{
		clearInterval(requestDataId_);
		
		skse.AllowTextInput(true);
		skse.SendModEvent("iEquip_textInputOpen");		
	}

	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{		
		var bHandledInput: Boolean = false;
		if (GlobalFunc.IsKeyPressed(details)) {
			if(details.navEquivalent == NavigationCode.ENTER) {
				exitMenu(false);
				bHandledInput = true;
			} else if(details.navEquivalent == NavigationCode.TAB) {
				exitMenu(true);
				bHandledInput = true;
			}
		}
		
		if(bHandledInput) {
			return bHandledInput;
		} else {
			var nextClip = pathToFocus.shift();
			if (nextClip.handleInput(details, pathToFocus)) {
				return true;
			}
		}
		
		return false;
	}

	private function setupButtons(platform: Number): Void
	{
		var acceptControls: Object;
		var cancelControls: Object;

		if (platform == 0) {
			acceptControls = Input.Enter;
			cancelControls = Input.Tab;
		} else {
			acceptControls = Input.Accept;
			cancelControls = Input.Cancel;
		}
		
		buttonPanel.clearButtons();
		var cancelButton = buttonPanel.addButton({text: "$Cancel", controls: cancelControls});
		var acceptButton = buttonPanel.addButton({text: "$Accept", controls: acceptControls});
		acceptButton.addEventListener("click", this, "onAcceptPress");
		cancelButton.addEventListener("click", this, "onCancelPress");
		buttonPanel.updateButtons();
	}
	
	private function onAcceptPress(): Void
	{
		exitMenu(false);
	}
	
	private function onCancelPress(): Void
	{
		exitMenu(true);
	}

	private function exitMenu(canceled: Boolean): Void
	{
		skse.AllowTextInput(false);
		skse.SendModEvent("iEquip_textInputClose", textInput.text, canceled ? 1 : 0);
		skse.CloseMenu("CustomMenu");
	}
	
  /* Papyrus */
  
	public function setPlatform(platform: Number): Void
	{
		buttonPanel.setPlatform(platform, false);
		setupButtons(platform);
	}
  
	public function initData(titleText: String, initText: String): Void
	{
		titleTextField.textAutoSize = "shrink";
		titleText = Translator.translateNested(titleText);
		titleTextField.SetText(titleText);
		initText = Translator.translateNested(initText);
		textInput.text = initText;
		if (initText == "RRGGBB"){
			textInput.textField.maxChars = 6;
			textInput.textField.restrict = "a-fA-F0-9";
		}else{
			textInput.textField.restrict = "^\\\\/\\:\\*\\?\"\\<\\>\\|";
		}
		gfx.managers.FocusHandler.instance.setFocus(textInput.textField);
		textInput.focused = true;
		Selection.setFocus(textInput.textField);
		Selection.setSelection(0,textInput.textField.text.length);
		_visible = true;
	}
}