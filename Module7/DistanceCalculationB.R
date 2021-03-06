library(dplyr)
library(geosphere)
library(readr)

dataset <- read_csv("./Data/NYCTaxiCabTrips.csv")

ComputeDist <-
  function(pickup_long,
		   pickup_lat,
		   dropoff_long,
		   dropoff_lat) {

	R <- 6371 / 1.609344 #radius in mile
	delta_lat <- dropoff_lat - pickup_lat
	delta_long <- dropoff_long - pickup_long
	degrees_to_radians = pi / 180.0
	a1 <- sin(delta_lat / 2 * degrees_to_radians)
	a2 <- as.numeric(a1) ^ 2
	a3 <- cos(pickup_lat * degrees_to_radians)
	a4 <- cos(dropoff_lat * degrees_to_radians)
	a5 <- sin(delta_long / 2 * degrees_to_radians)
	a6 <- as.numeric(a5) ^ 2
	a <- a2 + a3 * a4 * a6
	c <- 2 * atan2(sqrt(a), sqrt(1 - a))
	d <- R * c
	return(d)
  }

#TaxiData <- read_csv("./Data/NYCTaxiCabTrips.csv")
TaxiData <- dataset %>%
	mutate(
			 `Trip Distance (Custom Function)` =
				round(
					ComputeDist(
						pickup_long,
						pickup_lat,
						dropoff_long,
						dropoff_lat)
				, 1)
			  , `Trip Distance (Geosphere Function)` =
				round(
						by(dataset,
						1:nrow(dataset),
						function(row) {
							distHaversine(
									c(row$pickup_long, row$pickup_lat),
									c(row$dropoff_long, row$dropoff_lat))
						}
						)
					* 0.000621371, 1
				)
	)
