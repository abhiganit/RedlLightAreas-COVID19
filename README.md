# RLA-COVID19-India

## Mathematical model for COVID-19 transmission in general population as well as red-light areas in India
Abhishek Pandey <abhishek.pandey@yale.edu>, Sudhakar V. Nuti, Pratha, Sah, Chad, R. Wells, Alsion P. Galvani, Jeffrey P. Townsend. [Center for Infectious Disease Modeling and Analysis.](http://cidma.yale.edu/)

Copyright (C) <2020>, Abhishek Pandey et. al. All rights reserved. Released under the [GNU General Public License (GPL)](https://web.archive.org/web/20160316065455/https://opensource.org/licenses/gpl-3.0)

This repository contains codes and data used to simulate and analyze COVID-19 transmission burden under two possible scenarios after the end of nationwide initial lockdown in India to combat COVID-19 epidemic: 
1) Red-light areas are re-opened.
2) Extended closure of red-light areas.

An additional scenario is also simulated under the assumption that no initial nationwide lockdown was implemented.

The model code is primarily written in MATLAB and results are saved as MATLAB data files (extension .mat)  MATLAB result data files are then used to save data in excel sheets (Data_RLA directory) and to make plots (Plots directory) using Python. As MATLAB is not an open-source software/programming language, a compatible code that can be run using GNU Octave can be found in the directory named Octave in the repository.

## System requirements
### OS requirements
The codes developed here are tested on Linux operating system (Ubuntu 16.04). However as Matlab,Python and Octave are available for most operating systems, codes should run on Windows and Mac OSX as well.

## Installation guide
1. **MATLAB:** Installation instruction for MATLAB can be found at https://www.mathworks.com/help/install/install-products.html. Typical install time for MATLAB on a "normal" desktop is around 30-40 minutes. The current codes were developed and tested on MATLAB R2016b. 
2. **Python:** Installing python is not required to test the code and generate data. Python 3.5.2 is primarily used to save data in excel format as well as to make plots. Easiest way to install and use Python is through Anaconda software which is available for most operating systems. Installation guide to install Python through Anaconda can be found at https://docs.anaconda.com/anaconda/install/. Typical install time for Anaconda on a "normal" desktop is around 15-20 minutes.  We used several third-party libraries in Python namely: NumPy (1.18.2), SciPy (1.4.1), matplotlib (2.0.2), pandas (0.24.2), mat4py (0.4.3) , seaborn (0.9.1) and itertools. All these libraries can be installed using following code in Anaconda:
  `conda install packgage-name=version_number`
3. **GNU Octave:** When MATLAB is not accessible due to lack of license or any other reason, the open-source GNU Octave can be used to test the code. We tested our code with GNU Octave version 4.2.2. Necessary adjustment to code was done to make it compatible with GNU Octave and it can be found in the directory named Octave in the repository. Installation instruction for GNU octave can be found at https://www.gnu.org/software/octave/. Typical install time for GNU Octave on a "normal" desktop is 15 minutes or less. As most data is saved in MATLAB data file format as well, they can be read directly in GNU Octave for speed. If testing the code that reads the raw data and formats them (format_data.m), it may be essential to install 'io' package in GNU Octave and can be installed using `pkg install -forge io`, which can then be loaded in work environment using `pkg load io`. *NOTE: Simulations in GNU Octave were slower and typically take around two to three times longer to run than in MATLAB*

## Repo content & intstruction to use
### Data
1. **DDW-0000C-13.xls:** Raw 2011 census data from India obtained from https://censusindia.gov.in/2011census/C-series/C-13.html
2. **Population_distribution.xlsx:** has population for India as well as 5 cities considered and red-light areas within them for ages grouped by 5 years. Obtained after applying age-distribution from 2011 census data to current population estimates.
3. **India_datasheet.xlsx** Raw data on contact patterns in India between different age-groups by locations (Overall,Work,School,Household,Others) obtained from Supplementary File of PLOS Computational Biology article: https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005697.
4. **Observed data.xlsx:** Cumulative COVID-19 cases reported between April 22 to 28 2020 in 5 cities considered and in India.
5. **Sex Worker Contact Frequency Data Set.xlsx** Raw data on red-light area demography as well as contact frequency for 5 cities considered and India.
6. **observed_data.mat** Pre-loaded "Observed data.xlsx" in MATLAB file format to speed up the simulation time.
7. **IndiaDemo.mat** Pre-loaded "Population distribution.xlsx" & "India_datasheet.xlsx" in MATLAB file format to speed up the simulation time.
8. **Fitting.mat** Pre-loaded estimated values for initial prevalence obtained from model fitting.

### Codes & their functionality
1. **get_results.m** is the **main source file** to run all simulations ecompassing all scenarios at once and saves results. It runs and saves model results as MATLAB data files (.mat) for each location. 

2. **run_one.m** is a sub-set of **get_results.m** and can be used as **demo** file to test the code quickly. It runs the simulation for one location and one reproduction number. **Expected output** from the running the code for India (location=6) and R0 =2 is available as figure titled 'India.png' in the repository and can be used to validate the result. **Expected run time** of this demo code is **15** seconds on MATLAB and **45** seconds on GNU Octave.

3. **RunSimA.m** given an index for location (1,2,...6) and value for reporoduction number, this function runs model under the three scenarios: 1) no lockdown, 2) initial lockdown followed by re-opening of RLAs 3) initial lockdown followed by extended closure of red-light areas. The function returns solutions for each three strategies.

4. **ASODE.m** model equations that returns state of each compartment at next step.

5. **ParameterOutput.m** given number of age-groups being considered, reproduction number, location and lockdown status, this function returns all model parameters including transmision parameter by calibrating it to the given reporoduction number using 'getBeta.m' function.

6. **getBeta.m** estimates the transmission parameter 'beta' by calibrating model to given value of R0 and corresponding model parameters.

7. **getR0.m** calculates reproduction number R0 for given transmission parameter 'beta' and other model parameters.

8. **DemoIndia.m** formats demography data and contact patterns raw data to appropriate sizes. Population is converted from age-group sizes of five years to 0–19, 20–49,50–64,65+. Contact patterns are scaled down to 4x4 matrices to match the age-groups.

9. **get_likelihood.m** runs model and calculates least ssquare error using model model output and observed data that needs to be minimized for fitting.

10. **model_fit.m** calibrates model for each location by fitting model for symptomatic cases to observed data from each location by estimating initial prevalence.

11. **format_data.m** reads demography data from excel sheets and saves them as mat files (IndiaDemo.mat) for easy access and speeding up simulations in MATLAB/GNU Octave.

12. **format_popdata.py** Python file reads raw census data and applies its age-distribution to current population estimates to generate current population distribtution for each location and saves it as 'Population_distribution.xlsx'.

13. **save_results.py** Python file reads saved results in form of matlab files and saves them as excel sheets in "Data_RLA" directory in the repository. Moreover, it calculates relevant statistics and plot temporal results that are saved in "Plots" directory in the repository.

14. **Data_RLA/analysis.py** Python file reads the saved excel sheets, makes Figure 2–5 (.png) in "Plot" directory of repository and 'TableS3-S7' (.xlsx) in "Data_RLA" directory.


### Results 
Compiled results can be found either in form of MATLAB files in the repository or as excel files in 'Data_RLA' directory of repository with names:
1. Mumbai (.mat, .xlsx)
2. Nagpur (.mat, .xlsx)
3. Delhi (.mat, .xlsx)
4. Kolkata (.mat, .xlsx)
5. Pune (.mat, .xlsx)
6. India (.mat, .xlsx)
7. summary (.mat, .xlsx)













