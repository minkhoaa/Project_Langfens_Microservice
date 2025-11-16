using Microsoft.AspNetCore.Http.Features;
using speaking_service.Features;
using speaking_service.Features.Helper;
using speaking_service.Features.Services;
using Whisper.net;
using Whisper.net.LibraryLoader;

var builder = WebApplication.CreateBuilder(args);


// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSingleton<WhisperProcessor>( _ =>
{
    RuntimeOptions.RuntimeLibraryOrder = [
        RuntimeLibrary.Cuda,   
        RuntimeLibrary.Cpu,      
        RuntimeLibrary.CpuNoAvx
    ];
    var modelPath = WhisperModelHelper.EnsureModelDownloadedAsync().GetAwaiter().GetResult();
    var factory = WhisperFactory.FromPath(modelPath);
    return factory.CreateBuilder().WithLanguage("en").Build();
});




builder.Services.AddScoped<IWhisperService, WhisperService>();





var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapSpeakingEndpoint();
app.UseWebSockets();
app.Run();
