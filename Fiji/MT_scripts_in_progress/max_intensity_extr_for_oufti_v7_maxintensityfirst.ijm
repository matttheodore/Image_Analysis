// Get the path to the temporary directory
tmp = getDirectory("Data");
// If no directory is available, exit the program with an error message
if (tmp=="")
    exit("No temp directory available");

// Create a directory for processed test data
myDir = tmp+"testdata"+File.separator;
File.makeDirectory(myDir);
if (!File.exists(myDir))
    exit("Unable to create directory");
print("");

print(myDir);

// Get a list of all files in the directory
fileList = getFileList(tmp);

// Loop through all files in the directory
for (i = 0; i < fileList.length; i++) {
  // Skip the file if it's not an image (you can adjust the condition depending on the image file extensions you work with)
  if (!(endsWith(fileList[i], ".jpg") || endsWith(fileList[i], ".png") || endsWith(fileList[i], ".tif")))
    continue;

  // Get the name of the current file without its extension
  newname = replace(fileList[i], ".jpg", "");
  newname = replace(newname, ".png", "");
  newname = replace(newname, ".tif", "");

  // Create a directory for the current image file
  myDirImage = myDir + newname + File.separator;
  File.makeDirectory(myDirImage);
  if (!File.exists(myDirImage))
      exit("Unable to create directory");
  print("");
  print(myDirImage);

  // Create a 'max_intensity_single_channel' directory for the current image file
  myDirsingle_channel = myDirImage + "/max_intensity_single_channel" + File.separator;
  File.makeDirectory(myDirsingle_channel);
  if (!File.exists(myDirsingle_channel))
      exit("Unable to create directory");
  print("");
  print(myDirsingle_channel);

  // Open the current image file
  run("Bio-Formats Importer", "open=[" + tmp + fileList[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
  
  // Save the current image as a TIFF file in the directory created earlier
  saveAs("tiff", myDirImage + newname);

  // Split the image into its component color channels
  run("Split Channels");
  
  // Get the number of open images (there should be one for each color channel)
  n = nImages();

  // Apply 'Z Project' and 'Stack to Images' to each channel separately, then save each image and close it
  for (j = 1; j <= n; j++) {
      selectImage(j);
      title = getTitle();

      // Create a maximum intensity Z-projection for the image sequence
      run("Z Project...", "projection=[Max Intensity] all");
      run("Stack to Images");

      // Create a directory for each single channel image file
      myDirsingle_file = myDirsingle_channel + title + File.separator;
      File.makeDirectory(myDirsingle_file);
      if (!File.exists(myDirsingle_file))
          exit("Unable to create directory");
      print("");
      print(myDirsingle_file);

      // Save as TIFF file
      saveAs("Tiff", myDirsingle_file + title);
      close();
  }
}
