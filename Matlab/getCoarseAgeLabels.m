function ageCoarse = getCoarseAgeLabels(age, ageBreaks)
ageCoarse = discretize(age, [ageBreaks, inf], 'categorical', string(ageBreaks));

