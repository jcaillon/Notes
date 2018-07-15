# csharp

## Make an internal class visible to a test assembly

In the .cs file, after the using, put :

```cs
[assembly: InternalsVisibleTo("uHttpSharp.Test")]
```

```cs
public void AddLog(string message,
    [CallerMemberName] string memberName = "",
    [CallerFilePath] string sourceFilePath = "",
    [CallerLineNumber] int sourceLineNumber = 0)


var sf = new System.Diagnostics.StackTrace(1).GetFrame(0);
Console.WriteLine(" File: {0}", sf.GetFileName());
Console.WriteLine(" Line Number: {0}", sf.GetFileLineNumber());
// Note that the column number defaults to zero 
// when not initialized.
Console.WriteLine(" Column Number: {0}", sf.GetFileColumnNumber());
```
