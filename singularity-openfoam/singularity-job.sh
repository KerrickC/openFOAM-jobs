#!/bin/sh

#Run "Elbow" tutorial simulation with Singularity

#!/bin/sh

set -e

#ASSUMES ROOT PRIVELAGES

#cd to home dir
cd $HOME

#make directory where sim results will be stored
mkdir -p singularity_results
cd singularity_results
mkdir -p singularity-elbow

#get env vars and add to singularity docker image
#! First var binds $HOME/singularity_results/singulairty-elbow to data location (change to desired dir) !#
#! You can also remove this var and define this in the "singularity instance start..." !#

echo "Defining environment variables\n"
sleep 2s

tee env.list 2>&1 > /dev/null << EOF
FOAM_TUTORIALS=/opt/openfoam7/tutorials
LD_LIBRARY_PATH=/opt/ThirdParty-7/platforms/linux64Gcc/gperftools-svn/lib:/opt/paraviewopenfoam56/lib/paraview-5.6:/opt/openfoam7/platforms/linux64GccDPInt32Opt/lib/openmpi-system:/opt/ThirdParty-7/platforms/linux64GccDPInt32/lib/openmpi-system:/usr/lib/x86_64-linux-gnu/openmpi/lib:/home/openfoam/platforms/linux64GccDPInt32Opt/lib:/opt/site/7/platforms/linux64GccDPInt32Opt/lib:/opt/openfoam7/platforms/linux64GccDPInt32Opt/lib:/opt/ThirdParty-7/platforms/linux64GccDPInt32/lib:/opt/openfoam7/platforms/linux64GccDPInt32Opt/lib/dummy
MPI_BUFFER_SIZE=20000000
WM_PROJECT_INST_DIR=/opt
XDG_CONFIG_HOME=/home/openfoam/.config
FOAM_RUN=/home/openfoam/run
QT_GRAPHICSSYSTEM=native
ParaView_MAJOR=5.6
HOSTNAME=c175ddeaa1cd
WM_THIRD_PARTY_DIR=/opt/ThirdParty-7
WM_LDFLAGS=-m64
FOAM_APP=/opt/openfoam7/applications
WM_CXXFLAGS="-m64 -fPIC -std=c++0x"
FOAM_UTILITIES=/opt/openfoam7/applications/utilities
FOAM_APPBIN=/opt/openfoam7/platforms/linux64GccDPInt32Opt/bin
ParaView_DIR=/opt/paraviewopenfoam56
WM_PRECISION_OPTION=DP
FOAM_SOLVERS=/opt/openfoam7/applications/solvers
FOAM_EXT_LIBBIN=/opt/ThirdParty-7/platforms/linux64GccDPInt32/lib
WM_CC=gcc
FOAM_USER_APPBIN=/home/openfoam/platforms/linux64GccDPInt32Opt/bin
FOAM_SIGFPE=
PWD=/opt/openfoam7
WM_PROJECT_USER_DIR=/home/openfoam
WM_OPTIONS=linux64GccDPInt32Opt
WM_LINK_LANGUAGE=c++
WM_OSTYPE=POSIX
WM_PROJECT=OpenFOAM
ParaView_INCLUDE_DIR=/opt/paraviewopenfoam56/include/paraview-5.6
FOAM_LIBBIN=/opt/openfoam7/platforms/linux64GccDPInt32Opt/lib
MPI_ARCH_PATH=/usr/lib/x86_64-linux-gnu/openmpi
WM_CFLAGS="-m64 -fPIC"
ParaView_GL=mesa
WM_ARCH=linux64
FOAM_SRC=/opt/openfoam7/src
uid=98765
FOAM_ETC=/opt/openfoam7/etc
FOAM_SETTINGS=
FOAM_SITE_APPBIN=/opt/site/7/platforms/linux64GccDPInt32Opt/bin
TERM=xterm
user=openfoam
FOAM_SITE_LIBBIN=/opt/site/7/platforms/linux64GccDPInt32Opt/lib
WM_COMPILER_LIB_ARCH=64
WM_COMPILER=Gcc
ParaView_VERSION=5.6.0
WM_DIR=/opt/openfoam7/wmake
WM_LABEL_SIZE=32
WM_ARCH_OPTION=64
WM_PROJECT_VERSION=7
WM_LABEL_OPTION=Int32
WM_MPLIB=SYSTEMOPENMPI
FOAM_INST_DIR=/opt
WM_COMPILE_OPTION=Opt
SHLVL=1
WM_COMPILER_TYPE=system
WM_CXX=g++
FOAM_USER_LIBBIN=/home/openfoam/platforms/linux64GccDPInt32Opt/lib
PV_PLUGIN_PATH=/opt/openfoam7/platforms/linux64GccDPInt32Opt/lib/paraview-5.6
FOAM_MPI=openmpi-system
FOAM_JOB_DIR=/opt/jobControlsudo
WM_PROJECT_DIR=/opt/openfoam7
PATH=/opt/ThirdParty-7/platforms/linux64Gcc/gperftools-svn/bin:/opt/paraviewopenfoam56/bin:/home/openfoam/platforms/linux64GccDPInt32Opt/bin:/opt/site/7/platforms/linux64GccDPInt32Opt/bin:/opt/openfoam7/platforms/linux64GccDPInt32Opt/bin:/opt/openfoam7/bin:/opt/openfoam7/wmake:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
OMPI_MCA_btl_vader_single_copy_mechanism=none
_=/usr/bin/env
OLDPWD=/home/openfoam
EOF

echo 'Done!\n'
sleep 1s

echo 'Starting Singularity OpenFOAM Instance...\n'

#run openfoam docker image within singularity instance
singularity instance start --writable-tmpfs --keep-privs --env-file $HOME/env.list library://psumionka-task/default/ubuntu-16.04_openfoam-7 openfoam
sleep 2s
echo 'Running simulation...\n'

#run elbow simulation (example)
singularity exec --writable-tmpfs --keep-privs --env-file $HOME/env.list instance://openfoam /opt/openfoam7/tutorials/incompressible/icoFoam/elbow/Allrun

echo '\nDone!\n'
sleep 2s

echo 'Stopping instance.\n'

#stop singularity instance
#singularity instance stop openfoam

exit

#!Access data in $HOME/singularity_results