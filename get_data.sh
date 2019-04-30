#!/usr/bin/env sh
# Created: 2019-01-28
# Description: Download data necessary for notebooks
mkdir -p data
curl -L -o data/sqf_sample.rds "https://drive.google.com/uc?export=download&id=1yW-l-3atdKphyPlPPjZGDO9VaHMfwMh4"
curl -L -o data/bar_passage_data.csv "https://drive.google.com/uc?export=download&id=1F93eEZlZqJL7yYKy2YSWvPdLWQbgKUs7"
curl -L -o data/kc_inspections.rds "https://drive.google.com/uc?export=download&id=1JnwWB9oh8Jw5dfh4HJfm3MXfegZW3tQC"
curl -L -o data/compas.rds "https://drive.google.com/uc?export=download&id=1sfaE9KxAeHPisaOtkwXOlN5YNy8jrrs5"
