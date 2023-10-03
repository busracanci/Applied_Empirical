	set more off
	clear all
	set maxvar 10000

	global path = "C:\Users\buca4591\Desktop\GIT\Applied_Empirical\task5"
	cd "$path"
	
	global inputpath	"raw/data"
	global outputpath	"analysis/input"

	cd "$path"

	global inputpath	"analysis/input"
	global outputpath	"analysis/output"
	
	global MAIN			"female black hispanic othrace dep q1-q6 recall agelt35 agegt54 durable nondurable husd loc_10404-loc_10880"
	global SECORDER		"*X*"
	global ALLCOV		"$MAIN $SECORDER"
	
	set seed 20231003

* could not do the resampling 15 times since it takes ages. 

eststo clear
use "$inputpath/LassoAnalysis.dta", clear	

	* Plugin-formula
	eststo a1: xporegress loginuidur treatment, controls($ALLCOV) sel(plugin)  ///
					   cluster(abdt) xfold(5) resample(10) 
	lassoinfo, each
	mat B1 = r(table)
	esttab matrix(B1) using "$outputpath/LassoInfo_PF.tex", replace nomtitles label
	
	lassocoef (.,for(loginuidur) xfold(3) resample(5)) ///
			  (.,for(treatment) xfold(3) resample(5))
	mat C1 = r(coef)
	esttab matrix(C1) using "$outputpath/LassoCoef_PF.tex", replace nomtitles label

	
	* Always select, plugin-formula
	eststo a2: xporegress loginuidur treatment, controls(($MAIN) $SECORDER)  ///
						  sel(plugin) cluster(abdt) xfold(5) resample(10)
						  
	lassoinfo, each
	mat B2 = r(table)
	esttab matrix(B2) using "$outputpath/LassoInfo_PF-AS.tex", replace nomtitles label
	
	lassocoef (.,for(loginuidur) xfold(3) resample(5)) ///
			  (.,for(treatment) xfold(3) resample(5))
	mat C2 = r(coef)
	esttab matrix(C2) using "$outputpath/LassoCoef_PF-AS.tex", replace nomtitles label
			 
			 
	* Cross-validation
	eststo a3: xporegress loginuidur treatment, controls($ALLCOV) sel(cv) ///
					   cluster(abdt) xfold(5) resample(10)
	lassoinfo, each
	mat B3 = r(table)
	esttab matrix(B3) using "$outputpath/LassoInfo_CV.tex", replace nomtitles label
	
	lassocoef (.,for(loginuidur) xfold(3) resample(5)) ///
			  (.,for(treatment) xfold(3) resample(5))
	mat C3 = r(coef)
	esttab matrix(C3) using "$outputpath/LassoCoef_CV.tex", replace nomtitles label
	
	* Consolidating coefficients into one table
	esttab a1 a2 a3 using "$outputpath/CFPartialOut.tex", replace se nomtitles label 
			
*** END OF DO FILE 
	log close 
