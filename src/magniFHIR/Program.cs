using magniFHIR.Data;
using MudBlazor.Services;
using System.Reflection;
using OpenTelemetry.Exporter;
using OpenTelemetry.Metrics;
using OpenTelemetry.Trace;
using System.Net;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Prometheus;
using OpenTelemetry.Resources;
using OpenTelemetry;
using magniFHIR.Config;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddSingleton<IFhirService, FhirService>();
builder.Services.AddSingleton(sp =>
{
    var config = sp.GetService<IConfiguration>();
    return config!.Get<FhirServersOptions>()!;
});

builder.Services.AddSingleton(sp =>
{
    var config = sp.GetService<IConfiguration>();
    return config!.Get<ResourceBrowsersOptions>()!;
});

var serverOptions = builder.Configuration.Get<FhirServersOptions>()!;

foreach (var server in serverOptions.FhirServers)
{
    var clientBuilder = builder.Services
        .AddHttpClient(server.NameSlug)
        .SetHandlerLifetime(TimeSpan.FromMinutes(5))
        .UseHttpClientMetrics();

    if (!string.IsNullOrEmpty(server.Auth?.Basic?.Username))
    {
        clientBuilder.ConfigurePrimaryHttpMessageHandler(() =>
        {
            return new HttpClientHandler()
            {
                UseDefaultCredentials = true,
                Credentials = new NetworkCredential(
                    server.Auth.Basic.Username,
                    server.Auth.Basic.Password
                ),
            };
        });
    }
}

builder.Services.AddMudServices();

// Tracing
var isTracingEnabled = builder.Configuration.GetValue("Tracing:Enabled", false);
if (isTracingEnabled)
{
    var assemblyVersion =
        Assembly.GetExecutingAssembly().GetName().Version?.ToString() ?? "unknown";
    var tracingExporter =
        builder.Configuration.GetValue<string>("Tracing:Exporter")?.ToLowerInvariant() ?? "jaeger";
    var serviceName = builder.Configuration.GetValue<string>("Tracing:ServiceName") ?? "magniFHIR";

    builder.Services
        .AddOpenTelemetry()
        .WithTracing(options =>
        {
            options
                .ConfigureResource(
                    r =>
                        r.AddService(
                            serviceName: serviceName,
                            serviceVersion: assemblyVersion,
                            serviceInstanceId: Environment.MachineName
                        )
                )
                .SetSampler(new AlwaysOnSampler())
                .AddHttpClientInstrumentation()
                .AddAspNetCoreInstrumentation(o =>
                {
                    o.Filter = (r) =>
                    {
                        var ignoredPaths = new[] { "/healthz", "/readyz", "/livez" };

                        var path = r.Request.Path.Value;
                        return !ignoredPaths.Any(path!.Contains);
                    };
                });

            switch (tracingExporter)
            {
                case "jaeger":
                    options.AddJaegerExporter();
                    builder.Services.Configure<JaegerExporterOptions>(
                        builder.Configuration.GetSection("Tracing:Jaeger")
                    );
                    break;

                case "otlp":
                    options.AddOtlpExporter(
                        otlpOptions =>
                            otlpOptions.Endpoint = new Uri(
                                builder.Configuration.GetValue<string>("Tracing:Otlp:Endpoint")
                                    ?? "http://localhost:4317"
                            )
                    );
                    break;
            }
        });
}

builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.Logger.LogInformation("Running in Production mode");
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseStaticFiles();

app.UseMetricServer(app.Configuration.GetValue("Metrics:Port", 8081));

app.UseRouting();
app.UseHttpMetrics();

app.MapHealthChecks("/healthz");
app.MapHealthChecks("/readyz", new HealthCheckOptions { Predicate = _ => false });
app.MapHealthChecks("/livez", new HealthCheckOptions { Predicate = _ => false });

app.MapRazorPages();
app.MapBlazorHub();

app.MapFallbackToPage("/_Host");

app.Run();
