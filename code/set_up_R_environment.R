# Section 0: Set up package latest package versions --------------------------------------------------------

#Lines below only need to be run when script is executed for the first time

install.packages("renv")

library("renv")

source("renv/activate.R")

renv::activate()
renv::restore()
