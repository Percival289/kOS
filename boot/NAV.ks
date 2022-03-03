// TODO: Get targetAp from guidance computer


run "lib_general.ks".

print "Navigation".

function main {
	until false {
		if LISTEN():content = "Init Launch" { NAV_InitLaunch(). }
		if LISTEN():content = "Launch" { NAV_Launch(). }
		if LISTEN():content = "MAX THROTTLE" { set throttleVar to 1. }
		if LISTEN():content = "BURN_THROTTLE" { NAV_BurnThrottle(). }
	}
}

function NAV_InitLaunch {

	set throttleVar to 0.02.
	lock throttle to throttleVar.
	MSG("GUI", "NAV_Ready").
	FYI("Ready").
	print "Ready".

}

function NAV_Launch {

	set throttleVar to 0.8.
	MSG("GUI", "Go").
	NAV_Ascent(90, 80000).

	until apoapsis >= targetAP {
		// Anything done during ascent
		NAV_LaunchThrottle().

		print "== NAV Ascent Guidance ==".
		print "".
		print "Throttle          |  " + round(throttleVar,2).

		if ship:orbit:apoapsis >= 70000 {
			print "Orbital Velocity  |  " + round(ship:velocity:orbit:mag).
		} else {
			print "Surface Speed     |  " + round(ship:velocity:surface:mag).
		}
		
		wait 0.01.
		clearscreen.

		if ship:altitude > 3000 {
			MSG("GUI", "Gravity turn start").
		}
	}
	until ship:altitude > 70000 {
		print "== NAV Final AP Adjustments ==".
		print "".
		print "Throttle          |  " + round(throttleVar,2).
		print "AP Error          |  " + round(ship:apoapsis - targetAp).
		print "Orbital Velocity  |  " + round(ship:velocity:orbit:mag).
		
		if targetAp > ship:apoapsis {
			set throttleVar to 0.0002.
		} else {
			set throttleVar to 0.
		}
		wait 0.01.
		clearscreen.
		
	}
	NAV_Shutdown().
	FYI("Apoapsis reached target height ("+targetAp/1000+"km)").

}

function NAV_LaunchThrottle {
	// Quadratic controls throttle for last 2000m burn
	if abs(targetAP - ship:apoapsis) <= 5000 {
		
        set throttleVar to min(0.02 + 0.000169577 * abs(targetAP - ship:apoapsis) + (-0.0000000165) * abs(targetAP - ship:apoapsis) ^ 2, max(min(1.5 /( (933 * 1000) / ((ship:mass*1000) * constant:g0)), 1),0.01)).
    } else {
        set throttleVar to max(min(1.5 /( (933 * 1000) / ((ship:mass*1000) * constant:g0)), 1),0.01).
    }
}

function getPitch {
    set pitch to slope * apoapsis + 90.
    set pitch to max(pitch, 0).
    return pitch.
}

function NAV_BurnThrottle {
	// TODO: Change to work with any target periapsis
	set targetPe to ship:apoapsis. 
	until LISTEN():content = "Circ Done" {
		if abs(targetPe - ship:periapsis <= 5000) {
			set throttleVar to 0.02 + 0.000169577 * abs(targetPe - ship:periapsis) + (-0.0000000165) * abs(targetPe - ship:periapsis) ^ 2.
		} else {
			set throttleVar to 1.
		}
	}
}

function NAV_Ascent {
    
	parameter dir.
    parameter alt.
	set alt to alt / 1000.
    set slope to (0 - 90) / (1000 * (alt  - 10 - alt * .05) - 0).

    SAS off.
    lock steering to heading(dir, getPitch()).
}

function NAV_Shutdown {
	set throttleVar to 0.
	lock steering to prograde.
}

main().