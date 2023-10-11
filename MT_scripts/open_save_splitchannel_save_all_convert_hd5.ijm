
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
 run("Bio-Formats Importer", "open= name  autoscale color_mode=Default concatenate_series open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT swap_dimensions z_1=3 c_1=3 t_1=25");
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
 


 