# Define the source file path
$sourceFile = "C:\Users\boibl\.cache\wal\colors.css"

# Define the destination folder and new file name
$destinationFile = "C:\Users\boibl\.config\yasb\styles.css"

# Read the content of the source and destination files
$sourceContent = Get-Content -Path $sourceFile -Raw
$destinationContent = Get-Content -Path $destinationFile -Raw

# Extract CSS variables from source file
$sourceVars = @{}
$rootRegex = [regex]'(?s):root\s*\{\s*(.*?)\s*\}'
$sourceRootMatch = $rootRegex.Match($sourceContent)

if ($sourceRootMatch.Success) {
    $varRegex = [regex]'--([\w-]+)\s*:\s*([^;]+);'
    $varMatches = $varRegex.Matches($sourceRootMatch.Groups[1].Value)
    
    foreach ($match in $varMatches) {
        $varName = "--" + $match.Groups[1].Value
        $varValue = $match.Groups[2].Value.Trim()
        $sourceVars[$varName] = $varValue
    }
}

# Find and update :root in destination file
$destRootMatch = $rootRegex.Match($destinationContent)

if ($destRootMatch.Success) {
    $fullRootMatch = $destRootMatch.Value
    
    # Build new root content while preserving order
    $newRootContent = ":root {`n"
    $varRegex = [regex]'--([\w-]+)\s*:\s*([^;]+);'
    $varMatches = $varRegex.Matches($destRootMatch.Groups[1].Value)
    
    foreach ($match in $varMatches) {
        $varName = "--" + $match.Groups[1].Value
        # Use source value if exists, otherwise keep original value
        $varValue = if ($sourceVars.ContainsKey($varName)) { $sourceVars[$varName] } else { $match.Groups[2].Value.Trim() }
        $newRootContent += "    ${varName}: ${varValue};`n"
    }
    
    # Add any new variables from source that weren't in destination
    foreach ($varName in $sourceVars.Keys) {
        if ($varMatches.Count -eq 0 -or -not ($varMatches | ForEach-Object { "--$($_.Groups[1].Value)" } | Where-Object { $_ -eq $varName })) {
            $newRootContent += "    ${varName}: $($sourceVars[$varName]);`n"
        }
    }
    
    $newRootContent += "}"
    
    # Replace old root with new root
    $updatedContent = $destinationContent.Replace($fullRootMatch, $newRootContent)
    Set-Content -Path $destinationFile -Value $updatedContent
}
