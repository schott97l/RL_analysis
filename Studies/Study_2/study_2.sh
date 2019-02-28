#!/bin/sh

## Performance en fonction de la taille du buffer

PARALLEL_MAX=10

MEAN_BATCH_SIZE=10

POLICY_NAME="DDPG"

EXPLORATION_TIMESTEPS=1000

LEARNING_TIMESTEPS=20000

MIN_BUFFER=1000

BUFFER_INCREASE_STEP=0

MAX_BUFFER=1000

EVAL_FREQ=1000

DIMENSION=2

ROOT_DIR="$(pwd)/"

RESULT_DIR="results/"

MODE="velocity"

TITLE="Performance d apprentissage en fonction de la taille du replay buffer"

X_LABEL="Taille du replay buffer"

Y_LABEL="Reward moyen par step"


run_training()
{
  OUTPUT_DIR="${ROOT_DIR}${RESULT_DIR}${POLICY_NAME}_n$1_$2"

  COMMAND="python ../../learn_multidimensional.py\
    --policy_name=$POLICY_NAME\
    --exploration_timesteps=$EXPLORATION_TIMESTEPS\
    --learning_timesteps=$LEARNING_TIMESTEPS\
    --buffer_size=$1\
    --eval_freq=$EVAL_FREQ\
    --dimensions=$DIMENSION\
    --${MODE}\
    --save\
    --no-render\
    --no-new-exp\
    --output=${OUTPUT_DIR}"

  eval ${COMMAND} &
}


PARALLEL=0

for i in $(seq $MIN_BUFFER $BUFFER_INCREASE_STEP $MAX_BUFFER)
do
    for j in $(seq 0 $(($MEAN_BATCH_SIZE-1)))
    do
        PARALLEL=$(($PARALLEL+1))
        if [ $PARALLEL -ge $PARALLEL_MAX ]
        then
            echo "Training $i $j"
            run_training $i $j
            PARALLEL=0
        else
            echo "Training $i $j"
            run_training $i $j &
        fi
    done
done


COMMAND2="python ../plot_evaluations.py\
    --directory=$RESULT_DIR\
    --policy_name=$POLICY_NAME\
    --batch_size=$MEAN_BATCH_SIZE\
    --title='$TITLE'\
    --x_label='$X_LABEL'\
    --y_label='$Y_LABEL'"

eval ${COMMAND2}
