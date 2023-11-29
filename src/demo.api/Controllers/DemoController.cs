using Microsoft.AspNetCore.Mvc;
using System.Text;

namespace demo.api.Controllers;

[ApiController]
[Route("api")]
public class DemoController : ControllerBase
{
    
    private readonly ILogger<DemoController> _logger;
    private readonly IConfiguration _configuration;

    public DemoController(ILogger<DemoController> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    [HttpGet("Test")]
    public string Test()
    {
        return "API is working...";
    }

    [HttpGet("ListAppConfigs")]
    public string ListAppConfigs()
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
}
