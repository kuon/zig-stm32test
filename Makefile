
BIN="zig-out/bin/sensor-firmware"

.PHONY: build

build:
	zig build -Drelease-small


.PHONY: clean

clean:
	rm -fr zig-cache
	rm -fr zig-out


.PHONY: flash

flash: build
	openocd -f ocd/ocd.cfg -c "program ${BIN} verify reset exit"

.PHONY: run

run: build
	multitail \
		-cT ansi  -l \
		"bash -c 'make rtt-server || sleep 1d'" \
		-cT ansi -l \
		"bash -c 'make rtt-client || sleep 1d'" \

.PHONY: rtt-server

rtt-server:
	openocd -f ocd/ocd.cfg \
		-c "program ${BIN} verify reset" \
		-f ocd/ocd_rtt.cfg

.PHONY: rtt-client

rtt-client:
	sleep 3
	nc localhost 9090


.PHONY: ocd

ocd:
	openocd -f ocd/ocd.cfg

.PHONY: gdb

gdb:
	arm-none-eabi-gdb -q -x ocd/debug.gdb ${BIN}

