
// This script is written in the ImageJ Macro language and is designed to be implemented in Fiji. It takes all the files in a user-specified directory
// (intended to be files interoperable with Bio-Formats) and performs the following operations:
// 
// 1. Creates a subfolder directory named after each image file name
// 2. Reads the files into TIFF format and saves the file there
// 3. Creates a max intensity projection
// 4. Saves the projection as a TIFF file
// 5. Splits the image into individual channels
// 6. Saves each channel as a sequence of TIFF files in a subdirectory based on the channel name
// 
// User input is required at the start of the script to specify the initial directory and the number of channels.
// 
// 


// Define the number of channels at the beginning of the script
nChannels = 2; // You can change this value accordingly

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
    imageDir = baseDir + fileList[i].replace('.tif', '') + File.separator; // Remove extension from directory name
    File.makeDirectory(imageDir);
    if (!File.exists(imageDir))
        exit("Unable to create directory for image");

    // Open the current image file
    run("Bio-Formats Importer", "open=[" + tmp + fileList[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

    // Save the original image
    saveAs("Tiff", imageDir + fileList[i]);

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
