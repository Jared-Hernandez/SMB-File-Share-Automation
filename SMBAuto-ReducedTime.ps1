
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
[System.Collections.ArrayList]$arrayofvms = import-csv [REDACTED] | select-Object "DNS Name", "Name"
					
$vmNames = $arrayofVms."DNS Name".Where({ -not [string]::IsNullOrWhiteSpace($_) })
$vmsWithoutDNS = $Arrayofvms | Where-Object { $_.'DNS name' -in $null, '' }
$vmsWithoutDNS | select-object Name
$storagepath = '[REDACTED]'
Clear-Content -Path $storagePath
try {
    $results = Invoke-Command -ComputerName $vmNames -ScriptBlock {
        $SharedFolders = Get-WmiObject -Class Win32_Share |
            Where-Object {
                $_.Description -ne "Remote Admin" -and
                $_.Description -ne "Remote IPC" -and
                $_.Description -ne "Default share"
            }

        if ($SharedFolders.Count -eq 0) {
            write-host "Zero SMB Shares Present in $($Sharedfolders.PSComputerName)"
			$emptyServermessage = [PSCustomObject]@{ Name =  "0" }
            $emptyServermessage | Add-Member -NotePropertyName "AccessRight" -NotePropertyValue "0"
            $emptyServermessage | Add-Member -NotePropertyName "AccountName" -NotePropertyValue "0"
            return $emptyServermessage
        }

        else {
            foreach ($element in $SharedFolders) {
                Get-SmbShareAccess -Name $element.Name |
                Select-Object Name, AccountName, AccessRight
            }
            return $sharedfolders
        }
    }-ErrorVariable connectionErrors -throttlelimit 50

    if($results) { #If script successfully extracted information, proceed in here:
                $results = ($results | where-object{$_.AccountName -ne $null})
				$results | select-object Name, AccessRight, AccountName, PSComputerName | Export-Csv $storagepath -NoTypeInformation -Append -Force
    }
}

catch [System.ArgumentException] {
    Write-Host "Caught argument error: $_" -ForegroundColor Yellow
}
catch {
    Write-Host "Caught an unexpected error: $_" -ForegroundColor Red
}
if($connectionErrors){
        foreach ( $errorelement in $connectionErrors){
            $errormessage = [PSCustomObject]@{ PSComputerName =  "Process Failed to Extract $($errorElement.targetObject)" }
	        $errormessage | Add-Member -NotePropertyName "Name" -NotePropertyValue "N/A"
	        $errormessage | Add-Member -NotePropertyName "AccessRight" -NotePropertyValue "N/A"
	        $errormessage | Add-Member -NotePropertyName "AccountName" -NotePropertyValue "N/A"
	        #Write-Warning "An Exception occurred: $($_.Exception.Message)"
	        $errormessage | export-csv -path  $storagepath -NoTypeInformation -Append -Force
        }
}
    #same block of code but for the array of Servers that lack DNS name
try {
    $VmsResultsNamesOnly = Invoke-Command -ComputerName $vmswithoutDNS.Name -ScriptBlock {
        $SharedFolders = Get-WmiObject -Class Win32_Share |
            Where-Object {
                $_.Description -ne "Remote Admin" -and
                $_.Description -ne "Remote IPC" -and
                $_.Description -ne "Default share"
            }

        if ($SharedFolders.Count -eq 0) {
            write-host "Zero SMB Shares Present in $($Sharedfolders.PSComputerName)"
			$emptyServermessage = [PSCustomObject]@{ Name =  "0" }
            $emptyServermessage | Add-Member -NotePropertyName "AccessRight" -NotePropertyValue "0"
            $emptyServermessage | Add-Member -NotePropertyName "AccountName" -NotePropertyValue "0"
            return $emptyServermessage
        }

        else {
            foreach ($element in $SharedFolders) {
                Get-SmbShareAccess -Name $element.Name |
                Select-Object Name, AccountName, AccessRight
            }
            return $sharedfolders
        }
    }-ErrorVariable connectionErrors -throttlelimit 50

    if($VmsResultsNamesOnly) { #If script successfully extracted information, proceed in here:
                $VmsResultsNamesOnly = ($VmsResultsNamesOnly | where-object{$_.AccountName -ne $null})
				$VmsResultsNamesOnly | select-object Name, AccessRight, AccountName, PSComputerName | Export-Csv $storagepath -NoTypeInformation -Append -Force
    }
}

catch [System.ArgumentException] {
    Write-Host "Caught argument error: $_" -ForegroundColor Yellow
}
catch {
    Write-Host "Caught an unexpected error: $_" -ForegroundColor Red
}
if($connectionErrors){
        foreach ( $errorelement in $connectionErrors){
            $errormessage = [PSCustomObject]@{ PSComputerName =  "Process Failed to Extract $($errorElement.targetObject)" }
	        $errormessage | Add-Member -NotePropertyName "Name" -NotePropertyValue "N/A"
	        $errormessage | Add-Member -NotePropertyName "AccessRight" -NotePropertyValue "N/A"
	        $errormessage | Add-Member -NotePropertyName "AccountName" -NotePropertyValue "N/A"
	        #Write-Warning "An Exception occurred: $($_.Exception.Message)"
	        $errormessage | export-csv -path  $storagepath -NoTypeInformation -Append -Force
        }
}

$Stopwatch.Stop()
Write-Host "Script completed in: $($Stopwatch.Elapsed.TotalSeconds) seconds"