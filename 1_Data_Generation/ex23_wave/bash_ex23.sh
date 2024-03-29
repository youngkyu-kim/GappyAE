#!/bin/bash
#SBATCH -N 1
#SBATCH -J bash_ex23
#SBATCH -t 2:00:00
#SBATCH -p pbatch
#SBATCH -o bash_ex23.log
#SBATCH --open-mode truncate

source ../lasdi_venv/bin/activate

MFEM_DIR="../dependencies/mfem/examples"

cp ex23.cpp $MFEM_DIR
cp makefile_ex23 "$MFEM_DIR"
cp interp_to_numpy_23.py "$MFEM_DIR"

cd "$MFEM_DIR"
rm ex23_interp_*.npz
rm -rf ex23_sim
mkdir ex23_sim
make ex23 -f makefile_ex23
rm -rf ~/LaSDI/ex23_wave/timeit_FOM.txt

for i in $(seq 75 1 125)
#for i in $(seq 75 1 75)
do
	echo $i >> ~/LaSDI/ex23_wave/timeit_FOM.txt
        rm -rf ex23_sim/* 
	# if [ $i = 100 ]; then
	# 	start_time=$(date +%s.%3N)
	# 	./ex23 -m ../data/inline-quad.mesh -r 4 -o 4 -s 10 -tf 5.0 -dt 1.0e-2 -c $( echo "scale=2; $i/100" | bc ) -neu -vs 1
	# 	end_time=$(date +%s.%3N)
	# 	echo "scale=3; $end_time - $start_time" | bc > ~/LaSDI/ex23_wave/timeit_FOM.txt
	# else
	# 	./ex23 -m ../data/inline-quad.mesh -r 4 -o 4 -s 10 -tf 5.0 -dt 1.0e-2 -c $( echo "scale=2; $i/100" | bc ) -neu -vs 1
	# fi
	start_time=$(date +%s.%3N)
	./ex23 -m ../data/inline-quad.mesh -r 4 -o 3 -s 10 -tf 5.0 -dt 1.0e-2 -c $( echo "scale=2; $i/100" | bc ) -neu -vs 1
	# ./ex23 -m ../data/inline-quad.mesh -r 4 -o 4 -s 10 -tf 5.0 -dt 1.0e-2 -c $( echo "scale=2; $i/100" | bc ) -neu -vs 1
	end_time=$(date +%s.%3N)
	echo "scale=3; $end_time - $start_time" | bc >> ~/LaSDI/ex23_wave/timeit_FOM.txt	
	mv -f Example23* ex23_sim
    mv -f ex23*gf ex23_sim
	mv -f ex23.mesh ex23_sim
	python interp_to_numpy_23.py $i
done

make clean
cd ../../../ex23_wave/
rm -rf data
mkdir data
mv -f $MFEM_DIR/ex23_interp_*.npz ./data/
