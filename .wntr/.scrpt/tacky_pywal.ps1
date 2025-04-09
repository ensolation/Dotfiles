$walColorsPath = "C:/Users/boibl/.cache/wal/colors.json"
$tackyConfigPath = "C:/Users/boibl/.config/tacky-borders/config.yaml"

$walColors = Get-Content $walColorsPath -Raw | ConvertFrom-Json
$tackyConfigRaw = Get-Content $tackyConfigPath -Raw

$active_color = @("[`"$($walColors.colors.color1)`", `"$($walColors.colors.color6)`"]")
$inactive_color = @("[`"$($walColors.colors.color8)`", `"$($walColors.colors.color8)`"]")
$stack_color = @("[`"$($walColors.colors.color10)`", `"$($walColors.colors.color10)`"]")
$monocle_color = @("[`"$($walColors.colors.color11)`", `"$($walColors.colors.color11)`"]")
$floating_color = @("[`"$($walColors.colors.color12)`", `"$($walColors.colors.color12)`"]")

$updatedYaml = $tackyConfigRaw -replace "(?<=active_color:\s*colors:\s*)\[.*?\]", "$($active_color)"
$updatedYaml = $updatedYaml -replace "(?<=inactive_color:\s*colors:\s*)\[.*?\]", "['#00000000','#00000000']"
$updatedYaml = $updatedYaml -replace "(?<=stack_color:\s*colors:\s*)\[.*?\]", "$($stack_color)"
$updatedYaml = $updatedYaml -replace "(?<=monocle_color:\s*colors:\s*)\[.*?\]", "$($monocle_color)"
$updatedYaml = $updatedYaml -replace "(?<=floating_color:\s*colors:\s*)\[.*?\]", "$($floating_color)"

Set-Content -Path $tackyConfigPath -Value $updatedYaml.TrimEnd()
