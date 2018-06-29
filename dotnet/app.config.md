# App.config

## Use application settings

### app.config

```xml
<appSettings>
  <add key="JiraUrlWebservice" value="https://constellation.soprasteria.com/jira2" />
  <add key="JiraBasicAuth" value="amlyYWNuYWZzdmM6U29wcmExMjMq" />
  <add key="ClientSettingsProvider.ServiceUri" value="" />
</appSettings>
```
### code usage

```csharp
ConfigurationManager.AppSettings["JiraUrlWebservice"];
```

## Configure trace

### app.config

```xml
  <system.diagnostics>

    <!-- controls the default Trace.Write() and Debug.Write() -->
    <trace autoflush="true" indentsize="4">
      <listeners>
        <remove name="Default" />
        <add name="file" initializeData="_default.log" type="System.Diagnostics.TextWriterTraceListener" />
      </listeners>
    </trace>

    <!-- don't show Debug.Assert as a message box -->
    <assert assertuienabled="false" />

    <switches>
      <!-- JiraRestClientLogSwitch : 0/1 activate jira webservice logs -->
      <add name="RestClientLogSwitch" value="0" />
      <add name="PostgresLogSwitch" value="0" />
    </switches>

    <sources>
      
      <!-- controls the custom Tracer -->
      <!-- Off, Critical, Error, Warning, Information, Verbose, All -->
      <source name="TraceLogSwitch" switchValue="Information">
        <listeners>
          <add name="console" type="System.Diagnostics.ConsoleTraceListener" />
          <add name="file" initializeData="_.log" type="System.Diagnostics.TextWriterTraceListener" />
        </listeners>
      </source>
    </sources>
  </system.diagnostics>
```

### Use System.net trace :

```xml
<sources>
  <source name="System.Net" tracemode="protocolonly" maxdatasize="1024">
    <listeners>
      <add name="System.Net"/>
    </listeners>
  </source>
  <source name="System.Net.Cache">
    <listeners>
      <add name="System.Net"/>
    </listeners>
  </source>
  <source name="System.Net.Http">
    <listeners>
      <add name="System.Net"/>
    </listeners>
  </source>
</sources>
<switches>
  <add name="System.Net" value="Verbose"/>
  <add name="System.Net.Cache" value="Verbose"/>
  <add name="System.Net.Http" value="Verbose"/>
  <add name="System.Net.Sockets" value="Verbose"/>
  <add name="System.Net.WebSockets" value="Verbose"/>
</switches>
<sharedListeners>
  <add name="System.Net" traceOutputOptions="DateTime" type="System.Diagnostics.TextWriterTraceListener" initializeData="_network.log"/>
</sharedListeners>
```

### code usage

```csharp
Debug.Listeners.Add(new ConsoleTraceListener());
Tracer.Listeners.Add(new ConsoleTraceListener());

public static TraceSource Tracer => new TraceSource("TraceLogSwitch");

public static BooleanSwitch RestClientLogSwitch => new BooleanSwitch("JiraRestClientLogSwitch", "");

public static TraceSwitch TraceLogSwitch => new TraceSwitch("TraceLogSwitch", "Entire application");
```

## Proxy

```xml
<system.net>
  <defaultProxy useDefaultCredentials="true" />
</system.net>
```