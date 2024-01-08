// This script is written in the ImageJ Macro language and is designed to be implemented in Fiji. It takes all the files in a user-specified directory
// (intended to be files interoperable with Bio-Formats) and performs the following operations:
// This macro processes images in a specified main directory. 
// It performs channel selection, saves the modified images in a '2_channel' subdirectory, 
// and creates Z-projections saved in a 'MAX_' prefixed subdirectory.

// Turn on batch mode to reduce GUI updates
//setBatchMode(true); will use batch mode once functionality is proven

// Get the path to the main directory
mainDir = getDirectory("Data");
// If no directory is available, exit the program with an error message
if (mainDir=="")
    exit("No main directory available");

// Loop through each subdirectory (Biorep) *I think I need to get rid of this portion and all following portions for bioreps as I do not need to loop over bioreps, so this is one level or organization too high*
biorepDirs = getFileList(mainDir);
for (bd = 0; bd < biorepDirs.length; bd++) {
    // Skip if not a directory
    if (!File.isDirectory(mainDir + biorepDirs[bd]))
        continue;

    // Loop through each date_strain_name directory
    dateStrainDirs = getFileList(mainDir + biorepDirs[bd] + File.separator);
    for (dsd = 0; dsd < dateStrainDirs.length; dsd++) {
        // Skip if not a directory
        if (!File.isDirectory(mainDir + biorepDirs[bd] + File.separator + dateStrainDirs[dsd]))
            continue;

        // Set the temporary directory to the current date_strain_name subdirectory
        tmp = mainDir + biorepDirs[bd] + File.separator + dateStrainDirs[dsd] + File.separator;

        // Create a directory for processed images
        baseDir = tmp + "2_channel" + File.separator;
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

    // Open the current image file, export as OMEtiff to preserve metadata before channel operations
    run("Bio-Formats Importer", "open=[" + tmp + fileList[i] + "] autoscale color_mode=Default concatenate_series open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	run("Bio-Formats Exporter", "save=[" + imageDir + fileList[i].replace('.nd2', '_OME.ome.tiff') + "] compression=Uncompressed");

    // Get the dimensions of the image to find out the number of channels
    var width, height, channels, slices, frames;
    getDimensions(width, height, channels, slices, frames);
    nChannels = channels;
    
    run("Make Subset...", "channels=1,3 slices=1-5 frames=1-16"); // * I need to insert slices, and frames as variables into this Make Subset macro run how would I ddo that ? *
    
    
    

    // Save the two channel processed image
    saveAs("Tiff", imageDir + fileList[i]);
    

    // Create max intensity Z-projection
    run("Z Project...", "projection=[Max Intensity] all");

    // Save the Z-projection
    saveAs("Tiff", imageDir + "MAX_" + fileList[i]);
    
	close(); //*I think this will close the current opened image which should be fine, then I proceed back to the loop and open the next file right ?*