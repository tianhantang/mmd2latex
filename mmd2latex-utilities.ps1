# ////////////////////////////////////////////////////////////////
<#
	@brief:
	This utility script contains the following functions:
	- `check-whether-inside-block-comment`
	- `filter-out-line-comment`
	- `convert-cross-reference`
	- `convert-citation`

	@details:
	Functions are generally falls into categories of
	- block processing
	- line processing
	- character processing
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
	- Returns $false for lines that match the specified comment patterns, indicating they should be filtered out.
	- Returns $true for ordinary lines that should be passed to the next stage in the pipeline.

	@note:
	- Since in PowerShell, if the input parameter is set to [string], it will treat $null as emptry string "", this function is NOT intended to be directly chained in a pipeline, rather it is intended to conditionally chain pipelines.
#>
function filter-out-line-comment {
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)][AllowEmptyString()][string]$line	# a single line (contains no line break)
	)

	process {
		# Check for the exact start of a block comment
		if ($line -eq "<!--") {
			return $false
		}
		# Check for line comments that start and end on the same line
		elseif ($line -match '^<!--.*?-->$') {
			return $false
		}
		# If the line matches neither case, pass it to the next stage in the pipeline
		else {
			return $true
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
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)][AllowEmptyString()][string]$line	# a single line (contains no line break)
	)

	begin {
		# Define a hashtable to map prefixes to their corresponding text
		$prefix_map = @{
			'fig' = 'Figure';
			'eq'  = 'Equation';
			'tb' = 'Table';
			'sec' = 'Section'
		}

		# Regular expression to match the reference pattern
		# $pattern = '\[@(?<type>\w+):(?<label>\w+)\]'
		$pattern = '\[@(?<type>\w+):(?<label>[\w\/\-]+)\]'

		$callback = [System.Text.RegularExpressions.MatchEvaluator]{
			param($match)

			# Extract the type and label from the match
			$type = $match.Groups['type'].Value
			$label = $match.Groups['label'].Value
			$prefix = $prefix_map[$type]

			if ($prefix) {
				return "$prefix \ref{${type}:${label}}"
			} else {
				return $match.Value
			}
		}
	}

	process {
		# @note: Ordinary `-replace` operator does not populate the $match variable in a script block directly
		$result = [regex]::Replace($line, $pattern, $callback)

		return $result
	}
}

<#
	@brief: Converts mmd-style citation to corresponding LaTeX-style.

	@details:
	- This function searches for citation in a specific Markdown format, identified by `[@cite:label]`, and converts them into a LaTeX-valid format.

	@param[in]:
	- $line: The line of text to be processed. This line may contain zero or more citations in the Markdown format that need to be converted to the LaTeX format.

	@example:
	- Input: "As discussed in [@cite:Smith2020], the results are conclusive."
	- Output: "As discussed in \cite{Smith2020}, the results are conclusive."

	@date:
	- created on 2024-03-06
	- updated on 2024-03-06
#>
function convert-citation {
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)][AllowEmptyString()][string]$line	# a single line (contains no line break)
	)

	begin {
		# Regular expression to match the citation pattern
		$pattern = '\[@cite:(?<label>[\w\/\-]+)\]'

		$callback = [System.Text.RegularExpressions.MatchEvaluator]{
			param($match)

			# Extract the label from the match
			$label = $match.Groups['label'].Value

			return "\cite{$label}"
		}
	}

	process {
		# @note: Ordinary `-replace` operator does not populate the $match variable in a script block directly
		$result = [regex]::Replace($line, $pattern, $callback)

		return $result
	}
}

<#
	@brief: Handle LaTeX special characters by escaping them.

	@param[in]:
	- $line: The line of text to be processed. This line may contain zero or more LaTeX special characters that need to be escaped.

	@example:
	- Input: "It can scattering 100% of the incident acoustic wave."
	- Output: "It can scattering 100\% of the incident acoustic wave."

	@note:
	- Currently this function only handles `#`, `%`.
	- This is because the mmd is supposed to allow embeded LaTeX code.
#>
function escape-special-characters {
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)][AllowEmptyString()][string]$line	# a single line (contains no line break)
	)

	process {
		# Escape special characters
		$result = $line -replace '#', '\#' -replace '%', '\%'

		return $result
	}
}
