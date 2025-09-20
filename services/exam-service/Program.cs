using exam_service.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
var connectionString = builder.Configuration.GetConnectionString("Exam_DB") ?? Environment.GetEnvironmentVariable("CONNECTIONSTRING__EXAM");
builder.Services.AddDbContextPool<ExamDbContext>(option => option.UseNpgsql(connectionString));



var app = builder.Build();

// Configure the HTTP request pipeline.



app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.MapGet("/", () =>
{
    return "Hello world";
});

app.Run();
