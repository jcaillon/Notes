Types of Regex : different implementation 
If you post on stack overflow without specifying the type of Regex 
How Regex works implementation : back tracking 
When to use Regex and when is it bad : bad performance due to back tracking 


Basic goals of Regex 

Key concepts and vocabulary 
- matches group capture 

Usage examples :
- extracting pieces of text with sublime 
- validate email 
- complex searches 


Websites : 

- <https://regexr.com/>
- <https://regex101.com/>
- <http://www.rexegg.com/regex-quickstart.html>
- <https://www.regular-expressions.info/refflavors.html>

Ex :

    <!-- REGEX to build this -->
    <!-- <option value="([^"]*)">([^"]*)</option> -->
    <!-- <affectedVersion><jira_id>$1</jira_id><name>$2</name></affectedVersion> -->
    <!-- To do from http://forge.corp.sopra/jira2/secure/CreateIssue.jspa -->
	<!-- autre technique : aller à la page accueil d'un projet JIRA et cliquer sur une des versions, l'ID est présent dans l'URL  -->	
	<!-- Ex : http://forge.corp.sopra/jira2/browse/CSU/fixforversion/131521  -->
    <!-- Affected versions -->