# GappyAE

This repository contains Jupyter notebooks for numerical examples of the paper titled "[Gappy Data Reconstruction using Unsupervised Learning for Digital Twin](https://arxiv.org/abs/2312.07902)".
Note that an open-source FEM solver, [MFEM](https://mfem.org/) was used to generate training data. Please refer to the paper for more details. Since the size of the training data is large, we do not upload it here. The training data will be provided upon request via email at youngkyu_kim@berkeley.edu.

![](gappyAE_ani.gif)

## Data Generation
![](data_generation.png)

1. Build [LaSDI](https://github.com/LLNL/LaSDI) or [MFEM](https://mfem.org/) with souce codes and makefiles located in "1_Data_Generation" folder.
- Example 9 or Advection
- Example 16 or Diffusion
- Example 23 or Wave
2. Run shell scripts in "1_Data_Generation" folder to generate training data.  

Below figures show five snapshots for two extreme parameter values.

![](diffusion_mu1_sol.png)
*Diffusion simulation solutions from the initial to the final time for param=0.75*

![](diffusion_mu2_sol.png)
*Diffusion simulation solutions from the initial to the final time for param=1.25*

![](advection_mu1_sol.png)
*Advection simulation solutions from the initial to the final time for param=0.75*

![](advection_mu2_sol.png)
*Advection simulation solutions from the initial to the final time for param=1.25*

![](wave_mu1_sol.png)
*Wave simulation solutions from the initial to the final time for param=0.75*

![](wave_mu2_sol.png)
*Wave simulation solutions from the initial to the final time for param=1.25*

## Model Training
![](model_training.png)

To find nonlinear manifold denoted as function $g(\hat{x})$, run "train_NM_XXX.ipynb" in "2_Model_Training" folder.

## Data Reconstruction
![](data_reconstruction.png)

"gappyAE_PROBLEM_TYPE_MEASUREMENT_REGION_SAMPLING_ALGORITHM.ipynb" files in "3_Data_Reconstruction" run a data reconstruction algorithm.

- PROBLEM_TYPE: diffusion/advection/wave
- MEASUREMENT_REGION: inner/bndry
- SAMPLING_ALGORITHM: uniform/LHS/DEIM/SOPT

Note: You need to build [pylibROM](https://github.com/LLNL/pylibROM) and run python scripts in "SOPT_scripts" folder to get SOPT sample points. If you want to skip this step, you can use the SOPT sample points that are provided in "SOPT_sample_points" folder.

## Authors
- Youngkyu Kim (KIST)
- Hyeokmin Lee (KIST)
