
NAME=$1
SET=$2
TOOL=$3

mkdir -p results_peaks/$TOOL results_peaks/$TOOL/$SET
mkdir -p log/pc log/pc/$TOOL

files=$(ls results_peaks/$TOOL/$SET/*/*.bed 2> /dev/null | wc -l)
if [ "$files" = "0" ]; then

  echo "running peak calling tool: $TOOL with: $1 $2 $3" #$4 $5 $6 $7 $8 $9"
  
  cd results_peaks/$TOOL/$SET/
  
  LOG="../../../log/pc/$TOOL/$SET.log"
  RESULTSDIR="../../../results_peaks/$TOOL/$SET"
  
  mkdir s1 i1 s2 i2 r1 r2 chr
  
  bamToBed -i $4 > s1/S11.bed
  bamToBed -i $5 > s1/S12.bed
  bamToBed -i $6 > i1/IN1.bed
  
  bamToBed -i $7 > s2/S21.bed
  bamToBed -i $8 > s2/S22.bed
  bamToBed -i $9 > i2/IN2.bed
  
  #get right chr size
  CHROM=$(echo $NAME | grep -o "_chr[a-zA-Z]\{1\}\|_chr[1-9]\{1,2\}_" | sed "s/_//g")
  grep ${CHROM} /proj/chipseq_norm_diffbind_062017/analysis/18_simulating_add_chrom-frips/data/mm10_chrsize.bed | sed "s/mm_//" | cut -f1,3 > chr/chromsize.txt
  
  #sharp
  PCRUN=$RESULTSDIR"/sharp"
  mkdir -p $PCRUN
  
  #bash /apps/JAMM-JAMMv1.0.7.6/JAMM.sh -s s1 -c i1 -g /ssd/references/THOR/mm10/chr19.chrom.size -o r1 -r peak >> $LOG 2>&1
  #use all specific chromosomes of this set instead of only chr19
  bash /apps/JAMM-JAMMv1.0.7.6/JAMM.sh -s s1 -c i1 -g chr/chromsize.txt -o r1 -r peak >> $LOG 2>&1
  cat r1/peaks/filtered.peaks.narrowPeak | cut -f1,2,3,7 > $PCRUN/s11_peaks.bed #chr start stop and score
  cat r1/peaks/filtered.peaks.narrowPeak | cut -f1,2,3,7 > $PCRUN/s12_peaks.bed
  #clean up
  rm -rf r1/* 
  
  #bash /apps/JAMM-JAMMv1.0.7.6/JAMM.sh -s s2 -c i2 -g /ssd/references/THOR/mm10/chr19.chrom.size -o r2 -r peak >> $LOG 2>&1
  bash /apps/JAMM-JAMMv1.0.7.6/JAMM.sh -s s2 -c i2 -g chr/chromsize.txt -o r2 -r peak >> $LOG 2>&1
  cat r2/peaks/filtered.peaks.narrowPeak | cut -f1,2,3,7 > $PCRUN/s21_peaks.bed
  cat r2/peaks/filtered.peaks.narrowPeak | cut -f1,2,3,7 > $PCRUN/s22_peaks.bed
  #clean up
  rm -rf r2/*
  

  #broad
  PCRUN=$RESULTSDIR"/broad"
  mkdir -p $PCRUN
  
  #bash /apps/JAMM-JAMMv1.0.7.6/JAMM.sh -s s1 -c i1 -g /ssd/references/THOR/mm10/chr19.chrom.size -o r1 -r window -b 1000 -w 1 >> $LOG 2>&1
  bash /apps/JAMM-JAMMv1.0.7.6/JAMM.sh -s s1 -c i1 -g chr/chromsize.txt -o r1 -r window -b 1000 -w 1 >> $LOG 2>&1
  cat r1/peaks/filtered.peaks.narrowPeak | cut -f1,2,3,7 > $PCRUN/s11_peaks.bed
  cat r1/peaks/filtered.peaks.narrowPeak | cut -f1,2,3,7 > $PCRUN/s12_peaks.bed
  #clean up
  rm -rf r1/* 
   
  #bash /apps/JAMM-JAMMv1.0.7.6/JAMM.sh -s s2 -c i2 -g /ssd/references/THOR/mm10/chr19.chrom.size -o r2 -r window -b 1000 -w 1 >> $LOG 2>&1
  bash /apps/JAMM-JAMMv1.0.7.6/JAMM.sh -s s2 -c i2 -g chr/chromsize.txt -o r2 -r window -b 1000 -w 1 >> $LOG 2>&1
  cat r2/peaks/filtered.peaks.narrowPeak | cut -f1,2,3,7 > $PCRUN/s21_peaks.bed
  cat r2/peaks/filtered.peaks.narrowPeak | cut -f1,2,3,7 > $PCRUN/s22_peaks.bed
  #clean up
  rm -rf r2/*
  

  rm -rf i1 i2 r1 r2 s1 s2 chr
  
else
  echo "results_peaks/$TOOL/$SET/bed already exists exiting..."
fi
