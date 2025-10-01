using exam_service.Application.Exam;
using exam_service.Features.Exams.AdminEndpoint;
using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;
using exam_service.Features.Exams.InternalEndpoint;
using exam_service.Features.Exams.PublicEndpoint;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContextPool<ExamDbContext>(option =>
    option.UseNpgsql(Environment.GetEnvironmentVariable("CONNECTIONSTRING__EXAM")
                     ?? builder.Configuration.GetConnectionString("Exam_DB")));

builder.Services.AddScoped<IExamService, ExamService>();
builder.Services.AddScoped<IAdminExamService, AdminExamService>();
builder.Services.AddScoped<IAdminOptionService, AdminOptionService>();
builder.Services.AddScoped<IAdminSectionService, AdminSectionService>();
builder.Services.AddScoped<IInternalExamService, InternalExamService>();
builder.Services.AddScoped<IAdminQuestionService, AdminQuestionService>();
builder.Services.AddScoped<ExamInternalGrpcService>();

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




app.MapPublicExamEndpoints();
app.MapAdminExamEndpoint();
app.MapAdminSectionEndpoint();
app.MapAdminQuestionEndpoint();
app.MapAdminOptionEndpoint();
app.MapInternalExamEndpoint();
app.Run();