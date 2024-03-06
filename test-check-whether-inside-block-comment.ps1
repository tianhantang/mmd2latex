<# @brief: Test the function `check-whether-inside-block-comment` #>

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

# Initialize the state
$state = $true

# Read the test text file
$lines = Get-Content ([System.IO.Path]::Combine($script_dir, 'test_01.txt'))

# Expected output:
$expected_output = @(
	$true,
	$true,
	$true,
	$false,
	$false,
	$false,
	$true,
	$true,
	$true,
	$true,
	$true,
	$true
)

# Test the function
$idx = 0
foreach ($line in $lines) {
	# Save the state for the next iteration
	$state = check-whether-inside-block-comment -state $state -line $line

	# Verify the state
	if ($state -ne $expected_output[$idx]) {
		Write-Host "Error: state mismatch at line $idx"
		Write-Host "Expected: $($expected_output[$idx])"
		Write-Host "Actual: $state"
		# Return on error
		return
	}
	$idx++
}

# Test passed
Write-Host "TEST PASS"
