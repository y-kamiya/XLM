#!/bin/bash -e

CODES=60000     # number of BPE codes
SPM_CHARACTER_COVERAGE=1.0
SPM_N_SENTENCES=1000000
SPM_VOCAB_THRESHOLD=50

MAIN_PATH=$PWD
DATA_PATH=$PWD/data
MONO_PATH=$DATA_PATH/mono
PROC_PATH=$DATA_PATH/processed/vocab
TOOLS_PATH=$PWD/tools
MOSES=$TOOLS_PATH/mosesdecoder

REPLACE_UNICODE_PUNCT=$MOSES/scripts/tokenizer/replace-unicode-punctuation.perl
NORM_PUNC=$MOSES/scripts/tokenizer/normalize-punctuation.perl
REM_NON_PRINT_CHAR=$MOSES/scripts/tokenizer/remove-non-printing-char.perl

SPM_TRAIN=$TOOLS_PATH/sentencepiece/build/src/spm_train
SPM_ENCODE=$TOOLS_PATH/sentencepiece/build/src/spm_encode
SPM_INPUT_PATH=$PROC_PATH/spm_input
FULL_VOCAB=$PROC_PATH/vocab

mkdir -p $PROC_PATH

langs=$@

function preprocess()
{
    lang=$1
    input=$2
    output=$3
    cat $input | $REPLACE_UNICODE_PUNCT | $NORM_PUNC -l $lang | $REM_NON_PRINT_CHAR > $output
}

norms=()
for lang in $langs; do
    preprocess $lang $MONO_PATH/$lang/all.$lang $PROC_PATH/$lang.norm
    cat $PROC_PATH/$lang.norm | head -n $SPM_N_SENTENCES >> $SPM_INPUT_PATH
    norms+=($PROC_PATH/$lang.norm)
done

pushd $PROC_PATH
if ! [[ -f "xlm.model" ]]; then
    echo "creating model file of sentencepiece"
    $SPM_TRAIN --input=$SPM_INPUT_PATH --model_prefix=xlm --vocab_size=$CODES --character_coverage=$SPM_CHARACTER_COVERAGE --model_type=unigram --control_symbols='<special0>,<special1>' --bos_id=0 --eos_id=1 --pad_id=2 --unk_id=3
fi

echo "creating vocabulary file"
cat ${norms[@]} | $SPM_ENCODE --model=xlm.model --generate_vocabulary > $FULL_VOCAB

echo "creating tokenized file of each lang"
for norm in ${norms[@]}; do
    lang=$(basename $norm .norm)
    cat $norm | $SPM_ENCODE --model=xlm.model --output_format=piece --vocabulary=$FULL_VOCAB --vocabulary_threshold=$SPM_VOCAB_THRESHOLD > $PROC_PATH/train.$lang
done

popd



