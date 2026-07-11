#include "functions.h"

/*
	Author: Nimmersatt

	Description:
	Shows a dialog to rename a group using ctrlCreate on the main display.
	Uses setGroupIdGlobal to persist the name change across the network.

	Parameter(s):
	_this select 0: GROUP - The group to rename

	Returns: 
	Nothing
*/

params [["_group", grpNull]];

if (isNull _group) exitWith {};

disableSerialization;

waitUntil {!isNull (findDisplay 12)};
private _display = findDisplay 12;
private _currentName = groupId _group;

// Store references in uiNamespace so event handlers can access them
uiNamespace setVariable ["AIC_RenameGroup_Group", _group];
uiNamespace setVariable ["AIC_RenameGroup_Done", false];
uiNamespace setVariable ["AIC_RenameGroup_Result", ""];

// --- Create dialog background ---
private _bg = _display ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [
	0.35 * safeZoneW + safeZoneX,
	0.35 * safeZoneH + safeZoneY,
	0.3 * safeZoneW,
	0.15 * safeZoneH
];
_bg ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.9];
_bg ctrlCommit 0;

// --- Title ---
private _title = _display ctrlCreate ["RscText", -1];
_title ctrlSetPosition [
	0.35 * safeZoneW + safeZoneX,
	0.32 * safeZoneH + safeZoneY,
	0.3 * safeZoneW,
	0.03 * safeZoneH
];
_title ctrlSetStructuredText parseText "<t align='center' font='PuristaMedium' size='1.2'>Rename Group</t>";
_title ctrlCommit 0;

// --- Edit field ---
private _edit = _display ctrlCreate ["RscEdit", -1];
_edit ctrlSetPosition [
	0.36 * safeZoneW + safeZoneX,
	0.37 * safeZoneH + safeZoneY,
	0.28 * safeZoneW,
	0.04 * safeZoneH
];
_edit ctrlSetText _currentName;
_edit ctrlSetTextColor [0, 0, 0, 1];
_edit ctrlSetBackgroundColor [1, 1, 1, 1];
_edit ctrlSetFont "PuristaMedium";
_edit ctrlCommit 0;
ctrlSetFocus _edit;

// Store edit control reference
uiNamespace setVariable ["AIC_RenameGroup_Edit", _edit];

// --- OK Button ---
private _btnOk = _display ctrlCreate ["RscButton", -1];
_btnOk ctrlSetPosition [
	0.39 * safeZoneW + safeZoneX,
	0.44 * safeZoneH + safeZoneY,
	0.08 * safeZoneW,
	0.04 * safeZoneH
];
_btnOk ctrlSetText "OK";
_btnOk ctrlSetFont "PuristaMedium";
_btnOk ctrlCommit 0;
_btnOk ctrlAddEventHandler ["ButtonClick", {
	uiNamespace setVariable ["AIC_RenameGroup_Done", true];
	uiNamespace setVariable ["AIC_RenameGroup_Result", ctrlText (uiNamespace getVariable ["AIC_RenameGroup_Edit", controlNull])];
}];

// --- Cancel Button ---
private _btnCancel = _display ctrlCreate ["RscButton", -1];
_btnCancel ctrlSetPosition [
	0.48 * safeZoneW + safeZoneX,
	0.44 * safeZoneH + safeZoneY,
	0.08 * safeZoneW,
	0.04 * safeZoneH
];
_btnCancel ctrlSetText "Cancel";
_btnCancel ctrlSetFont "PuristaMedium";
_btnCancel ctrlCommit 0;
_btnCancel ctrlAddEventHandler ["ButtonClick", {
	uiNamespace setVariable ["AIC_RenameGroup_Done", true];
	uiNamespace setVariable ["AIC_RenameGroup_Result", ""];
}];

// --- Store control list for cleanup ---
uiNamespace setVariable ["AIC_RenameGroup_Controls", [_bg, _title, _edit, _btnOk, _btnCancel]];

// --- Wait for user input ---
waitUntil {
	sleep 0.01;
	(uiNamespace getVariable ["AIC_RenameGroup_Done", false]) || {isNull (findDisplay 12)}
};

// --- Process result ---
private _result = uiNamespace getVariable ["AIC_RenameGroup_Result", ""];

if (_result != "" && {!isNull _group}) then {
	// Trim whitespace
	_result = (_result splitString toString [9,10,13,32]) joinString " ";
	// Limit to 24 chars (Arma's groupId max length)
	if (count _result > 24) then { _result = _result select [0, 24] };
	
	if (_result != "") then {
		private _currentId = groupId _group;
		// setGroupIdGlobal expects format [group, [name, color]]
		[_group, [_result]] remoteExec ["setGroupIdGlobal", 2];
	};
};

// --- Cleanup ---
{
	ctrlDelete _x;
} forEach (uiNamespace getVariable ["AIC_RenameGroup_Controls", []]);

// --- Clear namespace variables ---
uiNamespace setVariable ["AIC_RenameGroup_Group", nil];
uiNamespace setVariable ["AIC_RenameGroup_Done", nil];
uiNamespace setVariable ["AIC_RenameGroup_Result", nil];
uiNamespace setVariable ["AIC_RenameGroup_Edit", nil];
uiNamespace setVariable ["AIC_RenameGroup_Controls", nil];