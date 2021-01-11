/****************  Files  **************************#
#Check if file exists in 2 directories and move from one to archive folder
$Source = "C:\SOURCE"
$DestArchive = "C:\PROCESS_ARCHIVE"
$DestProcess = "C:\PROCESS"
$LocalArchive = "C:\LOCAL_ARCHIVE"

Get-ChildItem $Source | ForEach-Object {

    $filename = $_.Name

    if (Test-Path "$DestArchive\$filename")
    {
        Move-Item $_.FullName -Destination $LocalArchive -Force
    }
    else
    {
        Copy-Item $_.FullName -Destination $DestProcess -Force
    }

}


#****************  Login/USER  *********************#
Get-DbaLogin -SqlInstance sqlinstance01 -Login userlogin1

#Get Databases
Get-DbaDatabase -SqlInstance sqlinstance01\SQL01 -Database Database1
#Create Login
New-DbaLogin -SqlInstance sqlinstance01 -Login userlogin1
#Create User on databases
New-DbaDbUser -SqlInstance sqlinstance01\SQL01 -Login userlogin1 -Verbose
#Add role to user "db_datawriter"
Add-DbaDbRoleMember -SqlInstance sqlinstance01 -Role "db_datareader" -User userlogin1 -WhatIf

#remove login
Remove-DbaLogin -SqlInstance s-ihrdwhdb02aue.ihrcloud.net -Login userlogin1 -whatif
#remove user
Remove-DbaDbUser -SqlInstance s-ihrdwhdb02aue.ihrcloud.net -User userlogin1




#**********************  Event Logs  **************************#
$s = 'ccierspisl01tol'

Get-EventLog -ComputerName $s -LogName Application -Newest 10;


#***********************MSMQ*****************************#
gwmi -class Win32_PerfRawData_MSMQ_MSMQQueue -computerName $s | select __SERVER,Name,MessagesinQueue



#***********************SQL JOBS*****************************#
Get-DbaAgentJob -SqlInstance $s -Job 'sqljob' | select SqlInstance,Name,CurrentRunStatus,LastRunDate,LastRunOutcome
#Get-DbaAgentJob -SqlInstance $s -Job 'sqljob' | Stop-DbaAgentJob -verbose
Get-DbaAgentJob -SqlInstance $s -Job 'sqljob' | select SqlInstance,CurrentRunStatus
#Get-DbaAgentJob -SqlInstance $s -Job 'USERDB Fullbackup' | select SqlInstance,Name,CurrentRunStatus,LastRunDate,LastRunOutcome
Get-DbaAgentJob -SqlInstance $s -Job 'sqljob' | select SqlInstance,Name,NextRunDate
#Remove-DbaAgentJob -SqlInstance $s -Job 'USERDB Fullbackup'
Get-DbaAgentJob -SqlInstance $s -Job 'sqljob' | select SqlInstance,Name,CurrentRunStatus,LastRunDate,LastRunOutcome
#Get-DbaAgentJob -SqlInstance $s -Job 'sqljob' | Stop-DbaAgentJob -verbose
Get-DbaAgentJob -SqlInstance $s -Job 'sqljob' | select SqlInstance,CurrentRunStatus
#Get-DbaAgentJob -SqlInstance $s -Job 'USERDB Fullbackup' | select SqlInstance,Name,CurrentRunStatus,LastRunDate,LastRunOutcome
Get-DbaAgentJob -SqlInstance $s -Job 'sqljob' | select SqlInstance,Name,NextRunDate
#Remove-DbaAgentJob -SqlInstance $s -Job 'USERDB Fullbackup'
Get-DbaAgentJobHistory -SqlInstance vrsanatx01 -Job 'sqljob' | where stepname -EQ '(Job outcome)' | select SqlInstance,Job,RunDate,Duration,Status |  sort rundate |  ft -AutoSize


#***********************SQL FILES****************************#
Get-DbaDbFile -SqlInstance sqlinstance01 | select ComputerName,SqlInstance,Database,TypeDescription,LogicalName,PhysicalName,size | ft -AutoSize
Get-DbaDiskSpace -ComputerName computerName1 | ft -AutoSize
Get-DbaDbFile -SqlInstance sqlinstance01 | ft -AutoSize
Get-DbaDiskSpace -ComputerName computerName1 | ft -AutoSize
Get-DbaDbFile -SqlInstance sqlinstance01 | ft -AutoSize

#***********************Backup****************************#
Get-DbaDbBackupHistory -SqlInstance sqlinstance01 -Database Database1 -LastFull | select SqlInstance,Database,Type,TotalSize,DeviceType,Start,Duration,End,path

'sqljob'
'sqljob'

#Backup-DbaDatabase -SqlInstance $s -Database Database1 -Path "\ddve-prd-vmc-02.iheartmediait.com\SQL\Daily\Radio\$s" -Type Full -IgnoreFileChecks 
Get-DbaDbBackupHistory -sqlinstance $s -Database Database1 -LastFull | where path -NotMatch 'ddve-prd-vmc-02.iheartmediait.com' | select sqlinstance
Get-DbaDbBackupHistory -sqlinstance $s -Database Database1 -LastFull | where path -NotMatch 'ddve-prd-vmc-02.iheartmediait.com' | select sqlinstance

$s = 'VRAUBUAL01'; Backup-DbaDatabase -SqlInstance $s -Database Database1 -CopyOnly -CompressBackup -Path "\\ddve-prd-vmc-02.iheartmediait.com\SQL\Daily\Radio\$s\" -Type Full -Verbose -IgnoreFileChecks

Get-DbaDbBackupHistory -SqlInstance sqlinstance01  -Database Database1 -IncludeCopyOnly -Type full |  select SqlInstance,Database,Type,TotalSize,DeviceType,Start,Duration,End,path | ft -AutoSize


Get-DbaDbBackupHistory -SqlInstance sqlinstance01\sql01 -LastFull | select SqlInstance,Database,Type,TotalSize,DeviceType,Start,Duration,End,path


#Backup-DbaDatabase -SqlInstance $s -Database Database1 -Path "\ddve-prd-vmc-02.iheartmediait.com\SQL\Daily\Radio\$s" -Type Full -IgnoreFileChecks 
Get-DbaDbBackupHistory -sqlinstance $s -Database Database1 -LastFull | where path -NotMatch 'ddve-prd-vmc-02.iheartmediait.com' | select sqlinstance
Get-DbaDbBackupHistory -sqlinstance $s -Database Database1 -LastFull | where path -NotMatch 'ddve-prd-vmc-02.iheartmediait.com' | select sqlinstance

Get-DbaAgentJobHistory -SqlInstance sqlinstance01 -Job 'sqljob' | where stepname -EQ '(Job outcome)' | select SqlInstance,Job,RunDate,Duration,Status |  sort rundate |  ft -AutoSize

$s = 'VRAUBUAL01'; Backup-DbaDatabase -SqlInstance $s -Database Database1 -CopyOnly -CompressBackup -Path "\\ddve-prd-vmc-02.iheartmediait.com\SQL\Daily\Radio\$s\" -Type Full -Verbose -IgnoreFileChecks

Get-DbaDbBackupHistory -SqlInstance sqlinstance01  -Database Database1 -IncludeCopyOnly -Type full |  select SqlInstance,Database,Type,TotalSize,DeviceType,Start,Duration,End,path | ft -AutoSize


#****************************** Parallel Run ***************************************#
$List = cat ba1

$List = Get-VieroDBServerList

$ScriptBlock = {
    Param($S)
    #Here is where the code would need to be modified depending on the command you want run
    Try{
        $gd=(get-date).AddDays(-1)
        Get-DbaAgentJobHistory -SqlInstance $s -StartDate $($gd.Date) | where { ($_.StepName -eq '(Job outcome)') -and ($_.status -eq 'Failed') }
    }Catch{
      $Exception = $error[0].Exception; $PositionMessage = $error[0].InvocationInfo.PositionMessage ;$ScriptStackTrace = $error[0].ScriptStackTrace
      Write-Error "$Exception - $PositionMessage - $ScriptStackTrace"
    }
}

Try{
    $List | Start-RSJob -ScriptBlock $ScriptBlock -ArgumentList $Instance -throttle 10 | Out-Null
}Catch{
    $Exception = $error[0].Exception; $PositionMessage = $error[0].InvocationInfo.PositionMessage ;$ScriptStackTrace = $error[0].ScriptStackTrace
    Write-Error "$Exception - $PositionMessage - $ScriptStackTrace"
}

Write-Verbose "Waiting for jobs to finish"
Get-rsjob | wait-rsjob -ShowProgress | Out-Null

$FailedJobs=Get-RSjob | Where-Object {$_.State -eq 'Failed' -or ($_.HasErrors -eq $True)}

if($FailedJobs){
    Write-Verbose "Failed Job Output:"
    $FailedJobs | Get-rsjob | Receive-rsjob
    Write-Verbose "Successfull Job Output:"
    $AllObjects= Get-rsjob | Where-Object {$_.State -eq 'Completed' -and ($_.HasErrors -eq $False)} | Receive-rsjob
}Else{
    Write-Verbose "No Failed jobs were detected"
    Write-Verbose "Successfull Job Output:"
    $AllObjects= Get-rsjob | Receive-rsjob
}

Get-rsjob | remove-rsjob

$AllObjects | ft -autosize
#***********************************************************************************#

Get-Service -ComputerName computerName1 -DisplayName 'Service1','Service2' | Stop-Service -WhatIf




Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body '{"text":"Hello World!"}' -Uri ''


--Check allocation size
$wql = "SELECT Label, Blocksize, Name FROM Win32_Volume WHERE FileSystem='NTFS'"
Get-WmiObject -Query $wql -ComputerName '.' | Select-Object Label, Blocksize, Name



$Databases=Get-DbaDatabase -SqlInstance $OldServerIP -ExcludeDatabase  -WarningAction Stop

Backup-DbaDatabase -SqlInstance sqlinstance01 -ExcludeDatabase master,model,msdb -Path \\t-etrv8db01sat\l$\Migration -FilePath dbname-backuptype-timestamp.bak -Type Full -ReplaceInName  -Verbose -whatif
$backupinfo= $Databases | ForEach-Object { Backup-DbaDatabase -SqlInstance $($_.ComputerName) -Database $($_.Name) -Path "$nonprod_dir\$ProductionServername" -FilePath dbname-backuptype-timestamp.diff -Type Differential -ReplaceInName -CreateFolder -WarningAction Stop }

Get-DbaDbBackupHistory -SqlInstance sqlinstance01 -Database bms1 -Type Full | select SqlInstance,Database,Type,TotalSize,DeviceType,Start,Duration,End,path | ft -AutoSize



#Remove server performance metrics
Get-WmiObject -computerName computerName1 Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select Average
Get-WmiObject -computerName computerName1 Win32_Processor | select LoadPercentage


#File transfer
Start-BitsTransfer -Source 'file.txt' -Destination . 
