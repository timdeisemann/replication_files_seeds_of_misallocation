Replication Package for: Nils Bohr, Tim Deisemann, Douglas Gollin, Frederic Kosmowski, Travis J. Lybbert, The seeds of misallocation: Fertilizer use and maize varietal misidentification in Ethiopia, Journal of Development Economics, 2024, 103349, ISSN 0304-3878, https://doi.org/10.1016/j.jdeveco.2024.103349. (https://www.sciencedirect.com/science/article/pii/S0304387824000981)

By Tim Deisemann (EBRD, timdeisemann@gmail.com) and Nils Bohr (bohr.nils98@gmail.com). For any questions, please do reach out to us.

This replication package produces all tables and figures shown in the paper and online appendix (except illustrative Figure A1). 

(1) Accessing the raw data

We do include the raw data in the replication package. The ESS4 data is available through the World Bank Microdata Library at https://microdata.worldbank.org/index.php/catalog/3823. The varietal data file was originally sourced from https://www.openicpsr.org/openicpsr/project/124681/version/V5/view. Following new information from breeders and scientists who reached out after the launch of the Ethiopian report, some correction were made to the file used for analysis, and available in the paper replication package ("Var_data_new.csv"). We expect to add this new version in the open repository after the finalisation of an upcoming report.

(2) Executing the code for figures 1, A2, A3, tables 2, A1-A10

Execute "create_master_data.do" to prepare the merged main dataset used for the analysis, then execute the respective dofiles in order of figures and tables appearing in the paper to reproduce the reported results. Note that "create_fig1_data.do" produces "figure1_data.csv" which is then used to produce figure 1 (figure1.R). "Create_figA3_data.do" prepares the dataset used to produce Figure A3 including yields data.

(3) Executing the code for the prediction/scaling exercise

Machine learning algorithms are prone to yield varying results across different machine environments. The variations we observed did not materially change any of the misallocation results reported in the paper.

Our prediction and scaling exercise results were created using the following system specifications

MacBook Pro (13-inch, 2020, Four Thunderbolt 3 ports)
Processor: 2 GHz Quad-Core Intel Core i5
Memory: 16 GB 3733 MHz LPDDR4X
Graphics: Intel Iris Plus Graphics 1536 MB
MACOS: Big Sur
R Version: 4.3.3 (Angel Food Cake)

In order to ensure the ability to exactly replicate our results across different machines and R/package versions, we have set up a docker container and are using the renv package. The steps for replication are hereby as follows: 

A) Set-up Docker Image

1) Install docker on local machine (https://www.docker.com/products/docker-desktop/) and create a dockerhub account (https://hub.docker.com/)
2) Pull the docker image associated with our project, which replicates the above system specifications: https://hub.docker.com/r/bohrnils/seeds_of_misallocation
Tip: can be done in the command line using: docker pull bohrnils/seeds_of_misallocation
3) On your machine, navigate into the replication package (replications_files_devec-d-23-01245) using the command line (e.g. "cd Downloads/replications_files_devec-d-23-01245")
4) Copy the following into the command line: "docker run --rm -p 8787:8787 -e DISABLE_AUTH=true -v $(pwd):/home/rstudio/Seeds_of_Misallocation  bohrnils/seeds_of_misallocation"
5) Open any web browser and type in the url: http://localhost:8787/

You should now see the R studio interface in your browser with the contents of the replication package in the Seeds_of_Misallocation folder

B) Execute R code within the docker image

Once you have completed A), follow the steps below. 

1) Open the Seeds_of_Misallocation.Rproj
2) Navigate into the code folder and run the script  "set_up_R_environment.R". This will load the renv file and install all necessary packages. To ensure this runs well, please execute line by line.
3) Run table3.R to generate all results shown in Table 3 (except for "predicted nitrogen level under corrected beliefs"). This code also generates main_prediction_output.dta and seeds_data_prediction_preprocessed.rds which is used in subsequent scripts.
4) Run "Table A11 - Part 1 Candidate Learners.R" and  "Table A11 - Part 2.R" to generate appendix results
5) To close the docker instance, terminate it in your command line)
6) Run 'table_3_prediction.do' to generate "predicted nitrogen level under corrected beliefs". This do-file can be run locally and does not need to be executed in the docker image. This docker image does not automatically synchronise data outputs to your local machine. For convenience, we readily include the 'main_prediction_output.dta' and 'seeds_data_prediction_preprocessed.rds' within the data folder in the replication package.

Important Note: Due to variability in the seed, all scripts need to be executed as a whole (by clicking 'source' in Rstudio) instead of running them line by line 

All steps in B) need to be repeated whenever the docker instance is reopened.