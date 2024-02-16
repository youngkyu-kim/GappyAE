import sys
import numpy as np 
import pickle
sys.path.append("../build")
import _pylibROM.linalg as linalg
import _pylibROM.hyperreduction as hyperreduction

# number of msmt
num_samples = 12

# latent space dim.
f_list=np.array([3,4,5,6])

# NM model seed
seed=5 # change

# Given parameters (ex16)
nx = 60
ny = 60
tf = 1.0
dt = 2.0e-3
nt = int(tf/dt)
xmin = 0; xmax = 1
ymin = 0; ymax = 1
dims = (ny,nx)

# generate mesh grid
[xv,yv]=np.meshgrid(np.linspace(xmin,xmax,nx),np.linspace(ymin,ymax,ny),indexing='xy')
x=xv.flatten()
y=yv.flatten()

# full, inner, bc index
multi_index_i,multi_index_j=np.meshgrid(np.arange(nx),np.arange(ny),indexing='xy')
full_multi_index=(multi_index_j.flatten(),multi_index_i.flatten())
x0_multi_index=(multi_index_j[:,0].flatten(),multi_index_i[:,0].flatten())
x1_multi_index=(multi_index_j[:,-1].flatten(),multi_index_i[:,-1].flatten())
y0_multi_index=(multi_index_j[0,:].flatten(),multi_index_i[0,:].flatten())
y1_multi_index=(multi_index_j[-1,:].flatten(),multi_index_i[-1,:].flatten())

dims=(ny,nx)
full_raveled_indicies=np.ravel_multi_index(full_multi_index,dims)
x0_raveled_indicies=np.ravel_multi_index(x0_multi_index,dims)
x1_raveled_indicies=np.ravel_multi_index(x1_multi_index,dims)
y0_raveled_indicies=np.ravel_multi_index(y0_multi_index,dims)
y1_raveled_indicies=np.ravel_multi_index(y1_multi_index,dims)
bc_raveled_indicies=np.unique(np.concatenate((x0_raveled_indicies,x1_raveled_indicies,
                                              y0_raveled_indicies,y1_raveled_indicies)))
inner_raveled_indicies=np.setdiff1d(full_raveled_indicies,bc_raveled_indicies)

# no oversampling
msmt_idx_list_inner=[]
msmt_idx_list_bndry=[]
for ii in range(len(f_list)):
    f=f_list[ii]
    print("Latent Space Dimension: {}".format(f))

    # file path
    file_path_residual_SVD="./model/ex16_AE_{}_swish_residual_SVD_seed_{}.p".format(f,seed) # change path
    with open(file=file_path_residual_SVD, mode='rb') as ff:  
        SVD = pickle.load(ff)

    orthonormal_mat_inner=SVD['U'][inner_raveled_indicies,:num_samples] # num_samples --> f
    orthonormal_mat_bndry=SVD['U'][bc_raveled_indicies,:num_samples] # num_samples --> f

    num_rows_inner, num_cols_inner = orthonormal_mat_inner.shape
    num_rows_bndry, num_cols_bndry = orthonormal_mat_bndry.shape

    u_inner= linalg.Matrix(orthonormal_mat_inner,True,False)
    u_bndry= linalg.Matrix(orthonormal_mat_bndry,True,False)

    f_sampled_row_inner= [0] * num_samples
    f_sampled_row_bndry= [0] * num_samples
    f_sampled_rows_per_proc_inner = [0] * 1
    f_sampled_rows_per_proc_bndry = [0] * 1
    f_basis_sampled_inv_inner = linalg.Matrix(num_samples, num_cols_inner ,False)
    f_basis_sampled_inv_bndry = linalg.Matrix(num_samples, num_cols_bndry ,False)

    f_sampled_row_inner,f_sampled_rows_per_proc_inner= hyperreduction.S_OPT(u_inner, num_cols_inner,f_basis_sampled_inv_inner, 0, 1, num_samples)
    f_sampled_row_bndry,f_sampled_rows_per_proc_bndry= hyperreduction.S_OPT(u_bndry, num_cols_bndry,f_basis_sampled_inv_bndry, 0, 1, num_samples)

    msmt_idx_list_inner.append(inner_raveled_indicies[f_sampled_row_inner])
    msmt_idx_list_bndry.append(bc_raveled_indicies[f_sampled_row_bndry])

    print("Inner Measurments",inner_raveled_indicies[f_sampled_row_inner])
    print("Boundary Measurments",bc_raveled_indicies[f_sampled_row_bndry])
    print(np.linalg.norm(np.array(f_basis_sampled_inv_inner)-np.linalg.pinv(orthonormal_mat_inner[f_sampled_row_inner]).T))
    print(np.linalg.norm(np.array(f_basis_sampled_inv_bndry)-np.linalg.pinv(orthonormal_mat_bndry[f_sampled_row_bndry]).T))

msmt_idx_list_inner=np.array(msmt_idx_list_inner)
msmt_idx_list_bndry=np.array(msmt_idx_list_bndry)
with open(file="./model/ex16_AE_inner_SOPT_no_oversampling.p",mode='wb') as fff:
    pickle.dump(msmt_idx_list_inner,fff)
with open(file="./model/ex16_AE_bndry_SOPT_no_oversampling.p",mode='wb') as ffff:
    pickle.dump(msmt_idx_list_bndry,ffff)

# oversampling
msmt_idx_list_inner=[]
msmt_idx_list_bndry=[]
for ii in range(len(f_list)):
    f=f_list[ii]
    print("Latent Space Dimension: {}".format(f))

    # file path
    file_path_residual_SVD="./model/ex16_AE_{}_swish_residual_SVD_seed_{}.p".format(f,seed) # change path
    with open(file=file_path_residual_SVD, mode='rb') as ff:  
        SVD = pickle.load(ff)

    orthonormal_mat_inner=SVD['U'][inner_raveled_indicies,:f] # num_samples --> f
    orthonormal_mat_bndry=SVD['U'][bc_raveled_indicies,:f] # num_samples --> f

    num_rows_inner, num_cols_inner = orthonormal_mat_inner.shape
    num_rows_bndry, num_cols_bndry = orthonormal_mat_bndry.shape

    u_inner= linalg.Matrix(orthonormal_mat_inner,True,False)
    u_bndry= linalg.Matrix(orthonormal_mat_bndry,True,False)

    f_sampled_row_inner= [0] * num_samples
    f_sampled_row_bndry= [0] * num_samples
    f_sampled_rows_per_proc_inner = [0] * 1
    f_sampled_rows_per_proc_bndry = [0] * 1
    f_basis_sampled_inv_inner = linalg.Matrix(num_samples, num_cols_inner ,False)
    f_basis_sampled_inv_bndry = linalg.Matrix(num_samples, num_cols_bndry ,False)

    f_sampled_row_inner,f_sampled_rows_per_proc_inner= hyperreduction.S_OPT(u_inner, num_cols_inner,f_basis_sampled_inv_inner, 0, 1, num_samples)
    f_sampled_row_bndry,f_sampled_rows_per_proc_bndry= hyperreduction.S_OPT(u_bndry, num_cols_bndry,f_basis_sampled_inv_bndry, 0, 1, num_samples)

    msmt_idx_list_inner.append(inner_raveled_indicies[f_sampled_row_inner])
    msmt_idx_list_bndry.append(bc_raveled_indicies[f_sampled_row_bndry])

    print("Inner Measurments",inner_raveled_indicies[f_sampled_row_inner])
    print("Boundary Measurments",bc_raveled_indicies[f_sampled_row_bndry])
    print(np.linalg.norm(np.array(f_basis_sampled_inv_inner)-np.linalg.pinv(orthonormal_mat_inner[f_sampled_row_inner]).T))
    print(np.linalg.norm(np.array(f_basis_sampled_inv_bndry)-np.linalg.pinv(orthonormal_mat_bndry[f_sampled_row_bndry]).T))

msmt_idx_list_inner=np.array(msmt_idx_list_inner)
msmt_idx_list_bndry=np.array(msmt_idx_list_bndry)
with open(file="./model/ex16_AE_inner_SOPT_oversampling.p",mode='wb') as fff:
    pickle.dump(msmt_idx_list_inner,fff)
with open(file="./model/ex16_AE_bndry_SOPT_oversampling.p",mode='wb') as ffff:
    pickle.dump(msmt_idx_list_bndry,ffff)