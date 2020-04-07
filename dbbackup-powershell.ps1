$operation=$args[0]
$ORACLE_SID="ORCLNOVO"
$RMAN_BACKUP_HOME_DIR="C:\backup"


switch ($operation)
{
    "level0" {"Starting backup Level0"}
    "level1" {"Starting backup Level1"}
    "arc" {"Starting backup Archivelog"}
    "crosscheck" {"Starting backup crosscheck"}
}