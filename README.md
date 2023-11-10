# **fMRI Experiment Designer**

Author: Kunru Song

Version: 2023-11-09

fMRI Experiment Designer is a simple warp to implement easy-to-use functional Magnetic Resonance Imaging (fMRI) experiment design, especially for event-related design. Some user-defined functions have been used in our published work:

> Yao YW, Song KR, Schuck NW, et al. The dorsomedial prefrontal cortex represents subjective value across effort-based and risky decision-making. *Neuroimage*. 2023;279:120326. doi:[10.1016/j.neuroimage.2023.120326](https://doi.org/10.1016/j.neuroimage.2023.120326)

This is an open-source software licensed under the GNU GENERAL PUBLIC (GPL) license, which includes code from two open-source software: SPM and CanlabCore. The following provides information about these two components.

### Dependencies

#### **SPM**

SPM, standing for Statistical Parameter Mapping, is a neural imaging data analysis software package based on MATLAB. This software includes some code from SPM to implement specific statistical analysis functions.

- **License**

SPM is licensed under the GPL, and you can find detailed license information and source code on its official website: <https://www.fil.ion.ucl.ac.uk/spm/software/>.

#### **CanlabCore**

CanlabCore is an open-source software for biomedical image analysis, providing a variety of image processing and analysis functions. This software includes some code from CanlabCore to implement specific task fMRI design optimization. For details, please see&#x20;

> Wager TD, Nichols TE. Optimization of experimental design in fMRI: a general framework using a genetic algorithm. *Neuroimage*. 2003;18(2):293-309. doi:[10.1016/s1053-8119(02)00046-0](<https://doi.org/10.1016/s1053-8119(02)00046-0>)

- **License**

CanlabCore is also licensed under the GPL, and you can find detailed license information and source code on its official website: <https://github.com/canlab/CanlabCore>.

#### **How to use the code from these two open-source software**

In this software, we have integrated the code from these two open-source software. You can directly find them in the source code of this software (**depends** folder). If you need to use this code, please comply with the respective license terms. We welcome any questions or suggestions during your use, so that we can continue to improve and refine this open-source software.
