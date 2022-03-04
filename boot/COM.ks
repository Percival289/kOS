// TODO: Write log to archive
set terminal:width to 70.
set terminal:height to 46.

run "lib_general.ks".

print "Communications".

function main {
	until false {
		print LISTEN():content[0].
	}
}

main().