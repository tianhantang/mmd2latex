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
# - filter-out-line-comment
. ([System.IO.Path]::Combine($script_dir, 'mmd2latex-utilities.ps1'))

# Read the test text file
$lines = Get-Content ([System.IO.Path]::Combine($script_dir, 'test_02.txt'))

# Output the results (for manual verification)
$filtered_lines = $lines | filter-out-line-comment

Write-Output "Test Results:"
Write-Output ">>>"
Write-Output $filtered_lines # @note: $null is automatically removed from list
Write-Output "<<<"

<# Expected Output:
Test Results:
>>>
@brief: This text file test the removal of HTML line comment

This line should remain.
This line should also remain.
<!-- This is NOT considered as a "pure" starting block comment.
This is inside the comment block, but should remain, since the test only handles line comment.
This is also inside the comment block, but shoudl remain.
-->
This line should remain.
<<<
#>
