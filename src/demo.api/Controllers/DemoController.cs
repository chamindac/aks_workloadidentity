using common.lib.Configs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using System.Text;

namespace demo.api.Controllers;

[ApiController]
[Route("api")]
public class DemoController : ControllerBase
{
    
    private readonly ILogger<DemoController> _logger;
    private readonly IConfiguration _configuration;
    private readonly Settings _settings;

    public DemoController(ILogger<DemoController> logger, IConfiguration configuration, IOptionsSnapshot<Settings> options)
    {
        _logger = logger;
        _configuration = configuration;
        _settings = options.Value;
    }

    [HttpGet("health")] // Fake health api call to support k8s probes. Do proper health endpoint implmentation for api (https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks?view=aspnetcore-8.0) 
    public string Test()
    {
        return "API is working...";
    }

    [HttpGet("ListAppConfigsFromIConfiguration")]
    public string ListAppConfigsFromIConfiguration()
    {
        StringBuilder sb = new ();
        sb.AppendLine("------------------------------------------------------");
        sb.AppendLine("App Config Values");
        sb.AppendLine("------------------------------------------------------");
        sb.AppendLine($"DemoSharedConfig1: {_configuration["DemoSharedConfig1"]}");
        sb.AppendLine($"DemoSharedConfig2: {_configuration["DemoSharedConfig2"]}");
        sb.AppendLine($"DemoConfig1: {_configuration["DemoConfig1"]}");
        sb.AppendLine($"DemoConfig2: {_configuration["DemoConfig2"]}");
        sb.AppendLine("------------------------------------------------------");
        sb.AppendLine("App Config KV Secret Values");
        sb.AppendLine("------------------------------------------------------");
        sb.AppendLine($"DemoSharedSecret1: {_configuration["DemoSharedSecret1"]}");
        sb.AppendLine($"DemoSharedSecret2: {_configuration["DemoSharedSecret2"]}");
        sb.AppendLine($"DemoBGSecret1: {_configuration["DemoBGSecret1"]}");
        sb.AppendLine($"DemoBGSecret2: {_configuration["DemoBGSecret2"]}");
        sb.AppendLine("------------------------------------------------------");

        return sb.ToString();
    }

    [HttpGet("ListAppConfigsFromAppSettngs")]
    public string ListAppConfigsFromSettings()
    {
        StringBuilder sb = new();
        sb.AppendLine("------------------------------------------------------");
        sb.AppendLine("App Config Values");
        sb.AppendLine("------------------------------------------------------");
        sb.AppendLine($"DemoSharedConfig1: {_settings.DemoSharedConfig1}");
        sb.AppendLine($"DemoSharedConfig2: {_settings.DemoSharedConfig2}");
        sb.AppendLine($"DemoConfig1: {_settings.DemoConfig1}");
        sb.AppendLine($"DemoConfig2: {_settings.DemoConfig2}");
        sb.AppendLine("------------------------------------------------------");
        sb.AppendLine("App Config KV Secret Values");
        sb.AppendLine("------------------------------------------------------");
        sb.AppendLine($"DemoSharedSecret1: {_settings.DemoSharedSecret1}");
        sb.AppendLine($"DemoSharedSecret2: {_settings.DemoSharedSecret2}");
        sb.AppendLine($"DemoBGSecret1: {_settings.DemoBGSecret1}");
        sb.AppendLine($"DemoBGSecret2: {_settings.DemoBGSecret2}");
        sb.AppendLine("------------------------------------------------------");

        return sb.ToString();
    }
}
