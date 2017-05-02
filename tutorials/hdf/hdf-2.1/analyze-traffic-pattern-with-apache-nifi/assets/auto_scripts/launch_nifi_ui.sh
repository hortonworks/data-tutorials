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
until [[ "$environment" == "Docker" || "$environment" == "VirtualBox" ]]; do
    user_menu
    case $environment in
        "Docker" )
            echo "You entered HDF Sandbox runs on: $environment"
            ./auto_scripts/docker-scripts/docker_sandbox_hdf.sh
            ;;
        "VirtualBox" )
            echo "You entered HDF Sandbox runs on: $environment"
            ./auto_scripts/virtualbox-scripts/virtualbox_sandbox_hdf.sh
            ;;
        * )
            echo "Please enter 'Docker' or 'VirtualBox'."
    esac
done

#Access NiFi HTML UI via Mac CLI
echo "Launch NiFi HTML UI, may take an extra 30 sec..."
sleep 30
open http://sandbox.hortonworks.com:19090/nifi/
