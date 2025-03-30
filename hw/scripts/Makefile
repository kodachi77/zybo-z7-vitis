
PRE_SYNTH ?= TRUE

all: project bitstream
	@echo
	@tput setaf 2 ; echo "Project built successfully!"; tput sgr0;
	@echo

project:
	vivado -mode batch -source generate_project.tcl -notrace

bitstream:
	@cd ../proj && vivado -mode batch -source ../scripts/generate_bitstream.tcl -notrace -tclargs $(PRE_SYNTH) || exit_code=$$? && cd ../scripts
	@if [ -n "$$exit_code" ]; then exit $$exit_code; fi

clean:
	@rm -rf ../proj/hw.* ../proj/.Xil ../proj/cache ../proj/*.jou ../proj/*.log *.jou *.log NA .Xil
