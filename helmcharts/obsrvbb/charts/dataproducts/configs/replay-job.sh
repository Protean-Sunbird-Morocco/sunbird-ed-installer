#!/usr/bin/env bash
DATA_DIR=/data/analytics/logs/data-products
[[ -d $DATA_DIR ]] || mkdir -p $DATA_DIR
export SPARK_HOME={{ .Values.global.spark_home }}
export MODELS_HOME={{ .Values.analytics.home }}/models-{{ .Values.model_version }}
export DP_LOGS=$DATA_DIR

cd {{ .Values.analytics.home }}/scripts
source model-config.sh
source replay-utils.sh

libs_path="{{ .Values.analytics.home }}/models-{{ .Values.model_version }}/data-products-1.0"

if [ "$1" == "telemetry-replay" ]
    then
    if [ ! $# -eq 5 ]
        then
        echo "Not suffecient arguments. killing process"
        exit
    fi
fi

get_report_job_model_name(){
    case "$1" in
        "assessment-correction") echo 'org.sunbird.analytics.job.report.AssessmentCorrectionJob'
        ;;
        *) echo $1
        ;;
    esac
}

if [ ! -z "$1" ]; then job_id=$(get_report_job_model_name $1); fi
if [ -z "$job_config" ]; then job_config=$(config $1 '__endDate__' $4 $5); fi
start_date=$2
end_date=$3
backup_key=$1

if [ "$1" == "gls-v1" ]
	then
	backup_key="gls"
elif [ "$1" == "app-ss-v1" ] 
	then
	backup_key="app-ss"	
fi

backup $start_date $end_date {{ .Values.bucket }} "derived/$backup_key" "derived/backup-$backup_key" >> "$DP_LOGS/$end_date-$1-replay.log"
if [ $? == 0 ]
 	then
  	echo "Backup completed Successfully..." >> "$DP_LOGS/$end_date-$1-replay.log"
  	echo "Running the $1 job replay..." >> "$DP_LOGS/$end_date-$1-replay.log"
  	echo "Job modelName - $job_id" >> "$DP_LOGS/$end_date-$1-replay.log"
  	$SPARK_HOME/bin/spark-submit --master local[*] --jars $(echo ${libs_path}/lib/*.jar | tr ' ' ','),$MODELS_HOME/analytics-framework-2.0.jar,$MODELS_HOME/scruid_2.12-2.5.0.jar --class org.ekstep.analytics.job.ReplaySupervisor $MODELS_HOME/batch-models-2.0.jar --model "$job_id" --fromDate "$start_date" --toDate "$end_date" --config "$job_config" >> "$DP_LOGS/$end_date-$1-replay.log"
else
  	echo "Unable to take backup" >> "$DP_LOGS/$end_date-$1-replay.log"
fi

if [ $? == 0 ]
	then
	echo "$1 replay executed successfully" >> "$DP_LOGS/$end_date-$1-replay.log"
	delete "{{ .Values.global.public_container_name }}/telemetry-data-store" "derived/backup-$backup_key" >> "$DP_LOGS/$end_date-$1-replay.log"
else
	echo "$1 replay failed" >> "$DP_LOGS/$end_date-$1-replay.log"
 	rollback "{{ .Values.global.public_container_name }}/telemetry-data-store"  "derived/$backup_key" "backup-$backup_key" >> "$DP_LOGS/$end_date-$1-replay.log"
 	delete "{{ .Values.global.public_container_name }}/telemetry-data-store" "derived/backup-$backup_key" >> "$DP_LOGS/$end_date-$1-replay.log"
fi