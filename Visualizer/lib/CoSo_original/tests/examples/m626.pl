% m626.json
% "A college student needs to schedule five prescribed courses for next semester.", "Only three of the five courses are able to be scheduled as the first class of the day.", "With that constraint, in how many ways can she select her schedule?"	null

courses = [1:5];
first = {1,2};
schedule in [| courses];
#schedule = 5;
schedule[1] = first;
