param()

function Get-AllFolders ()
{
	$folderarray = Get-ChildItem -Directory -Recurse

	ForEach-Object { 
		Get-AllRepos
	}
}

function Get-AllRepos ()
{
    Get-ChildItem -Recurse -Depth 2 -Force |
        Where-Object { $_.Mode -match "h" -and $_.FullName -like "*\.git" } |
        ForEach-Object {
            $dir = Get-Item (Join-Path $_.FullName "../")
            Push-Location $dir
 
            "Fetching $($dir.Name)"
            function Get-AllRemoteBranches {
			     Invoke-Expression "git branch -r"                       `
			     | ForEach-Object { $_ -Match "origin\/(?'name'\S+)" }  `
			     | ForEach-Object { Out-Null; $matches['name'] }        
			}


			function Get-AllBranches {
			    Get-AllRemoteBranches `
                    | ForEach-Object { Invoke-Expression "git checkout $_" } `
                    | ForEach-Object { Invoke-Expression "git pull" }
            }
            
            Get-AllBranches
            Invoke-Expression "git checkout master"
            
            Pop-Location
        }
 }
 
Get-AllFolders
