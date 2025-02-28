function[cutout_final,rectangle,Area] = Transwell_processing();

% Processing of merged microscopic images of stained cells in Transwell assay

% The script is used to analyze merged images of the lower side of the 
% Transwell membrane to determine the area covered with migrated cells.
% Merged image should describe the whole membrane surface with insert
% borders.

% As an output, you will get:
% cutout_final = membrane cutout
% rectangle = selected rectangle region in membrane cutout for processing
% Area = surface area covered with migrated cells (in %)

% Used MATLAB version: R2021a
% Author: Inna Zumberg 
% Brno University of Technology
% Faculty of Electrical Engineering and Communication
% Department of Biomedical Engineering
% Technicka 3082/12, 616 00 Brno, Czechia

% email address: zumberg@vutbr.cz

clc; close all;

[name,location]=uigetfile('*.*');
image=im2double(imread([location,name]));
fig1 = figure;
set(fig1, 'Name','Uploading the original image to create a membrane cutout','NumberTitle','off')
imshow(image);
title('Original image. To submit your cutout choice use double-click')

% Create a membrane cutout - use ellipse to mark the Transwell insert 
% borders. After finishing, use double-click to submit your choice

h_axes = gca;
circle = imellipse(h_axes);
setColor(circle, 'r');
wait(circle);
position = getPosition(circle);
delete(circle);
center = [position(1) + position(3)/2, position(2) + position(4)/2];
radius = min(position(3:4))/2;
[x, y] = meshgrid(1:size(image, 2), 1:size(image, 1));
mask_circle = ((x - center(1)).^2 + (y - center(2)).^2) <= radius^2;
cutout = image;

if length(size(image)) > 2
    for channel = 1:size(image, 3)
        cutout(:,:,channel) = image(:,:,channel) .* double(mask_circle);
    end
else
    cutout = image .* double(mask_circle);
end

boundingBox = regionprops(mask_circle, 'BoundingBox');
boundingBox = boundingBox.BoundingBox;
cutout_final = imcrop(cutout, boundingBox);

% Define a rectangle in the center of membrane cutout for future processing

if length(size(cutout_final)) > 2
    cutout_final_gray = rgb2gray(cutout_final);
else
    cutout_final_gray = cutout_final;
end

cutout_final_gray = 3*cutout_final_gray;
a = round(size(cutout_final_gray,1)/3);
b = round(size(cutout_final_gray,2)/3);
c = a*2;
d = b*2;

rectangle = cutout_final_gray(a:c,b:d);

demo = cutout_final;
for i = a:c
    for j = b:d
        demo(i,b:(b+20),1) = 1;
        demo(a:(a+20),j,1) = 1;
        demo(i,d:(d+20),1) = 1;
        demo(c:(c+20),j,1) = 1;
    end
end

fig2 = figure;
set(fig2, 'Name','Definition of the rectangle in the center of membrane cutout for future processing','NumberTitle','off')
subplot(1,3,1)
imshow(cutout_final);
title('Membrane cutout')
subplot(1,3,2)
imshow(demo);
title('Selected rectangle region for processing')
subplot(1,3,3)
imshow(rectangle);
title('Rectangle region')

%% Image processing to define the Area covered with migrated cells

rectangle_filt_diff = imdiffusefilt(rectangle);      % Anisotropic diffusion filtering
level=0.3;                                    
rectangle_bin = im2bw(rectangle_filt_diff,level);    % Image binarization
rectangle_bin = bwareaopen(rectangle_bin, 50);       % Removing the small round objects representing membrane pores

fig3 = figure;
set(fig3, 'Name','Image processing to define the Area covered with migrated cells','NumberTitle','off')
subplot(1,3,1)
imshow(rectangle);
title('Rectangle region')
subplot(1,3,2)
imshow(rectangle_filt_diff);
title('Filtered image')
subplot(1,3,3)
imshow(rectangle_bin);
title('Binarized image')


intersect = zeros(size(rectangle,1),size(rectangle,2),3);
intersect(:,:,1) = rectangle;
intersect(:,:,2) = rectangle_bin;

fig4 = figure;
set(fig4, 'Name','Similarity between original image and binarized image','NumberTitle','off')
imshow(intersect);
title('Use this marged image to evaluate the degree of similarity between original image and binarized image')

% Calculating the Area covered with migrated cells

number = nnz(rectangle_bin);                % Count white pixels in binarized image representing area occupied by cells
image_area = size(rectangle_bin,1)*size(rectangle_bin,2); % Binarized image area
Area = number/image_area * 100;             % Area covered with migrated cells

assignin('base','cutout_final',cutout_final);
assignin('base','rectangle',rectangle);
assignin('base','Area',Area);

disp(['Name of analyzed image: ',name])
fprintf('Area covered with migrated cells: %.3g%%',Area)

