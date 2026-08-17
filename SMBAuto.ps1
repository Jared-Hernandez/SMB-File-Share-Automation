$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[System.Collections.ArrayList]$arrayofvms = import-csv [REDACTED] | select-Object "DNS Name", "Name"
			#Location of storage for information:
$storagepath = '[REDACTED]'
Clear-Content -Path $storagePath
#$creds = get-credential


#testing and practice:
#(get-acl $sharedfolders[0].path).Access | format-table  	# ntfs permssions
#get-smbshareaccess -name $sharedfolders[0].name        	# Share permissions
#foreach( $element in $sharedfolders){get-smbshareaccess -name $element.name | select-object Name, AccountName, AccessRight}
#$arrayofVms[0]
															#finding and storing objects that are either contain a null or empty value
#$vmsWithoutDNS = $Arrayofvms | Where-Object { $_.'DNS name' -in $null, '' }

#begin gathering information:								#Store relevant information
# foreach( $element in $sharedfolders){
# 	$specific = get-smbshareaccess -name $element.name | select-object Name, AccountName, AccessRight 

# 	$specific | ForEach-Object {
#         	$_ | Add-Member -NotePropertyName "Server" -NotePropertyValue ([string]$arrayofvms[1].name) -Force
#         	$_ # Pass the updated row down the pipe
#     	} | Export-Csv $storagepath -NoTypeInformation -Append -Force 	  
# }
#$Sharedfolders =  Get-WmiObject -Class Win32_Share | where-object {$_.Description -ne "Remote Admin" -and $_.Description -ne "Remote IPC" -and $_.Description -ne "Default share"}
								#Arrays are a fixed size, so use array lists



$num = 10
$i = 0
for ($i = 0; $i -lt $arrayofvms.count; $i++) {
	
    try {
		if([string]::IsNullorEmpty($($arrayofVms[$i]."DNS Name"))){    #some vms do not have a DNS name in the file from CYS or APA
			$results = Invoke-Command -ComputerName $arrayofVms[$i].Name -ScriptBlock {

            $SharedFolders = Get-WmiObject -Class Win32_Share |
                Where-Object {											#grab specific folders
                    $_.Description -ne "Remote Admin" -and
                    $_.Description -ne "Remote IPC" -and
                    $_.Description -ne "Default share"
                }


                if($sharedfolders.count -eq 0){							#folders did not exist so create a variable
                    write-host "Nothing here"
					$emptyServermessage = [PSCustomObject]@{ Name =  "0" }
                    $emptyServermessage | Add-Member -NotePropertyName "AccessRight" -NotePropertyValue "0"
                    $emptyServermessage | Add-Member -NotePropertyName "AccountName" -NotePropertyValue "0"
                    return $emptyServermessage
                }

                else{													#folders did exist so iterate through them
                    foreach ($element in $SharedFolders) {
                        Get-SmbShareAccess -Name $element.Name |
                           Select-Object Name, AccountName, AccessRight
                    }
                    return $sharedfolders
                }
            }

		}
		else{								#same block of code, but executes for Vms that do have DNS (very likely)
			$results = Invoke-Command -ComputerName $arrayofVms[$i]."DNS Name" -ScriptBlock {

            $SharedFolders = Get-WmiObject -Class Win32_Share |
                Where-Object {											#grab specific folders
                    $_.Description -ne "Remote Admin" -and
                    $_.Description -ne "Remote IPC" -and
                    $_.Description -ne "Default share"
                }


                if($sharedfolders.count -eq 0){							#folders did not exist so create a variable
                    write-host "This Server contains no SMB Shares"
					$emptyServermessage = [PSCustomObject]@{ Name =  "0" }
                    $emptyServermessage | Add-Member -NotePropertyName "AccessRight" -NotePropertyValue "0"
                    $emptyServermessage | Add-Member -NotePropertyName "AccountName" -NotePropertyValue "0"
                    return $emptyServermessage
                }

                else{													#folders did exist so iterate through them
                    foreach ($element in $SharedFolders) {
                        Get-SmbShareAccess -Name $element.Name |
                           Select-Object Name, AccountName, AccessRight
                    }
                    return $sharedfolders
                }
            } 

		} 
		
		Write-Host "$($i+1) / $($arrayofVms.count): $($arrayofVms[$i].Name) complete`n" 	#print to make sure to user that progress is being made



        if ($results) { #If script successfully extracted information, proceed here, first cleanup returned data:
			$results = ($results | where-object{$_.AccountName -ne $null})
			$results = $results | select-object Name, AccessRight, AccountName
			

			if($results.name -eq 0){#if no shared folders exist in this server:
				$results | Add-member -NotePropertyName "Server" -NotePropertyValue "$($arrayofVms[$i].name)"
				$results | Export-Csv $storagepath -NoTypeInformation -Append -Force
			}
			else{				#Shared folders exist, iterate through them
				$results | ForEach-Object {
                	$_ | Add-Member -NotePropertyName "Server" `
                        	        -NotePropertyValue ([string]$arrayofVms[$i].Name) `
                    	            -Force

                	$_
           		} | Export-Csv $storagepath -NoTypeInformation -Append -Force
			}
        }
		
		else{     #script did not successfully extract information
			$errormessage = [PSCustomObject]@{ Server =  "Process Failed to Successfully Extract $($arrayofVms[$i]."DNS Name")" }
			$errormessage | Add-Member -NotePropertyName "Name" -NotePropertyValue "N/A"
			$errormessage | Add-Member -NotePropertyName "AccessRight" -NotePropertyValue "N/A"
			$errormessage | Add-Member -NotePropertyName "AccountName" -NotePropertyValue "N/A"
			Write-Warning "An Exception occurred: $($_.Exception.Message)"
			$errormessage | export-csv -path  $storagepath -NoTypeInformation -Append -Force
		}
    }
    catch {
		$errormessage = [PSCustomObject]@{ Server =  "Process Failed to Successfully Complete $($arrayofVms[$i]."DNS Name")" }
		$errormessage | Add-Member -NotePropertyName "Name" -NotePropertyValue "N/A"
		$errormessage | Add-Member -NotePropertyName "AccessRight" -NotePropertyValue "N/A"
		$errormessage | Add-Member -NotePropertyName "AccountName" -NotePropertyValue "N/A"
        Write-Warning "Could Not Do Something: $($_.Exception.Message)"
		$errormessage | export-csv -path  $storagepath -NoTypeInformation -Append -Force
    }
}



$Stopwatch.Stop()
Write-Host "Script completed in: $($Stopwatch.Elapsed.TotalSeconds) seconds"
pause
