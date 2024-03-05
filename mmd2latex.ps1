<#
	@brief: Checks whether the processing context is inside an HTML block comment based on the current state and the content of the current line.

	@param[in]: $state, the current boolean state indicating if the processing context is outside (`$true`) or inside (`$false`) a block comment.
	@param[in]: $line, a string representing the current line being processed. This line should contain no line breaks.
	
	@param[out]: bool, returns `$true` if the current context is determined to be outside of a block comment based on the input line, otherwise returns `$false`.

	@date:
	- created on 2024-03-05
#>
function check-whether-inside-block-comment {
    param(
        [Parameter(Mandatory = $true)][bool]$state, # Current state: $true if outside a comment block
        [Parameter(Mandatory = $true)][string]$line # a single line (contains no line break)
    )

    if ($line -eq "<!--") {
        return $false # Now inside a block comment
    }
    elseif ($line -eq "-->") {
        return $true # Exiting a block comment
    }
    else {
        return $state # No change in state
    }
}
