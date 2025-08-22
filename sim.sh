#!/bin/bash

set -e

mkdir -p sim
ghdl -a --std=08 --workdir=sim $(cat files.f)

cd sim
ghdl -e --std=08 tb_top
ghdl -r --std=08 tb_top --stop-time=10us --wave=waves.ghw

