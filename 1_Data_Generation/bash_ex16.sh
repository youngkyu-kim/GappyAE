#!/bin/bash
#SBATCH -N 1
#SBATCH -J bash_ex9
#SBATCH -t 2:00:00
#SBATCH -p pbatch
#SBATCH -o bash_ex9.log
#SBATCH --open-mode truncate

source ../lasdi_venv/bin/activate

MFEM_DIR="../dependencies/mfem/examples"

cp lasdi_ex16.cpp $MFEM_DIR
cp makefile_ex16 $MFEM_DIR
cp interp_to_numpy_16.py $MFEM_DIR

cd $MFEM_DIR
rm ex16_interp_*.npz
rm -rf ex16_sim
mkdir ex16_sim
make lasdi_ex16 -f makefile_ex16

# for i in $(seq 180 20 220)
# do
# 	for j in $(seq 180 20 220)
# 	do
# 		echo $i$j
# 		rm -rf ex16_sim/*
# 		if [ $i = 200 ] && [ $j = 200 ]; then
# 			start_time=$(date +%s.%3N)
# 			./lasdi_ex16 -m ../data/inline-tri.mesh -vs 1 -r 3 -visit -freq $((i/100)).$((i%100)) -am $((j/100)).$((j%100)) -tf 1.5 -dt 1.0e-3
# 			end_time=$(date +%s.%3N)
# 			echo "scale=3; $end_time - $start_time" | bc > ~/LaSDI/Diffusion/timeit_FOM.txt
# 		else
# 			./lasdi_ex16 -m ../data/inline-tri.mesh -vs 1 -r 3 -visit -freq $((i/100)).$((i%100)) -am $((j/100)).$((j%100)) -tf 1.5 -dt 1.0e-3
# 		fi
# 		mv -f Example16* ex16_sim
# 		mv -f ex16*gf ex16_sim
# 		python interp_to_numpy_16.py $i $j
# 	done
# done

rm -rf ~/LaSDI/Diffusion/timeit_FOM.txt
j=50
for i in $(seq 75 1 125)
#for i in $(seq 75 1 75)
do
	echo $i >> ~/LaSDI/Diffusion/timeit_FOM.txt	
	rm -rf ex16_sim/*
	# if [ $i = 100 ]; then
	# 	start_time=$(date +%s.%3N)
	# 	./lasdi_ex16 -m ../data/inline-tri.mesh -vs 1 -r 3 -visit -freq $((i/100)).$((i%100)) -am $((j/100)).$((j%100)) -tf 1.0 -dt 2.0e-3 -k 0.05 -a 1.0e-2
	# 	end_time=$(date +%s.%3N)
	# 	echo "scale=3; $end_time - $start_time" | bc > ~/LaSDI/Diffusion/timeit_FOM.txt
	# else
		# ./lasdi_ex16 -m ../data/inline-tri.mesh -vs 1 -r 3 -visit -freq $((i/100)).$((i%100)) -am $((j/100)).$((j%100)) -tf 1.0 -dt 2.0e-3 -k 0.05 -a 1.0e-2
	# fi
	start_time=$(date +%s.%3N)
	./lasdi_ex16 -m ../data/inline-quad.mesh -vs 1 -o 2 -r 4 -s 3 -visit -freq $( echo "scale=2; $i/100" | bc ) -am $( echo "scale=2; $j/100" | bc ) -tf 1.0 -dt 2.0e-3 -k 0.05 -a 1.0e-2
	# ./lasdi_ex16 -m ../data/inline-quad.mesh -vs 1 -r 4 -visit -freq $((i/100)).$((i%100)) -am $((j/100)).$((j%100)) -tf 1.0 -dt 2.0e-3 -k 0.05 -a 1.0e-2
	end_time=$(date +%s.%3N)
	echo "scale=3; $end_time - $start_time" | bc >> ~/LaSDI/Diffusion/timeit_FOM.txt	
	mv -f Example16* ex16_sim
	mv -f ex16*gf ex16_sim
	mv -f ex16.mesh ex16_sim
	python interp_to_numpy_16.py $i $j
done

make clean
cd ../../../Diffusion/
rm -rf data
mkdir data
mv -f $MFEM_DIR/ex16_interp_*.npz ./data/
