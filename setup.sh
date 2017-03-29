#!/bin/bash
PROFILENAME=mpitest
VENVDIR=$HOME/venvs/$PROFILENAME

function install {
    # create scratch directory
    SCRATCHDIR=/scratch/$USER/ipyparalleltmp
    mkdir -p $SCRATCHDIR
    
    # load modules
    module load openmpi/gcc
    module load python/3.4.2
    
    # First create the virtualenv
    virtualenv-3.4 --system-site-packages $VENVDIR
    source $VENVDIR/bin/activate
    pip install --upgrade pip
    pip install ipyparallel
    
    # Create ipython profile
    ipython profile create --parallel $PROFILENAME
    CONFDIR=$(pwd)
    cd $HOME/.ipython/profile_$PROFILENAME
    
    # Configure ipyparallel
    echo "c.HubFactory.ip ='*'" >> ipcontroller_config.py 
    echo "c.LSFLauncher.queue = 'mpi'" >> ipcluster_config.py 
    echo "c.IPClusterEngines.n = 10" >> ipcluster_config.py 
    
    echo "c.IPClusterStart.controller_launcher_class = 'LSFControllerLauncher'" >> ipcluster_config.py 
    echo "c.IPClusterEngines.engine_launcher_class = 'LSFEngineSetLauncher'" >> ipcluster_config.py 
    
    
    cp $CONFDIR/lsfmpi_engine_template ./
    cp $CONFDIR/lsfmpi_controller_template ./
    
    
    # configure scratch dir
    sed -i "s#<SCRATCHDIR>#$SCRATCHDIR#g"  lsfmpi_engine_template
    sed -i "s#<SCRATCHDIR>#$SCRATCHDIR#g"  lsfmpi_controller_template
    
    echo "import os;dir_path = os.path.dirname(os.path.realpath(__file__))" >> ipcluster_config.py 
    echo 'c.LSFEngineSetLauncher.batch_template_file = os.path.join(dir_path, "lsfmpi_engine_template")' >> ipcluster_config.py 
    echo 'c.LSFControllerLauncher.batch_template_file = os.path.join(dir_path, "lsfmpi_controller_template")' >> ipcluster_config.py 
    
    # Now add relevant lines in ~/.bash_profile
    echo "module load openmpi/gcc" >> $HOME/.bash_profile
    echo "module load python/3.4.2" >> $HOME/.bash_profile
    echo "source $VENVDIR/bin/activate" >> $HOME/.bash_profile
}


function uninstall {
    grep -v "source $VENVDIR/bin/activate" $HOME/.bash_profile > tmp && mv tmp $HOME/.bash_profile
    deactivate
    rm -rf $VENVDIR
    rm -rf $HOME/.ipython/profile_$PROFILENAME
}


if [ "$1" = "uninstall" ]
    then uninstall;
fi


if [ "$1" = "install" ]
    then install;
fi
