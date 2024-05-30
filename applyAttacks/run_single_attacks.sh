trap 'echo "# $BASH_COMMAND"' DEBUG

xdays="$3"  # precise the background knowledge of the attack , e.g., 15days
dataset="$4"  # e.g., privamov
lppm="$5"   # which LPPM ? geoi, promesse or trl?
workdir="$6" # absolute path to save results
sc="$7"  # path to source code
input_file_path="$8"

mkdir -p "$workdir"

possibleLog="$workdir/log-AP-XXXXXXXXXXX.txt"
possibleLog1="$workdir/log-POI-XXXXXXXXXXX.txt"
possibleLog2="$workdir/log-PIT-XXXXXXXXXXX.txt"

# AP-attack 
cellSize="800.meters"
json_ap="$sc/ap-attack.json"
log_ap=$(mktemp "$possibleLog") 
python "$sc/prepareTraceForAccio.py" "$input_file_path/train_data/" "$workdir/data-accio/train_data/" "geo"
python "$sc/prepareTraceForAccio.py" "$input_file_path/test_data/" "$workdir/data-accio/test_data/" "geo"

java -jar "$sc/accio.jar" run -workdir "$workdir" "$json_ap" >> "$log_ap"
bash "$sc/getCsv.sh" "$log_ap" "$workdir" "MatMatchingKSetsnonObf/matches" "$workdir/$xdays-ap-$lppm.csv"

# POI-attack 
json_poi="$sc/poi-attack.json"
log_poi=$(mktemp "$possibleLog1") 
java -jar "$sc/accio.jar" run -workdir "$workdir" "$json_poi" >> "$log_poi"
bash "$sc/getCsv.sh" "$log_poi" "$workdir" "PoisReidentKSet/matches" "$workdir/$xdays-poi-$lppm.csv"

# PIT-attack
json_pit="$sc/pit-attack.json"
log_pit=$(mktemp "$possibleLog2") 
java -jar "$sc/accio.jar" run -workdir "$workdir" "$json_pit" >> "$log_pit"
bash "$sc/getCsv.sh" "$log_pit" "$workdir" "MMCReIdentKSet/matches" "$workdir/$xdays-pit-$lppm.csv"

echo "$dataset,$xdays,$lppm,AP-attack,$acc_ap" >> "$workdir/attacks.csv"  
echo "$dataset,$xdays,$lppm,POI-attack,$acc_poi" >> "$workdir/attacks.csv"  
echo "$dataset,$xdays,$lppm,PIT-attack,$acc_pit" >> "$workdir/attacks.csv"
