%  Robust Demons Algorithm for Calf Numscle MR Images. 
%  Initiallty developed by Function is written by D.Kroon University of Twente (March 2009) and modified by Sarath Chintalapati, UCAIR -University of Utah (2017)  


%% Read the two IMA files put in the folder. Typecaste it to a double and  then normalize it storing the minimum and maximum values. 
imafiles=dir('*.IMA'); 
im = double(dicomread(imafiles(1).name));
I1=im/max(max(im));
max1= max(max(im));
im = double(dicomread(imafiles(2).name));
max2=max(max(im));
I2=im/max(max(im));

%% Crop the image to the calf muscle. 
I1crop = roipoly(I1);
I2crop = roipoly(I2);
I1cropf = I1.*I1crop;
I2cropf = I2.*I2crop; 


%% Simulation to generate a test image that has moved and rotated during a scan. 

%Initially finding out the centre of the image to move the calf to match to
%the perfect centre of the image. 
[xctr yctr] = findcentre(I1cropf);
[img_ctrx img_ctry] = size(I1cropf); 
img_ctrx = img_ctrx/2;
img_ctry = img_ctry/2;

%translate the image from the calf centre to image centre. 
Ipre1 = imagetranslate(I1cropf,(img_ctrx-xctr),(img_ctry-yctr));

% Rotate this image by an angle of 20 degrees to simulate a rotational motion in the leg. 
Ipre2 = imrotate(Ipre1,20,'crop');

% Translate the image by 10x10 pixels to the right and bottom respectively to simulate a positional change in the leg. 

Ipre3 = imagetranslate(Ipre2,10,10);

%% Apply demons registration to this image with a target image I2

Idem1 = basic_demons(Ipre3, I2cropf);

%% Use the automatic translation aand rotation for correcting the artifacts

[x1 y1] = findcentre(Ipre3);
[x2 y2] = findcentre(I2);

xdiff = x2-x1;
ydiff = y2-y1; 

Ipost1 = imagetranslate(Ipre3,xdiff,ydiff);

Ipost2 = affineRegister(Ipost1,I2,0);

Idem2 = basic_demons(Ipost2,I2cropf);

figure, 
subplot(2,2,1)
imagesc(I1cropf); colormap gray; axis image; axis off ; title('Original Image');
subplot(2,2,2)
imagesc(I2cropf); colormap gray; axis image; axis off ; title('Target Image');
subplot(2,2,3)
imagesc(Idem1); colormap gray; axis image; axis off ; title('Demons1 Image');
subplot(2,2,4)
imagesc(Idem2); colormap gray; axis image; axis off ; title('Demons Modified Image');

%% Calcluation of Metrics

% Similarity Metric

% unregcorrpre = corr2(Ipre3, I2cropf);

regcorrpre = corr2(Idem1, I2cropf);
regcorrpost = corr2(Idem2,I2cropf);



% Intensity based metrics
figure, 

[avg_lg stv_lg avg_mg stv_mg avg_sol stv_sol] = findeve(Ipre3);
Ipre3_values = [avg_lg stv_lg avg_mg stv_mg avg_sol stv_sol];

[avg_lg stv_lg avg_mg stv_mg avg_sol stv_sol] = findeve(Idem1);
Idem1_values = [avg_lg stv_lg avg_mg stv_mg avg_sol stv_sol];

[avg_lg stv_lg avg_mg stv_mg avg_sol stv_sol] = findeve(Idem2);
Idem2_values = [avg_lg stv_lg avg_mg stv_mg avg_sol stv_sol];

%% log file
c =clock; 

f123 =fopen('read_me.txt','w');
fprintf(f123,' Run performed at\t');
fprintf(f123,'%d', fix(c));
fprintf(f123, '\n\nThe following is the log of Image registration algorithm, initiallty developed by Function is written by D.Kroon University of Twente (March 2009) and modified by Sarath Chintalapati, UCAIR -University of Utah (2017) \n \n \n');

fprintf(f123,'The Intensity Based Metric \n');
fprintf(f123,'Avg_LG %d\t Stv_LG%d\t AVg_MG %d Stv_MG \t Avg_SOL\t Stv_SOL',Ipre3_values,Idem1_values,Idem2_values);

fprintf(f123,'\n\n\n Similarity Metrics\n');
fprintf(f123,'\nCorellation: \n \t Regular Demons Registered Image %d \t Modified Demons Registered Image %d', regcorrpre(:), regcorrpost(:));
fclose(f123);

