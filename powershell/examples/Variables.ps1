#-----------------------------------------------------------------------------#
# Introduction
#-----------------------------------------------------------------------------#

Clear-Host

# All variables start with a $. Show a simple assignment
$hi = "Hello World"

# Print the value
$hi

Write-Host $hi

# Show the type
$hi.GetType()

# Types are mutable
Clear-Host
$hi = 5
$hi.GetType()


Clear-Host
[System.Int32]$myint = 42  # Can make strongly typed variables
$myint
$myint.GetType()

$myint = "This won't work"

# There are shortcuts for most .net types
Clear-Host
[int] $myotherint = 42
$myotherint.GetType()

[string] $mystring="Pluralsight"
$mystring.GetType()

# Others include short, float, decimal, single, bool, byte, etc

(42).GetType()  # Not just variables are types
"Pluralsight Rocks".GetType()

# Accessing methods on objects
"Pluralsight Rocks".ToUpper()
"Pluralsight Rocks".Contains("Pluralsight")

# Comparisons
$var = 42

$var -gt 40
$var -lt 40
$var -eq 42

# List is:
#   -eq        Equals
#   -ne        Not equal to
#   -lt        Less Than
#   -gt        Greater then
#   -le        Less than or equal to
#   -ge        Greater then or equal to

#   -Like      Like wildcard pattern matching
#   -NotLike   Not Like 
#   -Match     Matches based on regular expressions
#   -NotMatch  Non-Matches based on regular expressions

# Calculations are like any other language
$var = 3 * 11  # Also uses +, -, and / 
$var

$var++  # Supports unary operators ++ and --
$var

# Implicit Type Conversions
"42" -eq 42
42 -eq "42"

# Whatever is on the right is converted to the data type on the left
# Can lead to some odd conversions
42 -eq "042"   # True because the string is coverted to an int
"042" -eq 42   # False because int is converted to a string

##


























#-----------------------------------------------------------------------------#
# String Handling
#-----------------------------------------------------------------------------#

# String Quoting 
Clear-Host
"This is a string"
'This is a string too!'

# Mixed quoted
'I just wanted to say "Hello World", OK?'
"I can't believe how cool Powershell is!"

# You can also double quote to get quotes in strings
"I just wanted to say ""Hello World"", OK?"
'I can''t believe how cool Powershell is!'

# Escape Sequences - use the backtick ` --------------------------------
Clear-Host
#   backspace `b (have to show in real window)
"Plural`bsight"

#   newline `n
"Plural`nsight"

#   carriage return `r (doesn't really show anything)
"Plural`rsight"

#   crlf `r`n
"Plural`r`nsight"

#   tabs
"Plural`tsight"

# Here Strings - for large blocks of text ------------------------------
Clear-Host
$heretext = @"
Some text here
Some more here
     a bit more

a blank line above
"@
     
$heretext

# the @ and quote must be last on starting line then first on ending line
# also works with single quotes
$moreheretext = @'
Here we go again
another line here
   let's indent this
   
a blank line above
'@

# note how the nested ' is handled OK, no double quoting needed
$moreheretext

# String Interpolation ---------------------------------------------------------------------------------------------------
Set-Location C:\PS
Clear-Host
$items = (Get-ChildItem).Count
$loc = Get-Location
"There are $items items are in the folder $loc."

# To actually display the variable, escape it with a backtick
"There are `$items items are in the folder `$loc."

# String interpolation only works with double quotes
'There are $items items are in the folder $loc.'

# It does work with here strings
$hereinterpolation = @"
Items`tFolder
-----`t----------------------
$items`t`t$loc

"@

$hereinterpolation 

# Can use expressions in strings, need to be wrapped in $()
Clear-Host
"There are $((Get-ChildItem).Count) items are in the folder $(Get-Location)."

"The 15% tip of a 33.33 dollar bill is $(33.33 * 0.15) dollars"



# String Formatting - C# like syntax is supported
#   In C you'd use:
[string]::Format("There are {0} items.", $items)

# Powershell shortcut
"There are {0} items." -f $items

"There are {0} items in the location {1}." -f $items, $loc

"The 20% tip of a 33.33 dollar bill is {0} dollars" -f (33.33 * 0.20) 

"The 20% tip of a 33.33 dollar bill is {0:0.00} dollars" -f (33.33 * 0.20) 

# Wildcards
Clear-Host
"Pluralsight" -like "Plural*"
"Pluralsight" -like "arcane*"
"Pluralsight" -like "?luralsight"  # question marks work for single characters
"Pluralsight" -like "Plural*[s-v]" # ends in a char between s and v
"Pluralsight" -like "Plural*[a-c]" # ends in a char between a and c

# Regular Expressions
Clear-Host
"888-368-1240" -match "[0-9]{3}-[0-9]{3}-[0-9]{4}"  # Pluralsights phone number - reallY!
"ZZZ-368-1240" -match "[0-9]{3}-[0-9]{3}-[0-9]{4}"  # Not quite Pluralsights phone number
"888.368.1240" -match "[0-9]{3}-[0-9]{3}-[0-9]{4}"  # Pluralsights phone number - reallY!

##
































#-----------------------------------------------------------------------------#
# Arrays
#-----------------------------------------------------------------------------#

# Simple array
Clear-Host
$array = "arcane", "code"
$array[0]
$array[1]
$array

$array.GetType()

# Updating arrays
$array = "robert", "cain"
$array

$array[0] = "plural"
$array[1] = "sight"
$array

# Formal Array Creation Syntax
$array = @("plural", "sight")
$array

$array = @()   # Only way to create an empty array
$array.Count

$array = 1..5  # Can load arrays using numeric range notation
$array

# Check to see if an item exists
Clear-Host
$numbers = 1, 42, 256
$numbers -contains 42

$numbers -notcontains 99

$numbers -notcontains 42


##
































#-----------------------------------------------------------------------------#
# Hash tables 
#-----------------------------------------------------------------------------#

$hash = @{"Key"         = "Value"; 
          "Pluralsight" = "pluralsight.com"; 
          "Arcane Code" = "arcanecode.com"}
          
$hash                  # Display all values
$hash["Pluralsight"]   # Get a single value from the key

$hash."Pluralsight"    # Get single value using object syntax

# You can use variables as keys
$mykey = "Pluralsight"
$hash.$mykey         # Using variable as a property
$hash.$($mykey)      # Evaluating as an expression
$hash.$("Plural" + "sight")

# Adding and removing values
$hash                              # Here's what's there to start
$hash["Top Gear"] = "topgear.com"  # Add value using new key
$hash                              # Show the additional row

$hash.Remove("Arcane Code")        # Remove by passing in key
$hash

# See if key exists
$hash.Contains("Top Gear")         # Should be there
$hash.Contains("Arcane Code")      # Gone since we just removed it

# See if value exists
$hash.ContainsValue("pluralsight.com")  # Will be there
$hash.ContainsValue("arcanecode.com")   # Not there since it was removed

# List keys and values
$hash.Keys
$hash.Values

# Find if a key or value is present
$hash.Keys -contains "Pluralsight"

$hash.Values -contains "pluralsight.com"


##









































#-----------------------------------------------------------------------------#
# Built in variables
#-----------------------------------------------------------------------------#
Clear-Host
Set-Location "C:\ps\01 - intro"
# Automatic Variables

# False and true
$false
$true

# Null
$NULL


# Current directory
$pwd


# Users Home Directory
$Home  


# Info about a users machine
$host

# Process ID
$PID

# Info about the current version of Powershell
$PSVersionTable


$_   # Current Object
Get-ChildItem | Where-Object {$_.Name -like "*.ps1"}


##



































#-----------------------------------------------------------------------------#
# Using the *-Variable cmdlets
#-----------------------------------------------------------------------------#
Clear-Host

# Normal variable usage
$normal = 33
$normal

$text = "In the morning"
$text


# Long version of $var = 123
New-Variable -Name var -Value 123
$var

# Displays the variable and it's value
Get-Variable var -valueonly

Get-Variable var

Get-Variable   # Without params it shows all variables

# Assign a new value to an existing variable
# $var = 789
Set-Variable -Name var -Value 789
$var

# Clear the contents of a variable
# Same as $var = $null
Clear-Variable -Name var
# After a clear you can still access $var, but it has no value
$var   

# Wipe out a variable
Remove-Variable -Name var
# Now var is gone, if you try to remove or clear again an error occurs
# (note if you try to access it by just doing a $var the var is recreated)

Get-Variable var   # Now produces an error

$var
##



