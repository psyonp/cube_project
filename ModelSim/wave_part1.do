onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -label KEY /testbench/KEY
add wave -noupdate -label SW /testbench/SW
add wave -noupdate -divider {Control}
add wave -noupdate -label move_sel -radix unsigned /testbench/U1/move_sel
add wave -noupdate -label reverse /testbench/U1/reverse

add wave -noupdate -divider {Cube Faces}
add wave -noupdate -label front -radix unsigned /testbench/U1/front
add wave -noupdate -label back -radix unsigned /testbench/U1/back
add wave -noupdate -label left -radix unsigned /testbench/U1/left
add wave -noupdate -label right -radix unsigned /testbench/U1/right
add wave -noupdate -label top -radix unsigned /testbench/U1/top
add wave -noupdate -label bottom -radix unsigned /testbench/U1/bottom

TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {10000 ns}
