% Load Oufti output file which includes cell mesh data.
load ouftiOut.mat

% Change to the 'signal' directory, may need to change name depending on
% output, maybe coudl loop over channels?

cd signal

% Initialize empty array for storing total intensity and area of cells.
cellInt = [];

% Initialize empty array for storing average background intensity.
avgBkgInt = [];

% Define a disk-shaped structuring element for mask dilation, with a radius of 2 pixels.
s2 = strel('disk',2);

% Define a disk-shaped structuring element for mask erosion, with a radius of 4 pixels.
s1 = strel('disk',4);

% Define the edge threshold for excluding the edge pixels in background calculation.
edgeThresh = 80;

% Start loop over all frames in the cell list data.
for nFrame =1:length(cellList.meshData)

    % Load corresponding image for each frame, change the string name 'MAX_red' to the image prefix correspondingly
    imSignal = imread(['MAX_red' num2str(nFrame-1,'%04d') '.tif']); 
    
    % Initialize a logical array with the same size as the image to store the combined cell mask.
    combinedCell = logical(zeros(size(imSignal,1),size(imSignal,2)));

    % Start loop over all cells in the current frame.
    for nCell = 1:length(cellList.meshData{nFrame})

        % Process only cells with non-zero mesh data.
        if cellList.meshData{nFrame}{nCell}.mesh ~=0

 % -- create binary mask based on cellMesh -- %

            % Get the mesh of the current cell.
            mesh = cellList.meshData{nFrame}{nCell}.mesh;

            % Generate polygon coordinates for the mask based on the cell mesh data.
            plgx = double(([mesh(:,1);flipud(mesh(:,3))])*1); 
            plgy = double(([mesh(:,2);flipud(mesh(:,4))])*1); 

            % Create a binary mask based on the polygon, dilate the mask.
            mask = imdilate(poly2mask(plgx,plgy,512,512),s2);

            % Multiply the mask with the image to get cell intensity, then sum up the intensities.
            totalInt =  immultiply(mask == 1, imSignal);
            totalInt = sum(totalInt(:));

            % Calculate the area of the cell.
            area = sum(mask,'all');

            % Store the total intensity and the area of the cell.
            cellInt = [cellInt; totalInt area];
        end
    end

    % -- frame background intensity calculation -- %

% Add the current mask to the combined cell mask.
    combinedCell = combinedCell + mask;

    % Set all non-zero elements in the combined cell mask to 2.
    combinedCell(combinedCell~=0) = 2;

    % Set all zero elements in the combined cell mask to 1.
    combinedCell(combinedCell==0) = 1;

    % Set all elements with value 2 in the combined cell mask back to 0 prevent the merging cell to give a mask value of 2 when add up masks
    combinedCell(combinedCell==2) = 0;

    % Erode the background binary mask equal to dilated cells.
    allCellDilate = imerode(combinedCell,s1);

    % Remove image edges based on the edge threshold value for background calculation.
    centerCell = allCellDilate(edgeThresh:511-edgeThresh,edgeThresh:511-edgeThresh);

    % Multiply the eroded mask with the image to get background intensity.
    imBkgDilate = immultiply(allCellDilate == 1, imSignal);

    % Remove image edges based on the edge threshold value for background calculation.
    centerBkg = imBkgDilate(edgeThresh:511-edgeThresh,edgeThresh:511-edgeThresh);

    % Sum up the background intensities.
    BkgInt = sum(centerBkg(:));

    % Calculate the area of the background.
    BkgArea = sum(centerCell(:));

    % Store the average background intensity for each frame.
    avgBkgInt = [avgBkgInt BkgInt./BkgArea];
end

% Calculate the overall mean background intensity.
bkgInt = mean(avgBkgInt);
