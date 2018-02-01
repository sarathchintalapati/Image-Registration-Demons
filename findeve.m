function [avg_lg stv_lg avg_mg stv_mg avg_sol stv_sol] = findeve(Image)
disp('Draw an ROI around LG');
[avg_lg stv_lg] = find_avg(Image);
disp('Draw an ROI around MG');
[avg_mg stv_mg] = find_avg(Image);
disp('Draw an ROI around SOL');
[avg_sol stv_sol] =find_avg(Image);

