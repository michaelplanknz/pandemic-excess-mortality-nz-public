function [xOut, yOut] = getFillArgs(x, yLow, yHi)

% Return arguments for a fill graph to plot a band between yLow and yHi against x
% The outputs can be used in a 'fill' call as follows:
% >> fill(xOut, yOut, ...)

% If inputs are column vectors, transpose them to get row vectors
if size(x, 2) == 1
   x = x';
end
if size(yLow, 2) == 1
    yLow = yLow';
end
if size(yHi, 2) == 1
    yHi = yHi';
end

xOut = [x, fliplr(x)];
yOut = [yLow, fliplr(yHi)];


