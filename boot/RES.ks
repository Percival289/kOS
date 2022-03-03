run "lib_general.ks".

print "Resources".

function main {
	until false {
		if LISTEN():content = "Init Launch" { RES_InitLaunch(). }
	}
}

function RES_InitLaunch {
	MSG("GUI", "RES_Ready").
	FYI("Ready").
    print "Ready".
}

main().