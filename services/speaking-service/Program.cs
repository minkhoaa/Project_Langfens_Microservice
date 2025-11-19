using speaking_service.Features;
using speaking_service.Features.Helper;
using speaking_service.Features.Services;
using Whisper.net;
using Whisper.net.LibraryLoader;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddCors(option =>
{
    option.AddPolicy("FE", policy => policy
        .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});
builder.Services.AddSingleton<WhisperProcessor>(_ =>
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
app.UseCors("FE");
app.MapSpeakingEndpoint();
app.MapWebsocketSpeaking();
app.UseWebSockets();
app.Run();
