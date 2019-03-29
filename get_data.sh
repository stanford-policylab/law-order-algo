#!/usr/bin/env sh

# Created: 2019-01-28
# Description: Download data necessary for notebooks

mkdir -p data
curl -L -o data/sqf_sample.rds "https://drive.google.com/uc?export=download&id=1yW-l-3atdKphyPlPPjZGDO9VaHMfwMh4"
curl -L -o data/bar_passage_data.csv "https://drive.google.com/uc?export=download&id=1mOE1s2MFxReEHqVmR829mUpfKzJS7Com"
