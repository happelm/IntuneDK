# Define the folder path
$folderPath = "C:\TestFolder"

# Check if the folder exists
if (-not (Test-Path -Path $folderPath)) {
    # Create the folder if it does not exist
    New-Item -Path $folderPath -ItemType Directory
    Write-Output "Folder created at $folderPath"
} else {
    Write-Output "Folder already exists at $folderPath"
}
