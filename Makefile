SHELL=/bin/bash

ifeq ($(YEAR), 1990)
	DATASET=data/1990_census.csv
else ifeq ($(YEAR), 2000)
	DATASET=data/2000_census.csv
else ifeq ($(YEAR), 2010)
	DATASET=data/2010_census.csv
else ifeq ($(YEAR), 2020)
	DATASET=data/2020_estimate.csv
else ifeq ($(strip $(DATASET)),)
	# Default to latest official census, unless DATASET is explicitly set too.
	override YEAR=2010
	DATASET=data/2010_census.csv
endif

APPORTION_SCRIPT := ./apportion_house.py
DATA_DIR := ./data
RESULTS_DIR := ./results

###

.PHONY: all results

all: results

###

RESULTS :=\
	$(RESULTS_DIR)/$(YEAR)_435.csv \
	$(RESULTS_DIR)/$(YEAR)_435_smallest.csv \
	$(RESULTS_DIR)/$(YEAR)_smallest.csv \
	$(RESULTS_DIR)/$(YEAR)_cube_root.csv \
	$(RESULTS_DIR)/$(YEAR)_cube_root_with_dc.csv \
	$(RESULTS_DIR)/$(YEAR)_cube_root_with_pr.csv \
	$(RESULTS_DIR)/$(YEAR)_cube_root_with_dc_and_pr.csv

results: $(RESULTS)

# Apportion according to current algorithm.
$(RESULTS_DIR)/$(YEAR)_435.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --seats=435 > $@

# Apportion with current seat limit using Wyoming Rule.
$(RESULTS_DIR)/$(YEAR)_435_smallest.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --seats=435 --use-smallest > $@

# Apportion using Wymoing Rule without a seat limit.
$(RESULTS_DIR)/$(YEAR)_smallest.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --use-smallest > $@

# Apportion using Cube Root Rule.
$(RESULTS_DIR)/$(YEAR)_cube_root.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv > $@

# Apportion using Cube Root Rule and include DC.
$(RESULTS_DIR)/$(YEAR)_cube_root_with_dc.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --include-dc > $@

# Apportion using Cube Root Rule and include PR.
$(RESULTS_DIR)/$(YEAR)_cube_root_with_pr.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --include-pr > $@

# Apportion using Cube Root Rule and include DC and PR.
$(RESULTS_DIR)/$(YEAR)_cube_root_with_dc_and_pr.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --include-dc --include-pr > $@

###

.PHONY: FORCE
FORCE:
.DELETE_ON_ERROR:
.POSIX:
