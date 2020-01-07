#requires -version 5.0
#requires -modules sqlserver

<#
.SYNOPSIS
    Export SQL server table to csv file with quotes and header

.DESCRIPTION
    Piping Invoke-Sqlcmd into csv file and save quotes only if needed.
    Also replace False and True on 0 and 1 for bit types columns.

.NOTES
   Original link: http://www.sqlmovers.com/removing-quotes-from-csv-created-by-powershell/
   Author: Russ Loski
   Version: 1.1
   Modified: 2020-01-07 by Konstantin Taranov
   Source link: https://github.com/ktaranov/sqlserver-kit/blob/master/Powershell/Export_Query_To_Csv.ps1
#>

$databaseName = "master";
$fileName = $tableName = "sys.objects";
$delimeter = ",";

Invoke-Sqlcmd -Query "SELECT * FROM $tableName;" `
              -Database $databaseName `
              -Server localhost |
ConvertTo-CSV -NoTypeInformation `
               -Delimiter $delimeter |
               % {$_ -replace  `
              '\G(?<start>^|,+)(("(?<output>[^,"]*?)"(?=,|$))|(?<output>".*?(?<!")("")*?"(?=,|$)))' `
              ,'${start}${output}'} |
               % {$_ -replace ($delimeter + 'False'), ($delimeter + '0')} |
               % {$_ -replace ($delimeter + 'True'), ($delimeter + '1')} |
Out-File "$fileName.csv" -fo -en utf8 ; 
