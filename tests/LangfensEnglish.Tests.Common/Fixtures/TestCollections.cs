using Xunit;

namespace LangfensEnglish.Tests.Common.Fixtures;

[CollectionDefinition(nameof(PostgresCollection))]
public class PostgresCollection : ICollectionFixture<PostgresContainerFixture>
{
}

[CollectionDefinition(nameof(RedisCollection))]
public class RedisCollection : ICollectionFixture<RedisContainerFixture>
{
}

[CollectionDefinition(nameof(RabbitMqCollection))]
public class RabbitMqCollection : ICollectionFixture<RabbitMqContainerFixture>
{
}

[CollectionDefinition(nameof(IntegrationTestCollection))]
public class IntegrationTestCollection : ICollectionFixture<PostgresContainerFixture>,
    ICollectionFixture<RedisContainerFixture>,
    ICollectionFixture<RabbitMqContainerFixture>
{
}
