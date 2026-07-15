#include "..\functions.h"

/*
	Author: [SA] Duda / Nimmersatt

	Description:
	Activates the defend/garrison task for a group via CBA_fnc_taskDefend
	and sets the AIC_IsDefending flag for UI tracking.
	Called from a waypoint completion statement.

	Parameter(s):
	_this select 0: GROUP - The group to set defending
	_this select 1: NUMBER - Defend radius

	Returns:
	Nothing
*/

params ["_group", "_defendRadius"];

[AIC_LOGLEVEL_DEBUG, format ["setDefendActive called: group=%1, _defendRadius=%2", groupId _group, _defendRadius]] call AIC_fnc_log;

[_group, _group, _defendRadius] call CBA_fnc_taskDefend;

[AIC_LOGLEVEL_DEBUG, format ["setDefendActive: CBA_fnc_taskDefend completed for group %1", groupId _group]] call AIC_fnc_log;

[_group, format ["Group %1 garrisoning at waypoint.", groupId _group]] call AIC_fnc_msgSideChat;
_group setVariable ["AIC_IsDefending", true, true];
// Also set on missionNamespace to survive waypoint revision rebuilds (line 222 of fn_commandControlManager.sqf)
missionNamespace setVariable [format ["AIC_IsDefending_%1", groupId _group], true, true];

[AIC_LOGLEVEL_DEBUG, format ["setDefendActive: AIC_IsDefending set to true for group %1", groupId _group]] call AIC_fnc_log;
