% m749.json
% "A committee of seven is to be chosen from a group of ten men and eight women.", "In how many ways can the committee be chosen if at most two men can serve on it?"	null


men = [1:10];
women = [11:18];
committees in {| men+women};
#committees = 7; 
#(men & committees) <=2;
