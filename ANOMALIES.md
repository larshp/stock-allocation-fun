# Bugs and issues

## A1 — initial lint configuration was invalid (fixed)

The initial configuration contained a non-JSON value and an incorrectly nested rules section.
Replaced it with a valid top-level rules configuration; lint and transpilation now execute.

## A2 — parameter alignment (fixed)

`align_type_expressions` includes the returning parameter when calculating the TYPE column.
Aligned the importing parameters to the returning parameter; lint passes.

## A3 — scaffold helper unavailable

The project setup helper reported no valid VS Code workspace despite the current directory
being accessible. Project files are created with editor tools in the existing repository instead.
