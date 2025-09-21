using exam_service.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContextPool<ExamDbContext>(option => option.UseNpgsql(Environment.GetEnvironmentVariable("CONNECTIONSTRING__EXAM")
                                                                            ?? builder.Configuration.GetConnectionString("Exam_DB")));



var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
    await db.Database.MigrateAsync();
}



app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.MapGet("/", () =>
{
    return "Hello world";
});

app.Run();
