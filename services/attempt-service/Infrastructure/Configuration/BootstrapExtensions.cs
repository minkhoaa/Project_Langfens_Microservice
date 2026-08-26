using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;
using attempt_service.Features.Helpers;
using attempt_service.Infrastructure.Persistence;

namespace Microsoft.Extensions.DependencyInjection;

// ─── Bootstrap extensions (attempt-service specific) ────────────────────────────

public static class AttemptBootstrapExtensions
{
    // ── Authorization policies (attempt-service specific) ─────────────────────

    public static IServiceCollection AddAttemptAuthorization(this IServiceCollection services)
    {
        services.AddAuthorization(opts =>
        {
            opts.FallbackPolicy = new AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser().Build();

            opts.AddPolicy(Roles.User, a => a.RequireRole(Roles.User));
            opts.AddPolicy(Roles.Admin, a => a.RequireRole(Roles.Admin));

            opts.AddPolicy(AttemptScope.AttemptStart, a => a.RequireAssertion(c =>
                c.User.HasAnyScope(AttemptScope.AttemptStart) || c.User.IsInRole(Roles.User)));
            opts.AddPolicy(AttemptScope.AttemptSubmit, a => a.RequireAssertion(c =>
                c.User.HasAnyScope(AttemptScope.AttemptSubmit) || c.User.IsInRole(Roles.User)));
            opts.AddPolicy(AttemptScope.AttemptReadOwn, a => a.RequireAssertion(c =>
                c.User.HasAnyScope(AttemptScope.AttemptReadOwn) || c.User.IsInRole(Roles.User)));
            opts.AddPolicy(AttemptScope.AttemptReadAny, a => a.RequireAssertion(c =>
                c.User.HasAnyScope(AttemptScope.AttemptReadAny) || c.User.IsInRole(Roles.Admin)));
        });
        return services;
    }

    // ── JSON serialization ─────────────────────────────────────────────────────

    public static IServiceCollection AddLangfensJson(this IServiceCollection services)
    {
        services.ConfigureHttpJsonOptions(opts =>
        {
            opts.SerializerOptions.PropertyNameCaseInsensitive = true;
            opts.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
        });
        return services;
    }

    // ── Persistence (attempt-db) ──────────────────────────────────────────────

    public static WebApplicationBuilder AddAttemptPersistence(this WebApplicationBuilder builder)
    {
        builder.AddNpgsqlDbContext<AttemptDbContext>("attempt-db");
        return builder;
    }

    // ── Grader foundation (DI wiring for Tasks 14-17) ──────────────────────────

    public static IServiceCollection AddGraderRegistry(this IServiceCollection s)
    {
        s.AddSingleton<ITextNormalizer, TextNormalizer>();
        s.AddSingleton<AnswerEnvelopeReader>();
        s.AddSingleton<IGrader, MultipleChoiceSingleGrader>();
        s.AddSingleton<IGrader, MultipleChoiceSingleImageGrader>();
        s.AddSingleton<IGrader, MultipleChoiceMultipleGrader>();
        s.AddSingleton<IGrader, TrueFalseNotGivenGrader>();
        s.AddSingleton<IGrader, YesNoNotGivenGrader>();
        s.AddSingleton<IGrader, SummaryCompletionGrader>();
        s.AddSingleton<IGrader, TableCompletionGrader>();
        s.AddSingleton<IGrader, NoteCompletionGrader>();
        s.AddSingleton<IGrader, FormCompletionGrader>();
        s.AddSingleton<IGrader, SentenceCompletionGrader>();
        s.AddSingleton<IGrader, MatchingHeadingGrader>();
        s.AddSingleton<IGrader, MatchingInformationGrader>();
        s.AddSingleton<IGrader, MatchingFeaturesGrader>();
        s.AddSingleton<IGrader, MatchingEndingsGrader>();
        s.AddSingleton<IGrader, ClassificationGrader>();
        s.AddSingleton<IGrader, DiagramLabelGrader>();
        s.AddSingleton<IGrader, MapLabelGrader>();
        s.AddSingleton<IGrader, FlowChartGrader>();
        s.AddSingleton<IGrader, FlowChartCompletionGrader>();
        s.AddSingleton<IGrader, ShortAnswerGrader>();
        s.AddSingleton<IGrader, AudioResponseGrader>();
        s.AddSingleton<GraderRegistry>();
        return s;
    }
}