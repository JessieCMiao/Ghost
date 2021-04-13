# McKade Thomas
# Stat495R Kaggle
# Classificaiton Competition


# Libraries needed
library(vroom)
library(caret)
library(ggiraph)
library(tidyverse)
library(ranger)

ggpairs(ghost.train)


ghost.train <- read.csv('train.csv')
ghost.test <- read.csv('test.csv')

ghost.train$type <- as.factor(ghost.train$type)
ghost.train$color <- as.factor(ghost.train$color)

ghost.test$color <- as.factor(ghost.test$color)

all_ids <- c(ghost.train$id,ghost.test$id)

## Random Forest
tgrid <- expand.grid(
  mtry = 5,
  splitrule = c("gini"),
  min.node.size = 10
)

ghost.forest <- train(form=type~bone_length+rotting_flesh +
                      hair_length+has_soul+color+has_soul*hair_length,
                     data=ghost.train, 
                     num.trees=500,
                     method="ranger",
                     trControl=trainControl(
                       method="repeatedcv",
                       number=10,
                       repeats=3,
                       verboseIter = TRUE),
                     tuneGrid = tgrid)

print(ghost.forest)

ghost.forest <- train(form=type~bone_length+rotting_flesh +
                        hair_length+has_soul+color+has_soul*hair_length,
                      data=ghost.train,
                      trControl=trainControl(
                        method="repeatedcv",
                        number=10,
                        repeats=3,
                        verboseIter = TRUE))

rng <- ranger(formula=type~bone_length+rotting_flesh +
                hair_length+has_soul+color,
              data = ghost.train,
              num.trees=500,mtry=5,splitrule="gini",min.node.size=10,probability=TRUE)
ghostPreds <- predict(rng, data=bind_rows(ghost.train,ghost.test ))

ghostPreds <- data.frame(predict(ghost.forest, newdata=ghost.test,type='prob')) %>% mutate(ID = ghost.test %>% pull(id))

all_preds <- data.frame(ghostPreds$predictions)
all_preds$ID <- 0:899

all_preds_new <- all_preds[, c("ID", "Ghost", "Ghoul", "Goblin")]


names(all_preds_new) <- c("ID", "PrGhoul_rf", "PrGob_rf", "PrGhost_rf")

write.csv(all_preds_new,file="./classification_submission_rf.csv",row.names=FALSE)
