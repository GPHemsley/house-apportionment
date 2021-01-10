#!/usr/bin/env python3

import argparse
import csv
import math
import sys

#####

parser = argparse.ArgumentParser(description="Apportion the U.S. House of Representatives according to the cube root rule")

parser.add_argument("DATASET", help="population dataset to use")

parser.add_argument("--include-dc", action="store_true", help="include DC in apportionment")
parser.add_argument("--include-pr", action="store_true", help="include PR in apportionment")
parser.add_argument("--seats", default=None, type=int, help="use an explicit number of seats for apportionment")
parser.add_argument("--use-smallest", action="store_true", help="use the population of the smallest constituency as the population per seat")
parser.add_argument("--csv", action="store_true", help="output as CSV file")

args = parser.parse_args()

#####


def get_apportionment(populations, seat_count):
	# All constituencies start with 1 seat.
	apportionment = { constituency: 1 for constituency in populations }

	seats_left = seat_count - constituency_count
	while seats_left > 0:
		quotients = { constituency: population / math.sqrt(apportionment[constituency] * (apportionment[constituency] + 1)) for (constituency, population) in populations.items() }

		winning_constituency = sorted(quotients.items(), key=lambda q: q[1], reverse=True)[0][0]

		apportionment[winning_constituency] += 1
		seats_left -= 1

	assert sum(apportionment.values()) == seat_count

	return apportionment

def get_stats(populations, apportionment, population_per_seat):
	stats = {}

	for constituency in apportionment:
		constituency_population_per_seat = round(populations[constituency] / apportionment[constituency])
		population_per_seat_deviance = constituency_population_per_seat - population_per_seat
		population_per_seat_deviance_percentage = (population_per_seat_deviance / population_per_seat) * 100

		stats[constituency] = {
			"population_per_seat": constituency_population_per_seat,
			"population_per_seat_deviance": population_per_seat_deviance,
			"population_per_seat_deviance_percentage": population_per_seat_deviance_percentage,
		}

	return stats

#####

populations = {}

with open(args.DATASET, newline="", encoding="utf-8") as population_data_file:
	population_data_reader = csv.DictReader(population_data_file)

	for population_data_row in population_data_reader:
		population_count = int(population_data_row.get("RESIDENT_POPULATION", 0))
		population_count += int(population_data_row.get("OVERSEAS_POPULATION", 0))

		populations[population_data_row["AREA"]] = population_count

#####

if not args.include_dc:
	if "District of Columbia" in populations:
		del populations["District of Columbia"]

if not args.include_pr:
	if "Puerto Rico" in populations:
		del populations["Puerto Rico"]

#####

constituency_count = len(populations)
total_population = sum(populations.values())

if args.use_smallest:
	population_per_seat = min(populations.values())
	seat_count = args.seats if args.seats is not None else math.ceil(total_population / population_per_seat)
else:
	seat_count = args.seats if args.seats is not None else math.ceil(math.pow(total_population, 1/3))
	population_per_seat = round(total_population / seat_count)

final_population_per_seat = round(total_population / seat_count)
final_population_per_seat_deviance = final_population_per_seat - population_per_seat
final_population_per_seat_deviance_percentage = (final_population_per_seat_deviance / population_per_seat) * 100

apportionment = get_apportionment(populations, seat_count)

stats = get_stats(populations, apportionment, population_per_seat)

if args.csv:
	fields = [
		"AREA",
		"APPORTIONMENT_POPULATION",
		"SEATS",
		"POPULATION_PER_SEAT",
		"POPULATION_PER_SEAT_DEVIANCE",
		"POPULATION_PER_SEAT_DEVIANCE_PERCENTAGE",
	]

	csv_writer = csv.DictWriter(sys.stdout, fields, quoting=csv.QUOTE_NONNUMERIC)

	csv_writer.writeheader()

	for constituency in apportionment:
		row = {
			"AREA": constituency,
			"APPORTIONMENT_POPULATION": populations[constituency],
			"SEATS": apportionment[constituency],
			"POPULATION_PER_SEAT": stats[constituency]["population_per_seat"],
			"POPULATION_PER_SEAT_DEVIANCE": stats[constituency]["population_per_seat_deviance"],
			"POPULATION_PER_SEAT_DEVIANCE_PERCENTAGE": stats[constituency]["population_per_seat_deviance_percentage"],
		}

		csv_writer.writerow(row)

	total_row = {
		"AREA": "TOTAL",
		"APPORTIONMENT_POPULATION": total_population,
		"SEATS": seat_count,
		"POPULATION_PER_SEAT": final_population_per_seat,
		"POPULATION_PER_SEAT_DEVIANCE": final_population_per_seat_deviance,
		"POPULATION_PER_SEAT_DEVIANCE_PERCENTAGE": final_population_per_seat_deviance_percentage,
	}

	csv_writer.writerow(total_row)
else:
	print(f"Population Dataset: {args.DATASET}")
	print(f"Number of Constituencies: {constituency_count}")
	print(f"Total Population: {total_population}")
	print(f"Total Number of Seats: {seat_count}")
	print(f"Population per Seat: {population_per_seat}")
	print()

	for (constituency, constituency_stats) in sorted(stats.items()):
		constituency_population_per_seat = constituency_stats["population_per_seat"]
		population_per_seat_deviance = constituency_stats["population_per_seat_deviance"]
		population_per_seat_deviance_percentage = constituency_stats["population_per_seat_deviance_percentage"]

		print(f"{constituency:20s}\t{apportionment[constituency]: 3d}\t{population_per_seat_deviance:+8d}\t{population_per_seat_deviance_percentage: 8.2f}%")
