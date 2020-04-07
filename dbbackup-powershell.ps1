$OPERATION=$args[0]
$ORACLE_SID="ORCL"
$RMAN_BACKUP_HOME_DIR="C:\backup"
$RMAN_FILE_NAME=$env:TEMP+"\rman-arc"+$(Get-Date -Format "ddMMyyyy-HHmmss")+".rman"
$RMAN_FILE_LOG=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\LOGS"
$RMAN_ARC_PATH=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\rman\arc"
$RMAN_LEVEL0_PATH=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\rman\level0"
$RMAN_LEVEL1_PATH=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\rman\level1"
$RMAN_CONTROL_PATH=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\rman\control"

function configure{
mkdir $RMAN_FILE_LOG
mkdir $RMAN_ARC_PATH
mkdir $RMAN_LEVEL0_PATH
mkdir $RMAN_LEVEL1_PATH
mkdir $RMAN_CONTROL_PATH

Write-Output "CONFIGURE BACKUP OPTIMIZATION ON;" | rman target /
Write-Output "CONFIGURE CONTROLFILE AUTOBACKUP ON;" | rman target /
Write-Output "CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '$RMAN_CONTROL_PATH\%F';" | rman target /
}


function print_usage{
  Write-Output "Usage:"
  Write-Output "  dbbackup-powershell.ps1 --level0"
  Write-Output "  dbbackup-powershell.ps1 --level1"
  Write-Output "  dbbackup-powershell.ps1 --arc"
  Write-Output "  dbbackup-powershell.ps1 --expdp"
  Write-Output "  dbbackup-powershell.ps1 --configure"
  Write-Output "  dbbackup-powershell.ps1 --crosscheck"
  Write-Output "  dbbackup-powershell.ps1 --validate"
}

switch ($operation)
{
    "--level0" {
        $RMAN_FILE_LOG=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\LOGS\inc0-"+$(Get-Date -Format "ddMMyyyy-HHmmss")+".log";
                Write-Output "run { " > $RMAN_FILE_NAME
                Write-Output "     ALLOCATE CHANNEL C1 TYPE DISK MAXPIECESIZE 8G;" >> $RMAN_FILE_NAME
                Write-Output "     BACKUP AS COMPRESSED BACKUPSET INCREMENTAL LEVEL 1 DATABASE FORMAT '$RMAN_LEVEL0_PATH/inc0_%T_set%s_piece%p_copy%c_%t.bkp' FILESPERSET 64;  " >> $RMAN_FILE_NAME
                Write-Output "     RELEASE CHANNEL C1;" >> $RMAN_FILE_NAME
                Write-Output " }" >> $RMAN_FILE_NAME
                        type $RMAN_FILE_NAME | rman target / msglog=$RMAN_FILE_LOG
                rm $RMAN_FILE_NAME
               }
    "--level1" {
        $RMAN_FILE_LOG=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\LOGS\inc1-"+$(Get-Date -Format "ddMMyyyy-HHmmss")+".log";
                Write-Output "run { " > $RMAN_FILE_NAME
                Write-Output "     ALLOCATE CHANNEL C1 TYPE DISK MAXPIECESIZE 8G;" >> $RMAN_FILE_NAME
                Write-Output "     BACKUP AS COMPRESSED BACKUPSET INCREMENTAL LEVEL 1 DATABASE FORMAT '$RMAN_LEVEL1_PATH/inc1_%T_set%s_piece%p_copy%c_%t.bkp' FILESPERSET 64;  " >> $RMAN_FILE_NAME
                Write-Output "     RELEASE CHANNEL C1;" >> $RMAN_FILE_NAME
                Write-Output " }" >> $RMAN_FILE_NAME
                        type $RMAN_FILE_NAME | rman target / msglog=$RMAN_FILE_LOG
                rm $RMAN_FILE_NAME
               }
    "--arc" {"Starting backup Archivelog";
    $RMAN_FILE_LOG=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\LOGS\arc-"+$(Get-Date -Format "ddMMyyyy-HHmmss")+".log";
   
                Write-Output "run { " > $RMAN_FILE_NAME
                Write-Output "     ALLOCATE CHANNEL C1 TYPE DISK MAXPIECESIZE 8G;" >> $RMAN_FILE_NAME
                Write-Output "     DELETE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO DEVICE TYPE DISK COMPLETED BEFORE 'SYSDATE-36/24'; " >> $RMAN_FILE_NAME
                Write-Output "     BACKUP ARCHIVELOG ALL  FORMAT '$RMAN_ARC_PATH/arc_%T_set%s_piece%p_copy%c_%t.bkp' FILESPERSET 64; " >> $RMAN_FILE_NAME
                Write-Output "     RELEASE CHANNEL C1;" >> $RMAN_FILE_NAME
                Write-Output " }" >> $RMAN_FILE_NAME
                Write-Output $RMAN_FILE_NAME
                        type $RMAN_FILE_NAME | rman target / msglog=$RMAN_FILE_LOG
                rm $RMAN_FILE_NAME
               
          }
    "--crosscheck" {"Starting backup crosscheck"}
    "--configure" {"Starting envoironment configuration"
    configure
    }
        Default {
        print_usage
    }
}