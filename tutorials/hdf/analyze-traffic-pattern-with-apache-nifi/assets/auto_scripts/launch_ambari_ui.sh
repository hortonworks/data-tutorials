#!/bin/bash

# User Selects Virtual Environment their HDF Sandbox Runs On
environment=
function user_menu
{
    echo ""
    echo "HDF Sandbox Virtual Environment Selection Menu"
    echo "'Docker' - is my environment"
    echo "'VirtualBox' - is my environment"
    echo ""
    echo -n "Enter the 'virtual environment' for HDF Sandbox: "
    read environment
    echo ""
}

# Start HDF Sandbox on the Virtual Environment User Selected
# Launch Ambari UI
until [[ "$environment" == "Docker" || "$environment" == "VirtualBox" ]]; do
    user_menu
    case $environment in
        "Docker" )
            echo "You entered HDF Sandbox runs on: $environment"
            ./auto_scripts/docker-scripts/start_sandbox-hdf.sh
            #Access Ambari UI via Mac CLI (Port Number Docker)
            echo "Launch Ambari UI..."
            open http://sandbox-hdf.hortonworks.com:9080/
            ;;
        "VirtualBox" )
            echo "You entered HDF Sandbox runs on: $environment"
            ./auto_scripts/virtualbox-scripts/virtualbox_sandbox_hdf.sh
            #Access Ambari UI via Mac CLI (Port Number VirtualBox)
            echo "Launch Ambari UI..."
            open http://sandbox-hdf.hortonworks.com:9080/
            ;;
        * )
            echo "Please enter 'Docker' or 'VirtualBox'."
    esac
done
