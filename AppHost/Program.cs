using Aspire.Hosting;
using CommunityToolkit.Aspire.MassTransit.RabbitMQ;

var builder = DistributedApplication.CreateBuilder(args);

var gamificationDbServer = builder.AddPostgres("gamification-db-server", port: 5444);
var gamificationDb = gamificationDbServer.AddDatabase("gamification-db");

var rabbitmq = builder.AddRabbitMQ("rabbitmq", port: 5672)
    .WithManagementPlugin();

var gamificationService = builder.AddProject("gamification-service", "gamification-service")
    .WithReference(gamificationDb)
    .WithReference(rabbitmq)
    .WaitFor(gamificationDb)
    .WaitFor(rabbitmq);

builder.Build().Run();