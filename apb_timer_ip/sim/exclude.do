coverage exclude -src ../rtl/apb_slave.v -code e -line 46-48 -comment {FEC rows decided only by PSEL or PENABLE in ACCESS state: unreachable without dropping PSEL/PENABLE mid-ACCESS (APB protocol violation, not in VPLAN)}
coverage exclude -scope /test_bench/dut/u_register -togglenode {TCR[2]} {TCR[3]} {TCR[4]} {TCR[5]} {TCR[6]} {TCR[7]} {TCR[12]} {TCR[13]} {TCR[14]} {TCR[15]} -comment {reserved bits}
coverage exclude -scope /test_bench/dut/u_register -togglenode {TCR[16]} {TCR[17]} {TCR[18]} {TCR[19]} {TCR[20]} {TCR[21]} {TCR[22]} {TCR[23]} {TCR[24]} {TCR[25]} -comment {reserved bits}
coverage exclude -scope /test_bench/dut/u_register -togglenode {TCR[26]} {TCR[27]} {TCR[28]} {TCR[29]} {TCR[30]} {TCR[31]} -comment {reserved bits}
