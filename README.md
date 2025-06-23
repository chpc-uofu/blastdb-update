# blastdb-update

## Overview
These scripts maintain up-to-date local copies of any number of BLAST
databases from [NCBI](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download) . 
This package includes a crontab file which is installed on dtn07.chpc.utah.edu
and is run by the user 'hpcapps'. This performs the download of all the 
databases in the database_list file. This download process takes about 3 
hours. Following the download, the Slurm script blastdb_installer.sh
is queued on the cluster, again as the 'hpcapps' user.

The installation step is run on the lonepeak cluster. The installer
checks the integrity of each database by running a blast job against the
database, and if the blast job succeeds the database is moved into place.
If the blast job fails the database files are moved into the Quarantine
directory.

## Installation
1. Clone this repository to the location where you want your database files 
to reside. The databases listed in our database_list file require 2.2 TB
of space.
2. Edit cronfile.download, setting the time and date of download and the
   full path of the Download directory. We use perl version 5.18.1 - you may
   need to load a different perl module for your installation.
3. Install cronfile.download script on your download machine with the
   "crontab cronfile.download" command.
4. Edit blastdb_installer.sh. This is a Slurm script, so you must set the
   SLURM account, partition, and email address for the job.
5. Update your Blast software module to set the BLASTDB environment variable
   **after the first download has successfully completed.**
