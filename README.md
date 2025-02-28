# TranswellQuantification

Processing of merged microscopic images of stained cells in Transwell assay using Transwell_processing.m function in MATLAB.

The script is used to analyze merged images of the lower side of the Transwell membrane to determine the area covered with migrated cells.
Merged image should describe the whole membrane surface with insert borders.

As an output, you will get these variables:
-   cutout_final = membrane cutout image
-   rectangle = selected rectangle region in membrane cutout for processing
-   Area = surface area covered with migrated cells (in %)
