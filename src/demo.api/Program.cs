using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;

var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddAzureAppConfiguration(options =>
{
    DefaultAzureCredential azureCredentials = new(
        // Provide tenant id as shwon below or specify environment variable AZURE_TENANT_ID
        //new DefaultAzureCredentialOptions { 
        //    TenantId = "tenat-id-here"
        //}
        );
    options.Connect(
        new Uri("https://ch-wi-dev-euw-001-appconfig-ac.azconfig.io"),
        azureCredentials);

    options
            .Select(KeyFilter.Any, "ch-wi-dev-euw-001-rg")
            .Select(KeyFilter.Any, "ch-wi-dev-euw-001-rg-blue");

    SecretClient secretClient = new(
        new Uri("https://ch-wi-dev-euw-001-kv.vault.azure.net/"),
        azureCredentials);

    options.ConfigureKeyVault(kv =>
        kv.Register(secretClient));
   });

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
//if (app.Environment.IsDevelopment())
//{
    // Use swagger always as this is a demo
    app.UseSwagger();
    app.UseSwaggerUI();
//}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
