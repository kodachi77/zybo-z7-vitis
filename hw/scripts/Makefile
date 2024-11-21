design_name := zybo_z7_20_base_202201

all: project bitstream
	@echo
	@tput setaf 2 ; echo "Built $(design_name) successfully!"; tput sgr0;
	@echo

project:
	vivado -mode batch -source checkout.tcl -notrace

bitstream:
	@cd ../proj && vivado -mode batch -source ../scripts/build_bitstream.tcl -notrace || exit_code=$$? && cd ../scripts
	@if [ -n "$$exit_code" ]; then exit $$exit_code; fi

clean:
	@rm -rf ../proj/hw.* *.jou *.log NA .Xil
