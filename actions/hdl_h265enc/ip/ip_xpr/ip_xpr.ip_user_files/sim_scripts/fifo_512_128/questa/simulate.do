onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_512_128_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_512_128.udo}

run -all

quit -force
