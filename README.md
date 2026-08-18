
I automated the remote connection and data extraction of SMB file shares for 97% of Hensel Phelp’s Microsoft servers. I then adjusted my code so it can perform more efficiently, which is why there are two versions. My first attempt created individual, sequential and alphabetically ordered remote connections. In my second attempt I went back and revised my code by adding all necessary information at once in an array and created batches of 50 connections which brought down the time from 6-7 minutes to less than 30 seconds




Access to video of script being Demo-ed:
https://github.com/Jared-Hernandez/SMB-File-Share-Automation/issues/1#issue-5175441609








Special shout outs to these resources that helped me with my task:
https://www.techtarget.com/it-infrastructure/tutorial/Reveal-Windows-file-server-permissions-with-PowerShells-help#:~:text=Find%20Windows%20file%20server%20permissions%20with%20the%20Get%2DAcl%20cmdlet&text=One%20of%20PowerShell's%20default%20cmdlets,in%20the%20folder's%20security%20descriptor.&text=The%20Access%20property%20on%20the,control%20list%20of%20the%20folder.

https://www.cyberdrain.com/documenting-with-powershell-chapter-5-file-share-permissions/

https://adamtheautomator.com/ntfs-permissions/

https://learn.microsoft.com/en-us/powershell/module/smbshare/get-smbshareaccess?view=windowsserver2025-ps

https://www.reddit.com/r/PowerShell/comments/rpndqe/how_to_loop_through_an_array_using_powershell/
