# Selenium Grid
Selenium Grid 4 for browser / UI tests: a hub plus Chrome, Firefox and Edge nodes (2 parallel sessions each).<br>
Grid UI + WebDriver endpoint: http://localhost:4447 (from other stacks: `http://selenium-hub:4444`)<br>
Watch a running test with noVNC: Chrome http://localhost:7900, Firefox http://localhost:7901, Edge http://localhost:7902
(password `Password123`).<br>

```csharp
// Selenium.WebDriver NuGet package
var options = new ChromeOptions();          // or FirefoxOptions / EdgeOptions
using var driver = new RemoteWebDriver(new Uri("http://localhost:4447"), options);
driver.Navigate().GoToUrl("http://host.docker.internal:5000/");   // your app, as seen from the browser container
```
Browsers run inside containers, so `localhost` there is the node itself. Use `host.docker.internal:<port>` for an app
on your machine (mapped on Linux too) or a GroupNetwork alias for another stack (e.g. `http://wiremock:8080`).

Playwright can use the grid for Chromium-based browsers: set `SELENIUM_REMOTE_URL=http://localhost:4447`.

All images share one tag (`SELENIUM_VERSION`, grid version + build date); each node tag ships that build's current
browser. Nodes use a 2 GB `/dev/shm` so Chrome doesn't crash on large pages. The Edge node is amd64 only.

https://www.selenium.dev/documentation/grid/
