file_path <- "C:/Users/harki/Documents/Quarter 3/510 Data mining and analytics/Team project/fin/Mentalhealth.csv"
file_path <- normalizePath(file_path)
mentalhealth.df <- read.csv(file_path)

str(mentalhealth.df)

#Pre-processing

#1. Removing index, timestamp and comment column 
mentalhealth1.df <- mentalhealth.df[ -c(1,2,5,6,28) ] 
str(mentalhealth1.df)

#2. Create base level
mentalhealth1.df$Age <- as.factor(mentalhealth1.df$Age)
mentalhealth1.df$Age <- relevel(mentalhealth1.df$Age, ref = "21-30")
mentalhealth1.df$Gender <- relevel(mentalhealth1.df$Gender, ref = "female")
mentalhealth1.df$Country <- relevel(mentalhealth1.df$Country , ref = "United States")
mentalhealth1.df$state <- relevel(mentalhealth1.df$state, ref = "NY")
mentalhealth1.df$self_employed <- relevel(mentalhealth1.df$self_employed, ref = "No")
mentalhealth1.df$family_history <- relevel(mentalhealth1.df$family_history, ref = "Yes")
mentalhealth1.df$work_interfere <- relevel(mentalhealth1.df$work_interfere, ref = "Never") 
mentalhealth1.df$no_employees <- relevel(mentalhealth1.df$no_employees, ref = "< 5")
mentalhealth1.df$remote_work <- relevel(mentalhealth1.df$remote_work, ref = "No")
mentalhealth1.df$tech_company <- relevel(mentalhealth1.df$tech_company, ref = "Yes")
mentalhealth1.df$benefits <- relevel(mentalhealth1.df$benefits, ref = "No")
mentalhealth1.df$care_options <- relevel(mentalhealth1.df$care_options, ref = "No")
mentalhealth1.df$wellness_program <- relevel(mentalhealth1.df$wellness_program, ref = "No")
mentalhealth1.df$seek_help <- relevel(mentalhealth1.df$seek_help, ref = "Yes")
mentalhealth1.df$anonymity <- relevel(mentalhealth1.df$anonymity, ref = "Yes")
mentalhealth1.df$leave <- relevel(mentalhealth1.df$leave, ref = "Very easy")
mentalhealth1.df$mental_health_consequence <- relevel(mentalhealth1.df$mental_health_consequence, ref = "No")
mentalhealth1.df$phys_health_consequence <- relevel(mentalhealth1.df$phys_health_consequence, ref = "No")
mentalhealth1.df$coworkers <- relevel(mentalhealth1.df$coworkers, ref = "No")
mentalhealth1.df$supervisor <- relevel(mentalhealth1.df$supervisor, ref = "Yes")
mentalhealth1.df$mental_health_interview <- relevel(mentalhealth1.df$mental_health_interview, ref = "Yes")
mentalhealth1.df$phys_health_interview <- relevel(mentalhealth1.df$phys_health_interview, ref = "No")
mentalhealth1.df$obs_consequence <- relevel(mentalhealth1.df$obs_consequence, ref = "No")

# Re-coding target variable
mentalhealth1.df$treatment <- as.numeric(mentalhealth1.df$treatment == "Yes") 

#Data Modelling

# Create training and validation sets
set.seed(5)

# select variables
selected.var <- c(1:23)
selected.df <- mentalhealth1.df[, selected.var]
str(selected.df)

# partition the data
train.index <- sample(1:nrow(mentalhealth1.df), nrow(mentalhealth1.df)*0.70) 
train.df <- mentalhealth1.df[train.index, ]
valid.df <- mentalhealth1.df[-train.index, ]

#Logistic Regression model
logit.reg <- glm(formula = treatment ~ Age + Gender+ no_employees+work_interfere+family_history+self_employed+benefits+care_options+mental_health_interview+seek_help+anonymity,data = train.df, family = "binomial") #alter to contian state and country
summary(logit.reg)

logit.reg.pred <- predict(logit.reg, data_test_new.df,  type = "response")


data_test_new.df <- valid.df            
data_test_new.df$Country[which(!(data_test_new.df$Country %in% unique(train.df$age)))] <- NA
data_test_new.df$state[which(!(data_test_new.df$state %in% unique(train.df$age)))] <- NA  # Replace new levels by NA


# Choose cutoff value and evaluate classification performance
pred <- ifelse(logit.reg.pred > 0.74, 1, 0)

#Checking model performance

# generate the confusion matrix based on the prediction
library(caret)
confusionMatrix(factor(pred), factor(valid.df$treatment), positive = "1")
str(valid.df)

#ROC curve
library(pROC)

r <- roc(valid.df$treatment, logit.reg.pred)
plot.roc(r)

coords(r, x = "best")

coords(r, x = c(0.9, 0.747, 0.5))

#Verifying confusion matrix
library(ggplot2)
ggplot(data =  valid.df, mapping = aes(x = label, y = method)) +
  geom_tile(aes(fill = value), colour = "white") +
  geom_text(aes(label = sprintf("%1.0f",value)), vjust = 1) +
  scale_fill_gradient(low = "white", high = "steelblue")