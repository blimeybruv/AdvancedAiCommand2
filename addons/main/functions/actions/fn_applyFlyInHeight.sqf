// Apply fly-in-height to a single vehicle on the machine that owns it.
// The vehicle owner machine is where flyInHeight / flyInHeightASL actually has effect —
// the script must run there, not on the menu-clicker's machine.
//
// Arma engine: flyInHeight and flyInHeightASL are FLOORS (minimum altitudes),
// not target altitudes — the helicopter will never descend to meet them.
// SetWaypointLoiterAltitude is applied separately by the sync loop in
// fn_commandControlManager.sqf for each waypoint, so this function only
// needs to set the altitude floors.
//
// Mode "AGL":  target = flyInHeight (AGL terrain-following), flyInHeightASL = 0.
//              The helicopter follows terrain at the given height above ground.
//
// Mode "ASL":  target = flyInHeightASL (sea-level floor), flyInHeight = 20 (safe AGL floor).
//
// If mode is omitted or unrecognised, defaults to "ASL" for backwards-compatibility.
params ["_vehicle", "_height", ["_mode", "ASL"]];

if (isNull _vehicle) exitWith {};
if !(_vehicle isKindOf "Air") exitWith {};
if (isNil "_height" || {_height <= 0}) exitWith {};

// Set the altitude floors
if (_mode == "AGL") then {
	_vehicle flyInHeightASL [0, 0, 0];
	_vehicle flyInHeight _height;
} else {
	_vehicle flyInHeightASL [_height, _height, _height];
	_vehicle flyInHeight 20;
};
