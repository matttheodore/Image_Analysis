# %% [markdown]
# This notebook combines the setup and image processing scripts for Omnipose, following the recommended installation procedures for Jupyter environments.

# %% [markdown]
# This notebook sets up the required dependencies for Omnipose using a conda virtual environment.

# %%
# Create a new conda virtual environment named 'omnipose_env'
#!conda create --name omnipose_env python=3.9.13

# Activate the virtual environment
!conda activate omnipose_env

# Install the required dependencies
#%conda install -c conda-forge pytest pathlib scikit-image

# Note: 'omnipose' might need to be installed through pip or other means if it's not available in conda channels
#!pip install omnipose


# %% [markdown]
# The following section contains the Omnipose image processing code.

# %%
# Import dependencies
import numpy as np
from cellpose_omni import models, core

# This checks to see if you have set up your GPU properly.
# CPU performance is a lot slower, but not a problem if you 
# are only processing a few images.
use_GPU = core.use_gpu()
print('>>> GPU activated? {}'.format(use_GPU))

# for plotting
import matplotlib as mpl
import matplotlib.pyplot as plt
mpl.rcParams['figure.dpi'] = 300
plt.style.use('dark_background')


# %% [markdown]
# Now that I have everything set up I need to load my images, which can be done in a variety of ways but here we will save them as variable "files" by importing a path and then matching file names with extensions and keywords
# 
# 

# %%
from pathlib import Path

basedir = r'C:\Users\MicrobeJ\Downloads\omnipose_trial'
files = [str(p) for p in Path(basedir).glob("C1-MAX-*")]

from cellpose_omni import io, transforms
from omnipose.utils import normalize99
imgs = [io.imread(f) for f in files]

# print some info about the images.
for i in imgs:
    print('Original image shape:',i.shape)
    print('data type:',i.dtype)
    print('data range: min {}, max {}\n'.format(i.min(),i.max()))
nimg = len(imgs)
print('\nnumber of images:',nimg)

fig = plt.figure(figsize=[40]*2,frameon=False) # initialize figure
print('\n')
for k in range(len(imgs)):
    img = transforms.move_min_dim(imgs[k]) # move the channel dimension last
    if len(img.shape)>2:
        # imgs[k] = img[:,:,1] # could pick out a specific channel
        imgs[k] = np.mean(img,axis=-1) # or just turn into grayscale 
        
    imgs[k] = normalize99(imgs[k])
    # imgs[k] = np.pad(imgs[k],10,'edge')
    print('new shape: ', imgs[k].shape)
    plt.subplot(1,len(files),k+1)
    plt.imshow(imgs[k],cmap='gray')
    plt.axis('off')

# %% [markdown]
# ## Decide Which Model to use
# Here we will list the models and choose which model to use. I am assuming we will almost always use the bact_phase_omni or bact_phase_cp models
# 

# %%
from cellpose_omni import models
from cellpose_omni.models import MODEL_NAMES

MODEL_NAMES

model_name = 'bact_phase_omni'
model = models.CellposeModel(gpu=False, model_type=model_name)
use_GPU = False

import time
chans = [0,0] #this means segment based on first channel, no second channel 

n = [-1] # make a list of integers to select which images you want to segment
n = range(nimg) # or just segment them all 

# define parameters
mask_threshold = -1
verbose = 0 # turn on if you want to see more output 
use_gpu = use_GPU #defined above
transparency = True # transparency in flow output
rescale=None # give this a number if you need to upscale or downscale your images
omni = True # we can turn off Omnipose mask reconstruction, not advised 
flow_threshold = 0 # default is .4, but only needed if there are spurious masks to clean up; slows down output
niter = None # None lets Omnipose calculate # of Euler iterations (usually <20) but you can tune it for over/under segmentation 
resample = True #whether or not to run dynamics on rescaled grid or original grid 
cluster = True # use DBSCAN clustering
augment = False # average the outputs from flipped (augmented) images; slower, usually not needed 
tile = False # break up image into smaller parts then stitch together
affinity_seg = 0 #new feature, stay tuned...

tic = time.time() 
masks, flows, styles = model.eval([imgs[i] for i in n],
                                  channels=chans,
                                  rescale=rescale,
                                  mask_threshold=mask_threshold,
                                  transparency=transparency,
                                  flow_threshold=flow_threshold,
                                  niter=niter,
                                  omni=omni,
                                  cluster=cluster, 
                                  resample=resample,
                                  verbose=verbose, 
                                  affinity_seg=affinity_seg,
                                  tile=tile,
                                  augment=augment)

net_time = time.time() - tic
print('total segmentation time: {}s'.format(net_time))

# %%
from cellpose_omni import plot
import omnipose

for idx,i in enumerate(n):

    maski = masks[idx] # get masks
    bdi = flows[idx][-1] # get boundaries
    flowi = flows[idx][0] # get RGB flows 

    # set up the output figure to better match the resolution of the images 
    f = 10
    szX = maski.shape[-1]/mpl.rcParams['figure.dpi']*f
    szY = maski.shape[-2]/mpl.rcParams['figure.dpi']*f
    fig = plt.figure(figsize=(szY,szX*4))
    fig.patch.set_facecolor([0]*4)
    
    plot.show_segmentation(fig, omnipose.utils.normalize99(imgs[i]), 
                           maski, flowi, bdi, channels=chans, omni=True)

    plt.tight_layout()
    plt.show()


base = os.path.splitext(image_name)[0]
outlines = utils.outlines_list(masks)
io.outlines_to_text(base, outlines)
io.save_to_png(images, masks, flows, image_names)   

# %%
from cellpose_omni import io, plot

# image_name is file name of image
# masks is numpy array of masks for image
base = os.path.splitext(image_name)[0]
outlines = utils.outlines_list(masks)
io.outlines_to_text(base, outlines)


