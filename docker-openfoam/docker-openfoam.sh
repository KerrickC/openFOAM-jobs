#!/bin/sh

readonly DOCKER_VERSION="$(sudo docker --version)"
echo "$DOCKER_VERSION"

#pull image from docker-hub
sudo docker pull openfoam/openfoam7-paraview56

#format image to get ID and assign to OPENFOAM_IMAGE_ID 
readonly OPENFOAM_IMAGE_ID="$(sudo docker images --format "{{.ID}}" openfoam/openfoam7-paraview56)"

# add env vars to list 
#redirect output to /dev/null
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
HOME=/home/openfoam
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
FOAM_JOB_DIR=/opt/jobControl
WM_PROJECT_DIR=/opt/openfoam7
PATH=/opt/ThirdParty-7/platforms/linux64Gcc/gperftools-svn/bin:/opt/paraviewopenfoam56/bin:/home/openfoam/platforms/linux64GccDPInt32Opt/bin:/opt/site/7/platforms/linux64GccDPInt32Opt/bin:/opt/openfoam7/platforms/linux64GccDPInt32Opt/bin:/opt/openfoam7/bin:/opt/openfoam7/wmake:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
OMPI_MCA_btl_vader_single_copy_mechanism=none
_=/usr/bin/env
OLDPWD=/home/openfoam
EOF

#run detached image with env var file and mounted volume
echo "Image ID: $OPENFOAM_IMAGE_ID"
readonly OPENFOAM_CONTAINER_NAME="my_container"
sudo docker container run --env-file ./env.list -it -u 0 --rm -d --name="$OPENFOAM_CONTAINER_NAME" "$OPENFOAM_IMAGE_ID" bash


#add environment variables and move necessary files
sudo docker exec -i "$OPENFOAM_CONTAINER_NAME" echo "Adding required environment variables..."
sleep 1s
sudo docker exec -it "$OPENFOAM_CONTAINER_NAME" bash -c "cd /opt/openfoam7/ && touch env.list && env >> ./env.list"
sudo docker exec -it "$OPENFOAM_CONTAINER_NAME" bash -c "mkdir /home/openfoam/system/"
sudo docker exec -it "$OPENFOAM_CONTAINER_NAME" bash -c "cp /opt/openfoam7/etc/controlDict /home/openfoam/system/"


#echo exec to ensure internal exec commands are working
sudo docker exec -i "$OPENFOAM_CONTAINER_NAME" echo "Connected to container successfully! Running simulation..."
sleep 2s
#define env vars, run sim
sudo docker exec -it my_container bash -c "/opt/openfoam7/tutorials/incompressible/icoFoam/elbow/Allclean && /opt/openfoam7/tutorials/incompressible/icoFoam/elbow/Allrun"
echo "\nSimulation complete!\n"
sleep 2s

#copy VTK file to host machine - NOT NECESSARY
#sudo docker cp my_container:/opt/openfoam7/tutorials/incompressible/simpleFoam/rotorDisk/VTK .

#export files to host
echo "Exporting files to /openfoam_results"
sleep 2s
cd $HOME
sudo mkdir -p docker-openfoam && cd docker-openfoam
#echo message
sleep 3s
if sudo docker cp $OPENFOAM_CONTAINER_NAME:/opt/openfoam7/tutorials/incompressible/icoFoam/elbow .; then
    echo "\nSuccess!\n\nYou can find the results in /openfoam_resuts.\n"
else
    echo "\nCannot export data! Exiting container... /n"
    sudo docker container stop my_container
    exit 1
fi

sleep 2s
echo "Exiting docker container...\n"

#stop container
sudo docker container stop my_container
