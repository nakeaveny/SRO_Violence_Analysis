clear
clear all
cd "C:\Users\nickk\OneDrive\Desktop\ECO 4381G\Major Project\Draft 2 WOrk"
log using "Project_Draft2_3.txt", text replace

*load/read original data
use pu_ssocs18

*discard unused variables
keep SCHID VIOINC18 SEC_FT18 SEC_PT18 C0562 C0143 C0661 C0174 C0183 C0176 C0181 C0175 C0175 C0177 C0179 C0186 C0272 C0273 FR_SIZE FR_URBAN VIOPOL18



/* VIOINC18 Total number of violent incidents recorded--dependent
Purpose: To provide a summary measure of the number of violent incidents recorded.
General explanation: Sum of item 30, column 1, rows a, b, c_i, c_ii, d_i, d_ii, e_i, and e_ii.

SAS code: VIOINC18 = sum(C0310, C0314, C0318, C0322, C0326, C0330, C0334, C0338);
tab VIOINC18 
*/
rename VIOINC18 Num_Violent_Incidents

/*Other Explanatory Variables
SEC_FT18                      Total number of full-time security guards, SROs, and other sworn law enforcement
	SRO's or other security or law enforcement personnel 
Purpose: To provide a summary measure of the number of full-time security personnel.
General explanation: Sum of items 18a_i, 18b_i, and 19_i.*/
tab SEC_FT18
rename SEC_FT18 Num_FT_SWE

*SEC_PT18                      Total number of part-time security guards, SROs, and other sworn law enforcement
tab SEC_PT18
rename SEC_PT18 Num_PT_SWE

/*FR_SIZE This is a SSOCS-created variable of school size categories as reported in the
2014–15 CCD school data file. This variable collapses the number of
students into four categories: 1 = less than 300, 2 = 300–499, 3 = 500–999,
and 4 = 1,000 or more students. (Categorical)
FR_SIZE was created based on the CCD 2014–15 variable FR_NOST, as
follows:
SAS code:
if FR_NOST < 300 then FR_SIZE=1;
else if 300 <= FR_NOST <= 499 then FR_SIZE=2;
else if 500 <= FR_NOST <= 999 then FR_SIZE=3;
else if FR_NOST >= 1000 then FR_SIZE = 4; */

*recode as 3 seperate binary/indicator variables
tab FR_SIZE
summarize FR_SIZE
recode FR_SIZE (4=1) (else=0), generate(enrollment_1000_plus)
recode FR_SIZE (3=1) (else=0), generate(enrollment_500_999)
recode FR_SIZE (2=1) (else=0), generate(enrollment_300_499)
recode FR_SIZE (1=1) (else=0), generate(enrollment_299_less)
*drop FR_SIZE

*Crime where school located C0562->High_Crime_Area
codebook C0562
summarize C0562
tab C0562
recode C0562 (1=1) (2=0) (3=0), generate(High_Crime_Area)
recode C0562 (1=0) (2=1) (3=0), generate(Moderate_Crime_Area)
recode C0562 (1=0) (2=0) (3=1), generate(Low_Crime_Area)
tab High_Crime_Area

//Testing Urbanicity
summarize FR_URBAN
tab1 FR_URBAN
describe FR_URBAN
regress Num_Violent_Incidents FR_URBAN

*recoding urbanicity as seperate dummy variables 
tab FR_URBAN
summarize FR_URBAN
recode FR_URBAN (4=1) (else=0), generate(urbanicity_4_rural)
recode FR_URBAN (3=1) (else=0), generate(urbanicity_3_town)
recode FR_URBAN (2=1) (else=0), generate(urbanicity_2_suburb)
recode FR_URBAN (1=1) (else=0), generate(urbanicity_1_city)
*drop FR_URBAN

/*Running regressions with urbanicity dummy variables
*regress Num_Violent_Incidents Num_FT_SWE urbanicity_4 urbanicity_3 urbanicity_2 enrollment_1000_plus enrollment_500_999 enrollment_300_499 High_Crime_Area Hotline_Present Mental_Health_Diagnostic_Present

*Regression with only significant p value vars
regress Num_Violent_Incidents Num_FT_SWE urbanicity_4 urbanicity_3 urbanicity_2  */


*Provide a structured anonymous threat reporting system C0143->Hotline_Present
tab C0143
recode C0143 (2=0) (1=1), generate(Hotline_Present)
recode C0143 (2=1) (1=0), generate(No_Hotline)
drop C0143

*Diagnostic mental health assessment for mental disorders  C0661->Mental_Health_Diagnostic_Present
tab C0661
recode C0661 (2=0) (1=1), generate(Mental_Health_Diagnostic_Present)
recode C0661 (2=1) (1=0), generate(MHD_NotPresent)
drop C0661


/*
*Histogram of Num_Violent_Incidents
histogram Num_Violent_Incidents, frequency title("Total Number of Violent Incidents Recorded")
graph export Num_Violent_Incidents_hist.png, replace

*Tabulation of Num_Violent_Incidents
tab Num_Violent_Incidents
*Tabulation

*Summary Statistics of Num_FT_SWE and histogram
tab Num_FT_SWE
summarize Num_FT_SWE
histogram Num_FT_SWE
graph export Num_FT_SWE_hist.png, replace

*Summary Statistics of Crime where school located C0562->High_Crime_Area
tab1 High_Crime_Area
summarize High_Crime_Area
*Summary Statistics of Provide a structured anonymous threat reporting system C0143->Hotline_Present
tab1 Hotline_Present
summarize Hotline_Present
*Summary Statistics of Diagnostic mental health assesment for mental disorders  C0661->Mental_Health_Diagnostic_Present
tab1 Mental_Health_Diagnostic_Present
summarize Mental_Health_Diagnostic_Present
*/


//Training Vars
*Recode  trainingvars variables with relevant names and in binary form
recode C0273 (1=1) (2=0) (-1=.), generate(ttraining_rec_bully)
recode C0272 (1=1) (2=0) (-1=.), generate(ttraining_ews_violence)
recode C0174 (1=1) (2=0) (-1=.), generate(prevention_curriculum)
recode C0183 (1=1) (2=0) (-1=.), generate(social_emotional_learning)
recode C0176 (1=1) (2=0) (-1=.), generate(behavioral_intervention_students)
recode C0181 (1=1) (2=0) (-1=.), generate(adult_mentoring_tutoring)
recode C0175 (1=1) (2=0) (-1=.), generate(peer_meditation)
recode C0177 (1=1) (2=0) (-1=.), generate(student_court)
recode C0179 (1=1) (2=0) (-1=.), generate(restorative_circles)
recode C0186 (1=1) (2=0) (-1=.), generate(community_integration_program)
vl create trainingvars = (ttraining_rec_bully ttraining_ews_violence prevention_curriculum social_emotional_learning behavioral_intervention_students adult_mentoring_tutoring peer_meditation  student_court restorative_circles community_integration_program)
tab1 $trainingvars
drop C0174 C0183 C0176 C0181 C0175 C0177 C0179 C0186 C0272 C0273

*ttraining_rec_bully + ttraining_ews_violence + prevention_curriculum + social_emotional_learning + behavioral_intervention_students +  adult_mentoring_tutoring

*Create "mainvars" varlist
*Create varlist "mainvars"
vl create mainvars = (Num_Violent_Incidents Num_FT_SWE enrollment_1000_plus enrollment_500_999 enrollment_300_499 urbanicity_4_rural urbanicity_2_suburb High_Crime_Area Hotline_Present Mental_Health_Diagnostic_Present)

*Correlations of Num_Violent_Incidents with expl
corr $mainvars

//Summary Statistics and Visualization



*Num_FT_SWE
tab Num_FT_SWE
	*Create binary variable to create pie chart for does/doesn't have SRO
	recode Num_FT_SWE (0=0) (else=1), gen(Has_FTSRO)
	label variable Has_FTSRO "School has full time SRO*"
	recode Num_FT_SWE (0=1) (else=0), gen(No_FTSRO)
	label variable No_FTSRO "School doesn't have full time SRO*"
	tab Has_FTSRO 
	tab No_FTSRO
	graph pie Has_FTSRO No_FTSRO, plabel(_all percent, size(large)) title("Schools With or Without SROs", span) note("*Full time SRO or other security or sworn law enforcement")
	graph save "C1pie_hasSRO.png", replace
	graph save C1pie_hasSRO, replace
	
hist Num_FT_SWE, title("Number of SROs* Present at American Public Schools in SSOCS") freq note("*SRO, full time security, or sworn law enforcement")
graph save "C1B_NFTSWE_histogram.png", replace
graph save C1B_NFTSWE_histogram, replace
graph box Num_FT_SWE, over(FR_SIZE)

*School Size Indicators
tab FR_SIZE
summarize FR_SIZE
	label variable enrollment_299_less "Schools With Less Than 300 Students"
	label variable enrollment_300_499 "Schools With 300-499 Students"
	label variable enrollment_500_999 "Schools With 500-999 Students"
	label variable enrollment_1000_plus "Schools With 1000 Students or More"
graph bar (sum) enrollment_299_less enrollment_300_499 enrollment_500_999 enrollment_1000_plus , blabel(bar) legend(label(1 "`:variable label enrollment_299_less'")) legend(label(2 "`:variable label enrollment_300_499'")) legend(label(3 "`:variable label enrollment_500_999'")) legend(label(4 "`:variable label enrollment_1000_plus'")) ytitle("Number of Schools") title("School Enrollment Size In SSOCS Sample", span)
graph save "C2Enrollment_Bar.png", replace
graph save C2Enrollment_Bar, replace

*Urbanicity Indicators
tab FR_URBAN
summarize FR_URBAN
	label variable urbanicity_1_city "School in City"
	label variable urbanicity_2_suburb "School in Suburb"
	label variable urbanicity_3_town "School in Town"
	label variable urbanicity_4_rural "School in Rural Area"
graph bar (sum) urbanicity_1_city urbanicity_2_suburb urbanicity_3_town urbanicity_4_rural, blabel(bar) legend(label(1 "`:variable label urbanicity_1_city'")) legend(label(2 "`:variable label urbanicity_2_suburb'")) legend(label(3 "`:variable label urbanicity_3_town'")) legend(label(4 "`:variable label urbanicity_4_rural'")) ytitle ("Number of Schools") title("Urbanicity Types of Schools in Sample", span)
graph save "C3Urbanicity_Bar.png", replace
graph save C3Urbanicity_Bar, replace

*High Crime Area
tab1 C0562 
label variable High_Crime_Area "High Crime"
label variable Moderate_Crime_Area "Moderate Crime"
label variable Low_Crime_Area "Low Crime"
graph pie High_Crime_Area Moderate_Crime_Area Low_Crime_Area, plabel(_all percent, size(large)) title("School Area Crime Level", span) note("SSOCS Survey respondents were asked to classify the school in an area of high, moderate, or low crime.")
graph save "C4School_Area_Crime_Pie.png", replace
graph save C4School_Area_Crime_Pie, replace

*Mental Health Diagnostic Present
label variable Mental_Health_Diagnostic_Present "Services Present" 
label variable MHD_NotPresent "Services not Present"
graph pie Mental_Health_Diagnostic_Present MHD_NotPresent, plabel(_all percent, size(large)) title("Schools With Mental Health Diagnostic Services", span)
graph save "C5MHD_Present_Pie.png", replace
graph save C5MHD_Present_Pie, replace

*Hotline_Present
label var Hotline_Present "Has Hotline"
label var No_Hotline "Doesn't Have Hotline"
graph pie Hotline_Present No_Hotline, plabel(_all percent, size(large)) title("Provides a Structured Anonymous Threat Reporting System", span)
graph save "C6Hotline_Pie.png", replace
graph save C6Hotline_Pie, replace

*Num_Violent_Incidents
hist Num_Violent_Incidents, discrete freq title("Number of Violent Incidents Recorded at Schools", span)
graph save "C7NVI_Histogram.png", replace
graph save C7NVI_Histogram, replace
summarize Num_Violent_Incidents, detail

*Scatterplot Num_Violent_Incidents Num_FT_SWE
graph twoway (scatter Num_Violent_Incidents Num_FT_SWE) (lfit Num_Violent_Incidents Num_FT_SWE) , title("Number of Violent Incidents at Schools by the" "Number of SROs Present") legend(off) ytitle(Number of Violent Incidents Recorded)
graph save "C8NVI_NFTSROs_scatter.png", replace
graph save C8NVI_NFTSROs_scatter, replace
	*Alternate graph for binary Has_FTSRO and No_FTSRO
	graph box Num_Violent_Incidents, over(Has_FTSRO, relabel(1 "Doesn't Have SRO*" 2 "Has SRO*")) title("Violent Incidents Recorded With or Without Full Time SRO*") note("*SRO, full time security, or sworn law enforcement") 
	graph save "C8BNVI_Has_FTSRO.png", replace
	graph save C8BNVI_Has_FTSRO, replace


	
	

*Box and Wisker: Num_Violent_Incidents & Enrollment
graph box Num_Violent_Incidents, over(FR_SIZE, relabel(1 "1-299" 2 "300-499" 3 "500-1000" 4 "Over 1000")) title("Violent Incidents Recorded by Enrollment Size*") note("*Enrollment data drawn from 2015-2015 CCD (See Appendix: Enrollment Size Categorical Variables)")
*graph box Num_Violent_Incidents, over(FR_URBAN)
graph save "C9NVI_Enrollment_Box.png", replace
graph save C9NVI_Enrollment_Box, replace

tab Num_Violent_Incidents

//RQ2 Summary Statistics and Graphs
*Rename VIOPOL18
rename VIOPOL18 Num_Violent_Incidents_RTP

*Generate variable for percentage of incidents reported to police
gen NVIRTP_Over_NVI = Num_Violent_Incidents_RTP/Num_Violent_Incidents
tab NVIRTP_Over_NVI


graph bar NVIRTP_Over_NVI, over(FR_SIZE, relabel(1 "1-299" 2 "300-499" 3 "500-1000" 4 "Over 1000")) title("Average Ratio of Violent Incidents Reported to Poilice" "Over Total Violent Incidents Recorded by Enrollment Size*") note("*Enrollment data drawn from 2015-2015 CCD (See Appendix: Enrollment Size Categorical Variables)")
*graph twoway dot NVIRTP_Over_NVI FR_SIZE
*graph dot (mean)NVIRTP, over(FR_SIZE) asc asy
*MAYBE come back to figure out how to make dot graph
graph save "C10Enrollment_NVIRTP_Bar.png", replace
graph save C10Enrollment_NVIRTP_Bar, replace

	*Alternate graph for binary Has_FTSRO and No_FTSRO
	graph box NVIRTP_Over_NVI, over(Has_FTSRO, relabel(1 "Doesn't Have SRO*" 2 "Has SRO*")) title("Proportion of Violent Incidents Reported to Police by SRO* Presence") note("*SRO, full time security, or sworn law enforcement") 
	graph save "1PPTNVIRTP_Over_NVI_Has_FTSRO.png", replace
	graph save 1PPTNVIRTP_Over_NVI_Has_FTSRO, replace

	



/*
*DELETE LATER for powerpoint
tab1 Num_FT_SWE 
tab1 Has_FTSRO
summarize Num_FT_SWE Has_FTSRO

tab1 FR_SIZE
tab1 enrollment_1000_plus enrollment_500_999 enrollment_300_499 enrollment_299_less
summarize enrollment_1000_plus enrollment_500_999 enrollment_300_499 enrollment_299_less

tab1 FR_URBAN
tab1 urbanicity_1_city urbanicity_2_suburb urbanicity_3_town urbanicity_4_rural
summarize urbanicity_1_city urbanicity_2_suburb urbanicity_3_town urbanicity_4_rural

tab1 Mental_Health_Diagnostic_Present
summarize Mental_Health_Diagnostic_Present

tab1 NVIRTP_Over_NVI
summarize NVIRTP_Over_NVI



log close
*/







/*/Testing
regress Num_Violent_Incidents Has_FTSRO enrollment_1000_plus enrollment_500_999  urbanicity_4_rural urbanicity_2_suburb High_Crime_Area Mental_Health_Diagnostic_Present Hotline_Present
regress Num_Violent_Incidents Num_FT_SWE enrollment_1000_plus enrollment_500_999  urbanicity_4_rural urbanicity_2_suburb High_Crime_Area Mental_Health_Diagnostic_Present Hotline_Present

regress NVIRTP_Over_NVI Has_FTSRO 
regress NVIRTP_Over_NVI Has_FTSRO enrollment_1000_plus*/

//New Model Regressions--RQ1 Model 1A
eststo clear
*Single Regression
*Num_Violent_Incidents = a + b1 * Num_FT_SWE + e
eststo: regress Num_Violent_Incidents Num_FT_SWE

*Multiple Regression
*Adding school size indicator variables Num_Violent_Incidents = a + b1 * Num_FT_SWE + b2*enrollment_1000_plus + b3*enrollment_500_999 + enrollment_300_499 + e
eststo: regress Num_Violent_Incidents Num_FT_SWE enrollment_1000_plus enrollment_500_999  

*Multiple Regression 
*Adding urbanicity indicator variables
eststo: regress Num_Violent_Incidents Num_FT_SWE enrollment_1000_plus enrollment_500_999  urbanicity_4_rural urbanicity_2_suburb

*Multiple Regression
*Adding "high crime area"
eststo: regress Num_Violent_Incidents Num_FT_SWE enrollment_1000_plus enrollment_500_999  urbanicity_4_rural urbanicity_2_suburb High_Crime_Area 

*Multiple Regression
*Adding Mental_Health_Diagnostic_Present
eststo: regress Num_Violent_Incidents Num_FT_SWE enrollment_1000_plus enrollment_500_999  urbanicity_4_rural urbanicity_2_suburb High_Crime_Area Mental_Health_Diagnostic_Present

*Multiple Regression
*Adding Hotline_Present
eststo: regress Num_Violent_Incidents Num_FT_SWE enrollment_1000_plus enrollment_500_999  urbanicity_4_rural urbanicity_2_suburb High_Crime_Area Mental_Health_Diagnostic_Present Hotline_Present
*RQ1 Regression Table for Report
esttab
esttab using draft2_rq1_regressions_new.csv, replace se r2 label
esttab using draft2_rq1_regressions_new.rtf, replace se r2 label


//RQ1 Model 1B
//New Model Regressions--RQ1 Model 1A
eststo clear
*Single Regression
*Num_Violent_Incidents = a + b1 * Has_FTSRO + e
eststo: regress Num_Violent_Incidents Has_FTSRO

*Multiple Regression
*Adding school size indicator variables Num_Violent_Incidents = a + b1 * Num_FT_SWE + b2*enrollment_1000_plus + b3*enrollment_500_999 + enrollment_300_499 + e
eststo: regress Num_Violent_Incidents Has_FTSRO enrollment_1000_plus enrollment_500_999  

*Multiple Regression 
*Adding urbanicity indicator variables
eststo: regress Num_Violent_Incidents Has_FTSRO enrollment_1000_plus enrollment_500_999  urbanicity_4_rural urbanicity_2_suburb

*Multiple Regression
*Adding "high crime area"
eststo: regress Num_Violent_Incidents Has_FTSRO enrollment_1000_plus enrollment_500_999  urbanicity_4_rural urbanicity_2_suburb High_Crime_Area 

*Multiple Regression
*Adding Mental_Health_Diagnostic_Present
eststo: regress Num_Violent_Incidents Has_FTSRO enrollment_1000_plus enrollment_500_999  urbanicity_4_rural urbanicity_2_suburb High_Crime_Area Mental_Health_Diagnostic_Present

*RQ1B Regression Table for Report
esttab
esttab using draft2_rq1B_regressions_new.csv, replace se r2 label
esttab using draft2_rq1B_regressions_new.rtf, replace se r2 label


//RQ2 Variables and Regressions
*Summary of Relevant variables to create Y2
*tab1 VIOPOL18 Num_Violent_Incidents
*regress Num_Violent_Incidents Num_FT_SWE
*regress VIOPOL18 Num_FT_SWE


*ESTSTO Regressions
eststo clear
regress NVIRTP_Over_NVI Has_FTSRO enrollment_1000_plus enrollment_500_999  urbanicity_4_rural urbanicity_2_suburb High_Crime_Area Mental_Health_Diagnostic_Present Hotline_Present $trainingvars
eststo: regress NVIRTP_Over_NVI Has_FTSRO  
eststo: regress NVIRTP_Over_NVI enrollment_1000_plus
eststo: regress NVIRTP_Over_NVI Has_FTSRO enrollment_1000_plus 
esttab
esttab using RQ2_Multiple_Regression.csv, replace se r2 label
esttab using RQ2_Multiple_Regression.rtf, replace se r2 label
/*
/*
//Testing
regress Num_Violent_Incidents $trainingvars
regress Num_FT_SWE enrollment_1000_plus enrollment_500_999 enrollment_300_499
regress Num_FT_SWE enrollment_299_less

*gen sum_training_var = total(ttraining_rec_bully + ttraining_ews_violence + prevention_curriculum + social_emotional_learning + behavioral_intervention_students +  adult_mentoring_tutoring)
*gen sum_training_var = sum($trainingvars)
regress Num_Violent_Incidents Num_FT_SWE enrollment_1000_plus enrollment_500_999 enrollment_300_499 urbanicity_4 urbanicity_3 urbanicity_2 High_Crime_Area Hotline_Present Mental_Health_Diagnostic_Present
regress NVIRTP_Over_NVI Num_FT_SWE enrollment_1000_plus enrollment_500_999 enrollment_300_499 urbanicity_4 urbanicity_3 urbanicity_2 High_Crime_Area Hotline_Present Mental_Health_Diagnostic_Present
regress NVIRTP_Over_NVI Num_FT_SWE enrollment_1000_plus c.Num_FT_SWE#c.enrollment_1000_plus
*/




//Testing alternate y var's
tab1 VIOPOL18 Num_Violent_Incidents
regress Num_Violent_Incidents Num_FT_SWE
regress VIOPOL18 Num_FT_SWE
rename VIOPOL18 Num_Violent_Incidents_RTP

*Generate variable for percentage of incidents reported to police
gen NVIRTP_Over_NVI = Num_Violent_Incidents_RTP/Num_Violent_Incidents
tab NVIRTP_Over_NVI

eststo clear
regress NVIRTP_Over_NVI Num_FT_SWE enrollment_1000_plus enrollment_500_999  urbanicity_4_rural urbanicity_2_suburb High_Crime_Area Mental_Health_Diagnostic_Present Hotline_Present $trainingvars
eststo: regress NVIRTP enrollment_1000_plus 
esttab
esttab using RQ2_Single_Regression.csv, replace se r2 label
esttab using RQ2_Single_Regression.rtf, replace se r2 label


*Save data in excel file
export excel auto, firstrow(variables) replace
*/
log close