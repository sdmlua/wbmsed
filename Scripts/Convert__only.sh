#!/bin/bash

PROJECTDIR="/home/beach/staff/saco2635/WBMsed_Runs/WBMsed-GPCCfull-NCEP-STN+HydroSHEDS-mTS-06min-Global_pre_n_post"

SCRIPT="${0##*/}"; SCRIPT="${SCRIPT%.sh}";

GHAAS_DIR="/home/beach/staff/saco2635/ghaas"

      USAGE="Usage: <Domain> <Resolution> [dist|dist+gbc|prist|prist+gbc]"
      MODEL="${PROJECTDIR}/Model/WBMplus/bin/wbmplus.bin"
RGISARCHIVE="/data/ccny/RGISarchive"
  RGISPILOT="/data/ccny/RGISpilot"
RGISRESULTS="${PROJECTDIR}/RGISresults-phase1" # $(date '+%Y-%m-%d')
 RGISBINDIR="${GHAAS_DIR}/bin"

source "${GHAAS_DIR}/Scripts/RGISfunctions.sh"
source "${PROJECTDIR}/Model/MFlib/Scripts/fwFunctions20_multi_postproc.sh"
       DOMAIN="${1}"; shift
   RESOLUTION="${1}"; shift
CONFIGURATION="${1}"; shift
OUTPUTSEXPORT="${PROJECTDIR}/BQARTmeanInputs/${DOMAIN}/"
  EXPERIMENT="NCEP"
		
             STARTYEAR=1968
               ENDYEAR=2000
               
        AIRTEMP_STATIC=$(RGISfile "${RGISARCHIVE}" "${DOMAIN}+" "air_temperature"              "NCEP"           "${RESOLUTION}+" "TS" "daily"   "1948")
       AIRTEMP_DYNAMIC=$(RGISfile "${RGISARCHIVE}" "${DOMAIN}+" "air_temperature"              "NCEP"           "${RESOLUTION}+" "TS" "daily"   "xxxx")
 MONTHLY_PRECIP_STATIC=$(RGISfile "${RGISARCHIVE}" "${DOMAIN}+" "precipitation"                "GPCCfull"       "${RESOLUTION}+" "TS" "monthly" "1948")
MONTHLY_PRECIP_DYNAMIC=$(RGISfile "${RGISARCHIVE}" "${DOMAIN}+" "precipitation"                "GPCCfull"       "${RESOLUTION}+" "TS" "monthly" "xxxx")
    PRECIP_FRAC_STATIC=$(RGISfile "${RGISARCHIVE}" "${DOMAIN}+" "daily_precipitation_fraction" "NCEP"           "${RESOLUTION}+" "TS" "daily"   "1948")
   PRECIP_FRAC_DYNAMIC=$(RGISfile "${RGISARCHIVE}" "${DOMAIN}+" "daily_precipitation_fraction" "NCEP"           "${RESOLUTION}+" "TS" "daily"   "xxxx")


case ${CONFIGURATION} in
	(dist|dist+gbc)
		DISTURBED="on"
		EXPERIMENT="${EXPERIMENT}+Dist"
	;;
	(prist|prist+gbc)
		DISTURBED="off"
		EXPERIMENT="${EXPERIMENT}+Prist"
	;;
	(*)
		echo "${USAGE}"
		exit 1
	;;
esac
case ${CONFIGURATION} in
	(dist+gbc|prist+gbc)
		GBC="on"
		EXPERIMENT="${EXPERIMENT}+GBC"
	;;
	(dist|prist)
		GBC="off"
	;;
	(*)
		echo "${USAGE}"
		exit 1
	;;
esac
case ${RESOLUTION} in
	(30min)
	           NETVERSION="PotSTNv602"
	;;
	(06min)
	          # NETVERSION="STN+HydroSHEDS" #changed for NAmerica run
	         #  NETVERSION="HydroSHEDS-STNv100" # changed for testing 22/11/2010
		   NETVERSION="PotSTNv120"
	;;
	(*)
		echo "${USAGE}"
		exit 1
		;;
esac

NETWORK=$(RGISfile ${RGISARCHIVE} ${DOMAIN} network ${NETVERSION} ${RESOLUTION} static)

                IRRMAP="FAO"
              CROPFILE="${PROJECTDIR}/ASCII/Cropfile_FourCrops_2008-06-07.txt"

echo "Configuration: ${PROJECTDIR} ${SCRIPT} ${EXPERIMENT} ${RESOLUTION} ${STARTYEAR} ${ENDYEAR}"

FwArguments -s on -f on -u on -n 2 -D off  $* || exit -1  

FwInit    "${MODEL}" "${DOMAIN}" "${NETWORK}" "${PROJECTDIR}/GDS" "${RGISRESULTS}" "${RGISBINDIR}" || exit -1 

(( DataNum = 0 ))
DATASOURCES[${DataNum}]="AirTemperature                static  Common        file  ${AIRTEMP_STATIC}";                                                                                           (( ++DataNum ))
DATASOURCES[${DataNum}]="AirTemperature                dynamic Common        file  ${AIRTEMP_DYNAMIC}";                                                                                          (( ++DataNum ))
DATASOURCES[${DataNum}]="FieldCapacity                 static  Common        file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ field_capacity              WBM         ${RESOLUTION}+ static)";         (( ++DataNum ))

DATASOURCES[${DataNum}]="MonthlyPrecipitation          static  Common        file  ${MONTHLY_PRECIP_STATIC}";                                                                                    (( ++DataNum ))
DATASOURCES[${DataNum}]="MonthlyPrecipitation          dynamic Common        file  ${MONTHLY_PRECIP_DYNAMIC}";                                                                                   (( ++DataNum ))
DATASOURCES[${DataNum}]="PrecipitationFraction         static  Common        file  ${PRECIP_FRAC_STATIC}";                                                                                       (( ++DataNum ))
DATASOURCES[${DataNum}]="PrecipitationFraction         dynamic Common        file  ${PRECIP_FRAC_DYNAMIC}";                                                                                      (( ++DataNum ))

DATASOURCES[${DataNum}]="RicePondingDepth              static  Common        const 50";                                                                                                          (( ++DataNum ))
DATASOURCES[${DataNum}]="RiverbedSlope                 static  Common        const 0.10";                                                                                                        (( ++DataNum ))
DATASOURCES[${DataNum}]="RootingDepth                  static  Common        file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ rooting_depth               WBM         ${RESOLUTION}+ static)";         (( ++DataNum ))
DATASOURCES[${DataNum}]="WiltingPoint                  static  Common        file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ wilting_point               WBM         ${RESOLUTION}+ static)";         (( ++DataNum ))

DATASOURCES[${DataNum}]="GrowingSeason1_Start          static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ growing_season1    Computed-CRU+FAO     ${RESOLUTION}+ LT annual)";      (( ++DataNum ))
DATASOURCES[${DataNum}]="GrowingSeason2_Start          static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ growing_season2    Computed-CRU+FAO     ${RESOLUTION}+ LT annual)";      (( ++DataNum ))

DATASOURCES[${DataNum}]="IrrigatedAreaFraction         static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ irrigated_area_fraction     GMIA        ${RESOLUTION}+ LT annual 2008)"; (( ++DataNum ))
DATASOURCES[${DataNum}]="IrrigatedAreaFraction         dynamic Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ irrigated_area_fraction     GMIA        ${RESOLUTION}+ TS annual xxxx)"; (( ++DataNum ))
DATASOURCES[${DataNum}]="IrrigationIntensity           static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ cropping_intensity          DWisser     ${RESOLUTION}+ LT annual)";      (( ++DataNum ))
DATASOURCES[${DataNum}]="IrrigationEfficiency          static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ irrigation_efficiency       DWisser     ${RESOLUTION}+ LT annual)";      (( ++DataNum ))

DATASOURCES[${DataNum}]="ReservoirCapacity             static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ reservoir_capacity          UNH661      ${RESOLUTION}+ LT annual 2008)"; (( ++DataNum ))
DATASOURCES[${DataNum}]="ReservoirCapacity             dynamic Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ reservoir_capacity          UNH661      ${RESOLUTION}+ TS annual xxxx)"; (( ++DataNum ))
DATASOURCES[${DataNum}]="RicePercolationRate           static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ rice_percolation_rate       DWisser     ${RESOLUTION}+ LT annual)";      (( ++DataNum ))
DATASOURCES[${DataNum}]="SmallReservoirStorageFraction static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ small_reservoir_coefficient GMIAderived ${RESOLUTION}+ LT annual 2008)"; (( ++DataNum ))
DATASOURCES[${DataNum}]="SmallReservoirStorageFraction dynamic Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ small_reservoir_coefficient GMIAderived ${RESOLUTION}+ TS annual xxxx)"; (( ++DataNum ))

DATASOURCES[${DataNum}]="CropFraction_01               static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ perennial_crop_fraction     SAGE        ${RESOLUTION}+ LT annual)";      (( ++DataNum ))
DATASOURCES[${DataNum}]="CropFraction_02               static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ vegetables_crop_fraction    SAGE        ${RESOLUTION}+ LT annual)";      (( ++DataNum ))
DATASOURCES[${DataNum}]="CropFraction_03               static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ other_crop_fraction         SAGE        ${RESOLUTION}+ LT annual)";      (( ++DataNum ))
DATASOURCES[${DataNum}]="CropFraction_04               static  Disturbed     file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ rice_crop_fraction          SAGE        ${RESOLUTION}+ LT annual)";      (( ++DataNum ))

#DATASOURCES[${DataNum}]="ContributingArea    		   static  Common       file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ contributing_area    ETOPO1 ${RESOLUTION}+ static)";      (( ++DataNum ))
#DATASOURCES[${DataNum}]="Elevation    		   		   static  Common       file  $(RGISfile ${RGISARCHIVE} ${DOMAIN}+ dem			ETOPO1stn ${RESOLUTION}+ static)";      (( ++DataNum ))

(( OptNum  = 0 ))
OPTIONS[${OptNum}]="CropParameterFileName   ${CROPFILE}";       (( ++OptNum ))
OPTIONS[${OptNum}]="Model                   BQARTpreprocess";      (( ++OptNum )) #changed from "balance" (S.C) then from "sedimentflux" then from "BQARTinputs" (8/9/10)
OPTIONS[${OptNum}]="Discharge               calculate";         (( ++OptNum ))
OPTIONS[${OptNum}]="DischargeMean           calculate";         (( ++OptNum ))
OPTIONS[${OptNum}]="DoubleCropping          FirstSeason";       (( ++OptNum ))
OPTIONS[${OptNum}]="GroundWaterBETA         0.01666667";        (( ++OptNum ))
OPTIONS[${OptNum}]="InfiltrationFraction    0.5";               (( ++OptNum ))
OPTIONS[${OptNum}]="Muskingum               static";            (( ++OptNum ))
OPTIONS[${OptNum}]="Precipitation           fraction";             (( ++OptNum )) #Changed
OPTIONS[${OptNum}]="RainInterception        none";              (( ++OptNum ))
OPTIONS[${OptNum}]="RainInfiltration        simple";            (( ++OptNum ))
OPTIONS[${OptNum}]="RainPET                 Hamon";             (( ++OptNum ))
OPTIONS[${OptNum}]="Riverbed                slope-independent"; (( ++OptNum ))
OPTIONS[${OptNum}]="Routing                 muskingum";         (( ++OptNum ))
OPTIONS[${OptNum}]="Runoff                  calculate";         (( ++OptNum ))
OPTIONS[${OptNum}]="RunoffVolume            calculate";         (( ++OptNum ))
OPTIONS[${OptNum}]="SoilMoisture            bucket";            (( ++OptNum ))
OPTIONS[${OptNum}]="SoilTemperature         none";              (( ++OptNum ))
OPTIONS[${OptNum}]="SoilMoistureALPHA       5.0";               (( ++OptNum ))
OPTIONS[${OptNum}]="SoilWaterCapacity       calculate";         (( ++OptNum ))
OPTIONS[${OptNum}]="WetlandAreaFraction     none";              (( ++OptNum ))
OPTIONS[${OptNum}]="SedimentFlux       calculate";              (( ++OptNum )) #new !!!! (S.C)

(( OutNum  = 0 ))
#OUTPUTS[${OutNum}]="Discharge";                                 (( ++OutNum ))
#OUTPUTS[${OutNum}]="Evapotranspiration";                        (( ++OutNum ))
#OUTPUTS[${OutNum}]="GroundWaterChange";                         (( ++OutNum ))
#OUTPUTS[${OutNum}]="RainPET";                                   (( ++OutNum ))
#OUTPUTS[${OutNum}]="Runoff";                                    (( ++OutNum ))
#OUTPUTS[${OutNum}]="SnowPackChange";                            (( ++OutNum ))
#OUTPUTS[${OutNum}]="SoilMoisture";                              (( ++OutNum ))
#OUTPUTS[${OutNum}]="SoilMoistureChange";                        (( ++OutNum ))
#OUTPUTS[${OutNum}]="RelativeSoilMoisture";                      (( ++OutNum ))
#OUTPUTS[${OutNum}]="SurfaceRunoff";                             (( ++OutNum ))
#OUTPUTS[${OutNum}]="WaterBalance";                              (( ++OutNum ))
#OUTPUTS[${OutNum}]="SedimentFlux";                              (( ++OutNum )) #NEW !!!!!!! (S.C)
#OUTPUTS[${OutNum}]="SedimentAcc";                              (( ++OutNum )) #NEW !!!!!!! (S.C)
OUTPUTS[${OutNum}]="BQART_A";                          (( ++OutNum )) #NEW !!!!!!! (S.C)
#OUTPUTS[${OutNum}]="BQART_B";                              (( ++OutNum )) #NEW !!!!!!! (S.C)
#OUTPUTS[${OutNum}]="BQART_R";           		                (( ++OutNum )) #NEW !!!!!!! (S.C)
#OUTPUTS[${OutNum}]="BQART_T";           		                (( ++OutNum )) #NEW !!!!!!! (S.C)
#OUTPUTS[${OutNum}]="Qbar";           		                (( ++OutNum )) #NEW !!!!!!! (S.C)
#OUTPUTS[${OutNum}]="BQART_Qbar_km3y";           		                (( ++OutNum )) #NEW !!!!!!! (S.C)
OUTPUTS[${OutNum}]="DischargeAcc";           		                (( ++OutNum )) #NEW !!!!!!! (S.C)
OUTPUTS[${OutNum}]="AirTempAcc_time";           		                (( ++OutNum )) #NEW !!!!!!! (S.C)
OUTPUTS[${OutNum}]="TimeSteps";           		                (( ++OutNum )) #NEW !!!!!!! (S.C)
OUTPUTS[${OutNum}]="DischargeMean";					 (( ++OutNum )) #NEW !!!!!!! (S.C)
#OUTPUTS[${OutNum}]="BQART_Qbar_m3s";					 (( ++OutNum )) #NEW !!!!!!! (S.C)
#OUTPUTS[${OutNum}]="MaxElevation";					 (( ++OutNum )) #NEW !!!!!!! (S.C)
if [[ "${DISTURBED}" == "on" ]]
then
	OPTIONS[${OptNum}]="IrrigatedAreaMap        ${IRRMAP}";      (( ++OptNum ))
	OPTIONS[${OptNum}]="Irrigation              calculate";      (( ++OptNum ))
	OPTIONS[${OptNum}]="IrrReferenceETP         Hamon";          (( ++OptNum ))
	OPTIONS[${OptNum}]="IrrUptakeRiver          calculate";      (( ++OptNum ))
	OPTIONS[${OptNum}]="IrrUptakeGrdWater       calculate";      (( ++OptNum ))
	OPTIONS[${OptNum}]="Reservoirs              calculate";      (( ++OptNum ))
	OPTIONS[${OptNum}]="SmallReservoirCapacity  calculate";      (( ++OptNum ))

	#OUTPUTS[${OutNum}]="IrrGrossDemand";                         (( ++OutNum ))
	#OUTPUTS[${OutNum}]="IrrReturnFlow";                          (( ++OutNum ))
	#OUTPUTS[${OutNum}]="IrrUptakeExcess";                        (( ++OutNum ))
	#OUTPUTS[${OutNum}]="IrrUptakeExternal";                      (( ++OutNum ))
	#OUTPUTS[${OutNum}]="IrrUptakeGroundWater";                   (( ++OutNum ))
	#OUTPUTS[${OutNum}]="IrrUptakeRiver";                         (( ++OutNum ))
	#OUTPUTS[${OutNum}]="ReservoirStorage";                       (( ++OutNum ))

	#OUTPUTS[${OutNum}]="SmallReservoirStorage";                  (( ++OutNum ))
	#OUTPUTS[${OutNum}]="SmallReservoirStorageChange";            (( ++OutNum ))
	#OUTPUTS[${OutNum}]="SmallReservoirCapacity";                 (( ++OutNum ))
	#OUTPUTS[${OutNum}]="IrrUptakeBalance";                       (( ++OutNum ))
	#OUTPUTS[${OutNum}]="IrrWaterBalance";                        (( ++OutNum ))
else
	OPTIONS[${OptNum}]="Irrigation              none";           (( ++OptNum ))
	OPTIONS[${OptNum}]="Reservoirs              none";           (( ++OptNum ))
fi

echo "entering FwDataSrc"
#FwDataSrc     "${DATASOURCES[@]}" || exit -1
echo "Exited FwDataSrc. "
#read
echo "entering FwOptions"
#echo "OPTIONS array: " ${OPTIONS[@]}
#FwOptions         "${OPTIONS[@]}" || exit -1 
echo "Exited FwOptions. "
#read
echo "entering FwOutputs"
#echo "OUTPUT array: " ${OUTPUTS[@]}
#FwOutputs         "${OUTPUTS[@]}" || exit -1
echo "Exited FwOutputs."
#read
echo "entering FwRun"
#FwRun  "${EXPERIMENT}" "${STARTYEAR}" "${ENDYEAR}" || exit -1


#Copy and rename output files needed for the BQART daily run model

mkdir -p ${OUTPUTSEXPORT}/AirTempAcc_time/BQART/${RESOLUTION}/Static/
cp -f ${RGISRESULTS}/${DOMAIN}/AirTempAcc_time/${DOMAIN}_AirTempAcc_time_${EXPERIMENT}_${RESOLUTION}_aTS${ENDYEAR}.gdbc ${OUTPUTSEXPORT}/AirTempAcc_time/BQART/${RESOLUTION}/Static/${DOMAIN}_AirTempAcc_time_BQART_${RESOLUTION}_Static.gdbc
grdDateLayers -e year ${OUTPUTSEXPORT}/AirTempAcc_time/BQART/${RESOLUTION}/Static/${DOMAIN}_AirTempAcc_time_BQART_${RESOLUTION}_Static.gdbc ${OUTPUTSEXPORT}/AirTempAcc_time/BQART/${RESOLUTION}/Static/${DOMAIN}_AirTempAcc_time_BQART_${RESOLUTION}_Static.gdbc
 
mkdir -p ${OUTPUTSEXPORT}/TimeSteps/BQART/${RESOLUTION}/Static/
cp -f ${RGISRESULTS}/${DOMAIN}/TimeSteps/${DOMAIN}_TimeSteps_${EXPERIMENT}_${RESOLUTION}_aTS${ENDYEAR}.gdbc ${OUTPUTSEXPORT}/TimeSteps/BQART/${RESOLUTION}/Static/${DOMAIN}_TimeSteps_BQART_${RESOLUTION}_Static.gdbc
grdDateLayers -e year ${OUTPUTSEXPORT}/TimeSteps/BQART/${RESOLUTION}/Static/${DOMAIN}_TimeSteps_BQART_${RESOLUTION}_Static.gdbc ${OUTPUTSEXPORT}/TimeSteps/BQART/${RESOLUTION}/Static/${DOMAIN}_TimeSteps_BQART_${RESOLUTION}_Static.gdbc

mkdir -p ${OUTPUTSEXPORT}/DischargeAcc/BQART/${RESOLUTION}/Static/
cp -f ${RGISRESULTS}/${DOMAIN}/DischargeAcc/${DOMAIN}_DischargeAcc_${EXPERIMENT}_${RESOLUTION}_aTS${ENDYEAR}.gdbc ${OUTPUTSEXPORT}/DischargeAcc/BQART/${RESOLUTION}/Static/${DOMAIN}_DischargeAcc_BQART_${RESOLUTION}_Static.gdbc
grdDateLayers -e year ${OUTPUTSEXPORT}/DischargeAcc/BQART/${RESOLUTION}/Static/${DOMAIN}_DischargeAcc_BQART_${RESOLUTION}_Static.gdbc ${OUTPUTSEXPORT}/DischargeAcc/BQART/${RESOLUTION}/Static/${DOMAIN}_DischargeAcc_BQART_${RESOLUTION}_Static.gdbc


#echo "Converting to output NetCDF"
./rgis2netcdf.sh ${RGISRESULTS} ${RGISRESULTS}
./rgisDelete.sh ${RGISRESULTS} ${RGISRESULTS}
rm -r ../GDS
# Runing the BQARTdaily.sh file (phase2)
#./BQARTdaily.sh NAmerica 06min dist
