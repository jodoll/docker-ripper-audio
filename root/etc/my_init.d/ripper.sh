#!/bin/bash

echo "Using this daily? Please sponsor me at https://github.com/sponsors/rix1337 - any amount counts!"

mkdir -p /config

# copy default script
if [[ ! -f /config/ripper.sh ]]; then
    cp /ripper/ripper.sh /config/ripper.sh
fi

# Update abcde OUTPUTDIR if specified in env variables
if [ -z ${STORAGE_CD+x} ]; then
    echo "STORAGE_CD not set, defaulting to /out/Ripper/CD"
else
    echo "Custom STORAGE_CD is set, updating abcde.conf with OUTPUTDIR=${STORAGE_CD}"
    sed -i "/OUTPUTDIR=/c\\OUTPUTDIR=$STORAGE_CD" /ripper/abcde.conf
fi

# move abcde.conf, if found
if [[ -f /config/abcde.conf ]]; then
    echo "Found abcde.conf."
    cp -f /config/abcde.conf /ripper/abcde.conf
fi

# Check if custom group is set and create it if it doesn't exist
if [ -z ${FILEGROUP+x} ]; then
    echo "Custom group not set, defaulting to users"
    FILEGROUP="users"
else
    echo "Custom group set"
    if [ $(getent group ${FILEGROUP}) ]; then
        echo "Group already exists, skipping."
    else
        if [ -z ${FILEGROUPID+x} ]; then
            FILEGROUPID="4321"
            echo "FILEGROUPID not set, defaulting to ID ${FILEGROUPID}"
        else
            echo "Using custom FILEGROUPID ${FILEGROUPID}"
        fi
        echo "Making custom group ${FILEGROUP} with ID ${FILEGROUPID}"
        groupadd -g ${FILEGROUPID} ${FILEGROUP}
    fi
fi

# Check if custom user is set and create it if it doesn't exist
if [ -z ${FILEUSER+x} ]; then
    echo "Custom user not set, defaulting to nobody"
    FILEUSER="nobody"
else
    echo "Custom user set"
    if id "${FILEUSER}" >/dev/null 2>&1; then
        echo "User already exists, skipping."
    else
        if [ -z ${FILEUSERID+x} ]; then
            FILEUSERID="321"
            echo "FILEUSERID not set, defaulting to ID ${FILEUSERID}"
        else
            echo "Using custom FILEUSERID ${FILEUSERID}"
        fi
        echo "Making custom group ${FILEUSER} with ID ${FILEUSERID}"
        useradd -g ${FILEGROUP} -u ${FILEUSERID} ${FILEUSER}
    fi
fi

# Check if custom permissions are set
if [ -z ${FILEMODE+x} ]; then
    echo "Custom file not permissions set, defaulting to g+rw"
    FILEMODE="g+rw"
else
    echo "Custom file permissions set to ${FILEMODE}"
fi

# permissions
chown -R ${FILEUSER}:${FILEGROUP} /config
chmod -R ${FILEMODE} /config

chmod +x /config/ripper.sh

bash /config/ripper.sh &
