#include "..\functions.h"

/*
	Author: Nimmersatt

	Description:
	Cancels the defend/garrison state for a group. Clears CBA defend waypoints,
	re-enables AI movement, and clears the AIC_IsDefending flag.

	Parameter(s):
	_this select 0: ARRAY - Menu params [_groupControlId]
	_this select 1: ARRAY - Action params

	Returns:
	Nothing
*/

params ["_menuParams", "_actionParams"];
_menuParams params ["_groupControlId"];

[AIC_LOGLEVEL_DEBUG, format ["cancelDefendActionHandler called. _groupControlId=%1", _groupControlId]] call AIC_fnc_log;

private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;

if (isNull _group) exitWith {
	[AIC_LOGLEVEL_ERROR, format ["cancelDefendActionHandler: Could not find group for _groupControlId=%1", _groupControlId]] call AIC_fnc_log;
};

[AIC_LOGLEVEL_DEBUG, format ["cancelDefendActionHandler: Cancelling defend for group %1.", groupId _group]] call AIC_fnc_log;

// Clear all current defend/patrol waypoints
[_group] call CBA_fnc_clearWaypoints;



// Re-enable movement and force them to regroup
{
	// Re-enable movement
	_x enableAI "PATH";

	// Set speed back to normal
	_x setSpeedMode "NORMAL";

	// Set behaviour back to normal
	_x setBehaviour "AWARE";

	// Regroup
	_x doFollow (leader _group);
} forEach units _group;

// Clear the defending flag so the shield icon disappears (both locations)
_group setVariable ["AIC_IsDefending", false, true];
missionNamespace setVariable [format ["AIC_IsDefending_%1", groupId _group], false, true];

[AIC_LOGLEVEL_DEBUG, format ["cancelDefendActionHandler: Defend cancelled for group %1. AIC_IsDefending set to false.", groupId _group]] call AIC_fnc_log;

// Notify via sidechat
[_group, format ["Group %1 defend/garrison cancelled.", groupId _group]] call AIC_fnc_msgSideChat;