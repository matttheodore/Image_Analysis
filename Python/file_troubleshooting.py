from xml.etree import ElementTree as ET
from tifffile import TiffFile

def extract_channel_names_from_ome_tiff(ome_tiff_path):
    """
    Extract channel names from an OME-TIFF file.
    
    Parameters:
        ome_tiff_path (str): Path to the OME-TIFF file.
        
    Returns:
        list: List of channel names.
    """
    # Initialize an empty list to store channel names
    channel_names = []
    
    # Open the OME-TIFF file using tifffile
    with TiffFile(ome_tiff_path) as tif:
        # Extract the OME-XML metadata
        ome_xml = tif.ome_metadata

        print("OME-XML metadata:", ome_xml)  # Add this line for debugging

        # Parse the OME-XML metadata
        root = ET.fromstring(ome_xml)

        # Loop through XML tree to find channel names
        for elem in root.iter('Channel'):
            channel_name = elem.attrib.get('Name', None)
            if channel_name:
                channel_names.append(channel_name)
                
    return channel_names


# Function invocation
channel_names = extract_channel_names_from_ome_tiff('C:\\Users\\MicrobeJ\\Downloads\\omnipose_multichannel\\sandbox_2\\biorep1\\20230801_LZ22225_imaging\\Image_Data\\2023.08.01_LZ22225_10min_uninf.004\\2023.08.01_LZ22225_10min_uninf.004_OME.ome.tiff')

print("Extracted channel names:", channel_names)
