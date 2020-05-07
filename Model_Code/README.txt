* Octave/Matlab files (*.m)
  + format_data.m:
    reads demography data from excel sheets and saves them as mat
    files for easier callable applicability in Octave/Matlab.

  + DemoIndia.m:
    formats demography data and contact patterns raw data to
    appropriate sizes. Population is converted from age-group sizes of
    five years to 0-19, 20-49,50-64,65+. Contact patterns are scaled
    down to 4X4 to match the age-groups.

  + CalcR0.m
    estimates transmission parameter 'beta' by calibrating model to given value of R0 and corresponding model
    parameters

  + ParametersOutput.m
    given number of age-groups being considered, reproduction number,
    location and lockdown status, it returns all model parameters.

  + RunSimA.m
    given an index for location (1,2,..6) and value for reproduction
    number, it runs model under three scenarios: 1) no lockdown, 2)
    initial lockdown followed by return to status quo and 3) initial
    lockdown followed by continued closure of red light areas. The
    function returns solutions for each three strategies.

  + ASODE.m
    model equations that returns state of each compartment at next step

  + get_results.m
    runs and saves model results as mat files for each location and
    for different values of R0 (1.75,2,2.25,2.5)

* Excel file
  + India_datasheet.xlsx
    has contact patterns of India by each sheet representing different
    locations: Overall, Home, Other, School and Work. Obtained from
    https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005697

  + Population_distribution.xlsx
    has population of each location and its red light area for ages
    grouped by 5 years. Obtained by applying age-distribution of
    relevant states from last census data (2011) to current
    populations.

* Results (.mat files)
  + Mumbai
  + Nagpur
  + Delhi
  + Kolkata
  + Pune
  + India

* Notes:
  + get_results.m can be treated as main file which can be also used
    to generate solutions for different R0 values.
  + IndiaDemo.mat file has data saved after processing excel
    sheets using format_data.m. So, it is not essential.
  + However, if the format_data.m needs to be run in octave. 'io'
    package will have to be installed and loaded before it can run. In
    matlab, it should run without any issue.
