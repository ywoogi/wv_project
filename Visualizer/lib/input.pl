% h849.json
% "In how many ways can 23 identical refrigerators be allocated among four stores so that one store gets eight refrigerators, another four, a third store five, and the last one six refrigerators?"	1

refrigerators = [1:23];
stores in partitions(refrigerators);
#stores = 4;
#{#store=8 | store in stores} = 1;
#{#store=4 | store in stores} = 1;
#{#store=5 | store in stores} = 1;
#{#store=6 | store in stores} = 1;

