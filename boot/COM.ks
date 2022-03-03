run "lib_general.ks".

print "Communications".

function main {
	until false {
		print LISTEN():content.
	}
}

main().