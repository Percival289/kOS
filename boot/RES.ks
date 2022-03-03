// TODO: Add resource monitoring
// TODO: Control electrical system + power management
// TODO: Monitor fuel quantities

run "lib_general.ks".

print "Resources".

function main {
	until false {
		set message to LISTEN().
		if message:content = "Init Launch" { RES_InitLaunch(). }
		if message:content[0]
	}
}

function RES_InitLaunch {
	MSG("GUI", "RES_Ready").
	FYI("Ready").
    print "Ready".
}

main().