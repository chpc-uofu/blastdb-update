#!/usr/bin/bash
# blastdb_installer.sh - submitted to SLURM by crontab to install downloaded 
# blast databases.

#SBATCH --account=chpc
#SBATCH --partition=lonepeak
#SBATCH --nodes=1
#SBATCH --mail-user=brett.milash@utah.edu
#SBATCH --mail-type=FAIL,BEGIN,END

# quarantine moves files to the Quarantine directory.
quarantine ()
{
	mv $* Quarantine
}

# check_md5_checksum - checks md5 checksums of file(s) for database, returning
# 0 if OK, quarantining files and returning 1 if not.
check_md5_checksum ()
{
	dbname=$1
	shift
	dbfiles=$*
	echo "Checking md5 checksums for database $dbname, database files $dbfiles"
	return_value=0
	#for targzfile in `find Download -name $dbname"*.tar.gz" -size +0c -print`
	for targzfile in $dbfiles
	do
		md5file=$targzfile".md5"
		local_checksum=`md5sum $targzfile | cut -f1 -d' '`
		remote_checksum=`cut -f1 -d' ' $md5file`
		if [ "$local_checksum" = "$remote_checksum" ]
		then
			echo "Checksum for file $targzfile ok."
		else
			echo "Checksum for file $targzfile incorrect. Quarantining file."
			quarantine $targzfile $md5file
			return_value=1
		fi
	done
	return $return_value
}

# install_database - un-tars files and moves them into the DbFiles directory.
install_database ()
{
	dbname=$1
	# Find .tar.gz files greater than 0 bytes.
	dbfiles=`find Download -name "$dbname.*tar.gz" -size +0c -print`
	if [ -n "$dbfiles" ]
	then
		echo
		echo "Found new database files for $dbname."
		check_md5_checksum $dbname $dbfiles
		if [ $? -eq 0 ]
		then
			# Database files OK.
			echo "Database files OK. Installing $dbname."
			tmpdir=tmp.$dbname.$$
			mkdir $tmpdir
			cd $tmpdir
			for targzfile in $dbfiles
			do
				echo "Untarring $targzfile in $tmpdir"
				tar xvfz ../$targzfile
			done
			mv * ../DbFiles
			cd ..
			rm -rf $tmpdir

			# Empty each downloaded .tar.gz file, preserving its
			# create and modify times.
			for targzfile in $dbfiles
			do
				echo "Creating empty file for $targzfile"
				emptyfile=$targzfile".empty"
				touch --reference=$targzfile $emptyfile
				mv $emptyfile $targzfile
			done
		else
			# At least one checksum mismatch.
			echo "At least one checksum mismatch. Not installing $dbname."
		fi
	else
		echo "No new files for database $dbname."
	fi
}

export -f install_database check_md5_checksum quarantine

main ()
{
	cat database_list | xargs -I DB --max-procs=3 bash -c "install_database DB"
}

main
