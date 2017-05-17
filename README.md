# Example

```
import proped;

auto loader = createPropertiesLoader();
auto properties = loader("config.json");
properties ~= loader("config-local.yml");


auto host = properties.getOrElse("server.host", "localhost");
auto port = properties.getOrElse("server.port", 8080);


auto serverConfig = properties.sub("server");
if (!serverConfig.isNull)
{
    auto sHost = serverConfig.getOrElse("host", "localhost");
    auto sPort = serverConfig.getOrElse("port", 8080);
}
```
