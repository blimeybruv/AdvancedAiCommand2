#include "..\functions.h"

/*
	Author: [SA] Duda / Nimmersatt

	Description:
	Activates the defend/garrison task for a group when it reaches a DEFEND waypoint.
	Delegates to CBA_fnc_taskDefend for garrison/patrol logic, then sets the
	AIC_IsDefending flag so the AIC server-side waypoint manager won't overwrite
	CBA's waypoints.

	Parameter(s):
	_this select 0: GROUP - The group to set defending
	_this select 1: NUMBER - Defend radius (Default: 100)
	_this select 2: NUMBER - Minimum building positions to consider for garrison (Default: 1)
	_this select 3: NUMBER - Chance for each unit to patrol instead of garrison (0-100, Default: 33)
	_this select 4: NUMBER - Chance for each unit to hold garrison position in combat (0-100, Default: 0)

	Returns:
	Nothing
*/

params [["_group", grpNull, [grpNull]], ["_defendRadius", 100, [0]], ["_threshold", 1, [0]], ["_patrolChance", 33, [0]], ["_holdChance", 0, [0]]];

[AIC_LOGLEVEL_DEBUG, format ["setDefendActive called: group=%1, _defendRadius=%2, _threshold=%3, _patrolChance=%4, _holdChance=%5", groupId _group, _defendRadius, _threshold, _patrolChance, _holdChance]] call AIC_fnc_log;

private _patrolFraction = _patrolChance / 100;
private _holdFraction = _holdChance / 100;

// Delegate garrison and patrol to CBA
// CBA_fnc_taskDefend handles static weapons, building garrison, and falls through to
// CBA_fnc_taskPatrol for units that don't garrison. AIC_IsDefending (set below) prevents
// the AIC server-side waypoint manager from deleting CBA's waypoints.
[_group, getPos (leader _group), _defendRadius, _threshold, _patrolFraction, _holdFraction] call CBA_fnc_taskDefend;

[AIC_LOGLEVEL_DEBUG, format ["setDefendActive: CBA_fnc_taskDefend completed for group %1", groupId _group]] call AIC_fnc_log;

[_group, format ["Group %1 garrisoning at waypoint.", groupId _group]] call AIC_fnc_msgSideChat;
_group setVariable ["AIC_IsDefending", true, true];
// Also set on missionNamespace to survive waypoint revision rebuilds (line 222 of fn_commandControlManager.sqf)
missionNamespace setVariable [format ["AIC_IsDefending_%1", groupId _group], true, true];

[AIC_LOGLEVEL_DEBUG, format ["setDefendActive: AIC_IsDefending set to true for group %1", groupId _group]] call AIC_fnc_log;
