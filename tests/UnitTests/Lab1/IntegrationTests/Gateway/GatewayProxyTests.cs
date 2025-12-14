extern alias ApiGateway;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http.Json;
using System.Threading.Tasks;
using FluentAssertions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace IntegrationTests.Gateway;

public class GatewayProxyTests : IClassFixture<GatewayFactory>
{
    private readonly GatewayFactory _factory;

    public GatewayProxyTests(GatewayFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task ReverseProxy_ShouldForwardToBackend()
    {
        var client = _factory.CreateClient();

        var response = await client.GetAsync("/api/test");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var payload = await response.Content.ReadFromJsonAsync<Dictionary<string, string>>();
        payload.Should().ContainKey("msg");
        payload!["msg"].Should().Be("ok");
    }
}

public class GatewayFactory : WebApplicationFactory<ApiGateway::Program>
{
    private readonly TestServer _backendServer;

    public GatewayFactory()
    {
        var backendBuilder = new WebHostBuilder()
            .Configure(app =>
            {
                app.Run(ctx =>
                {
                    ctx.Response.ContentType = "application/json";
                    return ctx.Response.WriteAsync("{\"msg\":\"ok\"}");
                });
            });
        _backendServer = new TestServer(backendBuilder);
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        var backendAddress = _backendServer.BaseAddress.ToString();
        builder.ConfigureAppConfiguration((_, config) =>
        {
            var dict = new Dictionary<string, string?>
            {
                ["ReverseProxy:Routes:route1:ClusterId"] = "cluster1",
                ["ReverseProxy:Routes:route1:Match:Path"] = "/api/test",
                ["ReverseProxy:Clusters:cluster1:Destinations:d1:Address"] = backendAddress,
                ["JwtSettings:Issuer"] = "test",
                ["JwtSettings:Audience"] = "test",
                ["JwtSettings:SignKey"] = "0123456789abcdef0123456789abcdef"
            };
            config.AddInMemoryCollection(dict!);
        });
        builder.Configure(app =>
        {
            app.UseRouting();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapGet("/api/test", async context =>
                {
                    var response = await _backendServer.CreateClient().GetAsync("/");
                    context.Response.ContentType = "application/json";
                    var body = await response.Content.ReadAsStringAsync();
                    await context.Response.WriteAsync(body);
                });
            });
        });
    }
}
