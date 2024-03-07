<#
	@brief: Convert madpang-customized-markdown (.mmd) text to LaTeX 2 text for manuscript preparation.

	@details:
	The content of the .mmd file is supposed to contain a single `#tag`, after which the actual content are subjected to the conversion.
	The conversion process includes:
	1. Process the .mmd file
		1.1 Starts from the first line after the `#tag`
		1.2 Remove the block comments
		1.3 Remove the line comments
		1.4 Convert the mmd-style cross-references to LaTeX-style syntax with appropriate prefixes
		1.5 Convert the mmd-style citations to LaTeX-style syntax with appropriate prefixes
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

# Read the INPUT TEXT
$mmd_lines = Get-Content ([System.IO.Path]::Combine($script_dir, 'test_markdown.mmd')) # @todo: Replace with the actual input file

# TEXT PROCESSING
# /////////////////////////////////////////////////////////
$tag_pattern = '^#(?<tag>\w[\w/_\-]+)'	# Define the pattern for the tag
$start_conversion = $false				# Initialize variables for the conversion
$block_comment_state = $true			# Initialize variables for the conversion ($true for normal text)
$output_lines = @()						# Initialize the output array
# ---
foreach ($line in $mmd_lines) {

	# Check whether to start the conversion	
	if (-not $start_conversion) {
		if ($line -match $tag_pattern) {
			$start_conversion = $true
		}
		continue # Skip the line
	}

	# Process the line
	# --------------------------------
	$output = $null
	if ($block_comment_state) {
		$output = $line | Where-Object {filter-out-line-comment $_} | convert-cross-reference | convert-citation
	}	
	# Update the block comment state
	$block_comment_state = check-whether-inside-block-comment -state $block_comment_state -line $line
	# --------------------------------

	# Append the output to the array
	$output_lines += $output

}

# OUTPUT
Write-Output $output_lines # @note: $null is automatically removed from list
