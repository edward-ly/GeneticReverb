# R script to get statistics for the Genetic Reverb subjective evaluation
# survey (LimeSurvey listening test)
# Requires R data and syntax files (exported from LimeSurvey) and
# a CSV file containing the answer key
#
# Run the script with `source("/path/to/GeneticReverb.R")`
#     or, alternatively, "Run line or selection" or "Run all" in RGui
#
# File: GeneticReverb.R
# Author: Edward Ly (edward.ly@pm.me)
# Version: 0.2.1
# Last Updated: 9 October 2020

############################################################################
## Load required libraries
library(lme4)
library(car)
library(ggplot2)
library(emmeans)

############################################################################
## Set location of data and syntax files as working directory
setwd("/Users/Edward/Documents/GitHub/GeneticReverb/data") # Windows
# setwd("/Documents/GitHub/GeneticReverb/data") # macOS

############################################################################
## Load data into workspace
# Survey responses to "data" variable
source("survey_117287_R_syntax_file.R")

# Answer key
key <- read.csv("answer_key.csv")
nQuestions <- nrow(key) # number of relevant survey questions

############################################################################
## Data Pre-Processing
# Exclude dummy responses, unused columns
data <- data[2:nrow(data), -31]

# Create new data table with each row containing one question
responses <- data.frame(
  id = numeric(),
  sex = character(),
  age = numeric(),
  exp = numeric(),
  quality = character(),
  rep = numeric(),
  x.type = character(),
  program = character(),
  hit = numeric(),
  stringsAsFactors = FALSE
)

for (i in 1:nrow(data)) {
  for (j in 1:nQuestions) {
    new.response <- data.frame(
      id = data[i, 1],
      sex = data[i, 8],
      age = data[i, 9],
      exp = data[i, 10],
      quality = if ((j - 1) %/% 3 %% 2 == 0) "High" else "Max",
      rep = (j - 1) %% 3 + 1,
      x.type = key[j, 3],
      program = if (j <= nQuestions / 2) "Speech" else "Music",
      hit = as.numeric(data[i, j + 12] == key[j, 4]),
      stringsAsFactors = FALSE
    )

    responses <- rbind(responses, new.response)
  }
}

write.csv(responses, "responses.csv")
# print(responses)

############################################################################
## Simple Exact Binomial Test (All Questions)
nCorrect <- sum(responses[, 9])
nTotal <- nrow(responses)
binom.test(nCorrect, nTotal)

############################################################################
## Generalized Linear Mixed Model (GLMM)

# Create a model for each fixed effect
# View the model with `summary(model)`
# Test significance of new model with `anova(model1, model2)`, for example
# Alternate ANOVA test can be done with
#     `Anova(model, type = "II", test = "Chisq")`

# Initial model
model <- glmer(hit ~ (1 | id), data = responses, family = binomial)

# Add random effects, keep if significant
model.sex <- update(model, ~ . + (1 | sex))
anova(model, model.sex) # not significant

model.age <- update(model, ~ . + (1 | age))
anova(model, model.age) # not significant

model.exp <- update(model, ~ . + (1 | exp))
anova(model, model.exp) # not significant

model.rep <- update(model, ~ . + (1 | rep))
anova(model, model.rep) # not significant

# Add fixed effects, keep if significant
model.program <- update(model, ~ . + program)
anova(model, model.program) # significant
model <- model.program

model.quality <- update(model, ~ . + quality)
anova(model, model.quality) # significant
model <- model.quality

model.x.type <- update(model, ~ . + x.type)
anova(model, model.x.type) # not significant

# Add two-way interactions, keep if significant
model.program.quality <- update(model, ~ . + program * quality)
anova(model, model.program.quality) # significant
model <- model.program.quality

model.program.x.type <- update(model, ~ . + program * x.type)
anova(model, model.program.x.type) # not significant

model.quality.x.type <- update(model, ~ . + quality * x.type)
anova(model, model.quality.x.type) # not significant

# Add three-way interaction (keep if significant)
model.all <- update(model, ~ . + program * quality * x.type)
anova(model, model.all) # not significant, model failed to converge

# Remove significant factors, keep if still significant
model.no.program <- update(model, ~ . - program)
anova(model, model.no.program) # significant

model.no.quality <- update(model, ~ . - quality)
anova(model, model.no.quality) # significant

model.no.program.quality <- update(model, ~ . - program:quality)
anova(model, model.no.program.quality) # significant


# Posthoc analysis: find least-squares means for all factors
tem1 <- emmeans(model, ~ program | quality)
print(tem1)
cmp1 <- contrast(tem1, method = "tukey", interaction = T)
test(cmp1, joint = F, by = c("quality"))

tem2 <- emmeans(model, ~ quality | program)
print(tem2)
cmp2 <- contrast(tem2, method = "tukey", interaction = T)
test(cmp2, joint = F, by = c("program"))

############################################################################
## Generate Figures
# Set the environment for printing ggplots that look good in publications
textSize <- 22
theme4journal <- theme(
  plot.title = element_text(size = .7 * textSize),
  axis.text.x = element_text(size = .5 * textSize),
  axis.text.y = element_text(size = .5 * textSize),
  axis.title.x = element_text(size = .5 * textSize, vjust = 0.1),
  axis.title.y = element_text(size = .6 * textSize, angle = 90, vjust = 1),
  legend.title = element_text(size = .6 * textSize),
  legend.text = element_text(size = .6 * textSize),
  strip.text = element_text(size = .6 * textSize)
)

tem.res1 <- emmeans(model, ~ program * quality, type = "response")
temdf <- as.data.frame(tem.res1)

p <- ggplot(
  temdf,
  aes(
    x = quality,
    y = prob,
    ymin = asymp.LCL,
    ymax = asymp.UCL,
    fill = program,
    group = program
  )
) +
  geom_col(
    position = position_dodge(),
    color = "black"
  ) +
  scale_fill_manual(values = c("#b2d5eb", "#f4cbba")) +
  geom_point(
    position = position_dodge(width = 0.9)
  ) +
  geom_errorbar(
    position = position_dodge(width = 0.9),
    width = 0.2
  ) +
  theme4journal +
  theme(legend.position = "bottom") +
  theme_classic() +
  labs(
    title = "",
    x = "Quality",
    fill = "",
    y = "Probability of Correct Response"
  )

############################################################################
## Part 2: Analyze the data again, but without any super-classifiers
#  (those who answered 100% correctly for 3 of 4 program/quality groups)

# Find and exclude super-classifiers
responses2 <- responses[with(responses, order(id, program, quality)), ]
i <- 1
while (i < nrow(responses2)) {
  grp1.p <- as.numeric(mean(responses2[i:(i + 8), 9]) == 1)
  grp2.p <- as.numeric(mean(responses2[(i + 9):(i + 17), 9]) == 1)
  grp3.p <- as.numeric(mean(responses2[(i + 18):(i + 26), 9]) == 1)
  grp4.p <- as.numeric(mean(responses2[(i + 27):(i + 35), 9]) == 1)
  if (grp1.p + grp2.p + grp3.p + grp4.p >= 3) {
    responses2 <- responses2[-(i:(i + 35)), ]
  } else {
    i <- i + 36
  }
}

write.csv(responses2, "responses_imp.csv")
# print(responses2)

############################################################################
## Simple Exact Binomial Test (All Questions)
nCorrect2 <- sum(responses2[, 9])
nTotal2 <- nrow(responses2)
binom.test(nCorrect2, nTotal2)

############################################################################
## Generalized Linear Mixed Model (GLMM)

# Initial model
model2 <- glmer(hit ~ (1 | id), data = responses2, family = binomial)

# Add random effects, keep if significant
model2.sex <- update(model2, ~ . + (1 | sex))
anova(model2, model2.sex) # not significant

model2.age <- update(model2, ~ . + (1 | age))
anova(model2, model2.age) # not significant

model2.exp <- update(model2, ~ . + (1 | exp))
anova(model2, model2.exp) # not significant

model2.rep <- update(model2, ~ . + (1 | rep))
anova(model2, model2.rep) # not significant

# Add fixed effects, keep if significant
model2.program <- update(model2, ~ . + program)
anova(model2, model2.program) # significant
model2 <- model2.program

model2.quality <- update(model2, ~ . + quality)
anova(model2, model2.quality) # not significant

model2.x.type <- update(model2, ~ . + x.type)
anova(model2, model2.x.type) # not significant

# Add two-way interactions, keep if significant
model2.program.quality <- update(model2, ~ . + program * quality)
anova(model2, model2.program.quality) # significant
model2 <- model2.program.quality

model2.program.x.type <- update(model2, ~ . + program * x.type)
anova(model2, model2.program.x.type) # not significant

model2.quality.x.type <- update(model2, ~ . + quality * x.type)
anova(model2, model2.quality.x.type) # not significant

# Add three-way interaction (keep if significant)
model2.all <- update(model2, ~ . + program * quality * x.type)
anova(model2, model2.all) # not significant

# Remove significant factors, keep if still significant
model2.no.quality <- update(model2, ~ . - program:quality)
anova(model2, model2.no.quality) # significant

model2.no.program <- update(model2, ~ . - program)
anova(model2, model2.no.program) # not significant

model2.no.quality <- update(model2, ~ . - quality)
anova(model2, model2.no.quality) # not significant


# Posthoc analysis: find least-squares means for all factors
tem3 <- emmeans(model2, ~ program | quality)
print(tem3)
cmp3 <- contrast(tem3, method = "tukey", interaction = T)
test(cmp3, joint = F, by = c("quality"))

tem4 <- emmeans(model2, ~ quality | program)
print(tem4)
cmp4 <- contrast(tem4, method = "tukey", interaction = T)
test(cmp4, joint = F, by = c("program"))

############################################################################
## Generate Figures

tem.res2 <- emmeans(model2, ~ program * quality, type = "response")
temdf <- as.data.frame(tem.res2)

p2 <- ggplot(
  temdf,
  aes(
    x = quality,
    y = prob,
    ymin = asymp.LCL,
    ymax = asymp.UCL,
    fill = program,
    group = program
  )
) +
  geom_col(
    position = position_dodge(),
    color = "black"
  ) +
  scale_fill_manual(values = c("#b2d5eb", "#f4cbba")) +
  geom_point(
    position = position_dodge(width = 0.9)
  ) +
  geom_errorbar(
    position = position_dodge(width = 0.9),
    width = 0.2
  ) +
  theme4journal +
  theme(legend.position = "bottom") +
  theme_classic() +
  labs(
    title = "",
    x = "Quality",
    fill = "",
    y = "Probability of Correct Response"
  )

############################################################################
## Save All Figures To PDF Files

ggsave(
  "figure_subj_all.pdf",
  plot = p,
  device = "pdf",
  path = "../data/",
  width = 6,
  height = 4.5
)
ggsave(
  "figure_subj_imp.pdf",
  plot = p2,
  device = "pdf",
  path = "../data/",
  width = 6,
  height = 4.5
)
