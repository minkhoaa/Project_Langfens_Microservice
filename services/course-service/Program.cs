using System.Runtime.InteropServices.Marshalling;
using course_service.Infrastructure;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();


// configure
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__COURSE")
                        ?? builder.Configuration.GetConnectionString("Course_DB")
                        ?? "Host=localhost;Port=5436;Database=course-db;Username=course;Password=course";
builder.Services.AddDbContext<CourseDbContext>(option => option.UseNpgsql(connectionString));


// DI



var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<CourseDbContext>();
    await context.Database.MigrateAsync();
}

// Configure the HTTP request pipeline.

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.MapGet("/", () => { return "Hello world"; });

app.Run();