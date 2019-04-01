#!/bin/bash

## Performance without new experiences generated by DDPG
## On a filtered replay buffer

PARALLEL_MAX=16

MEAN_BATCH_SIZE=8

POLICY_NAME="DDPG"

LEARNING_TIMESTEPS=40000

EVAL_FREQ=2000

DIMENSION=2

BUFFER_SIZE=4096

EXPLORATION_MODE="sequential"

FILTER_POS=1

ROOT_DIR="$(pwd)/"

RESULT_DIR="results-corner-sequential/"

TITLE="filter size"

X_LABEL="filter size"

Y_LABEL="reward/step"


run_training()
{
  OUTPUT_DIR="${ROOT_DIR}${RESULT_DIR}${POLICY_NAME}_n${1}_${2}"

  COMMAND="python ../../learn_multidimensional.py\
    --policy_name=${POLICY_NAME}\
    --exploration_timesteps=${BUFFER_SIZE}\
    --learning_timesteps=${LEARNING_TIMESTEPS}\
    --buffer_size=${BUFFER_SIZE}\
    --eval_freq=${EVAL_FREQ}\
    --dimensions=${DIMENSION}\
    --save\
    --no-render\
    --no-new-exp\
    --exploration_mode=${EXPLORATION_MODE}\
    --output=${OUTPUT_DIR}\
    --filter\
    --filter_pos=${FILTER_POS}\
    --filter_radius=${1}"

  eval ${COMMAND}
}


PARALLEL=0
PIDS=()

for i in "0" "0.2" "0.4" "0.6" "0.8" "1"
do
    for j in $(seq 0 $(($MEAN_BATCH_SIZE-1)))
    do
	echo "Training $i $j"
	run_training $i $j &
	PIDS[$j]=$!

        PARALLEL=$(($PARALLEL+1))
        if [ $PARALLEL -ge $PARALLEL_MAX ]
        then
            PARALLEL=0
	    wait ${PIDS[@]}
	    PIDS=()
        fi
    done
done
wait ${PIDS[@]}

COMMAND2="python ../plot_evaluations.py\
    --directory=$RESULT_DIR\
    --batch_size=$MEAN_BATCH_SIZE\
    --title='$TITLE'\
    --x_label='$X_LABEL'\
    --y_label='$Y_LABEL'\
    --log_scale"

eval ${COMMAND2}

COMMAND3="python ../plot_average_q.py\
    --directory=$RESULT_DIR\
    --batch_size=$MEAN_BATCH_SIZE\
    --learning_timesteps=$LEARNING_TIMESTEPS\
    --eval_freq=$EVAL_FREQ\
    --title='$TITLE'"

eval ${COMMAND3}

COMMAND4="python ../plot_average_pi.py\
    --directory=$RESULT_DIR\
    --batch_size=$MEAN_BATCH_SIZE\
    --learning_timesteps=$LEARNING_TIMESTEPS\
    --eval_freq=$EVAL_FREQ\
    --title='$TITLE'"

eval ${COMMAND4}

COMMAND5="python ../plot_average_learning_curve.py\
    --directory=$RESULT_DIR\
    --batch_size=$MEAN_BATCH_SIZE\
    --eval_freq=$EVAL_FREQ\
    --title='$TITLE'"

eval ${COMMAND5}