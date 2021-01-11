#!/bin/bash
#change all these to the volumes

INPUT_DIR=/INPUT
OUTPUT_DIR=/OUTPUT
GERMLINE_DIR=/GERMLINE


GERMLINE_BUILD_DIR=/GERMLINE_BUILD_DIR

mkdir -p $GERMLINE_BUILD_DIR


correct_usage()

{	
	/mixcrep/tools/correct_usage.txt

}


if [ -z "$1" ]

then 
	echo "SPECIES not provided. Will exit."
	correct_usage
	exit 2 
else
	SPECIES=$1
fi

if [ -z "$2" ] 

then 
	echo "RECEPTOR not provided. Will exit."
	correct_usage
	exit 2 
else
	RECEPTOR=$2
fi

collect_fastas()
{	
	the_path=$1
	the_output=$2
	the_pattern=$3

	FQ_LIST='find $the_path -t f -name "$the_pattern"'

	size=${#FQ_LIST}

}


collect_fastas $INPUT_DIR $INPUT_DIR "*.fasta"
#change so that you only copy the VDJ folder?
cp -R $GERMLINE_DIR/vdj $GERMLINE_BUILD_DIR
#create file for germline
mkdir $GERMLINE_BUILD_DIR/$RECEPTOR
#move to folder
cd /$GERMLINE_BUILD_DIR/vdj


grep -lir -i "$RECEPTOR" | xargs mv -t /$GERMLINE_BUILD_DIR/$RECEPTOR
#move to folder 
cd /$GERMLINE_BUILD_DIR/$RECEPTOR

#rename the files so they can be used by repseqio
#need to update IGH to receptro
mv $(find . -maxdepth 1 -name "*${RECEPTOR^^}D*" -print) d.fasta
mv $(find . -maxdepth 1 -name "*${RECEPTOR^^}J*" -print) j.fasta
mv $(find . -maxdepth 1 -name "*${RECEPTOR^^}V*" -print) v.fasta


#carry out repseqio steps
cd /mixcrep






#change to use the receptor
./repseqio/repseqio fromPaddedFasta -t 39442 -c $RECEPTOR --name-index 1 -g D --gene-feature DRegion /$GERMLINE_BUILD_DIR/$RECEPTOR/d.fasta ighd.fasta ighd.d.json
./repseqio/repseqio fromPaddedFasta -t 39442 -c $RECEPTOR --name-index 1 -g J --gene-feature JRegion /$GERMLINE_BUILD_DIR/$RECEPTOR/j.fasta ighj.fasta ighj.j.json
./repseqio/repseqio fromPaddedFasta -t 39442 -c $RECEPTOR --name-index 1 -g V --gene-feature VRegion /$GERMLINE_BUILD_DIR/$RECEPTOR/v.fasta ighv.fasta ighv.v.json

./repseqio/repseqio merge ighd.d.json ighj.j.json ighv.v.json lib2.json -f
./repseqio/repseqio inferPoints -g VRegion -g JRegion -g DRegion -f lib2.json lib2.json

cp /mixcrep/${RECEPTOR}d.fasta /mixcrep/mixcr-3.0.13/libraries
cp /mixcrep/${RECEPTOR}v.fasta /mixcrep/mixcr-3.0.13/libraries
cp /mixcrep/${RECEPTOR}j.fasta /mixcrep/mixcr-3.0.13/libraries


cp /mixcrep/lib2.json /mixcrep/mixcr-3.0.13/libraries

#mixcr alignemn
cd /mixcrep/mixcr-3.0.13
#change this input to the volume once mounted
mixcr align -f --write-all --library lib2 --species 39442 -O saveOriginalReads=true /../../INPUT/sample.fasta output.vdjca 

mixcr exportAlignments -descrsR1 -vHit -dHit -jHit -aaFeature CDR3 output.vdjca output.tsv -f

cp /mixcrep/mixcr-3.0.13/output.tsv $OUTPUT_DIR

