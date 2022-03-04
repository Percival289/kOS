// TODO: Detect Flight Phase
// TODO: Monitor system status (IMA)
// TODO: Abort system
// TODO: New messaging system (remove as much logic as possible from this script)

run "lib_general.ks".

// Initialize guidance system
function init {
	
	// If below 100 meters, enter launch mode
	if ship:altitude <= 100 {
        GUI_Launch().
	}
}

set IMA to list().
function listenForMessages {
    when not core:messages:empty then {
        set recieved to core:messages:peek.
        if recieved:content[0] = "IMA" { set IMA[recieved:content[1]] to missionTime. }
    }
}

function GUI_Launch {

	FYI(formatmet() + " START LAUNCH SEQUENCE").

	// Send init messages and start processes

    wait 0.5.
    MSG("NAV", "Init Launch").
	wait until LISTEN():content[0] = "NAV_Ready". GUI_Stage(). // Enable stage 1 engine

    wait 0.5.
	MSG("RES", "Init Launch").
    wait until LISTEN():content[0] = "RES_Ready".

    wait 0.5.
	MSG("TLM", "Init Launch").
    wait until LISTEN():content[0] = "TLM_Ready".
    
	// Mission log update
	FYI("Go for launch").
	
	// Engines to launch power
	MSG("NAV", "Launch").
    print "Launch sent to NAV".
	// Launch clamps released
	wait until LISTEN():content[0] = "Go". GUI_Stage().
    FYI("Clamps released").

    // Check for liftoff
    wait until ship:altitude > 5.
    FYI(formatmet() + " Liftoff confirmed").

    // Update points
    when LISTEN():content[0] = "Gravity turn start" then { FYI(formatmet() + " Gravity turn capture").}

    // Run until target AP reached
    until ship:apoapsis >= targetAp {
        GUI_LaunchStaging().
        wait 0.01.
    }

    // TODO: Replace with variable
    wait until ship:altitude > 70000.
    FYI(formatmet() + " Reached edge of atmosphere").
    
    // Once out of atmosphere, decouple launch stage and start engine
    wait 3.

    // TODO: Find new way to sepratate stages quickly
    MSG("BOOSTER", "Decouple").
    AG3 on. wait 0.01. GUI_Stage(). GUI_Stage().

    wait 1.

    // Calculate dV needed for circ burn
    set circBurnDeltaV to GUI_CalcCircularization().
    print "DeltaV for circularization burn: " + circBurnDeltaV.

    // Calculate burn time based on dV
    set circBurnTime to GUI_CalcBurnTime(circBurnDeltaV).
    print "Burn time: " + circBurnTime.

    // Start circularization burn
    FYI(formatmet() + " Start circularization process").
    GUI_CircBurn(circBurnTime).
	
}

// Safe stage separation
function GUI_Stage {
	wait until stage:ready.
	stage.
}

// Print message with mission time (T+)
function GUI_print {
    parameter message.
    print "[T+" + formatmet()() + "] " + message.
}

// Auto-staging during launch
function GUI_LaunchStaging {
    
    // Eject external tanks when empty
    // TODO: Move tank fuel checks to RES
    if ship:partsdubbed("measureTank"):length > 0 {
        set tank to ship:partsdubbed("measureTank")[0].
        for res in tank:resources {
            if res:name = "LIQUIDFUEL" {
                set lfAmount to res.
                break.
            }
        }
        if lfAmount:amount = 0 { GUI_Stage(). FYI(formatmet() + " External tanks jettisoned"). }
    }
    
}
// Calculate the dV required to circularize
function GUI_CalcCircularization {
    // Set constants
    set grav_param to constant:G * Kerbin:mass.
    set r_apo to ship:apoapsis + 600000. // TODO: Change to variable

    //Vis-viva equation to give speed we'll have at apoapsis.
    set v_apo to SQRT(grav_param * ((2 / r_apo) - (1 / ship:orbit:semimajoraxis))).

    //Vis-viva equation to calculate speed we want at apoapsis for a circular orbit. 
    //For a circular orbit, desired SMA = radius of apoapsis.
    set v_apo_wanted to SQRT(grav_param * ((2 / r_apo) - (1 / r_apo))).
    return v_apo_wanted - v_apo.
}

// Actual burn function to circularize
function GUI_CircBurn {
    parameter t.
    
    // Wait until the apoapsis is at the halfway point of the burn
    wait until eta:apoapsis <= t/2.
    FYI(formatmet() + " Start circularization burn").
    // NAV: Manage burn throttle
    MSG("NAV", "BURN_THROTTLE").
    wait until ship:periapsis >= targetAp.
	FYI(formatmet() + " Circularized ("+round(ship:apoapsis,0)+","+round(ship:periapsis,0)+")").
    

}

// Calculate the length of burn (seconds)
function GUI_CalcBurnTime {
    parameter dV.

    // TODO: Get engine ISP and thrust from engine variables instead of set values
    set v_exhaust to 325 * constant:g0.
    set burnTime to ((ship:mass*v_exhaust)/60000) * (1 - (constant:e ^ (-dV/v_exhaust))) * 1000.
    return burnTime.
}

init().