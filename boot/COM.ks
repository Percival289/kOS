// TODO: Write log to archive

run "lib_general.ks".

print "Communications".

function main {
	until false {
		print LISTEN():content[0].
	}
}

main().