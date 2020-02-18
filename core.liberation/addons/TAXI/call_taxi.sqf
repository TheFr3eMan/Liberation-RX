// Heli Taxi Script

//check dest place
_dest = (getPos player) findEmptyPosition [1,50, huron_typename];
if (player getVariable ["GRLIB_taxi_called", false]) exitWith {hintSilent "Sorry, Only one Taxi at time."};
if (count _dest == 0 || surfaceIsWater _dest) exitWith {hintSilent "Sorry, Taxi cannot Land on this place."};

// Action SetDest
action_dest = {
	openMap true;
	hintSilent "Select the Destination.";
	onMapSingleClick {
		_marker = createMarkerLocal ["taxi_dz", _pos];
		_marker setMarkerShapeLocal "ICON";
		_marker setMarkerTypeLocal "mil_flag";
		_marker setMarkerTextlocal "Taxi DZ";
		onMapSingleClick "";
		openMap false;
		true;
	};
	waitUntil {sleep 1;	(markerPos "taxi_dz") distance2D zeropos > 100};

	if (surfaceIsWater (markerPos "taxi_dz")) then {
		hintSilent "Sorry, Taxi cannot Land on this place.";
		deleteMarkerLocal "taxi_dz";
	};
};

// Heli Taxi
_taxi_type = ["C_Heli_light_01_luxe_F", "B_Heli_Light_01_F", "I_Heli_light_03_F", "I_Heli_Transport_02_F"] call BIS_fnc_selectRandom;

// Create Taxi
_air_grp = createGroup [GRLIB_side_civilian, true];
_air_spawnpos = [] call F_getNearestFob;
_air_spawnpos = [(((_air_spawnpos select 0) + 500) - random 1000),(((_air_spawnpos select 1) + 500) - random 1000),0];
_vehicle = createVehicle [_taxi_type, _air_spawnpos, [], 0, "FLY"];
_vehicle setVariable ["GRLIB_vehicle_owner", "server"];
_vehicle setVariable ["R3F_LOG_disabled", true];
_vehicle flyInHeight (100 + (random 80));

createVehicleCrew _vehicle;
_pilots = crew _vehicle;
{ _x addMPEventHandler ["MPKilled", {_this spawn kill_manager}] } foreach _pilots;
_pilots joinSilent _air_grp;
player setVariable ["GRLIB_taxi_called", true];
hintSilent "Air Taxi Called !";

// Set Pickup Point
_waypoint = _air_grp addWaypoint [ _dest, 1];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointSpeed "FULL";
_waypoint setWaypointBehaviour "AWARE";
_waypoint setWaypointCombatMode "GREEN" ;

waitUntil {
  sleep 5;
  isNil{hintSilent format ["Taxi on the way!\nDistance: %1m", round (_vehicle distance2D _dest)]};
  (!alive _vehicle || _vehicle distance2D _dest < 100)
};

if (alive _vehicle && alive player) then {
	_vehicle land "LAND";
	hintSilent "Taxi Landing...";

	waitUntil {sleep 1; isTouchingGround _vehicle};
	hintSilent "Taxi Landed.\nWaiting for Destination.";

	// Pickup Marker
	_marker = createMarkerLocal ["taxi_lz", getPos _vehicle];
	_marker setMarkerShapeLocal "ICON";
	_marker setMarkerTypeLocal "mil_pickup";
	_marker setMarkerTextlocal "Taxi PickUp";

	_stop = diag_tickTime + (5 * 60); // wait 5min max
	waitUntil {
		sleep 1;
		(!alive _vehicle || vehicle player == _vehicle || diag_tickTime > _stop)
	};

	deleteMarkerLocal "taxi_lz";
	if (diag_tickTime < _stop && alive _vehicle) then {
		_idact_dest = _vehicle addAction ["<t color='#8000FF'>-- TAXI Destination --</t>","[] call action_dest","",999,true,true,"","vehicle _this == _target"];
		waitUntil {
			sleep 1;
			(!alive _vehicle || !alive player || (markerPos "taxi_dz") distance2D zeropos > 100)
		};
		_vehicle removeAction _idact_dest;

		if (alive _vehicle && alive player && vehicle player == _vehicle) then {
			hintSilent "Ok, let's go...";
			_dest = markerPos "taxi_dz";
			_waypoint = _air_grp addWaypoint [ _dest, 1];
			_waypoint setWaypointType "MOVE";
			_waypoint setWaypointSpeed "FULL";
			_waypoint setWaypointBehaviour "AWARE";
			_waypoint setWaypointCombatMode "GREEN" ;

			waitUntil {
				sleep 5;
				isNil{hintSilent format ["Taxi transport...\nDestination: %1m", round (_vehicle distance2D _dest)]};
				(!alive _vehicle || vehicle player != _vehicle || _vehicle distance2D _dest < 100)
			};

			if (alive _vehicle && vehicle player == _vehicle) then {
				_vehicle land "LAND";
				hintSilent "Taxi Landing...";

				waitUntil {sleep 1; isTouchingGround _vehicle};
				hintSilent "Taxi Landed.\nGoodbye.";

				_outboarded = {
					params ["_vehicle"];
					_ret = true;
					{
						if ( vehicle _x == _vehicle) then {
							unassignVehicle _x;
							commandGetOut _x;
							doGetOut _x;
							_ret = false
						};
					} forEach units player;
					_ret;
				};
				waitUntil {sleep 1; [_vehicle] call _outboarded};
				_vehicle lock 2;

				// Go back
				_waypoint = _air_grp addWaypoint [zeropos, 1];
				_waypoint setWaypointType "MOVE";
				_waypoint setWaypointSpeed "FULL";
				_waypoint setWaypointBehaviour "AWARE";
				_waypoint setWaypointCombatMode "GREEN" ;
			};
		};
	};
};

// Cleanup
hintSilent "";
deleteMarkerLocal "taxi_dz";
sleep 60;
{deletevehicle _x} forEach _pilots;
deleteVehicle _vehicle;
player setVariable ["GRLIB_taxi_called", false];