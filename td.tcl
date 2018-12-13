import_device eagle_s20.db -package BG256
open_project picorv32-wb-test.al
elaborate -top top
optimize_rtl
report_area -file "picorv32-wb-test_rtl.area"
read_sdc "clocks.sdc"
read_adc "io.adc"
export_db "picorv32-wb-test_rtl.db"
map_macro
map
pack
report_area -file "picorv32-wb-test_gate.area"
export_db "picorv32-wb-test_gate.db"
start_timer
place
route
report_area -io_info -file "picorv32-wb-test_phy.area"
export_db "picorv32-wb-test_pr.db"
start_timer
report_timing -mode FINAL -net_info -ep_num 3 -path_num 3 -file "picorv32-wb-test_phy.timing"
bitgen -bit "picorv32-wb-test.bit" -version 0X00 -g ucode:00000000110111000000000000000000
