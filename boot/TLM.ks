// TODO: New way of displaying telemetry
// TODO: Write to file and send to archive
// TODO: Add more data

run "lib_general.ks".

print "Telemetry".

function main {
	until false {
		if LISTEN():content[0] = "Init Launch" { TLM_InitLaunch(). }
	}
}

function TLM_InitLaunch {
	MSG("GUI", "TLM_Ready").
	FYI("Ready").
    print "Ready".
    print "".
    until false {
        print "Q:         " + round(ship:q*1000,2) + "pa (MAX: 155pa)".
        print "Pitch:     " + round(ship:facing:pitch,3) + " degrees".
        print "Roll:      " + round(ship:facing:roll,3) + " degrees".
        print "Yaw:       " + round(ship:facing:yaw,3) + " degrees".
        print "Alt:       " + round(ship:altitude, 3) + "m".
        print "Apoapsis:  " + round(ship:apoapsis, 3) + "m".
        print "Periapsis: " + round(ship:periapsis, 3) + "m".
        print "V_Orbit:   " + round(ship:velocity:orbit:mag) + "m/s".
        wait 0.01.
        clearscreen.
    }
}

main().