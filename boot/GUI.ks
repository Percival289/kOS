// TODO: Detect Flight Phase
// TODO: Monitor system status
// TODO: Improve burn time on circ

run "lib_general.ks".
// Initialize guidance system
function init {
	
	// If below 100 meters, enter launch mode
	if ship:altitude <= 100 {
        GUI_Launch().
	}
}

function GUI_Launch {

	FYI("START LAUNCH SEQUENCE").

	// Send init messages and start processes

    wait 0.5.
    MSG("NAV", "Init Launch").
	wait until LISTEN():content = "NAV_Ready". GUI_Stage(). // Enable stage 1 engine

    wait 0.5.
	MSG("RES", "Init Launch").
    wait until LISTEN():content = "RES_Ready".

    wait 0.5.
	MSG("TLM", "Init Launch").
    wait until LISTEN():content = "TLM;Ready".
    
	// Mission log update
	FYI("Go for launch").
	
	// Engines to launch power
	MSG("NAV", "Launch").
    
	// Launch clamps released
	wait until LISTEN():content = "Go". GUI_Stage().
    FYI("Clamps released").

    // Check for liftoff
    wait until ship:altitude > 5.
    FYI("Liftoff confirmed").

    // Update points
    when LISTEN():content = "Gravity turn start" then { FYI("Gravity turn capture").}

    until ship:apoapsis >= targetAp {
        GUI_LaunchStaging().
        wait 0.01.
    }


    wait until ship:altitude > 70000.
    
    wait 3.
    AG3 on.
    wait 0.01.
    GUI_Stage().
    GUI_Stage().

    wait 1.
    set circBurnDeltaV to GUI_CalcCircularization().
    print "DeltaV for circularization burn: " + circBurnDeltaV.
    set circBurnTime to GUI_CalcBurnTime(circBurnDeltaV).
    print "Burn time: " + circBurnTime.

    GUI_CircBurn(circBurnTime).
	
}

function GUI_Stage {
	wait until stage:ready.
	stage.
}

function GUI_print {
    parameter message.
    print "[T+" + round(missionTime,0) + "]   " + message.
}

function GUI_LaunchStaging {

    if not(defined oldThrust) {
        global oldThrust is ship:availablethrust.
    }
    if ship:availablethrust < (oldThrust - 10) {
        GUI_Stage().
        if stage:number = 5 {
            MSG("NAV", "MAX THROTTLE").
            GUI_Stage().
        }
        FYI("Stage [" + stage:number + "] separation").
        wait 1.
        global oldThrust is ship:availablethrust.
    }

    // Eject LES
    if ship:altitude > 13000 and not AG2 {
        AG2 on.
        FYI("LES jettisoned").
    }

    // Eject external tanks
    if ship:partsdubbed("measureTank"):length > 0 {
        set tank to ship:partsdubbed("measureTank")[0].
        for res in tank:resources {
            if res:name = "LIQUIDFUEL" {
                set lfAmount to res.
                break.
            }
        }
        if lfAmount:amount = 0 { GUI_Stage(). FYI("External tanks jettisoned"). }
    }
    
}

function GUI_CalcCircularization {
    set grav_param to constant:G * Kerbin:mass.
    set r_apo to ship:apoapsis + 600000.

    //Vis-viva equation to give speed we'll have at apoapsis.
    set v_apo to SQRT(grav_param * ((2 / r_apo) - (1 / ship:orbit:semimajoraxis))).

    //Vis-viva equation to calculate speed we want at apoapsis for a circular orbit. 
    //For a circular orbit, desired SMA = radius of apoapsis.
    set v_apo_wanted to SQRT(grav_param * ((2 / r_apo) - (1 / r_apo))).
    return v_apo_wanted - v_apo.
}

function GUI_CircBurn {
    parameter t.

    wait until eta:apoapsis <= t/2.
    MSG("NAV", "MAX THROTTLE").
    wait t.
    MSG("NAV", "CUT THROTTLE").
}

function GUI_CalcBurnTime {

    // target 3 seconds
    parameter dV.

    set v_exhaust to 325 * constant:g0.
    set burnTime to ((ship:mass*v_exhaust)/60000) * (1 - (constant:e ^ (-dV/v_exhaust))) * 1000.
    return burnTime.
}

init().