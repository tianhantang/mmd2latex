<# @brief: Test the function `filter-out-line-comment` #>

# Get the execution path
$entry_point = Get-ItemProperty $MyInvocation.MyCommand.Path
if ($null -ne $entry_point.Target) { # It is called via a symbolic link
	$script_dir = Split-Path $entry_point.Target -Parent
}
else {
	$script_dir = $entry_point.Directory.FullName
}

# Load the function
# - check-whether-inside-block-comment
. ([System.IO.Path]::Combine($script_dir, 'mmd2latex-utilities.ps1'))

# Read the test text file
$lines = Get-Content ([System.IO.Path]::Combine($script_dir, 'test_02.txt'))

# Output the results (for manual verification)
$filtered_lines = $lines | filter-out-line-comment

Write-Host "Test Results:"
Write-Host ">>>"
$filtered_lines | ForEach-Object {
	if ($null -ne $_) {
		Write-Host "`t$_"  # Tab is added for better visual clarity
	}
}
Write-Host "<<<"

<# Expected Output:
Test Results:
>>>
	@brief: This text file test the removal of HTML line comment

	This line should remain
	This line should also remain
	<!-- This is NOT considered as a "pure" starting block comment
	NOT the end of comment block -->
	This line remains
<<<
#>
