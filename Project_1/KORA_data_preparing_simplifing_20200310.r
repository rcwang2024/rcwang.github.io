###########################
# KORA data pre-processing
###########################
setwd("/data/preparing")
list.files()

# load related packages
require('pROC')
require('openxlsx')
require('caret')
require('clusterSim')

###+++++++++++++++++++
# prepare the data set
###+++++++++++++++++++
Phen_new <- read.csv('KORA_20190617_JA_Ruichao_20200310.csv', header = TRUE)
head(Phen_new)
length(Phen_new$Index_JA) # 4261

#------------------
# for KORA S4
#------------------
S4_raw <- read.csv("KORA_S4_Biocrates_Data_RCW.csv", header = TRUE)
length(S4_raw$zz_nr_bio_S4) # 1610

Phen_S4 <- subset(Phen_new, is.na(Phen_new$zz_nr_biocrates_s4) == FALSE)
length(Phen_S4$zz_nr_biocrates_s4) # 1607
write.csv(Phen_S4, 'KORA_S4_20190617_JA_RCW_20200310.csv')

setdiff(S4_raw$zz_nr_bio_S4, Phen_S4$zz_nr_biocrates_s4)
# [1] 745000116 745001434 745001488 
# this three individuals will be removed, as they did not in the latest phenotype dataset
S4_raw <- subset(S4_raw, !(S4_raw$zz_nr_bio_S4 %in% setdiff(S4_raw$zz_nr_bio_S4, Phen_S4$zz_nr_biocrates_s4)))
length(S4_raw$zz_nr_bio_S4) # 1607

##+++ add the variable of metformin and zz_S4_biocrates
Phen_S4 <- Phen_S4[order(match(Phen_S4$zz_nr_biocrates_s4, S4_raw$zz_nr_bio_S4)), ]
S4_raw$ltmmetf <- Phen_S4$ltmmetf
S4_raw$zz_nr_biocrates_s4_new <- Phen_S4$zz_nr_biocrates_s4
all(S4_raw$zz_nr_bio_S4, S4_raw$zz_nr_biocrates_s4_new)
write.csv(S4_raw, 'KORA_S4_Biocrates_Data_RCW_20200310.csv')


##+++++++++++++ simplifiy the data by select variables and rename them +++++++++++##
S4 <- read.csv('KORA_S4_Biocrates_Data_RCW_20200310.csv', header = TRUE)
head(S4)

# select the confounders and metabolites which used for further analysis
S4_confouders <- data.frame(ID_S4 = S4$zz_nr_bio_S4,
                            ID_F4 = S4$zz_nr_bio_F4,
                            ##
                            Batch_bioc_S4 = S4$batch_bioc_S4,
                            Fasting_State = S4$ltnuecht,
                            Metf = S4$ltmmetf,
                            Or_andi = S4$ltmoadi,
                            ##
                            Class = S4$ltdmstat,
                            Class_who = S4$lp_diab_who06,
                            ##
                            Age = S4$ltalteru, 
                            Sex = S4$lcsex, 
                            BMI = S4$ltbmi,
                            ##
                            HbA1c = S4$ll_hbav,
                            FGa = S4$ltglukfast_a,
                            FGn = S4$ltglukfast_n,
                            G2ha = S4$ltgluk2a,
                            G2hn = S4$ltgluk2n,
                            ##
                            Phys = S4$ltphys,
                            Cigreg = S4$ltcigreg,
                            Alcohol = S4$ltalkkon,
                            Sys_BP = S4$ltsysmm,
                            Dia_BP = S4$ltdiamm,
                            ##
                            Tria = S4$ll_tria,
                            HDL = S4$ll_hdla,
                            LDL = S4$ll_ldla,
                            CHOL = S4$ll_chola,
                            ##
                            Hemoglobin = S4$ll_hgb,
                            Lekocytes = S4$ll_wbc,
                            Crp = S4$lh_crp,
                            HOMA_IR = S4$lthoma_ir
)

S4_metabolites <- S4[,70:209]

# combine the confounders and metabolites
S4 <- cbind(S4_confouders, S4_metabolites)
head(S4)

# define the catagorical group class

S4$Fasting_State_c <- NULL
for (i in 1:length(S4$Fasting_State)){
  if (S4$Fasting_State[i] == 1){
    S4$Fasting_State_c[i] = "Fast"
  }
  if (S4$Fasting_State[i] == 2){
    S4$Fasting_State_c[i] = "nonFast"
  }
}
table(S4$Fasting_State_c)


S4$Or_andi_c <- NULL
for (i in 1:length(S4$Or_andi)){
  if (is.na(S4$Or_andi)[i]){
    S4$Or_andi_c[i] = "NA"
  }
  else if (S4$Or_andi[i] == 1){
    S4$Or_andi_c[i] = "Yes"
  }
  else if (S4$Or_andi[i] == 2){
    S4$Or_andi_c[i] = "No"
  }
}
table(S4$Or_andi_c)

S4$Metf_c <- NULL
for (i in 1:length(S4$Metf)){
  if (is.na(S4$Metf)[i]){
    S4$Metf_c[i] = "NA"
  }
  else if (S4$Metf[i] == 1){
    S4$Metf_c[i] = "Yes"
  }
  else if (S4$Metf[i] == 2){
    S4$Metf_c[i] = "No"
  }
}
table(S4$Metf_c)


S4$Class_who_c <- NULL
for (i in 1:length(S4$Class_who)){
  if (S4$Class_who[i] == 0){
    S4$Class_who_c[i] = "NGT"
  }
  if (S4$Class_who[i] == 1){
    S4$Class_who_c[i] = "IFG_NGT"
  }
  if (S4$Class_who[i] == 2){
    S4$Class_who_c[i] = "NFG_IGT"
  }
  if (S4$Class_who[i] == 3){
    S4$Class_who_c[i] = "IFG_IGT"
  }
  if (S4$Class_who[i] == 4){
    S4$Class_who_c[i] = "ud_T2D"
  }
  if (S4$Class_who[i] == 5){
    S4$Class_who_c[i] = "ex_T2D"
  }
  if (S4$Class_who[i] == 99){
    S4$Class_who_c[i] = "unknown"
  }
  if (S4$Class_who[i] == 9999){
    S4$Class_who_c[i] = "unknown"
  }
}
table(S4$Class_who_c)


S4$Class_c <- NULL
for (i in 1:length(S4$Class)){
  if (S4$Class[i] == 0){
    S4$Class_c[i] = "NGT"
  }
  if (S4$Class[i] == 1){
    S4$Class_c[i] = "IFG"
  }
  if (S4$Class[i] == 2){
    S4$Class_c[i] = "IGT"
  }
  if (S4$Class[i] == 3){
    S4$Class_c[i] = "IFG_IGT"
  }
  if (S4$Class[i] == 4){
    S4$Class_c[i] = "dT2D"
  }
  if (S4$Class[i] == 5){
    S4$Class_c[i] = "known_T2D"
  }
  if (S4$Class[i] == 6){
    S4$Class_c[i] = "known_T1D"
  }
  if (S4$Class[i] == 7){
    S4$Class_c[i] = "known_diD"
  }
  if (S4$Class[i] == 9999){
    S4$Class_c[i] = "unknown"
  }
}
table(S4$Class_c)


S4$Phys_c <- NULL
for(i in 1:length(S4$Phys)){
  if (is.na(S4$Phys)[i]){
    S4$Phys_c[i] = "NA"
  }
  else if(S4$Phys[i] == 1){
    S4$Phys_c[i] = "active"
  }
  else if(S4$Phys[i] == 2){
    S4$Phys_c[i] = "inactive"
  }
 
}
table(S4$Phys_c)

S4$Alcohol_c <- NULL
for(i in 1:length(S4$Alcohol)){
  if (is.na(S4$Alcohol)[i]){
    S4$Alcohol_c[i] = "NA"
  }
  else if(S4$Sex[i] == 1 && S4$Alcohol[i] >= 40){
    S4$Alcohol_c[i] = "high"
  }
  else if(S4$Sex[i] == 1 && S4$Alcohol[i] < 40){
    S4$Alcohol_c[i] = "low"
  }
  else if(S4$Sex[i] == 2 && S4$Alcohol[i] >= 20){
    S4$Alcohol_c[i] = "high"
  }
  else if(S4$Sex[i] == 2 && S4$Alcohol[i] < 20){
    S4$Alcohol_c[i] = "low"
  }
}
table(S4$Alcohol_c)

S4$Smoking_c <- NULL
for(i in 1:length(S4$Cigreg)){
  if (is.na(S4$Cigreg)[i]){
    S4$Smoking_c[i] = "NA"
  }
  else if(S4$Cigreg[i] == 1 | S4$Cigreg[i] == 2){
    S4$Smoking_c[i] = "smoking"
  }
  else if(S4$Cigreg[i] == 3 | S4$Cigreg[i] == 4){
    S4$Smoking_c[i] = "non_smoking"
  }
}
table(S4$Smoking_c)

new_nameOrder <- c("ID_S4", "ID_F4", "Batch_bioc_S4",
                   "Fasting_State", "Fasting_State_c", "Metf", "Metf_c", "Or_andi", "Or_andi_c",
                   "Class", "Class_c", "Class_who", "Class_who_c",
                   "FGa", "FGn", "G2ha", "G2hn", "HbA1c", 
                   "Age", "Sex", "BMI",
                   "Phys", "Phys_c", "Cigreg", "Smoking_c", "Alcohol", "Alcohol_c", "Sys_BP", "Dia_BP", 
                   "Tria", "HDL", "LDL", "CHOL", "Hemoglobin", "Lekocytes", "Crp", "HOMA_IR",
                   "c0", "c2", "c3", "c4", "c4_1_dc__c6", "c5", "c7_dc", "c8", "c9", "c10", 
                   "c10_1", "c10_2", "c12", "c14", "c14_1", "c14_2", "c16", "c16_1", "c18", 
                   "c18_1", "c18_2", 
                   "pc_aa_c28_1", "pc_aa_c30_0", "pc_aa_c32_0", "pc_aa_c32_1", "pc_aa_c32_2", "pc_aa_c32_3", 
                   "pc_aa_c34_1", "pc_aa_c34_2", "pc_aa_c34_3", "pc_aa_c34_4", "pc_aa_c36_0", "pc_aa_c36_1", 
                   "pc_aa_c36_2", "pc_aa_c36_3", "pc_aa_c36_4", "pc_aa_c36_5", "pc_aa_c36_6", "pc_aa_c38_0", 
                   "pc_aa_c38_3", "pc_aa_c38_4", "pc_aa_c38_5", "pc_aa_c38_6", "pc_aa_c40_2", "pc_aa_c40_3", 
                   "pc_aa_c40_4", "pc_aa_c40_5", "pc_aa_c40_6", "pc_aa_c42_0", "pc_aa_c42_1", "pc_aa_c42_2", 
                   "pc_aa_c42_4", "pc_aa_c42_5", "pc_aa_c42_6", 
                   "pc_ae_c30_0", "pc_ae_c32_1", "pc_ae_c32_2", "pc_ae_c34_0", "pc_ae_c34_1", "pc_ae_c34_2", 
                   "pc_ae_c34_3", "pc_ae_c36_0", "pc_ae_c36_1", "pc_ae_c36_2", "pc_ae_c36_3", "pc_ae_c36_4", 
                   "pc_ae_c36_5", "pc_ae_c38_0", "pc_ae_c38_1", "pc_ae_c38_2", "pc_ae_c38_3", "pc_ae_c38_4", 
                   "pc_ae_c38_5", "pc_ae_c38_6", "pc_ae_c40_1", "pc_ae_c40_2", "pc_ae_c40_3", "pc_ae_c40_4", 
                   "pc_ae_c40_5", "pc_ae_c40_6", "pc_ae_c42_1", "pc_ae_c42_2", "pc_ae_c42_3", "pc_ae_c42_4", 
                   "pc_ae_c42_5", "pc_ae_c44_3", "pc_ae_c44_4", "pc_ae_c44_5", "pc_ae_c44_6", 
                   "lysopc_a_c16_0", "lysopc_a_c16_1", "lysopc_a_c17_0", "lysopc_a_c18_0", "lysopc_a_c18_1", 
                   "lysopc_a_c18_2", "lysopc_a_c20_3", "lysopc_a_c20_4", 
                   "sm__oh__c14_1", "sm__oh__c16_1", "sm__oh__c22_1", "sm__oh__c22_2", "sm__oh__c24_1", "sm_c16_0",
                   "sm_c16_1", "sm_c18_0", "sm_c18_1", "sm_c20_2", "sm_c24_0", "sm_c24_1", "sm_c26_1", 
                   "h1",
                   "arg", "gln", "gly", "his", "met", "orn", "phe", "pro", 
                   "ser", "thr", "trp", "tyr", "val", "leu", "ile", "ala", 
                   "asn", "asp", "cit", "glu", "lys", 
                   "creatinine", "adma", "ac_orn", "kynurenine", "met_so", "spermidine", "taurine", "total_dma")

S4 <- S4[, new_nameOrder]
head(S4)
write.csv(S4, "KORA_S4_simplified_RCW_20200310.csv")



#------------------
# for KORA F4
#------------------
F4_raw <- read.csv("KORA_F4_Biocrates_Data_RCW.csv", header = TRUE)
length(F4_raw$zz_nr_bio_F4) # 3044

Phen_F4 <- subset(Phen_new, is.na(Phen_new$zz_nr_biocrates_f4) == FALSE)
length(Phen_F4$zz_nr_biocrates_f4) # 3041
write.csv(Phen_F4, 'KORA_F4_20190617_JA_RCW_20200310.csv')

setdiff(F4_raw$zz_nr_bio_F4, Phen_F4$zz_nr_biocrates_f4)
# [1] 563000971 563001989 563002952
# this three individuals will be removed, as they did not in the latest phenotype dataset
F4_raw <- subset(F4_raw, !(F4_raw$zz_nr_bio_F4 %in% setdiff(F4_raw$zz_nr_bio_F4, Phen_F4$zz_nr_biocrates_f4)))
length(F4_raw$zz_nr_bio_F4) # 3041

##+++ add the variable of metformin and zz_F4_biocrates
Phen_F4 <- Phen_F4[order(match(Phen_F4$zz_nr_biocrates_f4, F4_raw$zz_nr_bio_F4)), ]
F4_raw$utmmetf <- Phen_F4$utmmetf
F4_raw$zz_nr_biocrates_f4_new <- Phen_F4$zz_nr_biocrates_f4
all(F4_raw$zz_nr_bio_F4, F4_raw$zz_nr_biocrates_f4_new)
write.csv(F4_raw, 'KORA_F4_Biocrates_Data_RCW_20200310.csv')


##+++++++++++++ simplifiy the data by select variables and rename them +++++++++++##
F4 <- read.csv('KORA_F4_Biocrates_Data_RCW_20200310.csv', header = TRUE)
head(F4)

# select the confounders and metabolites which used for further analysis
F4_confouders <- data.frame(ID_S4 = F4$zz_nr_bio_S4,
                            ID_F4 = F4$zz_nr_bio_F4,
                            ##
                            Batch_bioc_F4 = F4$batch_bioc,
                            Fasting_State = F4$utnuecht,
                            Metf = F4$utmmetf,
                            Or_andi = F4$utmoadi,
                            ##
                            Class = F4$utdmstat,
                            Class_who = F4$uk_diab_who06,
                            ##
                            Age = F4$utalteru, 
                            Sex = F4$ucsex, 
                            BMI = F4$utbmi,
                            ##
                            HbA1c = F4$ul_hbav,
                            FGa = F4$utglukfast_a,
                            FGn = F4$utglukfast_n,
                            G2ha = F4$utgluk2a,
                            G2hn = F4$utgluk2n,
                            ##
                            Phys = F4$utphys,
                            Cigreg = F4$utcigreg,
                            Alcohol = F4$utalkkon,
                            Sys_BP = F4$utsysmm,
                            Dia_BP = F4$utdiamm,
                            ##
                            Tria = F4$ul_tria,
                            HDL = F4$ul_hdla,
                            LDL = F4$ul_ldla,
                            CHOL = F4$ul_chola,
                            ##
                            Hemoglobin = F4$ul_hgb,
                            Lekocytes = F4$ul_wbc,
                            Crp = F4$uh_crp,
                            HOMA_IR = F4$uthoma_ir
)

F4_metabolites <- F4[, 84:214]

# combine the confounders and metabolites
F4 <- cbind(F4_confouders, F4_metabolites)
head(F4)

# +++++++ define the catagorical group class +++++++ #

F4$Fasting_State_c <- NULL
for (i in 1:length(F4$Fasting_State)){
  if (is.na(F4$Fasting_State)[i]){
    F4$Fasting_State_c[i] = "NA"
  }
  else if (F4$Fasting_State[i] == 1){
    F4$Fasting_State_c[i] = "Fast"
  }
  else if (F4$Fasting_State[i] == 2){
    F4$Fasting_State_c[i] = "nonFast"
  }
}
table(F4$Fasting_State_c)


F4$Or_andi_c <- NULL
for (i in 1:length(F4$Or_andi)){
  if (is.na(F4$Or_andi)[i]){
    F4$Or_andi_c[i] = "NA"
  }
  else if (F4$Or_andi[i] == 1){
    F4$Or_andi_c[i] = "Yes"
  }
  else if (F4$Or_andi[i] == 2){
    F4$Or_andi_c[i] = "No"
  }
}
table(F4$Or_andi_c)

F4$Metf_c <- NULL
for (i in 1:length(F4$Metf)){
  if (is.na(F4$Metf)[i]){
    F4$Metf_c[i] = "NA"
  }
  else if (F4$Metf[i] == 1){
    F4$Metf_c[i] = "Yes"
  }
  else if (F4$Metf[i] == 2){
    F4$Metf_c[i] = "No"
  }
}
table(F4$Metf_c)


F4$Class_who_c <- NULL
for (i in 1:length(F4$Class_who)){
  if (F4$Class_who[i] == 0){
    F4$Class_who_c[i] = "NGT"
  }
  if (F4$Class_who[i] == 1){
    F4$Class_who_c[i] = "IFG_NGT"
  }
  if (F4$Class_who[i] == 2){
    F4$Class_who_c[i] = "NFG_IGT"
  }
  if (F4$Class_who[i] == 3){
    F4$Class_who_c[i] = "IFG_IGT"
  }
  if (F4$Class_who[i] == 4){
    F4$Class_who_c[i] = "ud_T2D"
  }
  if (F4$Class_who[i] == 5){
    F4$Class_who_c[i] = "ex_T2D"
  }
  if (F4$Class_who[i] == 99){
    F4$Class_who_c[i] = "unknown"
  }
  if (F4$Class_who[i] == 9999){
    F4$Class_who_c[i] = "unknown"
  }
}
table(F4$Class_who_c)


F4$Class_c <- NULL
for (i in 1:length(F4$Class)){
  if (F4$Class[i] == 0){
    F4$Class_c[i] = "NGT"
  }
  if (F4$Class[i] == 1){
    F4$Class_c[i] = "IFG"
  }
  if (F4$Class[i] == 2){
    F4$Class_c[i] = "IGT"
  }
  if (F4$Class[i] == 3){
    F4$Class_c[i] = "IFG_IGT"
  }
  if (F4$Class[i] == 4){
    F4$Class_c[i] = "dT2D"
  }
  if (F4$Class[i] == 5){
    F4$Class_c[i] = "known_T2D"
  }
  if (F4$Class[i] == 6){
    F4$Class_c[i] = "known_T1D"
  }
  if (F4$Class[i] == 7){
    F4$Class_c[i] = "known_diD"
  }
  if (F4$Class[i] == 9999){
    F4$Class_c[i] = "unknown"
  }
}
table(F4$Class_c)


F4$Phys_c <- NULL
for(i in 1:length(F4$Phys)){
  if (is.na(F4$Phys)[i]){
    F4$Phys_c[i] = "NA"
  }
  else if(F4$Phys[i] == 1){
    F4$Phys_c[i] = "active"
  }
  else if(F4$Phys[i] == 2){
    F4$Phys_c[i] = "inactive"
  }
  
}
table(F4$Phys_c)

F4$Alcohol_c <- NULL
for(i in 1:length(F4$Alcohol)){
  if (is.na(F4$Alcohol)[i]){
    F4$Alcohol_c[i] = "NA"
  }
  else if(F4$Sex[i] == 1 && F4$Alcohol[i] >= 40){
    F4$Alcohol_c[i] = "high"
  }
  else if(F4$Sex[i] == 1 && F4$Alcohol[i] < 40){
    F4$Alcohol_c[i] = "low"
  }
  else if(F4$Sex[i] == 2 && F4$Alcohol[i] >= 20){
    F4$Alcohol_c[i] = "high"
  }
  else if(F4$Sex[i] == 2 && F4$Alcohol[i] < 20){
    F4$Alcohol_c[i] = "low"
  }
}
table(F4$Alcohol_c)

F4$Smoking_c <- NULL
for(i in 1:length(F4$Cigreg)){
  if (is.na(F4$Cigreg)[i]){
    F4$Smoking_c[i] = "NA"
  }
  else if(F4$Cigreg[i] == 1 | F4$Cigreg[i] == 2){
    F4$Smoking_c[i] = "smoking"
  }
  else if(F4$Cigreg[i] == 3 | F4$Cigreg[i] == 4){
    F4$Smoking_c[i] = "non_smoking"
  }
}
table(F4$Smoking_c)

new_nameOrder <- c("ID_S4", "ID_F4", "Batch_bioc_F4",
                   "Fasting_State", "Fasting_State_c", "Metf", "Metf_c", "Or_andi", "Or_andi_c",
                   "Class", "Class_c", "Class_who", "Class_who_c",
                   "FGa", "FGn", "G2ha", "G2hn", "HbA1c", 
                   "Age", "Sex", "BMI",
                   "Phys", "Phys_c", "Cigreg", "Smoking_c", "Alcohol", "Alcohol_c", "Sys_BP", "Dia_BP", 
                   "Tria", "HDL", "LDL", "CHOL", "Hemoglobin", "Lekocytes", "Crp", "HOMA_IR",
                   "c0", "c2", "c3", "c4", "c4_1_dc__c6", "c5","c8", "c8_1", "c9", 
                   "c10", "c10_1", "c10_2", "c12", "c12_dc", "c12_1", "c14", "c14_1", 
                   "c14_1_oh", "c14_2", "c16", "c16_1", "c18", "c18_1", "c18_2",
                   "pc_aa_c28_1", "pc_aa_c30_0", "pc_aa_c32_0", "pc_aa_c32_1", "pc_aa_c32_2", "pc_aa_c32_3", 
                   "pc_aa_c34_1", "pc_aa_c34_2", "pc_aa_c34_3", "pc_aa_c34_4", "pc_aa_c36_0", "pc_aa_c36_1", 
                   "pc_aa_c36_2", "pc_aa_c36_3", "pc_aa_c36_4", "pc_aa_c36_5", "pc_aa_c36_6", "pc_aa_c38_0", 
                   "pc_aa_c38_3", "pc_aa_c38_4", "pc_aa_c38_5", "pc_aa_c38_6", "pc_aa_c40_1", "pc_aa_c40_2", 
                   "pc_aa_c40_3", "pc_aa_c40_4", "pc_aa_c40_5", "pc_aa_c40_6", "pc_aa_c42_0", "pc_aa_c42_1", 
                   "pc_aa_c42_2", "pc_aa_c42_4", "pc_aa_c42_5", "pc_aa_c42_6",
                   "pc_ae_c30_0", "pc_ae_c30_2", "pc_ae_c32_1", "pc_ae_c32_2", "pc_ae_c34_0", "pc_ae_c34_1", 
                   "pc_ae_c34_2", "pc_ae_c34_3", "pc_ae_c36_1", "pc_ae_c36_2", "pc_ae_c36_3", "pc_ae_c36_4", 
                   "pc_ae_c36_5", "pc_ae_c38_0", "pc_ae_c38_1", "pc_ae_c38_2", "pc_ae_c38_3", "pc_ae_c38_4", 
                   "pc_ae_c38_5", "pc_ae_c38_6", "pc_ae_c40_0", "pc_ae_c40_1", "pc_ae_c40_2", "pc_ae_c40_3", 
                   "pc_ae_c40_4", "pc_ae_c40_5", "pc_ae_c40_6", "pc_ae_c42_0", "pc_ae_c42_1", "pc_ae_c42_2", 
                   "pc_ae_c42_3", "pc_ae_c42_4", "pc_ae_c42_5", "pc_ae_c44_3", "pc_ae_c44_4", "pc_ae_c44_5", 
                   "pc_ae_c44_6", 
                   "lysopc_a_c16_0", "lysopc_a_c16_1", "lysopc_a_c17_0", "lysopc_a_c18_0", 
                   "lysopc_a_c18_1", "lysopc_a_c18_2", "lysopc_a_c20_3", "lysopc_a_c20_4", 
                   "sm__oh__c14_1", "sm__oh__c16_1", "sm__oh__c22_1", "sm__oh__c22_2", "sm__oh__c24_1", 
                   "sm_c16_0", "sm_c16_1", "sm_c18_0", "sm_c18_1", "sm_c20_2", "sm_c24_0", "sm_c24_1", 
                   "sm_c26_1", 
                   "h1", 
                   "arg", "gln", "gly", "his",
                   "met", "orn", "phe", "pro",
                   "ser", "thr", "trp", "tyr", 
                   "val", "xleu")

F4 <- F4[, new_nameOrder]
head(F4)
write.csv(F4, "KORA_F4_simplified_RCW_20200310.csv")












