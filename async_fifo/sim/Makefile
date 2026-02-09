all:clean com sim dve

clean:
	rm -rf csrc *sim* *.key *.log *.log DVE* *.vpd

com:
	vcs -full64 -sverilog +v2k -timescale=1ns/1ps -debug_all +notimingcheck +nospecify -f file.list -R +fsdb+autoflush -l compile.log

sim:
	./simv +vcs+vcdpluson -l sim.log

dve:
	dve -full64 -vpd vcdplus.vpd &