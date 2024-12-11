function nDays = getDaysInMonth(yr, mnth)

% number of days in each calendar month in a non leap year
daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]';

% add on extra day in February in leap years
nDays = daysInMonth(mnth) + 1.0*(mod(yr, 4) == 0 & mnth == 2);    

