#!/bin/sh

#PBS -N rgis2netcdf
#PBS -o job_out.txt            
#PBS -e job_err.txt            
#PBS -m ae                    
#PBS -M sagy.cohen@colorado.edu
         
cd ${PBS_O_WORKDIR}
pwd
./rgis2netcdf.sh ../RGISresults ../RGISresults
