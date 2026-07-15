#include "..\functions.h"

/*
	Author: [SA] Duda / Nimmersatt

	Description:
	Activates the defend/garrison task for a group.
	Replaces CBA_fnc_taskDefend with a custom implementation that fixes the
	bug where units that "roll patrol" (skip garrison) are left idle instead
	of participating in the group's patrol.

	Logic:
	- Units that roll garrison move into buildings (or mount static weapons)
	- Units that roll patrol follow the leader (who leads the patrol)
	- Leader is always freed up to lead the patrol
	- CBA_fnc_taskPatrol creates the actual patrol waypoints

	Parameter(s):
	_this select 0: GROUP - The group to set defending
	_this select 1: NUMBER - Defend radius (Default: 50)
	_this select 2: NUMBER - Minimum building positions to consider for garrison (Default: 3)
	_this select 3: NUMBER - Chance for each unit to patrol instead of garrison (0-100, Default: 10)
	_this select 4: NUMBER - Chance for each unit to hold garrison position in combat (0-100, Default: 0)

	Returns:
	Nothing
*/

params [["_group", grpNull, [grpNull]], ["_defendRadius", 50, [0]], ["_threshold", 3, [0]], ["_patrolChance", 10, [0]], ["_holdChance", 0, [0]]];

[AIC_LOGLEVEL_DEBUG, format ["setDefendActive called: group=%1, _defendRadius=%2, _threshold=%3, _patrolChance=%4, _holdChance=%5", groupId _group, _defendRadius, _threshold, _patrolChance, _holdChance]] call AIC_fnc_log;

private _patrolFraction = _patrolChance / 100;
private _holdFraction = _holdChance / 100;

// === Custom garrison + patrol implementation ===
{
	_x enableAI "PATH";
} forEach units _group;

private _position = getPos (leader _group);
private _statics = _position nearObjects ["StaticWeapon", _defendRadius];
private _buildings = _position nearObjects ["Building", _defendRadius];

// Filter out occupied statics
_statics = _statics select {locked _x != 2 && {(_x emptyPositions "Gunner") > 0}};

// Filter out buildings below the size threshold and store positions
_buildings = _buildings select {
	private _positions = _x buildingPos -1;
	if (isNil {_x getVariable "AIC_taskDefend_positions"}) then {
		_x setVariable ["AIC_taskDefend_positions", _positions];
	};
	count _positions >= _threshold
};

// Leader is freed from garrison duty so it can lead the patrol
private _units = +units _group;
private _leader = leader _group;
_units deleteAt (_units find _leader);

{
	// 31% chance to occupy nearest free static weapon
	if ((random 1 < 0.31) && {_statics isNotEqualTo []}) then {
		_x assignAsGunner (_statics deleteAt 0);
		[_x] orderGetIn true;
	} else {
		// Roll for patrol vs garrison
		if (random 1 < _patrolFraction || _buildings isEqualTo []) then {
			// Unit should patrol - follow the leader
			_x doFollow _leader;
		} else {
			// Unit should garrison in a building
			private _building = selectRandom _buildings;
			private _buildingPositions = _building getVariable ["AIC_taskDefend_positions", []];
			
			if (_buildingPositions isNotEqualTo []) then {
				private _targetPos = _buildingPositions deleteAt (floor (random (count _buildingPositions)));
				
				if (_buildingPositions isEqualTo []) then {
					_buildings deleteAt (_buildings find _building);
					_building setVariable ["AIC_taskDefend_positions", nil];
				} else {
					_building setVariable ["AIC_taskDefend_positions", _buildingPositions];
				};
				
				// Wait until unit reaches position, then hold
				[_x, _targetPos, _holdFraction] spawn {
					params ["_unit", "_pos", "_hold"];
					if (surfaceIsWater _pos) exitWith {};
					_unit doMove _pos;
					waitUntil {unitReady _unit};
					if (random 1 < _hold) then {
						_unit disableAI "PATH";
					} else {
						doStop _unit;
					};
				};
			};
		};
	};
} forEach _units;

// Create patrol waypoints for the group
[_group, _position, _defendRadius, 5, "MOVE", "SAFE", "YELLOW", "LIMITED"] call CBA_fnc_taskPatrol;

[AIC_LOGLEVEL_DEBUG, format ["setDefendActive: custom garrison/patrol completed for group %1", groupId _group]] call AIC_fnc_log;

[_group, format ["Group %1 garrisoning at waypoint.", groupId _group]] call AIC_fnc_msgSideChat;
_group setVariable ["AIC_IsDefending", true, true];
// Also set on missionNamespace to survive waypoint revision rebuilds (line 222 of fn_commandControlManager.sqf)
missionNamespace setVariable [format ["AIC_IsDefending_%1", groupId _group], true, true];

[AIC_LOGLEVEL_DEBUG, format ["setDefendActive: AIC_IsDefending set to true for group %1", groupId _group]] call AIC_fnc_log;
