SHELL=/bin/bash

ifeq ($(YEAR), 1910)
	DATASET=data/1910_census.csv
else ifeq ($(YEAR), 1920)
	DATASET=data/1920_census.csv
else ifeq ($(YEAR), 1930)
	DATASET=data/1930_census.csv
else ifeq ($(YEAR), 1950)
	DATASET=data/1950_census.csv
else ifeq ($(YEAR), 1960)
	DATASET=data/1960_census.csv
else ifeq ($(YEAR), 1970)
	DATASET=data/1970_census.csv
else ifeq ($(YEAR), 1980)
	DATASET=data/1980_census.csv
else ifeq ($(YEAR), 1990)
	DATASET=data/1990_census.csv
else ifeq ($(YEAR), 2000)
	DATASET=data/2000_census.csv
else ifeq ($(YEAR), 2010)
	DATASET=data/2010_census.csv
else ifeq ($(YEAR), 2020)
	DATASET=data/2020_census.csv
else ifeq ($(strip $(DATASET)),)
	# Default to latest official census, unless DATASET is explicitly set too.
	override YEAR=2020
	DATASET=data/2020_census.csv
endif

APPORTION_SCRIPT := ./apportion_house.py
DATA_DIR := ./data
RESULTS_DIR := ./results

#####

.PHONY: all results

all: results

#####

RESULTS :=\
	$(RESULTS_DIR)/435/$(YEAR)_435.csv \
	$(RESULTS_DIR)/435_without_ak_and_hi/$(YEAR)_435_without_ak_and_hi.csv \
	$(RESULTS_DIR)/435_with_dc/$(YEAR)_435_with_dc.csv \
	$(RESULTS_DIR)/435_with_pr/$(YEAR)_435_with_pr.csv \
	$(RESULTS_DIR)/435_with_dc_and_pr/$(YEAR)_435_with_dc_and_pr.csv \
	$(RESULTS_DIR)/435_smallest/$(YEAR)_435_smallest.csv \
	$(RESULTS_DIR)/smallest/$(YEAR)_smallest.csv \
	$(RESULTS_DIR)/smallest_without_ak_and_hi/$(YEAR)_smallest_without_ak_and_hi.csv \
	$(RESULTS_DIR)/smallest_with_dc/$(YEAR)_smallest_with_dc.csv \
	$(RESULTS_DIR)/smallest_with_pr/$(YEAR)_smallest_with_pr.csv \
	$(RESULTS_DIR)/smallest_with_dc_and_pr/$(YEAR)_smallest_with_dc_and_pr.csv \
	$(RESULTS_DIR)/cube_root/$(YEAR)_cube_root.csv \
	$(RESULTS_DIR)/cube_root_without_ak_and_hi/$(YEAR)_cube_root_without_ak_and_hi.csv \
	$(RESULTS_DIR)/cube_root_with_dc/$(YEAR)_cube_root_with_dc.csv \
	$(RESULTS_DIR)/cube_root_with_pr/$(YEAR)_cube_root_with_pr.csv \
	$(RESULTS_DIR)/cube_root_with_dc_and_pr/$(YEAR)_cube_root_with_dc_and_pr.csv

results: $(RESULTS)

###

# Apportion according to current algorithm.
$(RESULTS_DIR)/435/$(YEAR)_435.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --seats=435 > $@

# Apportion according to current algorithm and exclude AK and HI.
$(RESULTS_DIR)/435_without_ak_and_hi/$(YEAR)_435_without_ak_and_hi.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --seats=435 --exclude-ak --exclude-hi > $@

# Apportion according to current algorithm and include DC.
$(RESULTS_DIR)/435_with_dc/$(YEAR)_435_with_dc.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --seats=435 --include-dc > $@

# Apportion according to current algorithm and include PR.
$(RESULTS_DIR)/435_with_pr/$(YEAR)_435_with_pr.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --seats=435 --include-pr > $@

# Apportion according to current algorithm and include DC and PR.
$(RESULTS_DIR)/435_with_dc_and_pr/$(YEAR)_435_with_dc_and_pr.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --seats=435 --include-dc --include-pr > $@

###

# Apportion with current seat limit using Wyoming Rule.
$(RESULTS_DIR)/435_smallest/$(YEAR)_435_smallest.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --seats=435 --use-smallest > $@

###

# Apportion using Wyoming Rule without a seat limit.
$(RESULTS_DIR)/smallest/$(YEAR)_smallest.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --use-smallest > $@

# Apportion using Wyoming Rule without a seat limit and exclude AK and HI.
$(RESULTS_DIR)/smallest_without_ak_and_hi/$(YEAR)_smallest_without_ak_and_hi.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --use-smallest --exclude-ak --exclude-hi > $@

# Apportion using Wyoming Rule without a seat limit and include DC.
$(RESULTS_DIR)/smallest_with_dc/$(YEAR)_smallest_with_dc.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --use-smallest --include-dc > $@

# Apportion using Wyoming Rule without a seat limit and include PR.
$(RESULTS_DIR)/smallest_with_pr/$(YEAR)_smallest_with_pr.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --use-smallest --include-pr > $@

# Apportion using Wyoming Rule without a seat limit and include DC and PR.
$(RESULTS_DIR)/smallest_with_dc_and_pr/$(YEAR)_smallest_with_dc_and_pr.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --use-smallest --include-dc --include-pr > $@

###

# Apportion using Cube Root Rule.
$(RESULTS_DIR)/cube_root/$(YEAR)_cube_root.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv > $@

# Apportion using Cube Root Rule and exclude AK and HI.
$(RESULTS_DIR)/cube_root_without_ak_and_hi/$(YEAR)_cube_root_without_ak_and_hi.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --exclude-ak --exclude-hi > $@

# Apportion using Cube Root Rule and include DC.
$(RESULTS_DIR)/cube_root_with_dc/$(YEAR)_cube_root_with_dc.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --include-dc > $@

# Apportion using Cube Root Rule and include PR.
$(RESULTS_DIR)/cube_root_with_pr/$(YEAR)_cube_root_with_pr.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --include-pr > $@

# Apportion using Cube Root Rule and include DC and PR.
$(RESULTS_DIR)/cube_root_with_dc_and_pr/$(YEAR)_cube_root_with_dc_and_pr.csv: FORCE
	$(APPORTION_SCRIPT) $(DATASET) --csv --include-dc --include-pr > $@

#####

.PHONY: FORCE
FORCE:
.DELETE_ON_ERROR:
.POSIX:
