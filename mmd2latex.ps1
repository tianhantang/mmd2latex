<#
	@brief: Convert madpang-customized-markdown text to LaTeX 2 text

	@details:
	1. Remove the block comments
#>

# Get the execution path
$entry_point = Get-ItemProperty $MyInvocation.MyCommand.Path
if ($null -ne $entry_point.Target) { # It is called via a symbolic link
	$script_dir = Split-Path $entry_point.Target -Parent
}
else {
	$script_dir = $entry_point.Directory.FullName
}

# Load the utilities
. ([System.IO.Path]::Combine($script_dir, 'mmd2latex-utilities.ps1'))

# Initialize variables for the conversion
$block_comment_state = $true

# Read the INPUT TEXT
$mmd_lines = Get-Content ([System.IO.Path]::Combine($script_dir, 'test_01.txt')) # @todo: Replace with the actual input file

# TEXT PROCESSING
# /////////////////////////////////////////////////////////
$output_lines = @()
foreach ($line in $mmd_lines) {
	if ($block_comment_state) {
		$line | filter-out-line-comment
	}
	
	# Check whether inside a block comment
	$block_comment_state = check-whether-inside-block-comment -state $block_comment_state -line $line
	# Convert the line
	$line = convert-mmd2latex -line $line -block_comment_state $block_comment_state
	# Output the line
	Write-Host $line
}