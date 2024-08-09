/*
	Replication code for "The seeds of misallocation: Fertilizer use and maize varietal misidentification in Ethiopia" by Nils Bohr, Tim Deisemann, Douglas Gollin, Frederic Kosmowski, Travis J. Lybbert (2024).
	
	Description: Computes summary statistics reported in 
	
	Table A9: Effective Urea use, seed beliefs and DNA type

	Author: Tim Deisemann
	Updated February 10, 2024
*/

/* ADAPT USER AND DIRECTORY HERE
global path ".../BDGLK_2024_replication_package"
global raw $path/raw/
global data $path/data/ */

use "${data}merged_data.dta", clear

gen dna_fingerprinting =.
replace dna_fingerprinting = 1 if exotic_source == "Yes" || exotic_source == "No"
replace dna_fingerprinting = 0 if dna_fingerprinting != 1

tab saq01 if dna_fingerprinting == 1
			
keep if saq01 == 1 | saq01 == 3 | saq01 == 4 | saq01 == 7 | saq01 == 13		

* Loop over variables
foreach var of varlist 	gender s1q03a s2q04 s7q04 s5q02 s3q08_ha ///
						nitrogen_kg_pha manure_use	 {
  * Summarize and pairwise mean comparison
	sum `var' if dna_fingerprinting == 1 
	sum `var' if dna_fingerprinting == 0 
    pwmean `var', over(dna_fingerprinting) mcompare(tukey) effects
}

*** PDS-LASSO selected controls (selected interaction terms omitted to save space)

replace s4q14 = 0 if s4q14 == 2
replace s5q16 = 0 if s5q16 == 2
replace s3q16 = 0 if s3q16 == 2

* Loop over variables
foreach var of varlist s4q14 s5q16 s7q22 cs4q26 s3q16 {
  * Summarize and pairwise mean comparison
	sum `var' if dna_fingerprinting == 1 
	sum `var' if dna_fingerprinting == 0
    pwmean `var', over(dna_fingerprinting) mcompare(tukey) effects
}

* Regional shares

gen tigray = 1 if saq01 == 1
replace tigray = 0 if tigray ==.

gen amhara = 1 if saq01 == 3
replace amhara = 0 if amhara ==.

gen oromia = 1 if saq01 == 4
replace oromia = 0 if oromia ==.

gen snnp = 1 if saq01 == 7
replace snnp = 0 if snnp ==.

gen harar = 1 if saq01 == 13
replace harar = 0 if harar ==.

* Loop over variables
foreach var of varlist 	tigray amhara oromia snnp harar {
  * Summarize and pairwise mean comparison
	sum `var' if dna_fingerprinting == 1
	sum `var' if dna_fingerprinting == 0
    pwmean `var', over(dna_fingerprinting) mcompare(tukey) effects
}
