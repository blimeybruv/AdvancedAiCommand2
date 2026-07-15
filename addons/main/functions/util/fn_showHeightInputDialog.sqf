/*
	Author: Nimmersatt

	Description:
	Shows a small dialog to input a numeric height value (meters).
	Returns the entered number, or a negative value to signal cancellation.

	Parameter(s):
	_this select 0: STRING - Dialog title (e.g. "Fly above ground (AGL)")

	Returns:
	NUMBER - The entered height in meters, or a negative value (e.g. -1) if cancelled
*/
params [["_title", "Enter Height"]];

disableSerialization;

waitUntil {!isNull (findDisplay 12)};
private _display = findDisplay 12;

// Store result
uiNamespace setVariable ["AIC_HeightInput_Done", false];
uiNamespace setVariable ["AIC_HeightInput_Result", -1];

// --- Background ---
private _bg = _display ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [
	0.32 * safeZoneW + safeZoneX,
	0.35 * safeZoneH + safeZoneY,
	0.36 * safeZoneW,
	0.20 * safeZoneH
];
_bg ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.92];
_bg ctrlCommit 0;

// --- Title ---
private _titleCtrl = _display ctrlCreate ["RscText", -1];
_titleCtrl ctrlSetPosition [
	0.32 * safeZoneW + safeZoneX,
	0.36 * safeZoneH + safeZoneY,
	0.36 * safeZoneW,
	0.03 * safeZoneH
];
_titleCtrl ctrlSetText _title;
_titleCtrl ctrlSetTextColor [1, 1, 1, 1];
_titleCtrl ctrlSetFont "PuristaMedium";
_titleCtrl ctrlCommit 0;

// --- Edit field ---
private _edit = _display ctrlCreate ["RscEdit", -1];
_edit ctrlSetPosition [
	0.33 * safeZoneW + safeZoneX,
	0.40 * safeZoneH + safeZoneY,
	0.34 * safeZoneW,
	0.04 * safeZoneH
];
_edit ctrlSetText "100";
_edit ctrlSetTextColor [0, 0, 0, 1];
_edit ctrlSetBackgroundColor [1, 1, 1, 1];
_edit ctrlSetFont "PuristaMedium";
_edit ctrlCommit 0;
ctrlSetFocus _edit;

uiNamespace setVariable ["AIC_HeightInput_Edit", _edit];

// --- Info label ---
private _info = _display ctrlCreate ["RscText", -1];
_info ctrlSetPosition [
	0.33 * safeZoneW + safeZoneX,
	0.45 * safeZoneH + safeZoneY,
	0.34 * safeZoneW,
	0.03 * safeZoneH
];
_info ctrlSetText "Height in meters (e.g. 100)";
_info ctrlSetTextColor [0.67, 0.67, 0.67, 1];
_info ctrlSetFont "PuristaMedium";
_info ctrlCommit 0;

// --- OK Button ---
private _btnOk = _display ctrlCreate ["RscButton", -1];
_btnOk ctrlSetPosition [
	0.38 * safeZoneW + safeZoneX,
	0.49 * safeZoneH + safeZoneY,
	0.11 * safeZoneW,
	0.04 * safeZoneH
];
_btnOk ctrlSetText "OK";
_btnOk ctrlSetFont "PuristaMedium";
_btnOk ctrlCommit 0;
_btnOk ctrlAddEventHandler ["ButtonClick", {
	private _text = ctrlText (uiNamespace getVariable ["AIC_HeightInput_Edit", controlNull]);
	private _num = parseNumber _text;
	if (_text != "" && _num > 0) then {
		uiNamespace setVariable ["AIC_HeightInput_Result", _num];
	} else {
		uiNamespace setVariable ["AIC_HeightInput_Result", -1];
	};
	uiNamespace setVariable ["AIC_HeightInput_Done", true];
}];

// --- Cancel Button ---
private _btnCancel = _display ctrlCreate ["RscButton", -1];
_btnCancel ctrlSetPosition [
	0.50 * safeZoneW + safeZoneX,
	0.49 * safeZoneH + safeZoneY,
	0.11 * safeZoneW,
	0.04 * safeZoneH
];
_btnCancel ctrlSetText "Cancel";
_btnCancel ctrlSetFont "PuristaMedium";
_btnCancel ctrlCommit 0;
_btnCancel ctrlAddEventHandler ["ButtonClick", {
	uiNamespace setVariable ["AIC_HeightInput_Result", -1];
	uiNamespace setVariable ["AIC_HeightInput_Done", true];
}];

// --- Store all controls for cleanup ---
uiNamespace setVariable ["AIC_HeightInput_Controls", [_bg, _titleCtrl, _edit, _info, _btnOk, _btnCancel]];

// --- Wait for input ---
waitUntil {
	sleep 0.01;
	(uiNamespace getVariable ["AIC_HeightInput_Done", false]) || {isNull (findDisplay 12)}
};

// --- Read result ---
private _result = uiNamespace getVariable ["AIC_HeightInput_Result", -1];

// --- Cleanup ---
{
	ctrlDelete _x;
} forEach (uiNamespace getVariable ["AIC_HeightInput_Controls", []]);

uiNamespace setVariable ["AIC_HeightInput_Done", nil];
uiNamespace setVariable ["AIC_HeightInput_Result", nil];
uiNamespace setVariable ["AIC_HeightInput_Edit", nil];
uiNamespace setVariable ["AIC_HeightInput_Controls", nil];

_result
