#include "..\functions.h"

/*
	Author: Nimmersatt

	Description:
	Shows an input dialog for DEFEND waypoint parameters.
	The dialog collects radius, threshold, patrol chance, and hold behavior
	and returns them via callback.

	Parameter(s):
	_this select 0: CODE - Callback function to call with the defend parameter array
	_this select 1: ARRAY - Default values [radius, threshold, patrol, hold]

	Returns:
	Nothing. The callback is invoked with: [_radius, _threshold, _patrolChance, _holdChance]
*/

params [["_callback", {}, [{}]], ["_defaultValues", [50, 3, 10, 0], [[]], [4]]];

_defaultValues params [["_defaultRadius", 50, [0]], ["_defaultThreshold", 3, [0]], ["_defaultPatrol", 10, [0]], ["_defaultHold", 0, [0]]];

disableSerialization;

waitUntil {!isNull (findDisplay 12)};
private _display = findDisplay 12;

// Store result
uiNamespace setVariable ["AIC_DefendInput_Done", false];
uiNamespace setVariable ["AIC_DefendInput_Cancelled", false];
uiNamespace setVariable ["AIC_DefendInput_Radius", _defaultRadius];
uiNamespace setVariable ["AIC_DefendInput_Threshold", _defaultThreshold];
uiNamespace setVariable ["AIC_DefendInput_Patrol", _defaultPatrol];
uiNamespace setVariable ["AIC_DefendInput_Hold", _defaultHold];

// Dialog dimensions
private _dlgX = 0.28 * safeZoneW + safeZoneX;
private _dlgY = 0.20 * safeZoneH + safeZoneY;
private _dlgW = 0.44 * safeZoneW;
private _dlgH = 0.35 * safeZoneH;

// --- Background ---
private _bg = _display ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [_dlgX, _dlgY, _dlgW, _dlgH];
_bg ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.92];
_bg ctrlCommit 0;

// --- Title ---
private _titleCtrl = _display ctrlCreate ["RscText", -1];
_titleCtrl ctrlSetPosition [
	_dlgX + 0.01 * safeZoneW,
	_dlgY + 0.01 * safeZoneH,
	_dlgW - 0.02 * safeZoneW,
	0.03 * safeZoneH
];
_titleCtrl ctrlSetText "Defend / Garrison Settings";
_titleCtrl ctrlSetTextColor [1, 1, 1, 1];
_titleCtrl ctrlSetFont "PuristaMedium";
_titleCtrl ctrlCommit 0;

// Helper macro for positioning fields
private _labelX = _dlgX + 0.02 * safeZoneW;
private _editX = _dlgX + 0.24 * safeZoneW;
private _editW = _dlgW - 0.26 * safeZoneW;
private _rowH = 0.045 * safeZoneH;
private _rowGap = 0.055 * safeZoneH;
private _startY = _dlgY + 0.06 * safeZoneH;

// --- Row 1: Radius ---
private _labelRadius = _display ctrlCreate ["RscText", -1];
_labelRadius ctrlSetPosition [_labelX, _startY, 0.20 * safeZoneW, _rowH];
_labelRadius ctrlSetText "Radius to defend (m):";
_labelRadius ctrlSetTextColor [0.67, 0.67, 0.67, 1];
_labelRadius ctrlSetFont "PuristaMedium";
_labelRadius ctrlCommit 0;

private _editRadius = _display ctrlCreate ["RscEdit", -1];
_editRadius ctrlSetPosition [_editX, _startY, _editW, _rowH];
_editRadius ctrlSetText (str _defaultRadius);
_editRadius ctrlSetTextColor [0, 0, 0, 1];
_editRadius ctrlSetBackgroundColor [1, 1, 1, 1];
_editRadius ctrlSetFont "PuristaMedium";
_editRadius ctrlCommit 0;
ctrlSetFocus _editRadius;

uiNamespace setVariable ["AIC_DefendInput_EditRadius", _editRadius];

// --- Row 2: Threshold ---
private _row2Y = _startY + _rowGap;

private _labelThreshold = _display ctrlCreate ["RscText", -1];
_labelThreshold ctrlSetPosition [_labelX, _row2Y, 0.20 * safeZoneW, _rowH];
_labelThreshold ctrlSetText "Min. Required Building Positions:";
_labelThreshold ctrlSetTextColor [0.67, 0.67, 0.67, 1];
_labelThreshold ctrlSetFont "PuristaMedium";
_labelThreshold ctrlCommit 0;

private _editThreshold = _display ctrlCreate ["RscEdit", -1];
_editThreshold ctrlSetPosition [_editX, _row2Y, _editW, _rowH];
_editThreshold ctrlSetText (str _defaultThreshold);
_editThreshold ctrlSetTextColor [0, 0, 0, 1];
_editThreshold ctrlSetBackgroundColor [1, 1, 1, 1];
_editThreshold ctrlSetFont "PuristaMedium";
_editThreshold ctrlCommit 0;

uiNamespace setVariable ["AIC_DefendInput_EditThreshold", _editThreshold];

// --- Row 3: Patrol Chance ---
private _row3Y = _row2Y + _rowGap;

private _labelPatrol = _display ctrlCreate ["RscText", -1];
_labelPatrol ctrlSetPosition [_labelX, _row3Y, 0.20 * safeZoneW, _rowH];
_labelPatrol ctrlSetText "Patrol Chance %:";
_labelPatrol ctrlSetTextColor [0.67, 0.67, 0.67, 1];
_labelPatrol ctrlSetFont "PuristaMedium";
_labelPatrol ctrlCommit 0;

private _editPatrol = _display ctrlCreate ["RscEdit", -1];
_editPatrol ctrlSetPosition [_editX, _row3Y, _editW, _rowH];
_editPatrol ctrlSetText (str _defaultPatrol);
_editPatrol ctrlSetTextColor [0, 0, 0, 1];
_editPatrol ctrlSetBackgroundColor [1, 1, 1, 1];
_editPatrol ctrlSetFont "PuristaMedium";
_editPatrol ctrlCommit 0;

uiNamespace setVariable ["AIC_DefendInput_EditPatrol", _editPatrol];

// --- Row 4: Hold Chance ---
private _row4Y = _row3Y + _rowGap;

private _labelHold = _display ctrlCreate ["RscText", -1];
_labelHold ctrlSetPosition [_labelX, _row4Y, 0.20 * safeZoneW, _rowH];
_labelHold ctrlSetText "Hold Positions in Combat Chance %:";
_labelHold ctrlSetTextColor [0.67, 0.67, 0.67, 1];
_labelHold ctrlSetFont "PuristaMedium";
_labelHold ctrlCommit 0;

private _editHold = _display ctrlCreate ["RscEdit", -1];
_editHold ctrlSetPosition [_editX, _row4Y, _editW, _rowH];
_editHold ctrlSetText (str _defaultHold);
_editHold ctrlSetTextColor [0, 0, 0, 1];
_editHold ctrlSetBackgroundColor [1, 1, 1, 1];
_editHold ctrlSetFont "PuristaMedium";
_editHold ctrlCommit 0;

uiNamespace setVariable ["AIC_DefendInput_EditHold", _editHold];

// --- OK Button ---
private _btnY = _row4Y + _rowGap + 0.01 * safeZoneH;
private _btnOk = _display ctrlCreate ["RscButton", -1];
_btnOk ctrlSetPosition [
	_dlgX + 0.12 * safeZoneW,
	_btnY,
	0.09 * safeZoneW,
	0.04 * safeZoneH
];
_btnOk ctrlSetText "OK";
_btnOk ctrlSetFont "PuristaMedium";
_btnOk ctrlCommit 0;
_btnOk ctrlAddEventHandler ["ButtonClick", {
	private _textRadius = ctrlText (uiNamespace getVariable ["AIC_DefendInput_EditRadius", controlNull]);
	private _textThreshold = ctrlText (uiNamespace getVariable ["AIC_DefendInput_EditThreshold", controlNull]);
	private _textPatrol = ctrlText (uiNamespace getVariable ["AIC_DefendInput_EditPatrol", controlNull]);
	private _textHold = ctrlText (uiNamespace getVariable ["AIC_DefendInput_EditHold", controlNull]);

	private _radius = parseNumber _textRadius;
	private _threshold = parseNumber _textThreshold;
	private _patrol = parseNumber _textPatrol;
	private _hold = parseNumber _textHold;

	if (_radius <= 0) then { _radius = 50; };
	if (_threshold <= 0) then { _threshold = 3; };
	if (_patrol < 0) then { _patrol = 0; };
	if (_patrol > 100) then { _patrol = 100; };
	if (_hold < 0) then { _hold = 0; };
	if (_hold > 100) then { _hold = 100; };

	uiNamespace setVariable ["AIC_DefendInput_Radius", _radius];
	uiNamespace setVariable ["AIC_DefendInput_Threshold", _threshold];
	uiNamespace setVariable ["AIC_DefendInput_Patrol", _patrol];
	uiNamespace setVariable ["AIC_DefendInput_Hold", _hold];
	uiNamespace setVariable ["AIC_DefendInput_Done", true];
}];

// --- Cancel Button ---
private _btnCancel = _display ctrlCreate ["RscButton", -1];
_btnCancel ctrlSetPosition [
	_dlgX + 0.22 * safeZoneW,
	_btnY,
	0.09 * safeZoneW,
	0.04 * safeZoneH
];
_btnCancel ctrlSetText "Cancel";
_btnCancel ctrlSetFont "PuristaMedium";
_btnCancel ctrlCommit 0;
_btnCancel ctrlAddEventHandler ["ButtonClick", {
	uiNamespace setVariable ["AIC_DefendInput_Cancelled", true];
	uiNamespace setVariable ["AIC_DefendInput_Done", true];
}];

// --- Store all controls for cleanup ---
uiNamespace setVariable ["AIC_DefendInput_Controls", [
	_bg, _titleCtrl,
	_labelRadius, _editRadius,
	_labelThreshold, _editThreshold,
	_labelPatrol, _editPatrol,
	_labelHold, _editHold,
	_btnOk, _btnCancel
]];

// --- Wait for input ---
waitUntil {
	sleep 0.01;
	(uiNamespace getVariable ["AIC_DefendInput_Done", false]) || {isNull (findDisplay 12)}
};

// --- Read result ---
private _cancelled = uiNamespace getVariable ["AIC_DefendInput_Cancelled", false];
private _radius = uiNamespace getVariable ["AIC_DefendInput_Radius", _defaultRadius];
private _threshold = uiNamespace getVariable ["AIC_DefendInput_Threshold", _defaultThreshold];
private _patrolChance = uiNamespace getVariable ["AIC_DefendInput_Patrol", _defaultPatrol];
private _holdChance = uiNamespace getVariable ["AIC_DefendInput_Hold", _defaultHold];

// --- Cleanup ---
{
	ctrlDelete _x;
} forEach (uiNamespace getVariable ["AIC_DefendInput_Controls", []]);

uiNamespace setVariable ["AIC_DefendInput_Done", nil];
uiNamespace setVariable ["AIC_DefendInput_Cancelled", nil];
uiNamespace setVariable ["AIC_DefendInput_Radius", nil];
uiNamespace setVariable ["AIC_DefendInput_Threshold", nil];
uiNamespace setVariable ["AIC_DefendInput_Patrol", nil];
uiNamespace setVariable ["AIC_DefendInput_Hold", nil];
uiNamespace setVariable ["AIC_DefendInput_EditRadius", nil];
uiNamespace setVariable ["AIC_DefendInput_EditThreshold", nil];
uiNamespace setVariable ["AIC_DefendInput_EditPatrol", nil];
uiNamespace setVariable ["AIC_DefendInput_EditHold", nil];
uiNamespace setVariable ["AIC_DefendInput_Controls", nil];

if (!_cancelled) then {
	[_radius, _threshold, _patrolChance, _holdChance] call _callback;
};