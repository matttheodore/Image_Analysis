from aicsimageio import AICSImage
import xml.etree.ElementTree as ET

# Load the OME-TIFF file
ome_file_path = 'C:\\Users\\MicrobeJ\\Downloads\\omnipose_multichannel\\sandbox_2\\biorep1\\20230801_LZ22225_imaging\\Image_Data\\2023.08.01_LZ22225_10min_uninf.004\\2023.08.01_LZ22225_10min_uninf.004_OME.ome.tiff'
img = AICSImage(ome_file_path)

# Extract the OME-XML metadata
ome_xml_str = img.metadata.ome_xml
ome_xml_root = ET.fromstring(ome_xml_str)

# Extract channel names
channel_names = []
for elem in ome_xml_root.iter('Channel'):
    channel_name = elem.attrib.get('Name')
    if channel_name:
        channel_names.append(channel_name)

channel_names
