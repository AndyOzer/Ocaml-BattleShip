# Ocaml Battleship

Authors: Zhe Ou, Ding Zhao

## Overview

The Purpose of this project is to create a battleship game with multiple level of AI difficulties to support Human vs. AI.

![battleship_overview](figures/battleship_overview.png)

## Installation and Compile

```opam install .--deps-only --working-dir```: install dependencies if not already installed

```dune build```: build the program

```dune test```: test coverage

```dune exec src/bin/main.exe```: open a browser for gameplay

```dune exec -- _build/default/src/bin/battleship_count.exe```: generate simulation results to analyze different AI strtegies

### Usage

#### Enter battleship size and select AI difficulty: Invalid input will trigger the `😈Demon Mode😈`

![battleship_homepage](figures/homepage.png)

#### Place ships: select the start coordinate and end coordinate to place the ship or click Enermy Board for random ship placement

![battleship_homepage](figures/placement.png)

#### Start the game!

![battleship_homepage](figures/gameplay.png)


#### Click Title "Ocaml Battleship" to return to the homepage

## Test Coverage

Note that only ```.ml``` files related to basic game logic is tested.

```src/lib/battleship_gameplay.ml```: 100%

```src/lib/battleship_helper.ml```: 100%

```src/lib/battleship_placement.ml```: 98%

### Dependencies

```Core, Ounit2, Core_Unix, Dream```