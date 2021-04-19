# Ghost

a. What is the overall purpose of this project?

The purpose of this notbook is to use some characteristics of monsters (bone length measurements, severity of rot, extent of soullessness, and other characteristics) to distinguish or to predict the type of monsters: ghouls, goblins or ghosts.




b. What do each file in your repository do?

test.csv and train.csv are the dataset from the Kaggle competition (https://www.kaggle.com/c/ghouls-goblins-and-ghosts-boo/data). Since this is a group assignments, there are many csv files which are from the classfication that different studnets did in class. StackModel.R is the file where I did the stacking of all the different models(include Random Forest, k-nearest neighbors, Logistic Regression, Multilayer perceptron,Gradient boosting, Support-vector machine, and Extreme gradient boosting tree.
Stack_submission2.csv include the file I submited to Kaggle and got a score of 0.71455. 

c. What methods did you use to clean the data or do feature engineering?
I decide to use the stacking models by first combine all the different csv files together in a big dataset. Then run the dataset using function preProcess (from the caret package) with principal component analysis. 

d. What methods did you use to generate predictions?
Then I combine the pca dataset with my original dataset and train in a ranger method with 10 fold 2 times repeated cross validation in order to predict the model. And use $bestTune to look at the best (highest cross-validated) accuracy, and returning that value. And I adjust my parameters to improve my model's performance.
