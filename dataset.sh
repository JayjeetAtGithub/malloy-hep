#!/bin/bash
set -ex

rm -rf /mnt/data/dataset
mkdir -p /mnt/data/dataset
for i in {1..10000};
do
	cp hep.parquet /mnt/data/dataset/hep.${i}.parquet
done
