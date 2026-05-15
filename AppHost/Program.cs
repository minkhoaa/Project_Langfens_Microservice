using Aspire.Hosting;
using CommunityToolkit.Aspire.MassTransit.RabbitMQ;
using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;

var builder = DistributedApplication.CreateBuilder(args);

var examDbServer = builder.AddPostgres("exam-db-server", port: 5433);
var examDb = examDbServer.AddDatabase("exam-db");

var gamificationDbServer = builder.AddPostgres("gamification-db-server", port: 5444);
var gamificationDb = gamificationDbServer.AddDatabase("gamification-db");

var rabbitmq = builder.AddRabbitMQ("rabbitmq", port: 5672)
    .WithManagementPlugin();

var exam = builder.AddProject("exam-service", "exam-service")
    .WithReference(examDb)
    .WaitFor(examDb);

var gamificationService = builder.AddProject("gamification-service", "gamification-service")
    .WithReference(gamificationDb)
    .WithReference(rabbitmq)
    .WaitFor(gamificationDb)
    .WaitFor(rabbitmq);

builder.Build().Run();