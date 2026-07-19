#include "..\..\functions.h"

/*
	Author: [SA] Duda

	Description:
	Draws the specified group control (including waypoints) on the map

	Parameter(s):
	_this select 0: STRING - Group Control ID
		
	Returns: 
	Nothing
*/

private ["_groupControlId"];

_groupControlId = param [0];

if!(AIC_fnc_getMapElementVisible(_groupControlId)) exitWith {};

private ["_group","_icon","_groupPosition"];

_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
_groupPosition = position leader _group;
_icon = [_groupControlId] call AIC_fnc_getGroupControlInteractiveIcon;

// Set current position to group's position

AIC_fnc_setInteractiveIconPosition(_icon,_groupPosition);	

// Draw the interactive icon at the group's position

[_icon, _group] call AIC_fnc_drawInteractiveIcon;

// Draw shield icon if group is defending
// Check both the group variable and missionNamespace (missionNamespace survives waypoint rebuilds)
private _isDefending = _group getVariable ["AIC_IsDefending", false] || { missionNamespace getVariable [format ["AIC_IsDefending_%1", groupId _group], false] };
if (_isDefending) then {
	private _shieldColor = ((AIC_fnc_getGroupControlColor(_groupControlId)) select 1) + [1];
	private _shieldPosition = [
		(_groupPosition select 0) + 5,
		(_groupPosition select 1)
	];
	AIC_MAP_CONTROL drawIcon [
		"\a3\ui_f\data\igui\cfg\simpletasks\types\defend_ca.paa",
		_shieldColor,
		_shieldPosition,
		18,
		18,
		0,
		"",
		1
	];
};

// Draw waypoints

private ["_waypointIcons"];

_waypointIcons = AIC_fnc_getGroupControlWaypointIcons(_groupControlId);

// Draw the lines between the waypoints

private ["_priorWaypointPosition","_lineFromPosition","_lineToPosition","_lineColor"];

if(AIC_fnc_getMapElementForeground(_groupControlId)) then {
	_lineColor = ((AIC_fnc_getGroupControlColor(_groupControlId)) select 1) + [1];
} else {
	_lineColor = ((AIC_fnc_getGroupControlColor(_groupControlId)) select 1) + [0.4];
};

private _addingWaypoints = AIC_fnc_getGroupControlAddingWaypoints(_groupControlId);
{
	// _x is [_wpIndex, _interactiveIconId, _wpState]
	private _wpState = if (count _x >= 3) then { _x select 2 } else { AIC_Waypoint_State_Active };
	// Skip waypoints that should not be visible at all:
	// - Deleted: always invisible (hard delete)
	// - Drafted/Disabled: invisible outside of adding-waypoints mode
	if (_wpState == AIC_Waypoint_State_Deleted) then { continue };
	if ((_wpState == AIC_Waypoint_State_Drafted || _wpState == AIC_Waypoint_State_Disabled) && {!_addingWaypoints}) then { continue };
	if(isNil "_priorWaypointPosition") then {
		// Draw line back to group
		_lineFromPosition = _groupPosition;
	} else {
		// Draw line back to last waypoint position
		_lineFromPosition = _priorWaypointPosition;
	};
	_lineToPosition = AIC_fnc_getInteractiveIconPosition(_x select 1);
	_priorWaypointPosition = _lineToPosition;
	AIC_MAP_CONTROL drawLine [
		_lineFromPosition,
		_lineToPosition,
		_lineColor
	];
} forEach _waypointIcons;

// If user adding waypoints, draw a line between the last waypoint or group and the cursor

if(AIC_fnc_getGroupControlAddingWaypoints(_groupControlId)) then {
	if(isNil "_priorWaypointPosition") then {
		_priorWaypointPosition = _groupPosition;
	};
	AIC_MAP_CONTROL drawArrow [
		_priorWaypointPosition,
		(AIC_fnc_getMouseMapPosition()),
		_lineColor
	];
	//hint str (AIC_fnc_getMouseMapPosition());
};

// Draw the waypoint interactive icons on top of the line

{
	private _wpIconId = _x select 1;
	// Skip waypoint icons that have been hidden (e.g., removed from the waypoint list)
	if (!AIC_fnc_getMapElementVisible(_wpIconId)) then { continue };
	private _wpState = if (count _x >= 3) then { _x select 2 } else { AIC_Waypoint_State_Active };
	// Skip waypoints that should not be visible at all:
	// - Deleted: always invisible (hard delete)
	// - Drafted/Disabled: invisible outside of adding-waypoints mode
	if (_wpState == AIC_Waypoint_State_Deleted) then { continue };
	if ((_wpState == AIC_Waypoint_State_Drafted || _wpState == AIC_Waypoint_State_Disabled) && {!_addingWaypoints}) then { continue };
	if (_wpState != AIC_Waypoint_State_Active) then {
		// Draw disabled waypoint icon with reduced alpha
		// Get the icon set (state-based: [unselected[], selected[], mouseOver[], pickedUp[]])
		private _wpPos = AIC_fnc_getInteractiveIconPosition(_wpIconId);
		private _wpIconSet = AIC_fnc_getInteractiveIconIconSet(_wpIconId);
		if (!isNil "_wpIconSet") then {
			// Draw each unselected icon with reduced alpha
			private _unselectedIconIds = _wpIconSet select 0;
			{
				private _iconProps = AIC_fnc_getMapIconProperties(_x);
				private _iconColor = +(_iconProps select 6);
				_iconColor set [3, (_iconColor select 3) * 0.35];
				AIC_MAP_CONTROL drawIcon [
					_iconProps select 0,
					_iconColor,
					_wpPos,
					_iconProps select 1,
					_iconProps select 2,
					0,
					"",
					_iconProps select 5
				];
			} forEach _unselectedIconIds;
		};
	} else {
		[_x select 1] call AIC_fnc_drawInteractiveIcon;
	};
} forEach _waypointIcons;
