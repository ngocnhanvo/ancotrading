using Microsoft.Owin.Cors;
using Owin;
using Microsoft.Owin;
using Microsoft.AspNet.SignalR;

[assembly: OwinStartup(typeof(Startup))]

public class Startup
{
    public void Configuration(IAppBuilder app)
    {
        var hubConfiguration = new HubConfiguration();
        hubConfiguration.EnableJSONP = true;
        hubConfiguration.EnableDetailedErrors = true;
        hubConfiguration.EnableJavaScriptProxies = true;
        app.MapSignalR(hubConfiguration);

        app.UseCors(CorsOptions.AllowAll);
    }
}
