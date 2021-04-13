
# Libraries needed
library(vroom)
library(tidyverse)
library(caret)
library(DataExplorer)

train <- vroom('train.csv')
test <- vroom('test.csv')

ghost <- bind_rows(train = train, test = test, .id = "Set")
ghost$type <- as.factor(ghost$type)
ghost$color <- as.factor(ghost$color)

nn_probs <- vroom('nn_Probs_65acc.csv')
gbm <- vroom('probs_gbm.csv')
knn <- vroom('Probs_KNN.csv')
svm <- vroom('probs_svm.csv')
xgbtree <- vroom('xgbTree_probs.csv')
rf <- vroom('classification_submission_rf.csv')
log_reg <- vroom('LogRegPreds.csv')
mlayer <- vroom('multilayerperceptron.csv')


names(nn_probs)[4] <- "id"
names(gbm)[1] <- "id"
names(knn)[1] <- 'id'
names(svm)[1] <- 'id'
names(xgbtree)[1] <- 'id'
names(rf)[1] <- 'id'
names(log_reg)[1] <- 'id'
names(mlayer)[1] <- 'id'

nn_probs <- nn_probs[c(4,1,2,3)]

all_ghost<- nn_probs %>% left_join(gbm, by = "id") %>% left_join(knn, by = "id") %>%
  left_join(svm, by = "id") %>% left_join(xgbtree, by = "id") %>%
  left_join(rf, by = "id") %>% left_join(log_reg, by = "id") %>% left_join(mlayer, by = 'id')


ghost_data <- preProcess(all_ghost, method = "pca")
pca_ghost_pred <- predict(ghost_data, newdata = all_ghost)

joint_ghost <- cbind(pca_ghost_pred, ghost)


ghost_new <- joint_ghost %>% select(-bone_length, -rotting_flesh, -hair_length, -has_soul, -color)
#xgTree
# xgGrid <- expand.grid(nrounds = 250, 
#                       max_depth = c(3,4,5), 
#                       eta = 1,
#                       gamma = 0, 
#                       colsample_bytree = 1,
#                       min_child_weight = 1, 
#                       subsample = 1)

xgGrid <- expand.grid(mtry = c(5,6,7),
                        splitrule = c("extratrees"),
                        min.node.size = 10)


ghost_new$type <- as.factor(ghost_new$type)
xgGhost <- train(form = type~. -id, 
                 data = ghost_new %>% filter(Set == "train") %>% select(-Set) , 
                 method = "ranger", 
                 tuneGrid = xgGrid,
                 trControl = trainControl(
                   method = "repeatedcv", 
                   number = 10, 
                   repeats = 2)) 
                   
print(xgGhost)

xgGhost$results

xgPreds <- predict(xgGhost, newdata = joint_ghost %>% filter(Set == "test"))

submission <- data.frame(id = ghost %>% filter(Set == "test") %>% pull(id), type = xgPreds)

write.csv(submission, file = "./stack_submission2.csv", row.names= FALSE)

