# blastdb-update

## Overview
These scripts maintain up-to-date local copies of any number of BLAST
databases from NCBI. This package includes two crontab scripts - one to
perform the download of any databases updated at NCBI since the last
download, and a second script to check the MD5 checksum, uncompress, and
install the database.

At CHPC, we perform these two steps on separate machines. Data download is
handled by one of our specialized 
[data transfer nodes](https://www.chpc.utah.edu/documentation/data_services.php#Data_Transfer_Nodes)
which have 40 Gb network connections. This download can take up to 4 hours,
depending on how many database files have been updated.

The second step, installation, is handled by a slurm script. We queue a
slurm job at least 4 hours after the download has begun to guarantee the
install does not begin before the download is complete. We use a slurm job
for the install since it can be a compute intensive task, and is best
handled by a compute node on the cluster.

New database files are downloaded to the Download directory. Once unpackaged
and checksum-verified, the database files are moved to the DbFiles
directory. Any files failing the checksum test are moved to the Quarantine
directory. **The BLASTDB environment variable for your Blast processes should
contain the full path name of the DbFiles directory.**

## Installation
1. Clone this repository to the location where you want your database files 
to reside. The databases listed in our database_list file require over 900
Gb of space.
2. Edit cronfile.download, setting the time and date of download and the
   full path of the Download directory. We use perl version 5.18.1 - you may
   need to load a different perl module for your installation.
3. Install cronfile.download script on your download machine with the
   "crontab cronfile.download" command.
4. Edit cronfile.install, setting the time and date of the installation.
   This should be some hours after your cronfile.download has started,
   giving the download ample time to complete. This time will be a function
   of your download speed and the size of the database files you download,
   so plan for a worst-case scenario where all database files will require a
   download. Also set the directory name to which you have cloned this repo.
5. Install cronfile.install on a head node of the cluster where you want the
   install to run.
6. Edit blastdb_installer.sh. This is a SLURM script, so you must set the
   SLURM account, partition, and email address for the job.
7. Update your Blast software module to set the BLASTDB environment variable
   **after the first download has successfully completed.**
