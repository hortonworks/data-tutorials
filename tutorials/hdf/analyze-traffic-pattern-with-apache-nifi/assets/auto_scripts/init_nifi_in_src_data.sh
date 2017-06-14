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

# Create Input Source Data for NiFi on the Virtual Environment User Selected
until [[ "$environment" == "Docker" || "$environment" == "VirtualBox" ]]; do
    user_menu
    case $environment in
        "Docker" )
            echo "You entered HDF Sandbox runs on: $environment"
            ./auto_scripts/docker-scripts/init_docker_src_data.sh
            ;;
        "VirtualBox" )
            echo "You entered HDF Sandbox runs on: $environment"
            ./auto_scripts/virtualbox-scripts/init_virtualbox_src_data.sh
            ;;
        * )
            echo "Please enter 'Docker' or 'VirtualBox'."
    esac
done
