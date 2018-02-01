function [xcentre ycentre] = findcentre(Image);
[muspix muspiy] = find(Image);
calf = [muspix muspiy];
N = length(muspix);

sumx = sum(muspix);
sumy = sum(muspiy);

xcentre = round(sumx/N);
ycentre = round(sumy/N);
end
