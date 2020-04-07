$OPERATION=$args[0]
$env:ORACLE_SID
$RMAN_BACKUP_HOME_DIR="C:\backup"
$RMAN_FILE_NAME=$env:TEMP+"\rman-arc.rman"
$RMAN_FILE_LOG=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\LOGS"
$RMAN_ARC_PATH=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\rman\arc"

Write-Output $RMAN_ARC_PATH
Function print_usage{
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
    "--level0" {"Starting backup Level0"}
    "--level1" {"Starting backup Level1"}
    "--arc" {"Starting backup Archivelog";
    $RMAN_FILE_LOG=$RMAN_BACKUP_HOME_DIR+"\$ORACLE_SID\LOGS\arc-"+$(Get-Date -Format "ddMMyyyy-HHmmss")+".log";
   
                Write-Output "run { " > $RMAN_FILE_NAME
                Write-Output "     ALLOCATE CHANNEL C1 TYPE DISK MAXPIECESIZE 8G;" >> $RMAN_FILE_NAME
                Write-Output "     DELETE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO DEVICE TYPE DISK COMPLETED BEFORE 'SYSDATE-36/24'; " >> $RMAN_FILE_NAME
                Write-Output "     BACKUP ARCHIVELOG ALL  FORMAT '$RMAN_ARC_PATH/arc_%T_set%s_piece%p_copy%c_%t.bkp' FILESPERSET 64; " >> $RMAN_FILE_NAME
                Write-Output "     RELEASE CHANNEL C1;" >> $RMAN_FILE_NAME
                Write-Output " }" >> $RMAN_FILE_NAME
                Write-Output $RMAN_FILE_NAME
                        type $RMAN_FILE_NAME | rman target /
               
          }
    "--crosscheck" {"Starting backup crosscheck"}
    Default {
        print_usage
    }
}