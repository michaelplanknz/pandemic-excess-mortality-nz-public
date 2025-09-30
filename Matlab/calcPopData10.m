function popData = calcPopData10(popData)

% Keep last month in each quarter only 
popData = popData(mod(popData.month, 3) == 0, :);

% Create continuous time variable represeting the "quarter ending" date
% (for ERP) or last day of the specified month (for admin data)
dom = getDaysInMonth(popData.Year, popData.month);
popData.t = datetime(popData.Year, popData.month, dom);

% Create age bin variable
popData.age10 = 10*floor(popData.age/10);

% Create group summary table
popData = groupsummary(popData, ["t", "age10"], "sum", "popSize");


