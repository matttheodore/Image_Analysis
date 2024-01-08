// This macro processes images in a specified main directory. 
// It performs channel selection, saves the modified images in a '2_channel' subdirectory, 
// and creates Z-projections saved in a 'MAX_' prefixed subdirectory.

// Turn on batch mode to reduce GUI updates
setBatchMode(true); // Uncomment this line to use batch mode once functionality is proven

// Get the path to the main directory
mainDir = getDirectory("Data");
// If no directory is available, exit the program with an error message
if (mainDir == "")
    exit("No main directory available");

// Loop through each date_strain_name directory
dateStrainDirs = getFileList(mainDir);
for (dsd = 0; dsd < dateStrainDirs.length; dsd++) {
    // Skip if not a directory
    if (!File.isDirectory(mainDir + dateStrainDirs[dsd]))
        continue;

    // Set the temporary directory to the current date_strain_name subdirectory
    tmp = mainDir + dateStrainDirs[dsd] + File.separator;

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
	    run("Bio-Formats Exporter", "save=[" + baseDir + fileList[i].replace('.nd2', '_OME.ome.tiff') + "] compression=Uncompressed");

        // Get the dimensions of the image to find out the number of channels
        getDimensions(width, height, channels, slices, frames);
        
        // Define slice and frame ranges
        startSlice = 1;
        endSlice = slices;
        startFrame = 1;
        endFrame = frames;

        // Make subset of the image with selected channels, slices, and frames
        run("Make Subset...", "channels=1,3 slices=" + startSlice + "-" + endSlice + " frames=" + startFrame + "-" + endFrame);
    
        // Save the two channel processed image
        saveAs("Tiff", baseDir + fileList[i]);
    
        // Create max intensity Z-projection
        run("Z Project...", "projection=[Max Intensity] all");

        // Save the Z-projection
        saveAs("Tiff", baseDir + "MAX_" + fileList[i]);
    
	    // Close the current opened image
	    close();
    }
}
// Turn off batch mode
setBatchMode(false);
