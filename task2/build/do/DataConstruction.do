* ==============================================================================
*
* Title				: AK91 Replication
* Modified by		: Busra Canci
* Stata version  	: 16
* Last modified  	: 20230909
*
* ==============================================================================
	

set more off
clear all

global path "C:\Users\buca4591\Desktop\2nd year\applied\busra_canci\task2"
	
cd "$path"

global inputpath	"raw/data"
global outputpath	"analysis/data"
	
/* AK91 */
	
	** UPLOAD DATA: ANGRIST & KRUEGER (1991)
	use "$inputpath/NEW7080.dta", clear
	
	** RENAME VARIABLES
	rename v1 AGE
	rename v2 AGEQ
	rename v4 EDUC
	rename v5 ENOCENT
	rename v6 ESOCENT
	rename v9 LWKLYWGE
	rename v10 MARRIED
	rename v11 MIDATL
	rename v12 MT
	rename v13 NEWENG
	rename v16 CENSUS
	rename v18 QOB
	rename v19 RACE
	rename v20 SMSA
	rename v21 SOATL
	rename v24 WNOCENT
	rename v25 WSOCENT
	rename v27 YOB
	
	** COHORT
	replace YOB = YOB-1900 if YOB >50 // I replace 1920s to 20s for xi purpose
	gen COHORT=2029
	replace COHORT=3039 if YOB<=39 & YOB >=30
	replace COHORT=4049 if YOB<=49 & YOB >=40
	replace AGEQ=AGEQ-1900 if CENSUS==80
	gen AGEQSQ= AGEQ*AGEQ
	
	** GENERATE YOB DUMMIES
	foreach i of numlist 0/9 {
	
		gen byte YR2`i' = YOB==2`i' | YOB==3`i' | YOB==4`i'
	
	}
	
	** GENERATE QOB DUMMIES
	foreach i of numlist 1/4 {
	
		gen byte QTR`i' = QOB==`i'
	
	}
	
	** GENERATE YOB*QOB DUMMIES
	foreach i of numlist 1/3 {
		foreach j of numlist 0/9 {
		
			gen QTR`i'2`j' = QTR`i'*YR2`j'
			
		}
	}
	
	** LABELING VARIABLE USED IN THE TABLE 
	la var EDUC 		"Years of education"
	la var RACE 		"Race (1 = black)"
	la var SMSA 		"SMSA (1 = center city)"
	la var MARRIED 		"Married (1 = married)"
	la var AGEQ 		"Age (quarterly)"
	la var AGEQSQ		"Age-squared"

	** SAVING THE DATA FOR EACH COHORT
	local c2 "IV"
	local c3 "V"
	local c4 "VI"
	forval i = 2/4 {
	preserve
	keep if COHORT==`i'0`i'9
	save "$outputpath/Table`c`i''_Data.dta", replace 
	restore
	}
	
	** KEEP ONLY RELEVANT VARIABLES FOR VALUE REVIEW AND REGRESSION
	keep AGE AGEQ EDUC ENOCENT ESOCENT LWKLYWGE MARRIED MIDATL MT ///
		 NEWENG CENSUS QOB RACE SMSA SOATL WNOCENT WSOCENT COHORT AGEQSQ ///
		 YR* QTR*
	
	** VARIABLE LABELING
	la var AGE 			"Age"
	la var ENOCENT 		"En 0 cent"
	la var ESOCENT 		"Es 0 cent"
	la var LWKLYWGE 	"Log weekly wage"
	la var NEWENG 		"New Eng"
	la var CENSUS 		"Census"
	la var QOB 			"Quarter of birth"
	la var WNOCENT 		"Wn 0 cent"
	la var WSOCENT 		"Ws 0 cent"
	la var COHORT 		"Cohort"
	
	** SAVING FULL SAMPLE DATSET
	save "$outputpath/AK91_Data.dta", replace 
	

/* AL99 */

	** VARIABLE RENAMING AND LABELING OF ANGRIST AND LAVY (1999) DATA
		
	
	forval i = 4/5 {
	
	use "$inputpath/final`i'.dta", clear
	
	** KEEP ONLY RELEVANT VARIABLES FOR VALUE REVIEW
	keep c_size c_boys c_girls c_num`i'rd c_type ///
		 flgrm`i' mrkgrm`i' ngrm`i' flmth`i' mrkmth`i' nmth`i' ///
		 grade cohsize mathsize avgmath passmath verbsize avgverb passverb
	
	** CORRECTING VALUES OF VARIABLES
	replace avgverb= avgverb-100 if avgverb>100
	replace avgmath= avgmath-100 if avgmath>100

	replace avgverb=. if verbsize==0
	replace passverb=. if verbsize==0

	replace avgmath=. if mathsize==0
	replace passmath=. if mathsize==0
	
	** VARIABLE RENAMING
	foreach var in flgrm mrkgrm ngrm flmth mrkmth nmth {
		rename `var'`i' `var'
	}
	
	** VARIABLE LABELING
	la var c_size 		"Class size"
	la var c_boys 		"Number of boys in class"
	la var c_girls 		"Number of firls in class"
	la var c_num`i'rd 	"Number 4th grade classes in school"
	la var c_type 		"Number of special education classes"
	la var flgrm 		"\% failer in grammar"
	la var mrkgrm 		"Mean mark in grammar"
	la var ngrm 		"Number of pupils in grammar class"
	la var flmth 		"\% failer in math"
	la var mrkmth 		"Mean mark in math"
	la var nmth 		"Number of pupils in math class"
	la var grade 		"Class grade"
	la var cohsize 		"Cohort size"
	la var mathsize 	"Number tested mathematics"
	la var avgmath 		"Mathematic score"
	la var passmath 	"Pass mathematic test"
	la var verbsize 	"Number tested reading"
	la var avgverb 		"Grammar score"
	la var passverb		"Pass grammar test"
	
	
	save "$outputpath/AL99_Grade`i'_Data.dta", replace 

	}
	
	*** END OF DO FILE ***
