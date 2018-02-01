function [avg stv] =  find_avg(Image)

tempcrop = roipoly(Image);
tempcropf = tempcrop.*Image;
avg = sum(sum(tempcropf))/length(find(tempcropf));
stv = std(tempcropf(tempcropf~=0));
end




