#!/bin/bash
set -e 
set -u

##external call with 3 arguments (sequencer, run and workDir)

module list

ENVIRONMENT_PARAMETERS=parameters_gattaca.csv
SEQUENCER=$1
RUNNUMBER=${2}_${SEQUENCER}
WORKDIR=$3
GROUP=$4
WORKFLOW=${EBROOTNGS_DEMULTIPLEXING}/workflow.csv
echo "$WORKDIR AND $RUNNUMBER"
echo "GROUPIE: $GROUP"

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

mkdir -p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/

if [ -f ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/out.csv  ];
then
    	rm -rf ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/out.csv
fi

#
###### Dual barcode checker
#
sampsheet=${WORKDIR}/generatedscripts/run_${RUNNUMBER}/run_${RUNNUMBER}.csv

mac2unix ${sampsheet}

rm -f barcode2.isthere

## Will return or nothing or in case there is a dualbarcode it will create a file
sh ${EBROOTNGS_DEMULTIPLEXING}/combineBarcodes.sh ${sampsheet} ${EBROOTNGS_DEMULTIPLEXING}
if [ $? == 0 ]
then
	dualBarcode="FALSE"
	
	if [ -f barcode2.is.there ]
	then	
		dualBarcode="TRUE"
	fi
	#
	#######
	#
	perl ${EBROOTNGS_DEMULTIPLEXING}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEXING}/parameters.csv > \
	${WORKDIR}/generatedscripts/run_${RUNNUMBER}/out.csv

	perl ${EBROOTNGS_DEMULTIPLEXING}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEXING}/${ENVIRONMENT_PARAMETERS} > \
	${WORKDIR}/generatedscripts/run_${RUNNUMBER}/environment_parameters.csv

	perl ${EBROOTNGS_DEMULTIPLEXING}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEXING}/parameters_${GROUP}.csv > \
	${WORKDIR}/generatedscripts/run_${RUNNUMBER}/parameters_group.csv

	sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
	-p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/out.csv \
	-p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/parameters_group.csv \
	-p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/environment_parameters.csv \
	-p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/run_${RUNNUMBER}.csv \
	-w ${WORKFLOW} \
	-rundir ${WORKDIR}/runs/run_${RUNNUMBER}/jobs \
	-o "dualBarcode=${dualBarcode}" \
	-b slurm \
	-weave \
	--generate

fi
