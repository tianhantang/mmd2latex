<# @brief: Test the function `convert-cross-reference` #>

# Get the execution path
$entry_point = Get-ItemProperty $MyInvocation.MyCommand.Path
if ($null -ne $entry_point.Target) { # It is called via a symbolic link
	$script_dir = Split-Path $entry_point.Target -Parent
}
else {
	$script_dir = $entry_point.Directory.FullName
}

# Load the function
# - convert-cross-reference
. ([System.IO.Path]::Combine($script_dir, 'mmd2latex-utilities.ps1'))

# Read the test text file
$lines = Get-Content ([System.IO.Path]::Combine($script_dir, 'test_03.txt'))

# Output the results (for manual verification)
$converted_lines = $lines | convert-cross-reference

Write-Output "Test Results:"
Write-Output ">>>"
Write-Output $converted_lines # @note: $null is automatically removed from list
Write-Output "<<<"

<# Expected Output:
Test Results:
>>>
@brief: This text file test the conversion of mmd style cross-reference to its LaTeX counterpart

According to Equation \ref{eq:01}, we know that energy equals to mass times the speed of light squared.

Substituting Equation \ref{@eq:01-01} into \ref{@eq:01-02}, we arrive at \ref{@eq:01-03}.

One can refer to Figure \ref{fig:01} for detailed explanation of Equation \ref{eq:Ch1/Sec1/04}.

Section \ref{sec:01} contains Table \ref{tb:02}.

This line contains an invalid tag [@unknown:01].
<<<
#>
