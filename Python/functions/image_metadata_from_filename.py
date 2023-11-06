import re

# Define a function to parse the 'IMAGE.name' column and extract the specified components
def parse_image_name_metadata(image_name):
    # Parse the date (first 8 characters are the date in YYYYMMDD format)
    date = image_name[:8]
    
    # Use a regular expression to find the strain identifier, which seems to be in the format LZ followed by numbers
    strain_match = re.search(r'(LZ\d+)', image_name)
    strain = strain_match.group(1) if strain_match else None
    
    # Use a regular expression to find the time point (number followed by 'min')
    time_match = re.search(r'(\d+)min', image_name)
    time = int(time_match.group(1)) if time_match else None
    
    # Use a regular expression to find the condition ('inf' or similar pattern)
    cond_match = re.search(r'min_([a-zA-Z]+)', image_name)
    cond = cond_match.group(1) if cond_match else None
    
    # Use a regular expression to find the frame number (after 'T=')
    frame_match = re.search(r'T=(\d+)', image_name)
    frame = int(frame_match.group(1)) if frame_match else None
    
    return date, strain, time, cond, frame

# Apply the parsing function to the 'IMAGE.name' column and create new columns
data_subset[['date', 'strain', 'time', 'cond', 'frame']] = data_subset.apply(
    lambda row: parse_image_name(row['IMAGE.name']), axis=1, result_type="expand"
)