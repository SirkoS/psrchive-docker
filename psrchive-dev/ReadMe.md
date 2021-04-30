# PSRCHIVE development setup

This image provides the environment to compile custom variations of [PSRCHIVE](http://psrchive.sourceforge.net/).

## Usage

* Clone/copy this folder and all of its contents.
* Clone the psrchive source files into `/share/psrchive`:
  `git clone git://git.code.sf.net/p/psrchive/code psrchive`
* Start the container (default name is `psrchive-dev`)
  `docker-compose up`
* Connect into the container
  `docker exec -it psrchive-dev /bin/bash`
* Build psarchive; run `build.sh` in `/home/share/`
* Run `psrchive` to check the success.

You can modify the sources in the host system by changing files in `/share/psrchive` and build afterwards.

To customize the behavior, check `docker-compose.yml` and the comments therein.

## Dependencies

* [docker](https://www.docker.com/)
* [docker-compose](https://docs.docker.com/compose/)
