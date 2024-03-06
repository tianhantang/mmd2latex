<# @brief: Test the function `convert-citation` #>

# Get the execution path
$entry_point = Get-ItemProperty $MyInvocation.MyCommand.Path
if ($null -ne $entry_point.Target) { # It is called via a symbolic link
	$script_dir = Split-Path $entry_point.Target -Parent
}
else {
	$script_dir = $entry_point.Directory.FullName
}

# Load the function
# - convert-citation
. ([System.IO.Path]::Combine($script_dir, 'mmd2latex-utilities.ps1'))

# Read the test text file
$lines = Get-Content ([System.IO.Path]::Combine($script_dir, 'test_04.txt'))

# Output the results (for manual verification)
$converted_lines = $lines | convert-citation

Write-Output "Test Results:"
Write-Output ">>>"
Write-Output $converted_lines # @note: $null is automatically removed from list
Write-Output "<<<"

<# Expected Output:
Test Results:
>>>
# @brief: This text file test the conversion of mmd style citation to its LaTeX counterpart

As discussed in \cite{Smith2020}, the results are conclusive.

This line contains two citations \cite{Smith2020} and \cite{Johnson2021}.

This line contains an invalid tag [@unknown:01].
<<<
#>
