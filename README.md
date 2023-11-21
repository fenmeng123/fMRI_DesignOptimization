# **fMRI Experiment Designer**

Author: Kunru Song

Version: 2023-11-09

fMRI Experiment Designer is a simple warp to implement easy-to-use functional Magnetic Resonance Imaging (fMRI) experiment design, especially for event-related design. Some user-defined functions have been used in our published work:

> Yao YW, Song KR, Schuck NW, et al. The dorsomedial prefrontal cortex represents subjective value across effort-based and risky decision-making. *Neuroimage*. 2023;279:120326. doi:[10.1016/j.neuroimage.2023.120326](https://doi.org/10.1016/j.neuroimage.2023.120326)

This is an open-source tool licensed under the GNU GENERAL PUBLIC (GPL) license, which includes code from two open-source software: SPM and CanlabCore. The following provides information about these two components.

### fMRI Experiment Design Table

The term **"experiment design table"** used here indicates a table-format data structure that contains all information to execute a psychological experiment among common psychological stimuli presentation software, including Psychtoolbox (MATLAB), PsychoPy (Python), and PsychJS (Java Script).

&#x20;In a canonical event-related fMRI task design, we defined 9 columns in the experiment design table, which are shown in below as an example:

| TrialNo | stimType | ISI  | TrialStart | JitterDura | stimOnset | stimOffset | TrialEnd | TrialDura |
| :------ | :------- | :--- | :--------- | :--------- | :-------- | :--------- | :------- | :-------- |
| 1       | Go       | 1000 | 0          | 1000       | 1000      | 1500       | 1500     | 1500      |
| 2       | Go       | 1500 | 1500       | 1000       | 2500      | 3000       | 3000     | 1500      |
| 3       | Go       | 2500 | 3000       | 2000       | 5000      | 5500       | 5500     | 2500      |
| 4       | Go       | 4500 | 5500       | 4000       | 9500      | 10000      | 10000    | 4500      |
| 5       | Nogo     | 1500 | 10000      | 1000       | 11000     | 11500      | 11500    | 1500      |
| 6       | Nogo     | 2500 | 11500      | 2000       | 13500     | 14000      | 14000    | 2500      |

In this table, we showed an experiment design for a Go-Nogo fMRI task.&#x20;

- **TrialNo:** The number in presentation order of this trial. It should be an non-negative integer.

- **stimType:** The type of stimuli, user-defined column with string content. It is commonly called as "**Condition**" in a psychological experiment.

Starting at the third column, values inside a singe cell reflect the onset (_Start_), offset (_end_), or duration (_Dura_) across different aspects in a psychological stimulus. As default, unit of these values are **milliseconds** (ms) with unsigned 32-digit integer data type (**uint32**). For onset and offset, values indicate a specific time point in a time series that covers the whole scanning length. For duration, values indicate a specific time window that reflect the time of duration for a jitter, a trial, or a inter-stimuli-interval (ISI).

- **ISI:** Inter-stimuli-interval. The time of duration between two successive stimuli.

- **TrailStart:** Onset time point of the current trial.

- **JitterDura:** The time of duration for a "jitter". Usually, a jitter is a black screen with a white fixation ('+') that is presented to a subject.

- **stimOnset**: Onset time point of stimulus in the current trial, from which stimulus is "turned on" and presented to a subject.

- **stimOffset:** Offset time point of stimulus. Since this time point, the stimulus is disappeared that subject can not see it any more.

- **TrialEnd:** Offset time point of the current trial. It indicates the end of a trial.

- **TrialDura:** The time of duration for the current trial.&#x20;

See a figure illustration for these columns in below:

![](README_md_files/d8f59fd0-8140-11ee-9a25-d58d24618b56.jpeg?v=1&type=image)

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

In this tool, we have integrated the code from these two open-source software. You can directly find them in the source code of this software (**depends** folder). If you need to use this code, please comply with the respective license terms. We welcome any questions or suggestions during your use, so that we can continue to improve and refine this open-source software.
