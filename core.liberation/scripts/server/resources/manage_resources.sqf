waitUntil { !isNil "save_is_loaded" };
waitUntil { !isNil "blufor_sectors" };
waitUntil { !isNil "saved_intel_res" };

_base_tick_period = 600;
resources_intel = saved_intel_res;

while { GRLIB_endgame == 0 } do {
	sleep _base_tick_period;

	if ( count allPlayers > 0 ) then {

		// AmmoBox
		_blufor_mil_sectors = [];
		{
			if ( _x in sectors_military ) then {
				_blufor_mil_sectors pushback _x;
			};
		} foreach blufor_sectors;

		if ( count _blufor_mil_sectors > 0 ) then {
			if ( GRLIB_passive_income ) then {

				private _income =  (round (125 + (random 75)));
				{
					private _ammo_collected = _x getVariable ["GREUH_ammo_count",0];
					_x setVariable ["GREUH_ammo_count", _ammo_collected + _income, true];
				} forEach allPlayers;
				_text = format ["Reward Received: + %1 Ammo.", _income];
				[gamelogic, _text] remoteExec ["globalChat", 0];
			} else {
				if ( ( { typeof _x == ammobox_b_typename } count vehicles ) <= ( ceil ( ( count _blufor_mil_sectors ) * 1.3 ) ) ) then {

					_spawnsector = ( _blufor_mil_sectors call BIS_fnc_selectRandom );
					_spawnpos = zeropos;
					while { _spawnpos distance zeropos < 1000 } do {
						_spawnpos =  ( [ ( markerpos _spawnsector), random 50, random 360 ] call BIS_fnc_relPos ) findEmptyPosition [ 10, 100, 'B_Heli_Transport_01_F' ];
						if ( count _spawnpos == 0 ) then { _spawnpos = zeropos; };
					};

					_newbox = [ammobox_b_typename, _spawnpos, false] call boxSetup;
					clearWeaponCargoGlobal _newbox;
					clearMagazineCargoGlobal _newbox;
					clearItemCargoGlobal _newbox;
					clearBackpackCargoGlobal _newbox;
				};
			};
		};

		// Fuel Barrel
		_blufor_fuel_sectors = [];
		{
			if ( _x in sectors_factory ) then {
				_blufor_fuel_sectors pushback _x;
			};
		} foreach blufor_sectors;

		if ( count _blufor_fuel_sectors > 0 ) then {
			if ( ( { typeof _x == fuelbarrel_typename } count vehicles ) <= ( ceil ( ( count _blufor_fuel_sectors ) * 1.3 ) ) ) then {

				_spawnsector = ( _blufor_fuel_sectors call BIS_fnc_selectRandom );
				_spawnpos = zeropos;
				while { _spawnpos distance zeropos < 1000 } do {
					_spawnpos =  ( [ ( markerpos _spawnsector), random 50, random 360 ] call BIS_fnc_relPos ) findEmptyPosition [ 10, 100, 'B_Heli_Transport_01_F' ];
					if ( count _spawnpos == 0 ) then { _spawnpos = zeropos; };
				};

				_newbox = [fuelbarrel_typename, _spawnpos, false] call boxSetup;
			};
		};

		// Water Barrel
		_blufor_water_sectors = [];
		{
			if ( _x in sectors_tower ) then {
				_blufor_water_sectors pushback _x;
			};
		} foreach blufor_sectors;

		if ( count _blufor_water_sectors > 0 ) then {
			if ( ( { typeof _x == waterbarrel_typename } count vehicles ) <= ( ceil ( ( count _blufor_water_sectors ) * 1.3 ) ) ) then {

				_spawnsector = ( _blufor_water_sectors call BIS_fnc_selectRandom );
				_spawnpos = zeropos;
				while { _spawnpos distance zeropos < 1000 } do {
					_spawnpos =  ( [ ( markerpos _spawnsector), random 50, random 360 ] call BIS_fnc_relPos ) findEmptyPosition [ 10, 100, 'B_Heli_Transport_01_F' ];
					if ( count _spawnpos == 0 ) then { _spawnpos = zeropos; };
				};

				_newbox = [waterbarrel_typename, _spawnpos, false] call boxSetup;
			};
		};

	};
	sleep 300;
};