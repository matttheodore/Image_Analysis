
  // Get path to temp directory
  tmp = getDirectory("Data");
  if (tmp=="")
      exit("No temp directory available");
 
  // Create a directory in temp
  myDir = tmp+"testdata"+File.separator;
  File.makeDirectory(myDir);
  if (!File.exists(myDir))
      exit("Unable to create directory");
  print("");
  print(myDir);
  
//  // Open your file of interest
//  File.openDialog(tmp);
//  	name = File.name;
//  	print(name);
  	
  	
  // Import The Image File
 run("Bio-Formats Importer", "autoscale color_mode=Default group_files open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT dimensions axis_1_number_of_images=6 axis_1_axis_first_image=1 axis_1_axis_increment=1 axis_2_number_of_images=3 axis_2_axis_first_image=1 axis_2_axis_increment=1 axis_3_number_of_images=3 axis_3_axis_first_image=1 axis_3_axis_increment=1");
  saveAs("tiff", myDir+getTitle);
  
  // Split Image Channels and save as tif
  run("Split Channels");
	title = getTitle();
	saveAs(myDir+ title); 
	close();
	title = getTitle();
	saveAs(myDir+title); 
	close();
	title = getTitle();
	saveAs(myDir+title); 
	close();
 


 