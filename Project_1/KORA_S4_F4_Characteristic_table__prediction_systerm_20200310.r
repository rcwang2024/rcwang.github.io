########################
# characterstics for KORA S4 and KORA F4 for prediction systerm development 
########################

setwd("D:/data_analysis/A_Thesis/Thesis_Characteristics")
list.files()
library(stringr)

##++++++++
# For S4
##++++++++


### ++++++++++ load the data +++++++++ ###
S4_raw <- read.csv("KORA_S4_simplified_RCW_20200310.csv", header = TRUE)
head(S4_raw)

# exclude nonFasting
S4_raw <- subset(S4_raw, S4_raw$Fasting_State_c == "Fast")
table(S4_raw$Fasting_State_c)
# exclude Metformin 
S4_raw <- subset(S4_raw, S4_raw$Metf_c == "No")
table(S4_raw$Metf_c)
# exclude Oral anti_diabetic medicine
S4_raw <- subset(S4_raw, S4_raw$Or_andi_c == 'No')
table(S4_raw$Or_andi_c)
# exclude unknown diabetes, and existed T1D, T2D drug-induced diabetes
S4_raw <- subset(S4_raw, S4_raw$Class_c != 'unknown')
S4_raw <- subset(S4_raw, S4_raw$Class_c != 'known_T1D')
S4_raw <- subset(S4_raw, S4_raw$Class_c != 'known_T2D')
S4_raw <- subset(S4_raw, S4_raw$Class_c != 'known_diD')

# exclude the seven individuals which have abnormal hexose level when comparing to the corresponding FG, 
# or possible outliers
S4_raw <- subset(S4_raw, S4_raw$ID_S4 != 745001179)
S4_raw <- subset(S4_raw, S4_raw$ID_S4 != 745001007)
S4_raw <- subset(S4_raw, S4_raw$ID_S4 != 745000542)
S4_raw <- subset(S4_raw, S4_raw$ID_S4 != 745000617)
S4_raw <- subset(S4_raw, S4_raw$ID_S4 != 745000293)
S4_raw <- subset(S4_raw, S4_raw$ID_S4 != 745000104)
S4_raw <- subset(S4_raw, S4_raw$ID_S4 != 745001406)


# exclude the NAs in the corresonding variables
S4_raw <- subset(S4_raw, is.na(S4_raw$FGa) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$G2ha) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$HbA1c) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$Age) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$Sex) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$BMI) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$Phys_c) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$Smoking_c) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$Alcohol_c) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$Sys_BP) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$Tria) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$HDL) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$LDL) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$CHOL) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$Hemoglobin) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$Lekocytes) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$Crp) == FALSE)
S4_raw <- subset(S4_raw, is.na(S4_raw$HOMA_IR) == FALSE)

length(S4_raw$Class_c)
table(S4_raw$Class_c)
S4 <- S4_raw
S4$Class <- factor(S4$Class_c, levels = c("dT2D", "IFG", "IFG_IGT", "IGT", "NGT"))
table(S4$Class)
# dT2D    IFG      IFG_IGT     IGT     NGT 
# 112     101      74          162     829 


# log transform and scaling the metabolites, 
# generate the z-score for each metabolites concentration
for (i in 39:178){
  S4[,i] <- scale(log(S4[,i]), center = TRUE, scale = TRUE)
}

S4_NGT <- subset(S4, S4$Class_c == 'NGT')
S4_NGT$Class <- "NGT"
S4_pre <- subset(S4, S4$Class_c == 'IFG' | S4$Class_c == 'IFG_IGT' | S4$Class_c == 'IGT')
S4_pre$Class <- "Prediabetes"
S4_dT2D <- subset(S4, S4$Class_c == 'dT2D')
S4_dT2D$Class <- "dT2D"



# Characteristics
age <- c(paste(round(mean(S4_NGT$Age), 1), round(sd(S4_NGT$Age), 1), sep = " ± "), 
         paste(round(mean(S4_pre$Age), 1), round(sd(S4_pre$Age), 1), sep = " ± "), 
         paste(round(mean(S4_dT2D$Age), 1), round(sd(S4_dT2D$Age), 1), sep = " ± "))
age

sex <- c(round(prop.table(table(S4_NGT$Sex))[[2]][1], 3),
         round(prop.table(table(S4_pre$Sex))[[2]][1], 3),
         round(prop.table(table(S4_dT2D$Sex))[[2]][1], 3))
sex

BMI <- c(paste(round(mean(S4_NGT$BMI),  3), round(sd(S4_NGT$BMI), 3), sep = " ± "), 
         paste(round(mean(S4_pre$BMI),  3), round(sd(S4_pre$BMI), 3), sep = " ± "),
         paste(round(mean(S4_dT2D$BMI),  3), round(sd(S4_dT2D$BMI), 3), sep = " ± "))
BMI

Phy <- c(round(prop.table(table(S4_NGT$Phys))[[1]][1],3),
         round(prop.table(table(S4_pre$Phys))[[1]][1],3),
         round(prop.table(table(S4_dT2D$Phys))[[1]][1], 3))
Phy

Aloc <- c(round(prop.table(table(S4_NGT$Alcohol))[[1]][1], 3),
          round(prop.table(table(S4_pre$Alcohol))[[1]][1], 3),
          round(prop.table(table(S4_dT2D$Alcohol))[[1]][1], 3))
Aloc

smoker <- c(round(prop.table(table(S4_NGT$Cigreg))[[2]][1], 3),
            round(prop.table(table(S4_pre$Cigreg))[[2]][1], 3),
            round(prop.table(table(S4_dT2D$Cigreg))[[2]][1], 3))
smoker

Sys_BP <- c(paste(round(mean(S4_NGT$Sys_BP),  1), round(sd(S4_NGT$Sys_BP), 1), sep = " ± "),
            paste(round(mean(S4_pre$Sys_BP),  1), round(sd(S4_pre$Sys_BP), 1), sep = " ± "),
            paste(round(mean(S4_dT2D$Sys_BP),  1), round(sd(S4_dT2D$Sys_BP), 1), sep = " ± "))
Sys_BP

HDL <- c(paste(round(mean(S4_NGT$HDL, na.rm = TRUE),  1), round(sd(S4_NGT$HDL, na.rm = TRUE), 1), sep = " ± "),
         paste(round(mean(S4_pre$HDL, na.rm = TRUE),  1), round(sd(S4_pre$HDL, na.rm = TRUE), 1), sep = " ± "),
         paste(round(mean(S4_dT2D$HDL, na.rm = TRUE),  1), round(sd(S4_dT2D$HDL, na.rm = TRUE), 1), sep = " ± "))
HDL

LDL <- c(paste(round(mean(S4_NGT$LDL, na.rm = T),  1), round(sd(S4_NGT$LDL, na.rm = T), 1), sep = " ± "), 
         paste(round(mean(S4_pre$LDL, na.rm = T),  1), round(sd(S4_pre$LDL, na.rm = T), 1), sep = " ± "), 
         paste(round(mean(S4_dT2D$LDL, na.rm = T),  1), round(sd(S4_dT2D$LDL, na.rm = T), 1), sep = " ± "))
LDL

Tri <- c(paste(round(mean(S4_NGT$Tria, na.rm = T),  1), round(sd(S4_NGT$Tria, na.rm = T), 1), sep = " ± "), 
         paste(round(mean(S4_pre$Tria, na.rm = T),  1), round(sd(S4_pre$Tria, na.rm = T), 1), sep = " ± "), 
         paste(round(mean(S4_dT2D$Tria, na.rm = T),  1), round(sd(S4_dT2D$Tria, na.rm = T), 1), sep = " ± "))
Tri

HbA1c <- c(paste(round(mean(S4_NGT$HbA1c),  2), round(sd(S4_NGT$HbA1c), 2), sep = " ± "), 
           paste(round(mean(S4_pre$HbA1c, na.rm = T),  2), round(sd(S4_pre$HbA1c, na.rm = T), 2), sep = " ± "),
           paste(round(mean(S4_dT2D$HbA1c),  2), round(sd(S4_dT2D$HbA1c), 2), sep = " ± "))
HbA1c

FG <- c(paste(round(mean(S4_NGT$FGa),  1), round(sd(S4_NGT$FGa), 1), sep = " ± "),
        paste(round(mean(S4_pre$FGa),  1), round(sd(S4_pre$FGa), 1), sep = " ± "),
        paste(round(mean(S4_dT2D$FGa),  1), round(sd(S4_dT2D$FGa), 1), sep = " ± "))
FG

G2h <- c(paste(round(mean(S4_NGT$G2ha),  1), round(sd(S4_NGT$G2ha), 1), sep = " ± "),
         paste(round(mean(S4_pre$G2ha),  1), round(sd(S4_pre$G2ha), 1), sep = " ± "),
         paste(round(mean(S4_dT2D$G2ha),  1), round(sd(S4_dT2D$G2ha), 1), sep = " ± "))
G2h

HOMA_IR <- c(paste(round(mean(S4_NGT$HOMA_IR, na.rm = TRUE),  2), round(sd(S4_NGT$HOMA_IR, na.rm = TRUE), 2), sep = " ± "), 
        paste(round(mean(S4_pre$HOMA_IR, na.rm = TRUE),  2), round(sd(S4_pre$HOMA_IR, na.rm = TRUE), 2), sep = " ± "),
        paste(round(mean(S4_dT2D$HOMA_IR, na.rm = TRUE),  2), round(sd(S4_dT2D$HOMA_IR, na.rm = TRUE), 2), sep = " ± "))
HOMA_IR

z <- rbind(age, sex, BMI, Phy, Aloc, smoker, Sys_BP, HDL, LDL, Tri, HbA1c, FG, G2h, HOMA_IR)
colnames(z) <- c("S4_NGT", "S4_pre", "S4_dT2D")
z
write.csv(z, "KORA_S4_characteristic_for prediction_20200310.csv")



##++++++++
# For F4
##++++++++


### ++++++++++ load the data +++++++++ ###
F4_raw <- read.csv("KORA_F4_simplified_RCW_20200310.csv", header = TRUE)
head(F4_raw)

# exclude nonFasting
F4_raw <- subset(F4_raw, F4_raw$Fasting_State_c == "Fast")
table(F4_raw$Fasting_State_c)
# exclude Metformin 
F4_raw <- subset(F4_raw, F4_raw$Metf_c == "No")
table(F4_raw$Metf_c)
# exclude Oral anti_diabetic medicine
F4_raw <- subset(F4_raw, F4_raw$Or_andi_c == 'No')
table(F4_raw$Or_andi_c)
# exclude unknown diabetes, and existed T1D, T2D drug-induced diabetes
F4_raw <- subset(F4_raw, F4_raw$Class_c != 'unknown')
F4_raw <- subset(F4_raw, F4_raw$Class_c != 'known_T1D')
F4_raw <- subset(F4_raw, F4_raw$Class_c != 'known_T2D')
F4_raw <- subset(F4_raw, F4_raw$Class_c != 'known_diD')


# exclude the NAs in the corresonding variables
F4_raw <- subset(F4_raw, is.na(F4_raw$FGa) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$G2ha) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$HbA1c) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$Age) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$Sex) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$BMI) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$Phys_c) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$Smoking_c) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$Alcohol_c) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$Sys_BP) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$Tria) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$HDL) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$LDL) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$CHOL) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$Hemoglobin) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$Lekocytes) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$Crp) == FALSE)
F4_raw <- subset(F4_raw, is.na(F4_raw$HOMA_IR) == FALSE)

length(F4_raw$Class_c)
table(F4_raw$Class_c)
F4 <- F4_raw
F4$Class <- factor(F4$Class_c, levels = c("dT2D", "IFG", "IFG_IGT", "IGT", "NGT"))
table(F4$Class)
# dT2D    IFG      IFG_IGT     IGT     NGT 
# 108     109      74          299     2096 

# log transform and scaling the metabolites, 
# generate the z-score for each metabolites concentration
for (i in 39:169){
  F4[,i] <- scale(log(F4[,i]), center = TRUE, scale = TRUE)
}

F4_NGT <- subset(F4, F4$Class_c == 'NGT')
F4_NGT$Class <- "NGT"
F4_pre <- subset(F4, F4$Class_c == 'IFG' | F4$Class_c == 'IFG_IGT' | F4$Class_c == 'IGT')
F4_pre$Class <- "Prediabetes"
F4_dT2D <- subset(F4, F4$Class_c == 'dT2D')
F4_dT2D$Class <- "dT2D"



# Characteristics
age <- c(paste(round(mean(F4_NGT$Age), 1), round(sd(F4_NGT$Age), 1), sep = " ± "), 
         paste(round(mean(F4_pre$Age), 1), round(sd(F4_pre$Age), 1), sep = " ± "), 
         paste(round(mean(F4_dT2D$Age), 1), round(sd(F4_dT2D$Age), 1), sep = " ± "))
age

sex <- c(round(prop.table(table(F4_NGT$Sex))[[2]][1], 3),
         round(prop.table(table(F4_pre$Sex))[[2]][1], 3),
         round(prop.table(table(F4_dT2D$Sex))[[2]][1], 3))
sex

BMI <- c(paste(round(mean(F4_NGT$BMI),  3), round(sd(F4_NGT$BMI), 3), sep = " ± "), 
         paste(round(mean(F4_pre$BMI),  3), round(sd(F4_pre$BMI), 3), sep = " ± "),
         paste(round(mean(F4_dT2D$BMI),  3), round(sd(F4_dT2D$BMI), 3), sep = " ± "))
BMI

Phy <- c(round(prop.table(table(F4_NGT$Phys))[[1]][1],3),
         round(prop.table(table(F4_pre$Phys))[[1]][1],3),
         round(prop.table(table(F4_dT2D$Phys))[[1]][1], 3))
Phy

Aloc <- c(round(prop.table(table(F4_NGT$Alcohol))[[1]][1], 3),
          round(prop.table(table(F4_pre$Alcohol))[[1]][1], 3),
          round(prop.table(table(F4_dT2D$Alcohol))[[1]][1], 3))
Aloc

smoker <- c(round(prop.table(table(F4_NGT$Cigreg))[[2]][1], 3),
            round(prop.table(table(F4_pre$Cigreg))[[2]][1], 3),
            round(prop.table(table(F4_dT2D$Cigreg))[[2]][1], 3))
smoker

Sys_BP <- c(paste(round(mean(F4_NGT$Sys_BP),  1), round(sd(F4_NGT$Sys_BP), 1), sep = " ± "),
            paste(round(mean(F4_pre$Sys_BP),  1), round(sd(F4_pre$Sys_BP), 1), sep = " ± "),
            paste(round(mean(F4_dT2D$Sys_BP),  1), round(sd(F4_dT2D$Sys_BP), 1), sep = " ± "))
Sys_BP

HDL <- c(paste(round(mean(F4_NGT$HDL, na.rm = TRUE),  1), round(sd(F4_NGT$HDL, na.rm = TRUE), 1), sep = " ± "),
         paste(round(mean(F4_pre$HDL, na.rm = TRUE),  1), round(sd(F4_pre$HDL, na.rm = TRUE), 1), sep = " ± "),
         paste(round(mean(F4_dT2D$HDL, na.rm = TRUE),  1), round(sd(F4_dT2D$HDL, na.rm = TRUE), 1), sep = " ± "))
HDL

LDL <- c(paste(round(mean(F4_NGT$LDL, na.rm = T),  1), round(sd(F4_NGT$LDL, na.rm = T), 1), sep = " ± "), 
         paste(round(mean(F4_pre$LDL, na.rm = T),  1), round(sd(F4_pre$LDL, na.rm = T), 1), sep = " ± "), 
         paste(round(mean(F4_dT2D$LDL, na.rm = T),  1), round(sd(F4_dT2D$LDL, na.rm = T), 1), sep = " ± "))
LDL

Tri <- c(paste(round(mean(F4_NGT$Tria, na.rm = T),  1), round(sd(F4_NGT$Tria, na.rm = T), 1), sep = " ± "), 
         paste(round(mean(F4_pre$Tria, na.rm = T),  1), round(sd(F4_pre$Tria, na.rm = T), 1), sep = " ± "), 
         paste(round(mean(F4_dT2D$Tria, na.rm = T),  1), round(sd(F4_dT2D$Tria, na.rm = T), 1), sep = " ± "))
Tri

HbA1c <- c(paste(round(mean(F4_NGT$HbA1c),  2), round(sd(F4_NGT$HbA1c), 2), sep = " ± "), 
           paste(round(mean(F4_pre$HbA1c, na.rm = T),  2), round(sd(F4_pre$HbA1c, na.rm = T), 2), sep = " ± "),
           paste(round(mean(F4_dT2D$HbA1c),  2), round(sd(F4_dT2D$HbA1c), 2), sep = " ± "))
HbA1c

FG <- c(paste(round(mean(F4_NGT$FGa),  1), round(sd(F4_NGT$FGa), 1), sep = " ± "),
        paste(round(mean(F4_pre$FGa),  1), round(sd(F4_pre$FGa), 1), sep = " ± "),
        paste(round(mean(F4_dT2D$FGa),  1), round(sd(F4_dT2D$FGa), 1), sep = " ± "))
FG

G2h <- c(paste(round(mean(F4_NGT$G2ha),  1), round(sd(F4_NGT$G2ha), 1), sep = " ± "),
         paste(round(mean(F4_pre$G2ha),  1), round(sd(F4_pre$G2ha), 1), sep = " ± "),
         paste(round(mean(F4_dT2D$G2ha),  1), round(sd(F4_dT2D$G2ha), 1), sep = " ± "))
G2h

HOMA_IR <- c(paste(round(mean(F4_NGT$HOMA_IR, na.rm = TRUE),  2), round(sd(F4_NGT$HOMA_IR, na.rm = TRUE), 2), sep = " ± "), 
             paste(round(mean(F4_pre$HOMA_IR, na.rm = TRUE),  2), round(sd(F4_pre$HOMA_IR, na.rm = TRUE), 2), sep = " ± "),
             paste(round(mean(F4_dT2D$HOMA_IR, na.rm = TRUE),  2), round(sd(F4_dT2D$HOMA_IR, na.rm = TRUE), 2), sep = " ± "))
HOMA_IR

z <- rbind(age, sex, BMI, Phy, Aloc, smoker, Sys_BP, HDL, LDL, Tri, HbA1c, FG, G2h, HOMA_IR)
colnames(z) <- c("F4_NGT", "F4_pre", "F4_dT2D")
z
write.csv(z, "KORA_F4_characteristic_for prediction_20200310.csv")




