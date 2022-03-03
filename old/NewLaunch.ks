// TODO: Change ISP with new engines
// TODO: Add corrections for atmospheric drag after end of burn
// TODO: Fix circularization math

print "Main Program".

set targetAP to 80000.

function doCircularization {
    until ship:periapsis >= targetAP {

        set etaFraction to ( ship:periapsis - initialPeriapsis)/( ship:apoapsis - initialPeriapsis).
        set desiredETA to etaFraction*(finalETA - initialETA) + initialETA.
        set desiredETA to max ( finalETA, min ( initialETA, desiredETA)).
        
        
        
        set err to ETA:apoapsis - desiredETA.
        set dT to missiontime - pT.
        set pT to missiontime .
        set dErr to (err-pErr)/dT.
        set errInt to errInt + err*dT.
        
        set th to P*err + I*errInt + D*dErr + 0.5. // plus 0.5 to give it pos and neg at beginning.
        
        if eta:apoapsis > 10* initialETA // something has gone wrong and we passed apoapsis
        {
            break.
        }
        
        lock throttle to th.
        wait 0.01.
    }
}


function calcBurn {
    set grav_param to constant:G * kerbin:mass.
    set r_apo to ship:apoapsis + 600000.

    // Vis-Viva equation to get speed at apoapsis
    set v_apo to sqrt(grav_param * ((2 / r_apo) - (1 / ship:orbit:semimajoraxis))).
    print(ship:orbit:semimajoraxis).
    // Vis-Viva to calculate desired speed for circular orbit
    set v_apo_wanted to sqrt(grav_param * ((2 / r_apo) - (1 / r_apo))).
    set circ_delta_v to v_apo_wanted - v_apo.
    
    set v_exhaust to 380 * constant:g0.
    // 400000 is thrust in Newtons
    set burnTime to (ship:mass * v_exhaust / 400000) * (1 - constant:e ^ (-circ_delta_v / v_exhaust)).
    print burnTime.
}
function doLaunch {
    set throttleVar to 0.8.
    lock throttle to throttleVar.
    doSafeStage().
    doSafeStage().
}

function getPitch {
    set pitch to slope * apoapsis + 90.
    set pitch to max(pitch, 0).
    //print round(pitch,2).
    return pitch.
}

function doAscent {
    parameter dir.
    parameter alt.

    set slope to (0 - 90) / (1000 * (alt  - 10 - alt * .05) - 0).

    SAS off.
    lock steering to heading(dir, getPitch()).
    
}

function doAutoStage {
    if not(defined oldThrust) {
        global oldThrust is ship:availablethrust.
    }
    if ship:availablethrust < (oldThrust - 10) {
        doSafeStage().
        if stage:number = 5 {
            set throttleVar to 1.
            doSafeStage().
        }
        wait 1.
        global oldThrust is ship:availablethrust.
    }

    // Decouple LES
    if ship:altitude > 12000 and not AG2 {
        AG2 on.
        NOTIFY("LES Ejection", 1).
    }

    // Seperate external tanks
    set tank to ship:partsdubbed("measureTank")[0].
    for res in tank:resources {
        if res:name = "LIQUIDFUEL" {
            set lfAmount to res.
            break.
        }
    }
    if lfAmount:amount = 0 { doSafeStage(). }
}

function doThrottleManage {
    list engines in engs.
    set eng to engs[1].
    set throttleVar to min((1.5/((eng:maxthrust * 1000)/((ship:mass*1000)*constant:g0)))+0.1, 1).
}

function doShutdown {
    lock throttle to 0.
    lock steering to prograde.
}

function doSafeStage {
    wait until stage: ready.
    stage.
}

function main {
    doLaunch().
    doAscent(90, 80).
    until apoapsis > targetAP {
        doAutoStage().
        doThrottleManage().
        wait 0.01.
    }
    doShutdown().
    doCircularization().
    print "It ran!".
    unlock steering.
    wait until false.
}
main().