param (
    [string]$sourceFolder,
    [string]$replicaFolder,
    [string]$logFilePath
)

# Function to synchronize folders
function Sync-Folders {
    param (
        [string]$source,
        [string]$replica
    )

    # Ensure replica folder exists
    if (!(Test-Path -Path $replica -PathType Container)) {
        New-Item -ItemType Directory -Path $replica -Force | Out-Null
        Write-Output "Created replica folder: $replica"
    }

    # Get all files and folders in source folder
    $sourceItems = Get-ChildItem -Path $source -Recurse

    foreach ($item in $sourceItems) {
        $destinationPath = $item.FullName.Replace($source, $replica)

        # If item is a directory
        if ($item.PSIsContainer) {
            # Create directory if it doesn't exist in replica
            if (!(Test-Path -Path $destinationPath -PathType Container)) {
                New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
                Write-Output "Created folder: $destinationPath"
            }
        }
        # If item is a file
        else {
            # Copy file to replica
            Copy-Item -Path $item.FullName -Destination $destinationPath -Force -ErrorAction SilentlyContinue
            Write-Output "Copied file: $($item.FullName) to $($destinationPath)"
        }
    }

    # Remove any files or folders in replica that don't exist in source
    $replicaItems = Get-ChildItem -Path $replica -Recurse
    foreach ($replicaItem in $replicaItems) {
        $sourcePath = $replicaItem.FullName.Replace($replica, $source)
        if (!(Test-Path -Path $sourcePath)) {
            Remove-Item -Path $replicaItem.FullName -Force -Recurse
            Write-Output "Removed: $($replicaItem.FullName)"
        }
    }
}

# Perform synchronization
$output = Sync-Folders -source $sourceFolder -replica $replicaFolder

# Log output to file
if ($logFilePath) {
    $output | Out-File -FilePath $logFilePath -Append
}
