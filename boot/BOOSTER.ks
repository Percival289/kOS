clearscreen.

function LISTEN {
    wait until not core:messages:empty.
	set recieved to core:messages:pop.
	return recieved.
}

wait until LISTEN():content[0] = "Decouple".

print "Stage decoupled".

wait 3.

RCS on.
lock steering to retrograde.

wait until vang(ship:facing:forevector,ship:retrograde:vector) < 2.

lock throttle to 1.

wait 2.

lock throttle to 0.