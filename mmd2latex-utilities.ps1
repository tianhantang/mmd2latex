# ////////////////////////////////////////////////////////////////
<#
	@summary:
	This utility script contains the following functions:
	- `check-whether-inside-block-comment`
	- `filter-out-line-comment`
	- `convert-cross-reference`
#>
# ////////////////////////////////////////////////////////////////

<#
	@brief: Checks whether the processing context is inside an HTML block comment based on the current state and the content of the current line.

	@details:
	- The $state variable should be used to determine whether the *next* line should be passed for further processing.
	- For general usage, the $state variable should be initialized to $true.
	- Therefore, the first line is always processed, even if it is a comment block start "<!--".
	- The comment block end "-->" is discarded if there is any.
	- The next stage line processor should handle the elimination of any remianing comment block start "<!--".
	- The next stage line processor should also handle the elmination of one line comment "<!--.-->"

	@param[in]:
	- $state: The current boolean state indicating if the processing context is outside (`$true`) or inside (`$false`) a block comment.
	- $line: A string representing the current line being processed. This line should contain no line breaks.
	
	@param[out]: bool, returns `$true` if the current context is determined to be outside of a block comment based on the input line, otherwise returns `$false`.

	@note: variable validation attribute `AllowEmptyString` is used to allow the input string to be empty. This is necessary because it is ordinary for a text file to contain empty lines.

	@date:
	- created on 2024-03-05
#>
function check-whether-inside-block-comment {
	param(
		[Parameter(Mandatory = $true)][bool]$state,								# Current state: $true if outside a comment block
		[Parameter(Mandatory = $true)][AllowEmptyString()][string]$line			# a single line (contains no line break)
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

<#
	@brief: Filters out lines that are entirely HTML comments or mark the start of an HTML comment block.

	@details:
	- This function strictly matches lines that start with "<!--" and end with "-->", representing a complete comment on a single line.
	- This function also matches lines that are exactly "<!--", marking the start of a block comment.
	- Lines that match these criteria are not passed to the next stage in the pipeline, effectively filtering them out.
	- All other lines are passed through unchanged for further processing.

	@param[in]:
	- $line: The single line of text to be processed. This can include empty strings, as the function is designed to accept and process any string input.

	@param[out]:
	- Returns $null for lines that match the specified comment patterns, indicating they should be filtered out.
	- For all other lines, the original line is returned, allowing it to be further processed in the pipeline.
#>
function filter-out-line-comment {
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)][AllowEmptyString()][string]$line	# a single line (contains no line break)
	)

	process {
		# Check for the exact start of a block comment
		if ($line -eq "<!--") {
			return $null
		}
		# Check for line comments that start and end on the same line
		elseif ($line -match '^<!--.*?-->$') {
			return $null
		}
		# If the line matches neither case, pass it to the next stage in the pipeline
		else {
			return $line
		}
	}
}

<#
	@brief: Converts mmd-style cross-references to corresponding LaTeX-style syntax with appropriate prefixes.

	@details:
	- This function searches for references in a specific Markdown format, identified by `[@type:label]`, and converts them into a LaTeX-valid format.
	- It supports different types of references, including figures, equations, tables, and sections, by prefixing them with the corresponding word (Figure, Equation, Table, Section) followed by a LaTeX `\ref{type:label}` command.

	@param[in]:
	- $line: The line of text to be processed. This line may contain zero or more references in the Markdown format that need to be converted to the LaTeX format.

	@example:
	- Input: "according to [@eq:01], we know that energy equals to mass times the speed of light squared."
	- Output: "according to Equation \ref{eq:01}, we know that energy equals to mass times the speed of light squared."

	@date:
	- created on 2024-02-25
	- updated on 2024-03-06
#>
function convert-cross-reference {
    param (
        [string]$line
    )

    # Define a hashtable to map prefixes to their corresponding text
    $prefixMap = @{
        'fig' = 'Figure';
        'eq'  = 'Equation';
        'tb' = 'Table';
        'sec' = 'Section'
    }

    # Regular expression to match the reference pattern
    $refPattern = '\[@ref:(\w+):(\w+)\]'

    # Find all matches in the line
    while ($line -match $refPattern) {
        $fullMatch = $matches[0]
        $type = $matches[1]
        $label = $matches[2]

        # Determine the prefix text based on the type
        $prefixText = $prefixMap[$type]

        # If the prefix is found, replace the reference with the LaTeX formatted reference
        if ($prefixText) {
            $replacement = "$prefixText \ref{${type}:${label}}"
            $line = $line -replace [regex]::Escape($fullMatch), $replacement
        }
		# @todo, there is a potential bug that if the prefix is not found, the program will enter an infinite loop
    }

    return $line
}
