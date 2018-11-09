#!/bin/bash --login
########## Define Resources Needed with SBATCH Lines ##########

#If we have to specify what cluster/nodes to use, the best cluster would probably have at least 10 nodes (for our 10 files) 
#with at least 36 cores per node(35 tasks/SVM runs to run in parallel on each file). The intel18 skl-[000-115] or skl-[116-131] 
#would seem to fit this task the best.

#I believe that each file could be considered a task, giving 10 total tasks. If this is the case, each task would need
#36 processors to run completely in parallel. If this is the case, explicitly requesting nodes might be redundant, since 
#slurm can probably allocate this dynamically, but I believe the specifications below should work. If '-n' specifies the 
#number of tasks per node, instead of the number of tasks total, then the line with the '-N' should be removed so that 
#10 different nodes are not requested for 360 processors each. 

#SBATCH -t 00:05:00 #time required. Five minutes for test task
#SBATCH -N 10 #number of nodes
#SBATCH -n 10 #number of tasks total. 
#SBATCH -c 36 #cpus/cores per task
#SBATCH --job-name sliding_window_svm_test
#SBATCH --mem=40G #memory per job. This gives 1 GB mem for each SVM run, plus a little wiggle room



####################set MATLAB version here######################

#################################################################



#change to the correct directory to run the test files. Here I am assuming the project is in the home directory of the user.
cd ~/ids_svm_slidingwindow/slurm_test_run

#run each file in parallel on a different node. Each file contains 35 test "svm runs" to run in parallel
#the '&' operator specifies to run in parallel. Each srun requests 1 node.

srun -N 1 matlab -nodisplay -nosplash -nojvm -r node1 &
srun -N 1 matlab -nodisplay -nosplash -nojvm -r node2 &
srun -N 1 matlab -nodisplay -nosplash -nojvm -r node3 &
srun -N 1 matlab -nodisplay -nosplash -nojvm -r node4 &
srun -N 1 matlab -nodisplay -nosplash -nojvm -r node5 &
srun -N 1 matlab -nodisplay -nosplash -nojvm -r node6 &
srun -N 1 matlab -nodisplay -nosplash -nojvm -r node7 &
srun -N 1 matlab -nodisplay -nosplash -nojvm -r node8 &
srun -N 1 matlab -nodisplay -nosplash -nojvm -r node9 &
srun -N 1 matlab -nodisplay -nosplash -nojvm -r node10 &


#make sure the SLURM job does not exit until all runs have finished
wait