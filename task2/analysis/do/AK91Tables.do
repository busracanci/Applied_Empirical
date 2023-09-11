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

global inputpath	"analysis/data" 
global outputpath	"analysis/results"
	
	** INDEPENDENT VARIABLES MACROS
	global CONTROLS "RACE MARRIED SMSA NEWENG MIDATL ENOCENT WNOCENT SOATL ESOCENT WSOCENT MT"
	global QTR		"QTR120-QTR129 QTR220-QTR229 QTR320-QTR329 YR20-YR28"
	
	******* CREATE TABLES IV-VI
	foreach x in IV V VI {
		
	** UPLOAD DATA
	use "$inputpath/Table`x'_Data.dta", clear
	
	** DATA ANALYSIS
	
	** Col 1 3 5 7 (OLS) ***
	eststo a1: qui xi: reg LWKLYWGE EDUC i.YOB
	estadd local yobd "Yes"
	estadd local rord "No"
	eststo a3: qui xi: reg LWKLYWGE EDUC i.YOB AGEQ AGEQSQ 
	estadd local yobd "Yes"
	estadd local rord "No"
	eststo a5: qui xi: reg LWKLYWGE EDUC $CONTROLS i.YOB 
	estadd local yobd "Yes"
	estadd local rord "No"
	eststo a7: qui xi: reg LWKLYWGE EDUC $CONTROLS i.YOB AGEQ AGEQSQ
	estadd local yobd "Yes"
	estadd local rord "No"

	** Col 2 4 6 8 (IV 2SLS) ***
	eststo a2: qui xi: ivregress 2sls LWKLYWGE i.YOB (EDUC = $QTR), first robust
	estadd local yobd "Yes"
	estadd local rord "Yes"
	eststo a4: qui xi: ivregress 2sls LWKLYWGE i.YOB AGEQ AGEQSQ (EDUC = $QTR), first robust
	estadd local yobd "Yes"
	estadd local rord "Yes"
	eststo a6: qui xi: ivregress 2sls  i.YOB $CONTROLS (EDUC = $QTR), first robust
	estadd local yobd "Yes"
	estadd local rord "Yes"
	eststo a8: qui xi: ivregress 2sls LWKLYWGE i.YOB $CONTROLS AGEQ AGEQSQ (EDUC = $QTR), first robust
	estadd local yobd "Yes"
	estadd local rord "Yes"
	
	#d;
	esttab a1 a2 a3 a4 a5 a6 a7 a8 using "$outputpath/AK91_Table`x'.tex", order(EDUC RACE SMSA MARRIED AGEQ AGEQSQ) 
	keep(EDUC RACE SMSA MARRIED AGEQ AGEQSQ) 
	label  collabels(none) mlabels(, none) starlevels(* 0.10 ** 0.05 *** 0.01)  
	cells(b(fmt(3)) se(fmt(3) par)) style(tex) stats(N yobd rord chi2,  
	labels("Number of Observations" "9 year-of-birth dummies" "8 Region of residence dummies" "$\chi^2$")
	fmt(%9.0fc 3)) replace;
	# d cr	
	eststo clear
	
	}
	
	
	******* CREATE TABLES USING PROGRAM
	
	do "build/do/Programs.do"
	
	eststo clear
	use "$inputpath/AK91_Data.dta", clear
	
	local set1 EDUC YR20-YR28
	local set2 EDUC YR20-YR28 AGEQ AGEQSQ 
	local set3 EDUC $CONTROLS YR20-YR28
	local set4 EDUC $CONTROLS YR20-YR28 AGEQ AGEQSQ 
	
	forval i = 1/4 {
		olsregression LWKLYWGE `set`i'', storename(b`i')
	}
	
	latexoutputtable EDUC RACE SMSA MARRIED AGEQ AGEQSQ using "$outputpath/AK91_Table_Programmed.tex", storename(b1 b2 b3 b4)
	
	*** END OF DO FILE ***
	