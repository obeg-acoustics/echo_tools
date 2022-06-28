# echo_tools
Set of Matlab scripts to process EK60/80 raw acoustic transects and analyze acoustic data

-> parameters.m : Lists processing variables, paths, to be edited before extraction and filtering echograms. 

-> extraction.m : Load and concatenate .raw acoustic data to save them into a matlab structure echogram.

-> filter_echogram.m : Apply multiple filters to unprocessed echograms and bin the acoustic signals at desired resolution. 

![alt text](https://github.com/obeg-acoustics/echo_tools/blob/main/schematics.png)
