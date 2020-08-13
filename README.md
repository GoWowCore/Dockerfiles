# Dockerfiles

![Travis (.com)](https://img.shields.io/travis/com/gowowcore/Dockerfiles?style=flat-square)

All containers are intended to be operated the same way.

Intended to be minimal manual preparation steps.

/config - realm/world/maps/etc files 
/wow - (Optional) Client folder for processing maps/dbc/vmaps/mmaps from if necessary

## Use

* Install docker-ce and docker-compose
* git clone https://github.com/GoWowCore/Dockerfiles.git
* cd Dockerfiles
* cd (pick a release)
* customize docker-compose.yml(Or if I've renamed them all, copy it to docker-compose.yml)
* docker-compose up -d #(First time will take a while if not already built)

To update from remote sources
* cd (back to that folder with your docker-compose.yml)
* docker-compose build #(This will rebuild the container)
* docker-compose up -d #(This will relaunch the container with the new image and the existing files/db/etc)

## Container flow

* Auto build maps/dbc/vmaps/mmaps/etc if missing(and /wow directory is found)
* Auto create relevant databases and users if MYSQL_ROOT_PASSWORD env var is defined
* Auto import databases if necessary (TrinityCore does this on their own, I've added startup scripts for MaNGOS)
* Auto enroll/sync the world/realm into the realmlist table
  * If M_MANGOSD_REALMID/TC_WORLDSERVER_REALMID is defined, can be used to rename servers
  * If they are not defined, will match against M_MANGOSD_NAME/TC_WORLDSERVER_NAME and use the REALMID from the database
* Auto create initial GM user, admin/admin

## Notes

Currently this builds all from their appropriate sources, and is not matching against specific commits or releases.  
Today's build may work, but tomorrows may fail.

The only thing missing in these containers is the MySQL/MariaDB server.  
Each container includes:
* realmd/authserver
* mangosd/worldserver
* "tools"

You can run a single container with all included.
