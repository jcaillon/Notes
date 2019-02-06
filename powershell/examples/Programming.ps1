#-----------------------------------------------------------------------------#
# Branching
#-----------------------------------------------------------------------------#
Clear-Host
# Branching - if/else
$var = 2
if ($var -eq 1)
{
  Clear-Host
  "If branch"
}
else
{
  Clear-Host
  "else branch"
}





  
# if elseif
if ($var -eq 1)
{
  Clear-Host
  "If -eq 1 branch"
}
else
{
    if ($var -eq 2)
    {
      Clear-Host
      "If -eq 2 branch"
    }
    else
    {
      Clear-Host
      "else else branch"
    }
}










# Switch statement for multiple conditions
Clear-Host
$var = 42                   # Also test with 43 and 49
switch  ($var)
{
  41 {"Forty One"}
  42 {"Forty Two"}
  43 {"Forty Three"}
  default {"default"}
}



# Will match all lines that match
Clear-Host
$var = 42
switch  ($var)
{
  42 {"Forty Two"}
  "42" {"Forty Two String"}
  default {"default"}
}






# To stop processing once a block is found use break
Clear-Host
$var = 42
switch  ($var)
{
  42 {"Forty Two"; break}
  "42" {"Forty Two String"}
  default {"default"}
}







# Switch works with collections, looping and executing for each match
Clear-Host
switch (3,1,2,42)
{
  1 {"One"}
  2 {"Two"}
  3 {"Three"}
  default {"The default answer"}
}












# String compares are case insensitive by default
Clear-Host
switch ("Pluralsight")
{
  "pluralsight" {"lowercase"}
  "PLURALSIGHT" {"uppercase"}
  "Pluralsight" {"mixedcase"}
}



# Use the -casesenstive switch to make it so
Clear-Host
switch -casesensitive ("Pluralsight")
{
  "pluralsight" {"lowercase"}
  "PLURALSIGHT" {"uppercase"}
  "Pluralsight" {"mixedcase"}
}









# Supports wildcards
Clear-Host
switch -Wildcard ("Pluralsight")
{
  "plural*" {"*"}
  "?luralsight" {"?"}
  "Pluralsi???" {"???"}
}

# Note it will also support regex matches

##








































#-----------------------------------------------------------------------------#
# Looping
#-----------------------------------------------------------------------------#

# While
Clear-Host
$i = 1
while ($i -le 5)
{
  "`$i = $i"
  $i = $i + 1
}



# won't execute if condition is already true
Clear-Host
$i = 6
while ($i -le 5)
{
  "`$i = $i"
  $i = $i + 1
}

# Do
Clear-Host
$i = 1
do
{
  "`$i = $i"
  $i++
} while($i -le 5)

# Do will always execute at least once
Clear-Host
$i = 6
do
{
  "`$i = $i"
  $i++
} while($i -le 5)

# Use until to make the check more positive
Clear-Host
$i = 1
do
{
  "`$i = $i"
  $i++
} until($i -gt 5)

# For loop interates a number of times
Clear-Host
for ($f = 0; $f -le 5; $f++)
{
  "`$f = $f"
}

# Note the initializer can be set seperately
Clear-Host
$f = 2
for (; $f -le 5; $f++)
{
  "`$f = $f"
}

# Iterating over a collection 1 by 1
Clear-Host
$array = 11,12,13,14,15   # Simple Array
for ($i=0; $i -lt $array.Length; $i++)
{
  "`$array[$i]=" + $array[$i]
}

# foreach works on a collection
Clear-Host
$array = 11,12,13,14,15   # Simple Array
foreach ($item in $array)
{
  "`$item = $item"
}

# foreach works with an array of objects
Clear-Host
Set-Location "C:\PS\01 - Intro"
foreach ($file in Get-ChildItem)
{
  $file.Name
}

# Combine with if to give a better focus
Clear-Host
Set-Location "C:\PS\01 - Intro"
foreach ($file in Get-ChildItem)
{
  if ($file.Name -like "*.ps1")
  {
    $file.Name
  }
}


# Use break to get out of the loop
Clear-Host
Set-Location "C:\PS\01 - Intro"
foreach ($file in Get-ChildItem)
{
  if ($file.Name -like "*.ps1")
  {
    $file.Name
    break  # exits the loop on first hit
  }
}

# Use continue to skip the rest of a loop but go onto the next iteration
Clear-Host
Set-Location "C:\PS\01 - Intro"
foreach ($file in Get-ChildItem)
{
  if ($file.Name -like "*.ps1")
  {
    $file.Name
    continue  # exits the loop on first hit
  }
  "This isn't a powershell file: $file"
}

# When used in a nested loop, break exits to the outer loop
Clear-Host
foreach ($outside in 1..3)
{
  "`$outside=$outside"
  foreach ($inside in 4..6)
  {
    "    `$inside = $inside"
    break
  }
}


# Use loop labels to break to a certain loop
Clear-Host
:outsideloop foreach ($outside in 1..3)
{
  "`$outside=$outside"
  foreach ($inside in 4..6)
  {
    "    `$inside = $inside"
    break outsideloop
  }
}


# Using continue inside an inner loop
Clear-Host
foreach ($outside in 1..3)
{
  "`$outside=$outside"
  foreach ($inside in 4..6)
  {
    "    `$inside = $inside"
    continue
    "this will never execute as continue goes back to start of inner for loop"
    # note, because we continue to the inside loop, the above line
    # will never run but it will go thru all iterations of the inner loop
  }
}

Clear-Host
:outsideloop foreach ($outside in 1..3)
{
  "`$outside=$outside"
  foreach ($inside in 4..6)
  {
    "    `$inside = $inside"
    continue outsideloop
    "this will never execute as continue goes back to start of inner for loop"
    # here, because we break all the way to the outer loop the last two
    # iterations (5 and 6) never run
  }
  "some more stuff here that will never run"
}


##









































#-----------------------------------------------------------------------------#
# Script Blocks
#-----------------------------------------------------------------------------#

# A basic script block is code inside {}
# The for (as well as other loops) execute a script block
for ($f = 0; $f -le 5; $f++)
{
  "`$f = $f"
}



# (note, to put multiple commands on a single line use the ; )
{Clear-Host; "Powershell and bowties are cool."}

# Exceucting only shows the contents of the block, doesn't execute it 


# You can store script blocks inside a variable
$cool = {Clear-Host; "Powershell and bowties are cool."}

$cool   # Just entering the variable though only shows the contents, doesn't run it

& $cool # To actually run it, use the & character

# Also works on blocks outside a variable
& {Clear-Host; "Fez hats are pretty cool too."}

# Since scripts can be put in a variable, you can do interesting things
$coolwall = {"Bugatti Veyron's are cool"}
$subzerowall = $coolwall
for ($i=0;$i -lt 3; $i++)
{ 
  &$coolwall;
  &$subzerowall;
}


# To return a value from a script, output it so it's not consumed
$value = {41 + 1}
& $value

1 + (&$value)  # to use in equation wrap in ()

1 + &$value    # this fails


# If you do multiple commands, it returns the first value
# not consumed, then runs the other commands
# (in this case it displays the message)
$value = { 42; Write-Host "Pluralsight is cool"}
&$value

# Because the text is consumed by the Write-Host cmdlet, it's not returned
# It just looks like it is because it displays the 42

# This will return 42, display the message, then add 1 to it and then display the result
1 + (&$value)  

# Places the return value of 42 in the variable, then displays the message
$fortytwo = &$value;

# Show the returned value
$fortytwo


# You can also use return to return a value, once you do though the script exits
$value = { return 42; Write-Host "Pluralsight is cool"}
&$value


# Using return alone will exit without returning anything
$value = { return; 42; Write-Host "Pluralsight is cool"}
&$value







# Parameters 1: Using the args collection
$qa = {
  $question = $args[0]
  $answer = $args[1]
  Write-Host "Here is your question: $question The answer is $answer"
}

&$qa "What is cool?" "Powershell!"



# Parameters 2: a more readable method - using the param block
$qa = {
  param ($question, $answer)
  Write-Host "Here is your question: $question The answer is $answer"
}

&$qa "What else is cool?" "Bowties!"
 
# You can also pass by name
&$qa -question "What else is cool?" -answer "Bowties!"

# With named parameters, order is not important
&$qa -answer "Bowties!" -question "What else is cool?" 

# You can shortcut parameter names by using only enough characters to make it unique
&$qa -a "Bugatti Veyron's!" -q "Is anything else cool?" 

# What happens when a value isn't passed:
&$qa "Question?" 

# By default it converts it to a null
# We can then check for an empty value
# (here, the ! (not) symbol implies the variable is not a value)
$qa = {
  param ($question, $answer)
  if (!$answer) { $answer = "Error: You must give an answer!" }
  Write-Host "Here is your question: $question The answer is $answer"
}

&$qa "Question?" 

# A shorthand syntax makes missing values behave like optional ones
$qa = {
  param ($question, $answer = "The question has no answer" )
  Write-Host "Here is your question: $question The answer is $answer"
}
&$qa "Question?" 





# You can use explicit typing on parameters
Clear-Host
$math = {
  param ([int] $x, [int] $y)
  return $x * $y
}

&$math 3 11

&$math 3 "x"






# Pipeline enabling a block
Set-Location "C:\PS\01 - Intro"

$onlyCoolFiles = 
{
  process { 
            if ($_.Name -like "*.ps1")
            { return $_.Name }
          }
}

Clear-Host
Get-ChildItem | &$onlyCoolFiles


# Use begin and end to run code prior to and after looping
# over the passed in pipeline data
$onlyCoolFiles = 
{
  begin  { $retval = "Here are some cool files: `r`n" }
  process { 
            if ($_.Name -like "*.ps1")
            { $retval = $retval + "`t" + $_.Name + "`r`n" }
          }
  end { return $retval }          
}

Clear-Host
Get-ChildItem | &$onlyCoolFiles



# You can combine pipelining with parameters
$onlyCoolFiles = 
{
  param ($headertext)
  begin  { $retval = $headertext + ": `r`n" }
  process { 
            if ($_.Name -like "*.ps1")
            { $retval = $retval + "`t" + $_.Name + "`r`n" }
          }
  end { return $retval }          
}

Clear-Host
Get-ChildItem | &$onlyCoolFiles "Here is my cool header text"

Get-ChildItem | &$onlyCoolFiles "These are as cool as bowties"

##




































#-----------------------------------------------------------------------------#
# Variable Scope
#-----------------------------------------------------------------------------#

# Variables declared outside a block are useable inside a block
Clear-Host
$var = 42
& { Write-Host "Inside block: $var"}
Write-Host "Outside block: $var"


# If you try to change the variable inside a block,
# Powershell makes a local copy and uses that, leaving the original alone
Clear-Host
$var = 42
& { $var = 33; Write-Host "Inside block: $var"}
Write-Host "Outside block: $var"

# Displaying variables is a shortcut to Get-Variable
Get-Variable var

Get-Variable var -valueOnly  # Displays only the value

# Using $var= is a shortcut for Set-Variable
Set-Variable "var" 99        # Same as $var=99

Get-Variable var -valueOnly  # Same as just $var

# The Get/Set-Variable supports a scope parameter
# 0 is current scope, 1 is it's parent, 2 grandparent and so on
# Using scope we can see both copies of $var
Clear-Host
$var = 42
& { $var = 33; 
    Write-Host "Inside block: $var"
    Write-Host "Parent: " (Get-Variable var -valueOnly -scope 1)}
Write-Host "Outside block: $var"


# Using Set-Variable with Scope you can change values outside a block
Clear-Host
$var = 42
& { Set-Variable var 33 -scope 1; 
    Write-Host "Inside block: $var"
}
Write-Host "Outside block: $var"



# You can also specify scope 
# making it global allows it to be used inside the script, and won't be copied
Clear-Host
$global:var = 42
& { $global:var = 33 }  
Write-Host "Outside block: $global:var"

# On the reverse side, private makes it very private
Clear-Host
$private:unmentionables = 42
& { Write-Host $unmentionables }  # Will be null
Write-Host "Outside block: $private:unmentionables"

# Can catch it by checking for null
Clear-Host
$private:unmentionables = 42
& { if ($unmentionables -eq $null) 
      {Write-Host "I can't show you my `$unmentionables, they are null."} 
  }  
Write-Host "Outside block: $private:unmentionables"



# Variables declared inside a block are available only in it (local scope)
Clear-Host
& { $localboy = 42; Write-Host "Inside block: $localboy" }
Write-Host "Outside block: $localboy" # Will be null


##


































#-----------------------------------------------------------------------------#
# Functions
#-----------------------------------------------------------------------------#

# Functions are basically script blocks with names.
function Get-Fullname($firstName, $lastName)
{
  Write-Host ($firstName + " " + $lastName)
}

Get-Fullname "Arcane" "Code"

# Unlike other languages, you don't use () or , 


# Rather than using Set-Variable with its -scope, you can pass by ref
# Note however it turns it into an object, thus requiring the .Value syntax
function Set-FVar([ref] $myparam)
{
  $myparam.Value = 33
}

Clear-Host
$fvar = 42
"fvar before: $fvar"
Set-FVar ([ref] $fvar) # Must add ref to call
"fvar after: $fvar"


# Read from pipeline
function Get-CoolFiles ()
{
  begin  { $retval = "Here are some cool files: `r`n" }
  process { 
            if ($_.Name -like "*.ps1")
            { $retval = $retval + "`t" + $_.Name + "`r`n" }
          }
  end { return $retval }          
}

Clear-Host
Get-ChildItem | Get-CoolFiles

# Above works but ties it to PS1



# Filters can be built to remove unwantd files
filter Show-PS1Files 
{
  $filename = $_.Name
  if ($filename -like "*.ps1")
  { 
    return $_
  }
}

Clear-Host
Get-ChildItem | Show-PS1Files

# This version doesn't check for the ps1, it just lists what's passed in
function List-FileNames ()
{
  begin  { $retval = "Here are some cool files: `r`n" }
  process { 
            $retval = $retval + "`t" + $_.Name + "`r`n" 
          }
  end { return $retval }          
}

Get-ChildItem | List-FileNames

# Now combine the two for real flexibility
Get-ChildItem | Show-PS1Files | List-FileNames

# Now to do other files, just create another filter
filter Show-TxtFiles 
{
  $filename = $_.Name
  if ($filename -like "*.txt")
  { 
    return $_
  }
}

Get-ChildItem | Show-TxtFiles | List-FileNames

# Now you have two ways to use your function
Clear-Host
Get-ChildItem | Show-PS1Files | List-FileNames
Get-ChildItem | Show-TxtFiles | List-FileNames




# Having your function output to the pipeline
Clear-Host
Set-Location "C:\PS\01 - Intro"
Get-ChildItem | Select-Object "Name"

function Get-ChildName ()
{
  Write-Output (Get-ChildItem | Select-Object "Name")
}

Get-ChildName | Where-Object {$_.Name -like "*.ps1"}


# Supporting -verbose and -debug options
# To support, first need to change the values of the special variables:
# $DebugPreference      Default is SilentlyContinue, change to Continue
# $VerbosePreference    Default is SilentlyContinue, change to Continue


function Get-ChildName ()
{
  param([switch]$verbose, [switch]$debug)
  
  if ($verbose.IsPresent)
  {
    $VerbosePreference = "Continue"    
  }
  else
  {
    $VerbosePreference = "SilentlyContinue"
  }
  
  if ($debug.IsPresent)
  {
    $DebugPreference = "Continue"    
  }
  else
  {
    $DebugPreference = "SilentlyContinue"
  }

  Write-Verbose "Current working location is $(Get-Location)"
  Write-Output (Get-ChildItem | Select-Object "Name")
  Write-Debug "OK I've selected some."
}

Get-ChildName
Get-ChildName -verbose
Get-ChildName -debug
Get-ChildName -verbose -debug


##






#-----------------------------------------------------------------------------#
# Error Handling
#-----------------------------------------------------------------------------#

function divver($enum,$denom)
{  
  Write-Host "Divver begin."
  $result = $enum / $denom
  Write-Host "Result: $result"
  Write-Host "Divver done."
}

Clear-Host
divver 33 11

divver 33 0



function divver($enum,$denom)
{   
  Write-Host "Divver begin."
  $result = $enum / $denom
  Write-Host "Result: $result"
  Write-Host "Divver done."
  
  trap
  {
    Write-Host "Oh NO! An error has occurred!!"
    Write-Host $_.ErrorID
    Write-Host $_.Exception.Message
    continue  # Continue will continue with the next line of code after the error
  }
}

Clear-Host
divver 33 0


function divver($enum,$denom)
{   
  Write-Host "Divver begin."
  $result = $enum / $denom
  Write-Host "Result: $result"
  Write-Host "Divver done."
  
  trap
  {
    Write-Host "Oh NO! An error has occurred!!"
    Write-Host $_.ErrorID
    Write-Host $_.Exception.Message
    break  # With break, or omitting it, error bubbles up to parent
  }
}

Clear-Host
divver 33 0


# Check for specific errors
function divver($enum,$denom)
{   
  trap [System.DivideByZeroException]
  {
    Write-Host "Hey, chowderhead, you can't divide by zero!"
    continue  
  }
  trap
  {
    Write-Host "Oh NO! An error has occurred!!"
    Write-Host $_.ErrorID
    Write-Host $_.Exception.Message
    break  # With break, or omitting it, error bubbles up to parent
  }

  Write-Host "Divver begin."
  $result = $enum / $denom  
  Write-Host "Result: $result"
  Write-Host "Divver done."
  
}


Clear-Host
divver 33 0

# Two main ways to handle errors
# Option 1 - Handle Error Internally - See above function

# Option 2 - Add trap logic in parent

# Change continue to break
function divver($enum,$denom)
{   
  trap [System.DivideByZeroException]
  {
    Write-Host "Hey, chowderhead, you can't divide by zero!"
    break  # With break, or omitting it, error bubbles up to parent
  }
  trap
  {
    Write-Host "Oh NO! An error has occurred!!"
    Write-Host $_.ErrorID
    Write-Host $_.Exception.Message
    break  # With break, or omitting it, error bubbles up to parent
  }

  Write-Host "Divver begin."
  $result = $enum / $denom  
  Write-Host "Result: $result"
  Write-Host "Divver done."
  
}

# Now call routine in a script block or other function
& {

  Clear-Host
  divver 33 0

  # Assume child has handled error, keep going silently
  trap
  {
    continue
  }
}





##







#-----------------------------------------------------------------------------#
# Adding Help to Your Functions
#-----------------------------------------------------------------------------#
Clear-Host
Get-Help Get-ChildName


# Custom tags within a comment block that Get-Help will recognize
# Note that not all of them are required
# .SYNOPSIS - A brief description of the command
# .DESCRIPTION - Detailed command description
# .PARAMETER name - Include one description for each parameter
# .EXAMPLE - Detailed examples on how to use the command
# .INPUTS - What pipeline inputs are supported
# .OUTPUTS - What this funciton outputs
# .NOTES - Any misc notes you haven't put anywhere else
# .LINK - A link to the URL for more help. Use one .LINK tag per URL
# Use "Get-Help about_comment_based_help" for full list and details

function Get-ChildName ()
{
<#
  .SYNOPSIS
  Returns a list of only the names for the child items in the current location.
  
  .DESCRIPTION
  This function is similar to Get-ChildItem, except that it returns only the name
  property. 
  
  .INPUTS
  None. 
  
  .OUTPUTS
  System.String. Sends a collection of strings out the pipeline. 
  
  .EXAMPLE
  Example 1 - Simple use
  Get-ChildName
  
  .EXAMPLE
  Example 2 - Passing to another object in the pipeline
  Get-ChildName | Where-Object {$_.Name -like "*.ps1"}

  .LINK
  Get-ChildItem 
  
#>

  Write-Output (Get-ChildItem | Select-Object "Name")
  
}

Clear-Host
Get-Help Get-ChildName


Clear-Host
Get-Help Get-ChildName -full
































#-----------------------------------------------------------------------------#
# Working with Files
#-----------------------------------------------------------------------------#
Clear-Host
Set-Location "C:\PS\01 - Intro"
Get-ChildItem "?.txt"

Get-Content "a.txt"
$a = Get-Content "a.txt"

Clear-Host
$a

# Looks are deceptive, this is actually an array
$a[0]
$a[3]

$a.GetType()

Clear-Host
for($i=0;$i -le $a.Count;$i++)
{$a[$i]}

# To combine, we can use Join, passing in the seperator and the variable
$separator = [System.Environment]::NewLine  # could have done `r`n
$all = [string]::Join($separator, $a)

$all

$all.GetType()

# Supports wildcards
$courses = Get-Content "?.txt"
$courses

$allcourses = [string]::Join($separator, $courses)
$allcourses

# To write things to disk, use Set-Content

# Just to prove it's not there
Get-ChildItem "All Courses.txt"  

Set-Content -Value $allcourses -Path "All Courses.txt"

Get-Content "All Courses.txt"

# Set-Content is destructive!!! If the file exists it's overwritten
Set-Content -Value "Powershell" -Path "All Courses.txt"
Get-Content "All Courses.txt"

# To append, use Add-Content
Set-Content -Value $allcourses -Path "All Courses.txt" # Recreate file
Get-Content "All Courses.txt" # Show it

Add-Content -Value "Powershell" -Path "All Courses.txt"
Get-Content "All Courses.txt" # Show it again with new course

# Clean up afterward
Remove-Item "All Courses.txt"


# CSV files
# Use it to save objects
Get-Process | Export-Csv "Processes.csv"

# And then read them
$header = "__NounName","Name","Handles","VM","WS","PM","NPM","Path","Company","CPU","FileVersion","ProductVersion","Description","Product","BasePriority","ExitCode","HasExited","ExitTime","Handle","HandleCount","Id","MachineName","MainWindowHandle","MainWindowTitle","MainModule","MaxWorkingSet","MinWorkingSet","Modules","NonpagedSystemMemorySize","NonpagedSystemMemorySize64","PagedMemorySize","PagedMemorySize64","PagedSystemMemorySize","PagedSystemMemorySize64","PeakPagedMemorySize","PeakPagedMemorySize64","PeakWorkingSet","PeakWorkingSet64","PeakVirtualMemorySize","PeakVirtualMemorySize64","PriorityBoostEnabled","PriorityClass","PrivateMemorySize","PrivateMemorySize64","PrivilegedProcessorTime","ProcessName","ProcessorAffinity","Responding","SessionId","StartInfo","StartTime","SynchronizingObject","Threads","TotalProcessorTime","UserProcessorTime","VirtualMemorySize","VirtualMemorySize64","EnableRaisingEvents","StandardInput","StandardOutput","StandardError","WorkingSet","WorkingSet64","Site","Container"
$processes = Import-Csv "Processes.csv" -Header $header
$processes



# XML Files
# Create an XML Template
$courseTemplate = @"
<courses version="1.0">
  <course>
    <name></name>
    <level></level>
  </course>
</courses>
"@

$courseTemplate | Out-File "C:\PS\01 - Intro\PluralsightCourses.xml"

# Create a new XML variable and load it from the file
$courseXml = New-Object xml
$courseXml.Load("C:\PS\01 - Intro\PluralsightCourses.xml")

# Grab the template
$newCourse = (@($courseXml.courses.course)[0]).Clone()

# Loop over the collection from the CSV and add them to the XML
$header = "Course", "Level"
$coursecsv = Import-Csv "All Courses.csv" -Header $header

for($i=0;$i -lt $coursecsv.Count;$i++)
{
  $newCourse = $newCourse.Clone() # copy the previous object, or for the first time copy the template
  $newCourse.Name = $coursecsv[$i].Course
  $newCourse.Level = $coursecsv[$i].Level
  $courseXml.Courses.AppendChild($newCourse) > $null # If you don't redirect to Null it echos each append to the console
}
  
# Remove the template since we now have data
$courseXml.Courses.Course | 
  Where-Object { $_.Name -eq "" } |
  ForEach-Object { [void]$courseXml.Courses.RemoveChild($_) }

# Save to XML file
$courseXml.Save("C:\PS\01 - Intro\PluralsightCourses.xml")


# Open it up and show as a plain text file 
$testxml = Get-Content "C:\PS\01 - Intro\PluralsightCourses.xml"  
$testxml


# Open it up and work with it as an XML file
[xml]$myCoursesXml = Get-Content "C:\PS\01 - Intro\PluralsightCourses.xml"  
foreach ($course in $myCoursesXml.Courses.Course)
{
  Write-Host "The course" $course.Name "is a Level" $course.Level "course."
}


##