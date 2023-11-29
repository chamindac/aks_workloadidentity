using Microsoft.AspNetCore.Mvc;

namespace demo.api.Controllers;

[ApiController]
[Route("api")]
public class DemoController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<DemoController> _logger;

    public DemoController(ILogger<DemoController> logger)
    {
        _logger = logger;
    }

    [HttpGet("Test")]
    public string Test()
    {
        return "API is working...";
    }
}
