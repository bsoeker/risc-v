### Makefile for simulation
# Variables
GHDL = ghdl
STD = --std=08
SIMDIR = sim
TOP = tb_top

# Default target
all: run

# Step 1: Analyze sources
analyze:
	$(GHDL) -a $(STD) --workdir=$(SIMDIR) $(shell cat files.f)

# Step 2: Elaborate top-level TB
elab: analyze
	$(GHDL) -e $(STD) --workdir=$(SIMDIR) -o $(SIMDIR)/$(TOP) $(TOP)

# Step 3: Run simulation
run: elab
	$(SIMDIR)/$(TOP) --stop-time=10us --wave=$(SIMDIR)/waves.ghw

# Utility
view:
	gtkwave $(SIMDIR)/waves.ghw &

clean:
	$(GHDL) --clean --workdir=$(SIMDIR)
	rm -rf $(SIMDIR)/*

