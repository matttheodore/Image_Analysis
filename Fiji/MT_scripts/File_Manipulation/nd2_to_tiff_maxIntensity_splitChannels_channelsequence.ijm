// Get the path to the temporary directory
tmp = getDirectory("Data");
// If no directory is available, exit the program with an error message
if (tmp=="")
    exit("No temp directory available");

// Create a directory for processed test data
baseDir = tmp + "Image_Data" + File.separator;
File.makeDirectory(baseDir);
if (!File.exists(baseDir))
    exit("Unable to create directory");

// Get a list of all files in the directory
fileList = getFileList(tmp);

// Loop through all files in the directory
for (i = 0; i < fileList.length; i++) {
    // Skip the file if it's not an image
    if (!(endsWith(fileList[i], ".jpg") || endsWith(fileList[i], ".png") || endsWith(fileList[i], ".tif") || endsWith(fileList[i], ".nd2")))
        continue;

    // Create a directory for the current image file
    imageDir = baseDir + fileList[i].replace('.nd2', '') + File.separator; // Remove extension from directory name
    File.makeDirectory(imageDir);
    if (!File.exists(imageDir))
        exit("Unable to create directory for image");

    // Open the current image file
    run("Bio-Formats Importer", "open=[" + tmp + fileList[i] + "] autoscale color_mode=Default concatenate_series open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");


    // Get the dimensions of the image to find out the number of channels
    var width, height, channels, slices, frames;
    getDimensions(width, height, channels, slices, frames);
    nChannels = channels;

    // Save the original image
    saveAs("Tiff", imageDir + fileList[i]);
    
    // Update fileList[i] to .tif after conversion
    fileList[i] = fileList[i].replace('.nd2', '.tif');

    // Create max intensity Z-projection
    run("Z Project...", "projection=[Max Intensity] all");

    // Save the Z-projection
    saveAs("Tiff", imageDir + "MAX.tif");
    
    // Create directory for max image later
    sequenceDir = imageDir + "MAX" + File.separator;
    File.makeDirectory(sequenceDir);

    // Split the channels
    run("Split Channels");

    // Loop over the channels
    for (j = 1; j <= nChannels; j++) {
        selectWindow("C" + j + "-MAX.tif");

        // Save the channel image
        saveAs("Tiff", imageDir + "C" + j + "-MAX");

        // Create directory for image sequence
        sequenceDir = imageDir + "C" + j + "-MAX_sequence" + File.separator;
        File.makeDirectory(sequenceDir);

        // Check if the image is a stack
        if (nSlices() > 1) {
            // Convert stack to images
            run("Stack to Images");
            
            // Save each image of the sequence
            for (k = 1; k <= nImages(); k++) {
                selectImage(k);
                title = getTitle();
                if (startsWith(title, "C" + j + "-MAX-")) {
                    saveAs("Tiff", sequenceDir + title);
                }
            }

            // Close all the images related to this channel
            for (k = nImages(); k >= 1; k--) {
                selectImage(k);
                title = getTitle();
                if (startsWith(title, "C" + j + "-MAX-")) {
                    close();
                }
            }
        }
    }

    // Close the original image
    selectWindow(fileList[i]);
    close();
}
