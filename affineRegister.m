function registeredImage = affineRegister(sourceImage, targetImage, interpolationMethod)

% Read source image and compute its dimensions

numberRows = size(sourceImage,1);
numberColumns = size(sourceImage,2);

% Read target image


% Have the user select landmarks on the source image
figure; imagesc(sourceImage); colormap gray; axis image

[x_source, y_source] = ginput;
close;

% Have the user select landmarks on the target image
figure; imagesc(targetImage); colormap gray; axis image

[x_target, y_target] = ginput(length(x_source));
close;

% Set up the system of equations to solve for the elements of the affine transformation matrix
targetVector = zeros(2*length(x_target),1);
for i = 1:length(x_target)
    targetVector(2*i-1) = x_target(i);
    targetVector(2*i) = y_target(i);
end

sourceMatrix = zeros(2*length(x_source),6);
for i = 1:length(x_source)
    sourceMatrix(2*i-1,1) = x_source(i); sourceMatrix(2*i,1) = 0;
    sourceMatrix(2*i-1,2) = y_source(i); sourceMatrix(2*i,2) = 0;    
    sourceMatrix(2*i-1,3) = 1; sourceMatrix(2*i,3) = 0;    
    sourceMatrix(2*i-1,4) = 0; sourceMatrix(2*i,4) = x_source(i);
    sourceMatrix(2*i-1,5) = 0; sourceMatrix(2*i,5) = y_source(i);
    sourceMatrix(2*i-1,6) = 0; sourceMatrix(2*i,6) = 1;
end

% Solve for the elements of the affine transformation matrix
transformParameters = sourceMatrix\targetVector;

% Build the affine transformation matrix
affineMatrix = [transformParameters(1), transformParameters(4), transformParameters(6); ...
                transformParameters(2), transformParameters(5), transformParameters(3); ...
                0, 0, 1];


% Pre-allocate output image matrix
registeredImage = zeros(size(targetImage,1), size(targetImage,2));

% Visit every pixel in the output image
for xCoordinate = 1:size(targetImage,1)
    for yCoordinate = 1:size(targetImage,2)
        
        % Compute the corresponding source location
        sourceLocation = affineMatrix\[xCoordinate; yCoordinate; 1];
        
        % Perform nearest neighbor interpolation
        if strcmp(interpolationMethod, 'NN') == 1
            
            % Round source location to nearest grid point
            sourceLocation = round(sourceLocation);
            
            % Check to see if the pixel maps back to within the original image
            if sourceLocation(1) >= 1 && sourceLocation(1) <= numberRows && sourceLocation(2) >= 1 && sourceLocation(2) <= numberColumns
                
                % If a pixel maps back to the original image, assign the intensity at its location to the corresponding output pixel
                registeredImage(xCoordinate,yCoordinate) = sourceImage(sourceLocation(1), sourceLocation(2));
            
            % If a pixel doesn't map to the source image, set it to zero
            else registeredImage(xCoordinate,yCoordinate) = 0;
            end
                
        else % Perform bilinear interpolation
            
            % Check to see if the pixel maps back to within the original image
            if sourceLocation(1) >= 1 && sourceLocation(1) <= (numberRows-1) && sourceLocation(2) >= 1 && sourceLocation(2) <= (numberColumns-1)
            
            % Find the four nearest neighbors of the non-grid source-image location
            leftIndex = floor(sourceLocation(2));
            rightIndex = ceil(sourceLocation(2));
            
            if leftIndex == rightIndex
                rightIndex = rightIndex + 1;
            end
            
            topIndex = floor(sourceLocation(1));
            bottomIndex = ceil(sourceLocation(1));
            
            if topIndex == bottomIndex
                bottomIndex = bottomIndex + 1;
            end
            
            % Find the intensities of the four nearest neighbors of the non-grid source-image location
            bottomLeftPixel = sourceImage(bottomIndex,leftIndex);
            topLeftPixel = sourceImage(topIndex,leftIndex);
            bottomRightPixel = sourceImage(bottomIndex,rightIndex);
            topRightPixel = sourceImage(topIndex,rightIndex);
            
            % Compute the weighted average of the neighbor intensities and assign it to the ouput pixel
            registeredImage(xCoordinate,yCoordinate) = (1/((rightIndex-leftIndex).*(bottomIndex-topIndex))) .* ...
                (bottomLeftPixel.*(rightIndex-sourceLocation(2)).*(sourceLocation(1)-topIndex) + ...
                bottomRightPixel.*(sourceLocation(2)-leftIndex).*(sourceLocation(1)-topIndex) + ...
                topLeftPixel.*(rightIndex-sourceLocation(2)).*(bottomIndex-sourceLocation(1)) + ...
                topRightPixel.*(sourceLocation(2)-leftIndex).*(bottomIndex-sourceLocation(1)));
            
            % If a pixel doesn't map to the source image, set it to zero
            else registeredImage(xCoordinate,yCoordinate) = 0;    
            end
        end
    end
end

% % Plot the source, target, and registered image
% figure(1); imagesc(sourceImage); colormap gray; axis image; axis off
% figure(2); imagesc(targetImage); colormap gray; axis image; axis off
% figure(3); imagesc(registeredImage); colormap gray; axis image; axis off

end