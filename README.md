# Example

```
import proped;

auto loader = createPropertiesLoader();
auto properties = loader("config.json");
properties ~= loader("config-local.yml");

auto host = properties.getOrElse("server.host", "localhost");
auto port = properties.getOrElse("server.port", 8080);
```
