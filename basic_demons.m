%  Basic demon registration code. (To easy understand the algorithm)

function demonsreg = basic_demons(moving,static)
% Clean
% clc; clear all; close all;

% Compile the mex files
% compile_c_files

% Read two images

I1=moving/max(max(moving));
max1= max(max(moving));

max2=max(max(static));
I2=static/max(max(static));
% Set static and moving image

S=static; M=moving; 

% Alpha (noise) constant
alpha=2.5;

% Velocity field smoothing kernel
Hsmooth=fspecial('gaussian',[60 60],10);

% The transformation fields
Tx=zeros(size(M)); Ty=zeros(size(M));

[Sy,Sx] = gradient(S);
% 
% figure
% contour(I1);
% hold on;
% quiver(Sx,Sy);
% hold off;

% figure, contour(S), hold on, quiver(Sx,Sy), hold off;
for itt=1:200
	    % Difference image between moving and static image
        Idiff=M-S;        

        % Default demon force, (Thirion 1998)
        %Ux = -(Idiff.*Sx)./((Sx.^2+Sy.^2)+Idiff.^2);
        %Uy = -(Idiff.*Sy)./((Sx.^2+Sy.^2)+Idiff.^2); 
        % Extended demon force. With forces from the gradients from both
        % moving as static image. (Cachier 1999, He Wang 2005)
        [My,Mx] = gradient(M);
	
        Ux = -Idiff.*  ((Sx./((Sx.^2+Sy.^2)+alpha^2*Idiff.^2))+(Mx./((Mx.^2+My.^2)+alpha^2*Idiff.^2)));
        Uy = -Idiff.*  ((Sy./((Sx.^2+Sy.^2)+alpha^2*Idiff.^2))+(My./((Mx.^2+My.^2)+alpha^2*Idiff.^2)));
 
        % When divided by zero
        Ux(isnan(Ux))=0; Uy(isnan(Uy))=0;

        % Smooth the transformation field
        Uxs=3*imfilter(Ux,Hsmooth);
        Uys=3*imfilter(Uy,Hsmooth);

        % Add the new transformation field to the total transformation field.
        Tx=Tx+Uxs;
        Ty=Ty+Uys;
        M=movepixels(moving,Tx,Ty); 
         %if mod(itt, 10)==0
         %figure, imshow(M,[]);
         %end
end

I1f = I1*max1; 
I2f=I2*max2;
 demonsreg = M*max1;
 
% figure1 = figure; 
%  subplot(1,3,1), imagesc(I1cropf); colormap gray; axis image; title('image 1');
%  subplot(1,3,2), imagesc(I2cropf); colormap gray; axis image; title('image 2');
%  subplot(1,3,3), imagesc(M); colormap gray; axis image;  title('Registered image 1');
%  saveas(figure1, 'fig1m.jpg');
% 
% Mdiff = Mf-I2cropf; 
% 
% figure2 = figure; 
% subplot(2,2,1), imagesc(I1cropf); colormap gray; axis image; title('image 1');
% subplot(2,2,2), imagesc(I2cropf); colormap gray; axis image; title('image 2');
% subplot(2,2,3), imagesc(Mf); colormap gray; axis image; title('Registered image 1');
% subplot(2,2,4), imagesc(Mdiff); colormap gray; axis image;  title('Difference');
% saveas(figure2, 'fig2m.jpg');
% 
% 
% diffint = sum(abs(imhist(I1cropf)-imhist(M)));
% diffperc = 100*(diffint/(length(I1cropf)^2));
% 
% 
% figure3 = figure; 
% plot((imhist(I1cropf)-imhist(M))), axis([0 265 -100 100]);
% saveas(figure3, 'histdiff.jpg');
% 
% c =clock; 
% 
% 
% 
% % The following code is to calcuate the sum of Absolute Differences. 
% 
% unregdiffSAD = abs(I1-I2);
% regdiffSAD = abs(I1-M);
% %display('SAD - Unregistered Images');
% %display(sum(unregdiff(:)));
% %display(' SAD - Registered Images'); 
% %display(sum(regdiff(:)));
% 
% 
% % The following is to calcluate the sum of squared Differences 
% 
% 
% unregdiff = abs(I1-I2);
% regdiff = abs(I1-M);
% %display('SSD - Unregistered Images');
% unregdiffSSD = unregdiff.^2;
% %display(sum(unregdiffsq(:)));
% %display(' SSD - Registered Images'); 
% regdiffSSD = regdiff.^2;
% %display(sum(regdiffsq(:)));
% 
% % The folllowing is to calcluate maximum of absolute differences
% 
% unregdiffMAD = abs(I1-I2);
% regdiffMAD = abs(I1-M);
% %display('MAD - Unregistered Images');
% %display(max(unregdiff(:)));
% %display(' MAD - Registered Images'); 
% %display(max(regdiff(:))); 
% 
% % Performance measurement using Correlation Ratio
% 
% unregcorr = corr2(I1, I2);
% regcorr = corr2(I1, M);
% %display( ' Correlation - Unregistered'); 
% %display(unregcorr(:));
% %display( 'Correlation - Registered');
% %display(regcorr(:));
% 
% % Log file generation. 
% 
% f123 =fopen('details.txt','w');
% fprintf(f123,' Run performed at');
% fprintf(f123,'%d', fix(c));
% fprintf(f123, '\n\nThe following is the log of Image registration algorithm, initiallty developed by Function is written by D.Kroon University of Twente (March 2009) and modified by Sarath Chintalapati, UCAIR -University of Utah (2017) \n \n \n');
% fprintf(f123,'The absolute sum of difference is %d',diffint);
% fprintf(f123,'\n The percentage Change is %d',diffperc);
% fprintf(f123,'\n\n\n Similarity Metrics\n');
% fprintf(f123,'The Sum of Absolute Differences (SAD): \n \t Unregistered Image %d \t Registered Image %d', sum(unregdiffSAD(:)), sum(regdiffSAD(:)));
% fprintf(f123,'\nThe Max of Absolute Differences (MAD): \n \t Unregistered Image %d \t Registered Image %d', max(unregdiffSAD(:)), max(regdiffSAD(:)));
% fprintf(f123,'\nThe Sum of Squared Differences (SSD): \n \t Unregistered Image %d \t Registered Image %d', sum(unregdiffSSD(:)), sum(regdiffSSD(:)));
% fprintf(f123,'\nCorellation: \n \t Unregistered Image %d \t Registered Image %d', unregcorr(:), regcorr(:));
% fclose(f123);
% 
