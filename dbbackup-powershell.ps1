$OPERATION=$args[0]
$ORACLE_SID="ORCLNOVO"
$RMAN_BACKUP_HOME_DIR="C:\backup"
$RMAN_FILE_NAME=$env:TEMP+"\rman-arc.rman"
$RMAN_FILE_LOG=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\LOGS\"

Function print_usage{
  echo "Usage:"
  echo "  dbbackup-powershell.ps1 --level0"
  echo "  dbbackup-powershell.ps1 --level1"
  echo "  dbbackup-powershell.ps1 --arc"
  echo "  dbbackup-powershell.ps1 --expdp"
  echo "  dbbackup-powershell.ps1 --configure"
  echo "  dbbackup-powershell.ps1 --crosscheck"
  echo "  dbbackup-powershell.ps1 --validate"
}

switch ($operation)
{
    "--level0" {"Starting backup Level0"}
    "--level1" {"Starting backup Level1"}
    "--arc" {"Starting backup Archivelog";
    $RMAN_FILE_LOG=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\LOGS\arc-"+$(Get-Date -Format "ddMMyyyy-HHmmss")+".log";
    $RMAN_FILE_LOG
                echo $env:TEMP
                echo "run { " > $RMAN_FILE_NAME
                echo "     ALLOCATE CHANNEL C1 TYPE DISK MAXPIECESIZE 8G;" >> $RMAN_FILE_NAME
                echo "     DELETE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO DEVICE TYPE DISK COMPLETED BEFORE 'SYSDATE-36/24'; " >> $RMAN_FILE_NAME
                echo "     BACKUP ARCHIVELOG ALL  FORMAT '$RMAN_ARC_PATH/arc_%T_set%s_piece%p_copy%c_%t.bkp' FILESPERSET 64; " >> $RMAN_FILE_NAME
                echo "     RELEASE CHANNEL C1;" >> $RMAN_FILE_NAME
                echo " }" >> $RMAN_FILE_NAME
                rm $RMAN_FILE_NAME
          }
    "--crosscheck" {"Starting backup crosscheck"}
    Default {
        print_usage
    }
}