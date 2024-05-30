trap 'echo "# $BASH_COMMAND"' DEBUG

#Parameters 
data=$(realpath "$1")
level=$2
nameOutput=$3
nbRuns="1"
sc="$4"
#values
promesse="$6"
geoi="$7"
trl=$8
flag=$9
workdir="$5$3_$flag"

mkdir "$workdir"

tri="tri-$flag-$nameOutput-split-range-$trl"

mkdir "$tri"

mv "$tri" "$workdir/$tri"
cd ..


##*********** DATA preparation for accio***********###
######################################################


python "$sc/"prepareTraceForAccio.py $data "$workdir/data-accio" "geo"
urlData=$(realpath "$workdir/data-accio/")
possibleLog="$workdir""/log-XXXXXXXXXXX.txt"

echo $urlData

 #1- apply GEOI (LPPM)

echo "*******geoi*******"
json_geoi="$sc/json/geoi.json"
loggeoi=$(mktemp $possibleLog) 
java -jar "$sc/"accio2.jar run -workdir $workdir -params "url=$urlData"  $json_geoi >> $loggeoi  
path_geoi=$(bash "$sc/"getPath.sh $loggeoi $workdir "GeoIndistinguishability/data")
echo "$path_geoi"
python "$sc/"formatData_To_FeatureVectors.py "$path_geoi" $level "$workdir/geoi-$flag-$nameOutput-split-level-$level.csv" 

echo "**************Distortion in GEOI *****************"
json_sdistgeoi="$sc/json/spatialTemporalDistortion.json"
log_sdistgeoi=$(mktemp $possibleLog)
java -jar "$sc/"accio2.jar run -workdir $workdir -params "urltrain=$urlData urltest=$path_geoi"  $json_sdistgeoi >> $log_sdistgeoi
bash "$sc/"getCsv.sh $log_sdistgeoi $workdir "SpatioTemporalDistortiongeoi/avg" "$workdir/$flag-dist-spatio-temporal-geoi-$geoi.csv"

echo "**************Distortion2 in GEOI *****************"
json_sdistgeoi2="$sc/json/areaCoverage.json"
log_sdistgeoi2=$(mktemp $possibleLog)
java -jar "$sc/"accio2.jar run -workdir $workdir -params "urltrain=$urlData urltest=$path_geoi"  $json_sdistgeoi2 >> $log_sdistgeoi2
bash "$sc/"getCsv.sh $log_sdistgeoi2 $workdir "AreaCoverageMatrix/writtenStats" "$workdir/$flag-dist-area-coverage-geoi-$geoi.csv"
       

##2- apply promesse (LPPM)
# echo "******promesse******"
# run_output="$workdir/run-1"

# json_promesse="$sc/json/promesse.json" 
# logpromesse=$(mktemp $possibleLog) 
# java -jar "$sc/"accio2.jar run -workdir $workdir -params "url=$urlData"  $json_promesse >> $logpromesse
# path_promesse=$(bash "$sc/"getPath.sh $logpromesse $workdir "Promesse/data")
# python "$sc/"formatData_To_FeatureVectors.py "$path_promesse" $level  "$workdir/promesse-train-$nameOutput-split-$split-level-$level.csv" 

# echo "**************Distortion in promesse *****************"
# json_sdistpro="$sc/spatialTemporalDistortion.json"
# log_sdistpro=$(mktemp $possibleLog)
# java -jar "$sc/"accio2.jar run -workdir $workdir -params "urltrain=$urlData urltest=$path_promesse"  $json_sdistpro >> $log_sdistpro
# bash "$sc/"getCsv.sh $log_sdistpro $workdir "SpatioTemporalDistortiongeoi/avg" "$workdir/train-dist-spatio-temporal-promesse-$promesse.csv"

# echo "**************Distortion2 in promesse *****************"
# json_sdistpro2="$sc/areaCoverage.json"
# log_sdistpro2=$(mktemp $possibleLog)
# java -jar "$sc/"accio2.jar run -workdir $workdir -params "urltrain=$urlData urltest=$path_promesse"  $json_sdistpro2 >> $log_sdistpro2
# bash "$sc/"getCsv.sh $log_sdistpro2 $workdir "AreaCoverageMatrix/writtenStats" "$workdir/train-dist-area-coverage-promesse-$promesse.csv"

##3- apply TRL (LPPM)
echo "********Trilateration********"
pathTri="$workdir/tri-$flag-$nameOutput-split-range-$trl/"
echo "$pathTri"
python "$sc/"prepareTraceForTrilateration.py $data "$workdir/data-trilateration"
java -jar "$sc/"trilaterationv3.jar "$workdir/data-trilateration/" $pathTri 0.6 $trl
python "$sc/"formatData_To_FeatureVectors.py  $pathTri $level  "$workdir/tri-$flag-$nameOutput-split-level-$level-range-$trl.csv" 

## we measure the spatial temporal distortion using accio:
echo "**************Distortion measuring*****************"
python "$sc/"prepareTraceForAccio.py $pathTri "$workdir/tri-accio" "trilateration"
urlTestTri=$(realpath "$workdir/tri-accio")
json_sdist="$sc/json/spatialTemporalDistortion.json"
log_sdist=$(mktemp $possibleLog)
java -jar "$sc/"accio2.jar run -workdir $workdir -params "urltrain=$urlData urltest=$urlTestTri"  $json_sdist >> $log_sdist
bash "$sc/"getCsv.sh $log_sdist $workdir "SpatioTemporalDistortiongeoi/avg" "$workdir/$flag-dist-spatio-temporal-trl-$trl.csv"

echo "**************Distortion2 measuring*****************"
json_sdist2="$sc/json/areaCoverage.json"
log_sdist2=$(mktemp $possibleLog)
java -jar "$sc/"accio2.jar run -workdir $workdir -params "urltrain=$urlData urltest=$urlTestTri"  $json_sdist2 >> $log_sdist2
bash "$sc/"getCsv.sh $log_sdist2 $workdir "AreaCoverageMatrix/writtenStats" "$workdir/$flag-dist-area-coverage-trl-$trl.csv"
