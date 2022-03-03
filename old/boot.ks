
// Send HUD notification
function NOTIFY {

    parameter message.
    parameter type.
    if type = 1 {hudtext(message, 2, 2, 10, GREEN, false).} else if type = 2 {hudtext(message, 3, 2, 15, YELLOW, false).} else {hudtext(message, 5, 2, 15, RED, false).}
    
}

function HAS_FILE {

    parameter name.
    parameter vol.

    switch to vol.
    list files in allFiles.
    for x in allFiles {
        if x:name = name {
            switch to 1.
            return true.
        }
    }
    switch to 1.
    return false.
}

function DOWNLOAD {

    parameter name.

    if HAS_FILE(name, 1) {
        deletePath("1:/"+name).
    }
    if HAS_FILE(name, 0) {
        copyPath("0:/"+name, "1:/"+name).
    }
}

function UPLOAD {

    parameter name.

    if HAS_FILE(name, 0) {
        switch to 0. deletePath("0:/"+name). switch to 1.
    }
    if HAS_FILE(name, 1) {
        copyPath("1:/"+name, "0:/"+name).
    }
}

function REQUIRE {

    parameter name.
    
    if not HAS_FILE(name, 1) { DOWNLOAD(name). }
    run name.
}

set updateScript TO SHIP:NAME + ".update.ks".

if ship:connection:isConnected {
    if HAS_FILE(updateScript, 0) {

        DOWNLOAD(updateScript).
        switch to 0. deletePath(updateScript). switch to 1.
        runPath(updateScript).
        deletePath(updateScript).

    }
}

if HAS_FILE("startup.ks", 1) {

    run "startup.ks".

} else {

    wait until ship:connection:isConnected.
    wait 10.
    reboot.

}