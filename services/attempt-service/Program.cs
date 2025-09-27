using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__ATTEMPT") 
                       ?? builder.Configuration.GetConnectionString("Attempt_DB") ;
Console.Write(connectionString);
builder.Services.AddDbContext<AttemptDbContext>(option => option.UseNpgsql(connectionString)); 
var app = builder.Build();



using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AttemptDbContext>();
    var all     = (db.Database.GetMigrations()).ToList();
    var applied = (await db.Database.GetAppliedMigrationsAsync()).ToList();
    var pending = (await db.Database.GetPendingMigrationsAsync()).ToList();
    Console.WriteLine($"[EF] All:     {string.Join(", ", all)}");
    Console.WriteLine($"[EF] Applied: {string.Join(", ", applied)}");
    Console.WriteLine($"[EF] Pending: {string.Join(", ", pending)}");
    await db.Database.MigrateAsync();
}

// Configure the HTTP request pipeline.

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.MapGet("/", async (AttemptDbContext dbContext) =>
{
    var attempt = await dbContext.Attempts.AsNoTracking().ToListAsync();
    return Results.Ok(attempt);
});

app.Run();