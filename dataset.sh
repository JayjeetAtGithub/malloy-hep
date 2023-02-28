#!/bin/bash
set -ex

rm -rf /mnt/data/*
mkdir -p /mnt/data
for i in {1..10000};
do
	cp hep.parquet /mnt/data/hep.${i}.parquet
done
