#!/bin/bash
#SBATCH -N 1
#SBATCH -J bash_ex9
#SBATCH -t 2:00:00
#SBATCH -p pbatch
#SBATCH -o bash_ex9.log
#SBATCH --open-mode truncate

source ../lasdi_venv/bin/activate

MFEM_DIR="../dependencies/mfem/examples"

cp lasdi_ex9.cpp $MFEM_DIR
cp makefile_ex9 "$MFEM_DIR"
cp interp_to_numpy_9.py "$MFEM_DIR"

cd "$MFEM_DIR"
rm ex9_interp_*.npz
rm -rf ex9_sim
mkdir ex9_sim
make lasdi_ex9 -f makefile_ex9
rm -rf ~/LaSDI/Radial\ Advection/timeit_FOM.txt

for i in $(seq 75 1 125)
do
	echo $i >> ~/LaSDI/Radial\ Advection/timeit_FOM.txt
        rm -rf ex9_sim/* 
	# if [ $i = 100 ]; then
	# 	start_time=$(date +%s.%3N)
	# 	./lasdi_ex9 -m ../data/periodic-square.mesh -p 3 -r 3 -tf 3 -dt 5.0e-3 -vs 1 -freq $((i/100)).$((i%100)) -visit
	# 	end_time=$(date +%s.%3N)
	# 	echo "scale=3; $end_time - $start_time" | bc > ~/LaSDI/Radial\ Advection/timeit_FOM.txt
	# else
	# 	./lasdi_ex9 -m ../data/periodic-square.mesh -p 3 -r 3 -tf 3 -dt 5.0e-3 -vs 1 -freq $((i/100)).$((i%100)) -visit
	# fi
	start_time=$(date +%s.%3N)
	./lasdi_ex9 -m ../data/periodic-square.mesh -p 3 -r 3 -tf 3 -dt 5.0e-3 -vs 1 -freq $((i/100)).$((i%100)) -visit
	end_time=$(date +%s.%3N)
	echo "scale=3; $end_time - $start_time" | bc >> ~/LaSDI/Radial\ Advection/timeit_FOM.txt	
	mv -f Example9* ex9_sim
    mv -f ex9*gf ex9_sim
	mv -f ex9.mesh ex9_sim
	python interp_to_numpy_9.py $i
done

make clean
cd ../../../Radial\ Advection/
rm -rf data
mkdir data
mv -f $MFEM_DIR/ex9_interp_*.npz ./data/
