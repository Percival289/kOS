/////////////////////////////////////////////
// lib_general.ks is downloaded and run by //
// every processor on the ship.			   //
//										   //
// runs IMA message and mission updates.   //
/////////////////////////////////////////////

declare global targetAp to 80000.

// Formatted time
function formatmet {
	local ts is time+missiontime-time:seconds. 
	return "[T+"+padZ(ts:year-1)+"-"+padZ(ts:day-1,3)+"   "+padZ(ts:hour)+":"+padZ(round(ts:second))+"]".
}

// Vertical padding
function padZ {
	parameter t, l is 2.
	return (""+t):padleft(l):replace(" ", "0").
}

// Messages to mission log
function FYI {
	parameter n.
	MSG("GUI", core:tag+";"+n).
	MSG("COM", core:tag+";"+n).
}

function MSG {
    parameter target.
    parameter message.
    parameter value to "None".

    set p to processor(target).
    p:connection:sendmessage(list(message, value)).
}

function LISTEN {
	wait until not core:messages:empty.
	set recieved to core:messages:pop.
	return recieved.
}

// Send IMA message
function FIU {
	parameter n.
	MSG("GUI", core:tag+";"+n).
}

// I AM ALIVE (IMA) message
set clock to time:seconds.
when time:seconds > clock + 1 then { set clock to time:seconds. FIU("IMA"). return true. }

// Open terminal and clear
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
clearscreen.