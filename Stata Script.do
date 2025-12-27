*Encode country to numeric ID and set panel structure
encode country, gen(country_id)
xtset country_id year
* ======================================
*Create and transform key variables
*======================================
*Log-transform for skewed variables
gen GDP = log(gdp_capita)
gen EI= log(energy_intensity)
gen PM25 = log(pm25_exposure + 1)
gen PPPE = log(ppp_energy + 1)
gen C02 = log(co2_total + 1) 
gen RN = log(rents_natural_gdp + 1)
gen GHG = log(ghg + 1)
*Interaction terms to explore variable interplay
gen GDP_RQ = gdp_capita * reg_quality 
gen CO2_RQ = co2_total * reg_quality 
gen GDP_PS = gdp_capita * pol_stability 
gen CO2_PS = co2_total * pol_stability
*Growth variables
gen GDPG = (gdp_capita - L.gdp_capita) / L.gdp_capita
gen RG = (ec_renewable - L.ec_renewable) / L.ec_renewable
*Add control variables
. gen RN = log(rents_natural_gdp + 1)
. gen IF = log(inflation + 1)
. gen TO = log(trade_open)
. gen LFPR = log(lfpr_total)
. gen POP = log(pop_growth + 1)
=====
*PCA
egen z_ASE = std(as_energy_gni)
egen z_ECR = std(ec_renewable)
egen z_EGR = std(eg_renewable)
egen z_REC = std(rec_total)
pca z_ASE z_ECR z_EGR z_REC
predict SEDI_pca, score
sum SEDI_pca
PRE STAGE 
**(STIRPAT) MODELS 
*Consider 2-step regression: element of SED and SEDI (score)
. asdoc sum SEDI_pca GDP PPPE EI C02 GHG PM25 RN IF TO POP, star(all) replace nonum save(DES)
. asdoc pwcorr  SEDI_pca GDP PPPE EI C02 GHG PM25 RN IF TO POP, star(all) replace nonum save(CORR)
. regress SEDI_pca GDP PPPE EI C02 GHG PM25 RN IF TO POP
. asdoc vif, replace save(VIF.doc)

// Stationary test  
xtunitroot fisher SEDI_pca, dfuller drift demean lag(0)
xtunitroot fisher GDP, dfuller drift demean lag(0)
xtunitroot fisher  PPPE, dfuller drift demean lag(0)
xtunitroot fisher EI, dfuller drift demean lag(0)
xtunitroot fisher C02, dfuller drift demean lag(0)
xtunitroot fisher GHG, dfuller drift demean lag(0)
xtunitroot fisher PM25, dfuller drift demean lag(0)
xtunitroot fisher RN, dfuller drift demean lag(0)
xtunitroot fisher IF , dfuller drift demean lag(0)
xtunitroot fisher TO  , dfuller drift demean lag(0)
xtunitroot fisher POP , dfuller drift demean lag(0)
====
* Run each xtunitroot command and save results to the same file
asdoc xtunitroot fisher SEDI_pca, dfuller drift demean lag(0) replace nonum save(unitroot_results.doc)
asdoc xtunitroot fisher GDP, dfuller drift demean lag(0) append nonum save(unitroot_results.doc)
asdoc xtunitroot fisher PPPE, dfuller drift demean lag(0) append nonum save(unitroot_results.doc)
asdoc xtunitroot fisher EI, dfuller drift demean lag(0) append nonum save(unitroot_results.doc)
asdoc xtunitroot fisher C02, dfuller drift demean lag(0) append nonum save(unitroot_results.doc)
asdoc xtunitroot fisher GHG, dfuller drift demean lag(0) append nonum save(unitroot_results.doc)
asdoc xtunitroot fisher PM25, dfuller drift demean lag(0) append nonum save(unitroot_results.doc)
asdoc xtunitroot fisher RN, dfuller drift demean lag(0) append nonum save(unitroot_results.doc)
asdoc xtunitroot fisher IF, dfuller drift demean lag(0) append nonum save(unitroot_results.doc)
asdoc xtunitroot fisher TO, dfuller drift demean lag(0) append nonum save(unitroot_results.doc)
asdoc xtunitroot fisher POP, dfuller drift demean lag(0) append nonum save(unitroot_results.doc
STAGE 1: ECO
GROUP A.1: *OLS-FEM-REM 
regress SEDI_pca GDP PPPE EI IF TO POP
est store ols 
vif 
xtreg SEDI_pca GDP PPPE EI IF TO POP, fe 
est store fe 
xtreg SEDI_pca GDP PPPE EI IF TO POP, re 
est store re 
hausman fe re 
xttest0 
xtserial SEDI_pca GDP PPPE EI IF TO POP  

esttab ols fe re, star(* 0.1 ** 0.05 *** 0.01) replace

. asdoc esttab ols fe re, star(* 0.1 ** 0.05 *** 0.01) replace save(OLS-FEM-REM.doc)
GROUP B.1: *FLGS -PCSE
xtgls SEDI_pca GDP PPPE EI IF TO POP, panels(heteroskedastic) force
est store gls
. asdoc xtgls SEDI_pca GDP PPPE EI IF TO POP, panels(heteroskedastic) force, replace title(FGLS) 
. xtpcse SEDI_pca GDP PPPE EI IF TO POP, hetonly 
est store pcse
. asdoc . xtpcse SEDI_pca GDP PPPE EI IF TO POP, hetonly, replace title(PCSE) 

. asdoc esttab gls pcse, star(* 0.1 ** 0.05 *** 0.01) replace save(FGLS.doc)

GROUP B.1: *FLGS 
xtgls SEDI_pca GDP PPPE EI IF TO POP, panels(heteroskedastic) force
est store gls
. asdoc xtgls SEDI_pca GDP PPPE EI IF TO POP, panels(heteroskedastic) force, replace title(FGLS) 
. asdoc esttab gls , star(* 0.1 ** 0.05 *** 0.01) replace save(FGLS.doc)



GROUP C.1 :*INTER
FOR ORIGINAL 
regress SEDI_pca GDP PPPE EI IF TO POP GDP_RQ GDP_PS
est store olsi
xtreg SEDI_pca GDP PPPE EI IF TO POP GDP_RQ GDP_PS, fe
est store fixedi
xtreg SEDI_pca GDP PPPE EI IF TO POP GDP_RQ GDP_PS, re
est store randomi
xtgls SEDI_pca GDP PPPE EI IF TO POP GDP_RQ GDP_PS, panels(heteroskedastic) force
est store glsi
xtpcse SEDI_pca GDP PPPE EI IF TO POP GDP_RQ GDP_PS, hetonly
est store pcsei
esttab olsi fixedi randomi glsi pcsei, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab olsi fixedi randomi glsi pcsei, star(* 0.1 ** 0.05 *** 0.01) replace save(INTER.doc)

GROUP D.1:*QUAN
qreg SEDI_pca GDP PPPE EI IF TO POP, quantile(.25)
est store quantile_25
. asdoc qreg SEDI_pca GDP PPPE EI IF TO POP, quantile(.25), replace title(QUAN.25) 
qreg SEDI_pca GDP PPPE EI IF TO POP, quantile(.75)
est store quantile_75
. asdoc qreg SEDI_pca GDP PPPE EI IF TO POP, quantile(.25), replace title(QUAN.75) 

esttab quantile_25 quantile_75, star(* 0.1 ** 0.05 *** 0.01) replace
. asdoc esttab quantile_25 quantile_75, star(* 0.1 ** 0.05 *** 0.01) replace save(QUAN.doc)

**ROBUSTNESS CHECK S1
FOR RB-01
regress ECR GDP PPPE EI IF TO POP GDP_RQ GDP_PS
est store rb1
xtreg ECR GDP PPPE EI IF TO POP GDP_RQ GDP_PS, fe
est store  rb11
xtreg ECR GDP PPPE EI IF TO POP GDP_RQ GDP_PS, re
est store  rb111
xtgls ECR  GDP PPPE EI IF TO POP GDP_RQ GDP_PS, panels(heteroskedastic) force
est store rb1111
xtpcse ECR  GDP PPPE EI IF TO POP GDP_RQ GDP_PS, hetonly
est store rb11111
esttab rb1 rb11 rb111 rb1111 rb11111, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab rb1 rb11 rb111 rb1111 rb11111, star(* 0.1 ** 0.05 *** 0.01) replace save(INTER.doc)

***FOR RB-02 ++-
regress ASE GDP PPPE EI IF TO POP GDP_RQ GDP_PS
est store rb2
xtreg ASE GDP PPPE EI IF TO POP GDP_RQ GDP_PS, fe
est store  rb22
xtreg ASE GDP PPPE EI IF TO POP GDP_RQ GDP_PS, re
est store  rb222
xtgls ASE  GDP PPPE EI IF TO POP GDP_RQ GDP_PS, panels(heteroskedastic) force
est store rb2222
xtpcse ASE GDP PPPE EI IF TO POP GDP_RQ GDP_PS, hetonly
est store rb22222
esttab rb2 rb22 rb222 rb2222 rb22222, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab rb2 rb22 rb222 rb2222 rb22222, star(* 0.1 ** 0.05 *** 0.01) replace save(ROBUSTT.doc)
FOR RB-03
regress EGR GDP PPPE EI IF TO POP GDP_RQ GDP_PS
est store rb3
xtreg EGR GDP PPPE EI IF TO POP GDP_RQ GDP_PS, fe
est store  rb33
xtreg EGR GDP PPPE EI IF TO POP GDP_RQ GDP_PS, re
est store  rb333
xtgls EGR  GDP PPPE EI IF TO POP GDP_RQ GDP_PS, panels(heteroskedastic) force
est store rb3333
xtpcse EGR GDP PPPE EI IF TO POP GDP_RQ GDP_PS, hetonly
est store rb33333
esttab rb3 rb33 rb333 rb3333 rb33333, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab rb3 rb33 rb333 rb3333 rb33333, star(* 0.1 ** 0.05 *** 0.01) replace save(INTER.doc)
FOR RB-04

regress REC  GDP PPPE EI IF TO POP GDP_RQ GDP_PS
est store rb4
xtreg REC GDP PPPE EI IF TO POP GDP_RQ GDP_PS, fe
est store  rb44
xtreg REC GDP PPPE EI IF TO POP GDP_RQ GDP_PS, re
est store  rb444
xtgls REC  GDP PPPE EI IF TO POP GDP_RQ GDP_PS, panels(heteroskedastic) force
est store rb4444
xtpcse REC GDP PPPE EI IF TO POP GDP_RQ GDP_PS, hetonly
est store rb44444
esttab rb4 rb44 rb444 rb4444 rb44444, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab rb4 rb44 rb444 rb4444 rb44444, star(* 0.1 ** 0.05 *** 0.01) replace save(INTER.doc)
FOR RB-05
regress sed_index  GDP PPPE EI IF TO POP GDP_RQ GDP_PS
est store rb5
xtreg sed_index GDP PPPE EI IF TO POP GDP_RQ GDP_PS, fe
est store  rb55
xtreg sed_index GDP PPPE EI IF TO POP GDP_RQ GDP_PS, re
est store  rb555
xtgls sed_index  GDP PPPE EI IF TO POP GDP_RQ GDP_PS, panels(heteroskedastic) force
est store rb5555
xtpcse sed_index GDP PPPE EI IF TO POP GDP_RQ GDP_PS, hetonly
est store rb55555
esttab rb5 rb55 rb555 rb5555 rb55555, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab rb5 rb55 rb555 rb5555 rb55555, star(* 0.1 ** 0.05 *** 0.01) replace save(INTER.doc)

STAGE 2: ENVI
GROUP A.2: *OLS-FEM-REM 
regress SEDI_pca C02 GHG PM25 RN IF TO POP
est store ols2
vif 

xtreg SEDI_pca C02 GHG PM25 RN IF TO POP, fe
est store fe2

xtreg SEDI_pca C02 GHG PM25 RN IF TO POP, re
est store re2

hausman fe2 re2 

xtreg SEDI_pca C02 GHG PM25 RN IF TO POP, fe
xttest3 
xtserial SEDI_pca C02 GHG PM25 RN IF TO POP

esttab ols2 fe2 re2, star(* 0.1 ** 0.05 *** 0.01) replace

GROUP D.2: *FLGS-PCSE
xtgls SEDI_pca C02 RN GHG PM25 IF TO POP, panels(heteroskedastic) corr(ar1) force
est store gls2

esttab gls2, star(* 0.1 ** 0.05 *** 0.01) replace

xtpcse SEDI_pca C02 GHG PM25 RN IF TO POP, hetonly  

esttab gls2 pcse2, star(* 0.1 ** 0.05 *** 0.01) replace 

GROUP C.2 :*INTER-QUAD 
regress SEDI_pca C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS
est store olsii
xtreg SEDI_pca C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, fe
est store fixedii
xtreg SEDI_pca C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, re
est store randomii
xtgls SEDI_pca C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, panels(heteroskedastic) force
est store glsii
xtpcse SEDI_pca C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, hetonly
est store pcseii
esttab olsii fixedii randomii glsii pcseii, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab olsii fixedii randomii glsii pcseii, star(* 0.1 ** 0.05 *** 0.01) replace save(INTER_02.doc)

GROUP D.2:*QUAN
qreg SEDI_pca C02 GHG PM25 RN IF TO POP, quantile(.25)
est store quantile2_25
. asdoc qreg SEDI_pca C02 GHG PM25 RN IF TO POP, quantile(.25), replace title(QUAN.25)

qreg SEDI_pca C02 GHG PM25 RN IF TO POP, quantile(.75)
est store quantile2_75
. asdoc qreg SEDI_pca C02 GHG PM25 RN IF TO POP, quantile(.75), replace title(QUAN.75) 

esttab quantile2_25 quantile2_75, star(* 0.1 ** 0.05 *** 0.01) replace
. asdoc esttab quantile2_25 quantile2_75, star(* 0.1 ** 0.05 *** 0.01) replace save(QUAN -02.doc)

**ROBUSTNESS CHECK S2 +++-
FOR RRB-01
regress ECR C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS
est store rrb1
xtreg ECR C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, fe
est store  rrb11
xtreg ECR C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, re
est store  rrb111
xtgls ECR  C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, panels(heteroskedastic) force
est store rrb1111
xtpcse ECR  C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, hetonly
est store rrb11111
esttab rrb1 rrb11 rrb111 rrb1111 rrb11111, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab rrb1 rrb11 rrb111 rrb1111 rrb11111, star(* 0.1 ** 0.05 *** 0.01) replace save(INTER.doc)

FOR RRB-02 ++-
regress ASE C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS
est store rrb2
xtreg ASE C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, fe
est store  rrb22
xtreg ASE C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, re
est store  rrb222
xtgls ASE  C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, panels(heteroskedastic) force
est store rrb2222
xtpcse ASE C02 GHG PM25 RN IF TO POP CO2_RQ CO2_PS, hetonly
est store rrb22222
esttab rrb2 rrb22 rrb222 rrb2222 rrb22222, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab rrb2 rrb22 rrb222 rrb2222 rrb22222, star(* 0.1 ** 0.05 *** 0.01) replace save(ROBUSTT.doc)
FOR RB-03
regress EGR GDP PPPE EI IF TO POP GDP_RQ GDP_PS
est store rb3
xtreg EGR GDP PPPE EI IF TO POP GDP_RQ GDP_PS, fe
est store  rb33
xtreg EGR GDP PPPE EI IF TO POP GDP_RQ GDP_PS, re
est store  rb333
xtgls EGR  GDP PPPE EI IF TO POP GDP_RQ GDP_PS, panels(heteroskedastic) force
est store rb3333
xtpcse EGR GDP PPPE EI IF TO POP GDP_RQ GDP_PS, hetonly
est store rb33333
esttab rb3 rb33 rb333 rb3333 rb33333, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab rb3 rb33 rb333 rb3333 rb33333, star(* 0.1 ** 0.05 *** 0.01) replace save(INTER.doc)
FOR RB-04

regress REC  GDP PPPE EI IF TO POP GDP_RQ GDP_PS
est store rb4
xtreg REC GDP PPPE EI IF TO POP GDP_RQ GDP_PS, fe
est store  rb44
xtreg REC GDP PPPE EI IF TO POP GDP_RQ GDP_PS, re
est store  rb444
xtgls REC  GDP PPPE EI IF TO POP GDP_RQ GDP_PS, panels(heteroskedastic) force
est store rb4444
xtpcse REC GDP PPPE EI IF TO POP GDP_RQ GDP_PS, hetonly
est store rb44444
esttab rb4 rb44 rb444 rb4444 rb44444, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab rb4 rb44 rb444 rb4444 rb44444, star(* 0.1 ** 0.05 *** 0.01) replace save(INTER.doc)

FOR RB-05
regress sed_index  GDP PPPE EI IF TO POP GDP_RQ GDP_PS
est store rb5
xtreg sed_index GDP PPPE EI IF TO POP GDP_RQ GDP_PS, fe
est store  rb55
xtreg sed_index GDP PPPE EI IF TO POP GDP_RQ GDP_PS, re
est store  rb555
xtgls sed_index  GDP PPPE EI IF TO POP GDP_RQ GDP_PS, panels(heteroskedastic) force
est store rb5555
xtpcse sed_index GDP PPPE EI IF TO POP GDP_RQ GDP_PS, hetonly
est store rb55555
esttab rb5 rb55 rb555 rb5555 rb55555, star(* 0.1 ** 0.05 *** 0.01) replace 
. asdoc esttab rb5 rb55 rb555 rb5555 rb55555, star(* 0.1 ** 0.05 *** 0.01) replace save(INTER.doc)
