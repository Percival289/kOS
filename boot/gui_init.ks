function HAS_FILE { parameter n. parameter v. switch to v. list files in f. for file in f { if file:name = n { switch to 1. return true. }} switch to 1. return false. }

copypath("0:/libraries/lib_general.ks","").
copypath("0:/boot/Safemode.ks","").
run "lib_general.ks".
set terminal:width to 70.
set terminal:height to 46.

FYI("").
FYI("----- START OF MISSION LOG -----").
FYI("").
FYI("Guidance is internal.").
wait 0.1.
FYI("Deactivating other processors").

processor("NAV"):deactivate.
processor("RES"):deactivate.
processor("TLM"):deactivate.
processor("COM"):deactivate.
processor("BOOSTER"):deactivate.

FYI("Copying general files to other processors.").

copypath("lib_general.ks","NAV:/lib_general.ks").
copypath("lib_general.ks","RES:/lib_general.ks").
copypath("lib_general.ks","TLM:/lib_general.ks").
copypath("lib_general.ks","COM:/lib_general.ks").
copypath("lib_general.ks","BOOSTER:/lib_general.ks").

wait 0.2.

FYI("Initializing processor TLM").
copypath("0:/boot/TLM.ks","TLM:/TLM.ks").
set TLMp to processor("TLM").
set TLMp:bootfilename to "TLM.ks".
processor("TLM"):activate.
wait 0.3.

FYI("Initializing processor COM").
copypath("0:/boot/COM.ks","COM:/COM.ks").
set COMp to processor("COM").
set COMp:bootfilename to "COM.ks".
processor("COM"):activate.
wait 0.3.

FYI("Initializing processor NAV").
copypath("0:/boot/NAV.ks","NAV:/NAV.ks").
//copypath("0:/libraries/Lib_NAV.ks","NAV:/Lib_NAV.ks").
set NAVp to processor("NAV").
set NAVp:bootfilename to "NAV.ks".
processor("NAV"):activate.
wait 0.3.

FYI("Initializing processor RES").
copypath("0:/boot/RES.ks","RES:/RES.ks").
set RESp to processor("RES").
set RESp:bootfilename to "RES.ks".
processor("RES"):activate.
wait 0.3.

FYI("Initializing processor BOOSTER").
copypath("0:/boot/BOOSTER.ks","BOOSTER:/BOOSTER.ks").
set BOOSTERp to processor("BOOSTER").
set BOOSTERp:bootfilename to "BOOSTER.ks".
processor("BOOSTER"):activate.
wait 0.3.

FYI("Initializing self").
copypath("0:/boot/GUI.ks","").
set GUIp to processor("GUI").
set GUIp:bootfilename to "GUI.ks".
wait 0.3.

FYI("Rebooting").
wait 2.
reboot.