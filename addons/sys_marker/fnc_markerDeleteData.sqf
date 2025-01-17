#include "\x\alive\addons\sys_marker\script_component.hpp"
SCRIPT(markerDeleteData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_markerDeleteData

Description:
Triggers deleting Data on running SYS marker instances, triggers and ends Loadingscreen
Needs to run serverside

Parameters:
none

Returns:
Boolean

Examples:
(begin example)
//trigger SYS marker load from DB
[] call ALIVE_fnc_markerDeleteData;
(end)

See Also:
ALIVE_fnc_markerSaveData

Author:
Highhead
---------------------------------------------------------------------------- */

if !(isDedicated && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

private ["_data","_async","_missionName","_docid","_rev","_markerName","_markerHash","_indexName"];

_markerName = _this select 0;
_markerHash = _this select 1;

_async = true;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName];
_docid = _missionName + "-" + _markerName;

_rev = [_markerHash, "_rev", "MISSING"] call ALIVE_fnc_hashGet;

if (_rev == "MISSING") exitWith {false};

_data = [GVAR(DATAHANDLER), "delete", ["sys_marker", _async, _docid, _rev]] call ALIVE_fnc_Data;

_count = count (GVAR(STORE) select 1) - 1;
LOG(_count);
if ( (count (GVAR(STORE) select 1) - 1) == 0 ) then {
    // Delete index doc if store hits zero records
    private "_indrevs";
    _indrevs = [GVAR(DATAHANDLER), "indexRevs", ""] call ALIVE_fnc_hashGet;
    LOG(str _indrevs);
    if (typeName _indrevs != "STRING") then {
        private ["_response","_i","_indexName"];

            {
                if (_foreachIndex == 0) then {
                    _indexName = format["%1_%2", ALIVE_SYS_DATA_GROUP_ID, missionName];
                } else {
                    _indexName = format["%1_%2_%3", ALIVE_SYS_DATA_GROUP_ID, missionName, _foreachIndex];
                };
                _response = [GVAR(DATAHANDLER), "delete", ["sys_marker", _async, _indexName, _indrevs select _foreachIndex]] call ALIVE_fnc_Data;
            } foreach _indrevs;
    };
};


_data