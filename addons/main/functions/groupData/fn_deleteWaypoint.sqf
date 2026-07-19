#include "\z\aicommand2\addons\main\functions\functions.h"

/*
	Author: [SA] Duda

	Description:
	Marks a waypoint as deleted. Semantically this is a "soft delete" (the
	waypoint record is preserved for undo/debug but it will never be executed
	or displayed outside of the editing session). Unlike the "disabled" state,
	"deleted" waypoints are unconditionally hidden from the map.

	Parameter(s):
	_this select 0: GROUP - group that owns the waypoint
	_this select 1: NUMBER - waypoint index

	Returns:
	The updated waypoint array, or nil if the waypoint was not found.
*/

private _group = param [0];
private _waypointId = param [1];

private _waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;

if (isNil "_waypoint") exitWith {
	[AIC_LOGLEVEL_ERROR, format ["fn_deleteWaypoint: No waypoint with id=%1", _waypointId]] call AIC_fnc_log;
	nil
};

_waypoint set [AIC_Waypoint_ArrayIndex_State, AIC_Waypoint_State_Deleted];

[_group, _waypoint] call AIC_fnc_setWaypoint;

_waypoint
