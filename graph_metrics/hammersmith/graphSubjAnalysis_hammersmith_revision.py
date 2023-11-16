# -*- coding: utf-8 -*-
"""
@author: tim
"""

import numpy as np
from maybrain import brain as mb
from maybrain.utils.brain_utils import write_results
from maybrain.utils import bct as mbbct
from maybrain.algorithms import normalisation
from maybrain.algorithms import edgelength

# set the range of thresholds
EDGEPC = [edge_pc * 5 for edge_pc in range(1, 1)]

# set the parcellation number
# 246 is the Brainnetome parcellation, all others refer to the Craddock
# parcellations
PARCEL_NUMBER = "079"


EXCLUDED_NODES = []

PARCEL_FILE = "hammers.txt"

THRESHOLD_TYPE = "local"
ADJ_MAT_FILE = "adjMat_079_pearson_fcorr.txt"
DELIM = " "

a_brain = mb.Brain()
APPVAL = False


# weighted measures
a_brain.import_adj_file(ADJ_MAT_FILE, delimiter=DELIM, nodes_to_exclude=EXCLUDED_NODES)
a_brain.apply_threshold() 
a_brain.remove_unconnected_nodes()

a_brain.weight_to_distance()
OFB = "brain_"
APPVAL = False
a_brain.import_spatial_info(PARCEL_FILE)  # read spatial information
a_bctmat = mbbct.makebctmat(a_brain)

# weighted hub metrics
degs = {v[0]:v[1] for v in a_brain.G.degree(weight='weight')}
write_results(degs, "degree_wt", OFB, append=APPVAL)

