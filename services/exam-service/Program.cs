using exam_service.Data;
using Microsoft.EntityFrameworkCore;
using Shared.Contracts.Contracts;

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
await using (var scope = app.Services.CreateAsyncScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
    var pending = (await db.Database.GetPendingMigrationsAsync()).ToList();
    Console.WriteLine($"[EF] Pending migrations: {pending.Count} => {string.Join(", ", pending)}");
    await db.Database.MigrateAsync();
}


app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

// MINIMAL API
app.MapGet("/api/all-exams", async (ExamDbContext context) =>
{  
    try {
        var exams = await context.Exams.AsNoTracking().ToListAsync();
        return Results.Ok(new ApiResultDto(true, "Success", data: exams));
    }
    catch (Exception e) 
    {
        return  Results.NotFound(e.Message ?? "Not found");
    }
    
}).AllowAnonymous()
    .Produces(StatusCodes.Status200OK)
    .Produces(StatusCodes.Status404NotFound);













app.Run();
