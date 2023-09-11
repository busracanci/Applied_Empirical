* ==============================================================================
*
* Title				: AK91 Replication
* Aim				: Data cleaning for Table IV
* Modified by		: Busra Canci
* Stata version  	: 16
* Last modified  	: 20230905
*
* ==============================================================================

set more off
clear all

global path "C:\Users\buca4591\Desktop\GIT\Applied_Empirical\task1\AK91"
	
cd "$path"

	global inputpath	"analysis/data" 
	global outputpath	"analysis/result"
	

	use "$inputpath/TableIV_Data.dta", clear
	
	** Col 1 3 5 7 (OLS) ***
	eststo a1: qui reg LWKLYWGE EDUC YR20-YR28, robust
	estadd local yobd "Yes"
	estadd local rord "No"
	eststo a3: qui reg LWKLYWGE EDUC YR20-YR28 AGEQ AGEQSQ 
	estadd local yobd "Yes"
	estadd local rord "No"
	eststo a5: qui reg LWKLYWGE EDUC RACE MARRIED SMSA NEWENG MIDATL ENOCENT WNOCENT SOATL ESOCENT WSOCENT MT YR20-YR28 
	estadd local yobd "Yes"
	estadd local rord "No"
	eststo a7: qui reg LWKLYWGE EDUC RACE MARRIED SMSA NEWENG MIDATL ENOCENT WNOCENT SOATL ESOCENT WSOCENT MT YR20-YR28 AGEQ AGEQSQ
	estadd local yobd "Yes"
	estadd local rord "No"

	** Col 2 4 6 8 (IV 2SLS) ***
	eststo a2: qui ivregress 2sls LWKLYWGE YR20-YR28 (EDUC = QTR120-QTR129 QTR220-QTR229 QTR320-QTR329), first robust
	estadd local yobd "Yes"
	estadd local rord "Yes"
	eststo a4: qui ivregress 2sls LWKLYWGE YR20-YR28 AGEQ AGEQSQ (EDUC = QTR120-QTR129 QTR220-QTR229 QTR320-QTR329), first robust
	estadd local yobd "Yes"
	estadd local rord "Yes"
	eststo a6: qui ivregress 2sls LWKLYWGE YR20-YR28 RACE MARRIED SMSA NEWENG MIDATL ENOCENT WNOCENT SOATL ESOCENT WSOCENT MT  (EDUC = QTR120-QTR129 QTR220-QTR229 QTR320-QTR329), first robust
	estadd local yobd "Yes"
	estadd local rord "Yes"
	eststo a8: qui ivregress 2sls LWKLYWGE YR20-YR28 RACE MARRIED SMSA NEWENG MIDATL ENOCENT WNOCENT SOATL ESOCENT WSOCENT MT AGEQ AGEQSQ (EDUC = QTR120-QTR129 QTR220-QTR229 QTR320-QTR329), first robust
	estadd local yobd "Yes"
	estadd local rord "Yes"
	
	#d;
	esttab a1 a2 a3 a4 a5 a6 a7 a8 using "$outputpath/TableV.tex", order(EDUC RACE SMSA MARRIED AGEQ AGEQSQ) 
	keep(EDUC RACE SMSA MARRIED AGEQ AGEQSQ) 
	label  collabels(none) mlabels(, none) starlevels(* 0.10 ** 0.05 *** 0.01)  
	cells(b(fmt(3)) se(fmt(3) par)) style(tex) stats(N yobd rord chi2,  
	labels("Number of Observations" "9 year-of-birth dummies" "8 Region of residence dummies" "$\chi^2$")
	fmt(%9.0fc 3)) replace;
	# d cr	
	eststo clear
	
	