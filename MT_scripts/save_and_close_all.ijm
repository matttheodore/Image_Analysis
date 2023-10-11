// Obtenido de http://imagej.1557.x6.nabble.com/How-to-save-all-opened-images-td3686986.html

// get image IDs of all open images
dir = getDirectory("Choose a Directory");
//ids=newArray(nImages);
for (i=0;i<nImages;i++) {
        selectImage(i+1);
        title = getTitle;
        print(title);
        //ids[i]=getImageID;

        saveAs("tiff", dir+title);
} 
run("Close All");