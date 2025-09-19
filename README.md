# docker-ripper-audio

This is a slimmed down version of rix1337 docker-ripper, supporting only audio ripping. 

Therefore it was possible to remove the dependency on MakeMKV. This dependency may be problematic in some countries and is not needed to rip audio discs.

Other than being based on his work, this isn't related to him at all, but if you want to support him, please do: [![Github Sponsorship](https://img.shields.io/badge/support-me-red.svg)](https://github.com/users/rix1337/sponsorship).

This container will detect audio disks and rip them automatically.

# Output

Disc Type | Output | Tools used
---|---|---
Audio-CD | MP3 FLAC | abcde (lame and flac), ddrescue

### Prerequistites

#### (1) Create the required directories, for example, in /home/yourusername. Do _not_ use sudo mkdir to achieve this.

```
mkdir config rips
```

#### (2) Find out the name(s) of the optical drive

```
lsscsi -g
```

In this example, /dev/sr0 and /dev/sg0 are the two files that refer to a single optical drive. These names will be
needed for the docker run command.  
![lsscsi -g](https://raw.githubusercontent.com/rix1337/docker-ripper/main/.github/screenshots/lsscsi.png)

Screenshot of Docker run command with the example provided  
![docker run](https://raw.githubusercontent.com/rix1337/docker-ripper/main/.github/screenshots/dockerrun.png)

## Docker run

In the command below, the paths refer to the output from your lsscsi-g command, along with your config and rips
directories. If you created /home/yourusername/config and /home/yourusername/rips then those are your paths.

```
docker run -d \
  --name="Ripper" \
  -v /path/to/config/:/config:rw \
  -v /path/to/rips/:/out:rw \
  -p port:9090 \
  --device=/dev/sr0:/dev/sr0 \
  --device=/dev/sg0:/dev/sg0 \
  rix1337/docker-ripper:manual-latest
  ```

Some systems are not able to pass through optical drives without this flag
```
--privileged
```

#### Configuring the web UI for logs

Add these optional parameters when running the container
```
  -e OPTIONAL_WEB_UI_PATH_PREFIX=/ripper-ui \ 
  -e OPTIONAL_WEB_UI_USERNAME=myusername \ 
  -e OPTIONAL_WEB_UI_PASSWORD=strongpassword \
  -e DEBUGTOWEB=true \
```

`OPTIONAL_WEB_UI_USERNAME ` and `OPTIONAL_WEB_UI_PASSWORD ` both need to be set to enable http basic auth for the web UI.
`OPTIONAL_WEB_UI_PATH_PREFIX ` can be used to set a path prefix (e.g. `/ripper-ui`). This is useful when you are running multiple services at one domain.

## Docker compose

Check the device mount points and optional settings before you run the container.

`docker-compose up -d`

### Environment Variables

- `EJECTENABLED`: Optional - If set to `true`, the disc is ejected after ripping is completed. Default is `true`.
- `STORAGE_CD`: Optional - The path for storing ripped CD content. Default is `/out/Ripper/CD`.
- `DRIVE`: Optional - The device file for the optical drive (e.g., `/dev/sr0`). Default is `/dev/sr0`.
- `BAD_THRESHOLD`: Optional - The number of allowed consecutive bad read attempts before failing. Default is `5`.
- `DEBUG`: Optional - Enables verbose logging when set to `true`. Default is `false`.
- `DEBUGTOWEB`: Optional - If `true`, debug logs are published to the web UI. Default is `false`.
- `SEPARATERAWFINISH`: Optional - When `true`, separates raw and final rips into different directories. Default is `false`.
- `TIMESTAMPPREFIX`: Optional - If `true`, prefixes output folders with a timestamp for organization. Default is `false`.
- `PREFIX`: Optional - path prefix for the integrated web ui when commented out or set to /, the web ui will be at the root of the server
- `USER`: Optional - user name for the integrated web ui (requires PASS to be set) - if not set, the web ui will not require authentication
- `PASS`: Optional - password for the integrated web ui (requires USER to be set) - if not set, the web ui will not require authentication

### Building and Running with Docker Compose

- To build the image:
  
  ```docker-compose build``` or ```docker-compose build --no-cache```

- To start the container:

```docker-compose up -d``` or ```docker-compose up```
This command with the `-d` flag will start the container in detached mode, meaning it will run in the background. Without the `-d` flag, the container will run in the foreground and log to the console. You can stop the container with `docker-compose stop` or `docker-compose down`. The latter will also remove the container. 

- Logs

Logs can be viewed with `docker-compose logs` or `docker-compose logs -f` to follow the logs in real time.

If you prefer to build the Docker image manually without Docker Compose, you can use the docker build command:

To build the "latest" image using docker build:

```docker build -f latest/Dockerfile -t jodoll/docker-ripper-audio:latest .```

This command performs the same operation as the docker-compose build but requires manual input of build context and parameters.

Remember to periodically pull the latest changes from the git repository to keep your Dockerfile up to date and rebuild the image if any updates have been made.



# FAQ

### There is an error regarding 'ccextractor'

Add the following line to settings.conf

```
app_ccextractor = "/usr/local/bin/ccextractor" 
```

### How do I set ripper to do something else?

_Ripper will place a bash-file ([ripper.sh](https://github.com/rix1337/docker-ripper/blob/main/root/ripper/ripper.sh))
automatically at /config that is responsible for detecting and ripping disks. You are completely free to modify it on
your local docker host. No modifications to this main image are required for minor edits to that file._

_Additionally, you have the option of creating medium-specific override scripts in that same directory location:_

Medium | Script Name | Purpose
--- | --- | ---
Audio CD | `CDrip.sh` | Overrides audio CD ripping commands in `ripper.sh` with script operation

_Note that these optional scripts must be of the specified name, have executable permissions set, and be in the same
directory as `ripper.sh` to be executed._

### How do I rip from multiple drives simultaneously?

**This is unsupported!**

Users have however been able to achieve this by running multiple containers of this image, passing through each drive to only one instance of the container, when disabling privileged mode.

### How do I customize the audio ripping output?

_You need to edit /config/abcde.conf_

### The docker keeps locking up and/or crashing and/or stops reading from the drive

_Have you checked the docker host's udev rule for persistent storage for a common flaw?_

```
sudo cp /usr/lib/udev/rules.d/60-persistent-storage.rules /etc/udev/rules.d/60-persistent-storage.rules
sudo vim /etc/udev/rules.d/60-persistent-storage.rules
```

_In the file you should be looking for this line:_
```
# probe filesystem metadata of optical drives which have a media inserted
KERNEL=="sr*", ENV{DISK_EJECT_REQUEST}!="?*", ENV{ID_CDROM_MEDIA_TRACK_COUNT_DATA}=="?*", ENV{ID_CDROM_MEDIA_SESSION_LAST_OFFSET}=="?*", \
  IMPORT{builtin}="blkid --offset=$env{ID_CDROM_MEDIA_SESSION_LAST_OFFSET}"
# single-session CDs do not have ID_CDROM_MEDIA_SESSION_LAST_OFFSET
KERNEL=="sr*", ENV{DISK_EJECT_REQUEST}!="?*", ENV{ID_CDROM_MEDIA_TRACK_COUNT_DATA}=="?*", ENV{ID_CDROM_MEDIA_SESSION_LAST_OFFSET}=="", \
  IMPORT{builtin}="blkid --noraid"
```

_Those IMPORT lines cause issues so we need to replace them with a line that tells udev to end additional rules for SR* devices:_
```
# probe filesystem metadata of optical drives which have a media inserted
KERNEL=="sr*", ENV{DISK_EJECT_REQUEST}!="?*", ENV{ID_CDROM_MEDIA_TRACK_COUNT_DATA}=="?*", ENV{ID_CDROM_MEDIA_SESSION_LAST_OFFSET}=="?*", \
  GOTO="persistent_storage_end"
##  IMPORT{builtin}="blkid --offset=$env{ID_CDROM_MEDIA_SESSION_LAST_OFFSET}"
# single-session CDs do not have ID_CDROM_MEDIA_SESSION_LAST_OFFSET
KERNEL=="sr*", ENV{DISK_EJECT_REQUEST}!="?*", ENV{ID_CDROM_MEDIA_TRACK_COUNT_DATA}=="?*", ENV{ID_CDROM_MEDIA_SESSION_LAST_OFFSET}=="", \
  GOTO="persistent_storage_end"
##  IMPORT{builtin}="blkid --noraid"
```

_You can comment these lines out or delete them all together, then replace them with the GOTO lines. You may then either reboot OR reload the rules. If you're using Unraid, you'll need to edit the original udev rule and reload._
```
root@linuxbox# udevadm control --reload-rules && udevadm trigger
```


# Credits

- [rix1337 docker-ripper](https://github.com/rix1337/docker-ripper)