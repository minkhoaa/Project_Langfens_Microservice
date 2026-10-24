using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;
using exam_service.Features.Exams.PublicEndpoint;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using Npgsql;
using QuestionType = Shared.ExamDto.Contracts.Exam.Enums.QuestionType;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace exam_service.Tests;

public sealed class Phase14ExamApiFactory : WebApplicationFactory<exam_service.Program>
{
    private readonly string _connection;
    public const string TestSigningKey = "SuperSecretTestingKeyPhase14MustBe32BytesLong!";
    public const string TestInternalApiKey = "test-phase14-internal-api-key-32chars";

    static Phase14ExamApiFactory()
    {
        Environment.SetEnvironmentVariable("JwtSettings__Issuer", "https://auth.langfens.local");
        Environment.SetEnvironmentVariable("JwtSettings__Audience", "langfens-api");
        Environment.SetEnvironmentVariable("JwtSettings__SignKey", TestSigningKey);
        Environment.SetEnvironmentVariable("EXAMSERVICE__INTERNAL__API__KEY", TestInternalApiKey);
        LoadLoopCapsEnv(null);
    }

    private static void LoadLoopCapsEnv(IWebHostBuilder? builder)
    {
        var envPath = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "../../../../../deploy/envs/loop-caps.env"));
        if (!File.Exists(envPath))
            envPath = Path.GetFullPath("deploy/envs/loop-caps.env");
        if (File.Exists(envPath))
        {
            foreach (var line in File.ReadAllLines(envPath))
            {
                var trimmed = line.Trim();
                if (string.IsNullOrWhiteSpace(trimmed) || trimmed.StartsWith("#")) continue;
                var eqIdx = trimmed.IndexOf('=');
                if (eqIdx > 0)
                {
                    var k = trimmed[..eqIdx].Trim();
                    var v = trimmed[(eqIdx + 1)..].Trim();
                    Environment.SetEnvironmentVariable(k, v);
                    builder?.UseSetting(k, v);
                }
            }
        }
    }

    public Phase14ExamApiFactory(string connection)
    {
        _connection = connection;
        Environment.SetEnvironmentVariable("JwtSettings__Issuer", "https://auth.langfens.local");
        Environment.SetEnvironmentVariable("JwtSettings__Audience", "langfens-api");
        Environment.SetEnvironmentVariable("JwtSettings__SignKey", TestSigningKey);
        Environment.SetEnvironmentVariable("EXAMSERVICE__INTERNAL__API__KEY", TestInternalApiKey);
        Environment.SetEnvironmentVariable("ConnectionStrings__exam-db", _connection);
        LoadLoopCapsEnv(null);
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.UseSetting("JwtSettings__Issuer", "https://auth.langfens.local");
        builder.UseSetting("JwtSettings__Audience", "langfens-api");
        builder.UseSetting("JwtSettings__SignKey", TestSigningKey);
        builder.UseSetting("ConnectionStrings__exam-db", _connection);
        builder.UseSetting("EXAMSERVICE__INTERNAL__API__KEY", TestInternalApiKey);
        builder.UseSetting("Langfens:PromptFormatEnforce", "true");

        builder.ConfigureServices(services =>
        {
            var workerDescriptors = services.Where(d =>
                d.ServiceType == typeof(IHostedService) &&
                d.ImplementationType == typeof(ReadingPaperWorker)).ToList();
            foreach (var w in workerDescriptors) services.Remove(w);

            var dbDescriptors = services.Where(d =>
                d.ServiceType == typeof(DbContextOptions<ExamDbContext>) ||
                d.ServiceType == typeof(ExamDbContext)).ToList();
            foreach (var d in dbDescriptors) services.Remove(d);

            services.AddDbContext<ExamDbContext>(options =>
            {
                options.UseNpgsql(_connection, npg =>
                {
                    npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
                    npg.EnableRetryOnFailure();
                });
                options.ConfigureWarnings(w => w.Ignore(RelationalEventId.PendingModelChangesWarning));
            });
        });
    }

    public HttpClient CreateAdminClient()
    {
        var client = CreateClient();
        var token = GenerateAdminJwtToken(TestSigningKey);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return client;
    }

    private static string GenerateAdminJwtToken(string signKey)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var claims = new[]
        {
            new Claim("sub", "editor-admin-test"),
            new Claim(ClaimTypes.NameIdentifier, "editor-admin-test"),
            new Claim("roles", "ADMIN"),
            new Claim("role", "ADMIN"),
            new Claim(ClaimTypes.Role, "ADMIN"),
            new Claim("scope", "exam:manage reading:curate")
        };

        var token = new JwtSecurityToken(
            issuer: "https://auth.langfens.local",
            audience: "langfens-api",
            claims: claims,
            expires: DateTime.UtcNow.AddHours(2),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}

[Collection("DatabaseTests")]
public class Phase14LineageFeedbackTests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_phase14_lineage;Username=exam;Password=exam";

    private async Task<(Phase14ExamApiFactory Factory, HttpClient Client, string Connection)> SetupTestServerAsync()
    {
        var connection = Environment.GetEnvironmentVariable("READING_TEST_POSTGRES") ?? DefaultConn;

        var csb = new NpgsqlConnectionStringBuilder(connection);
        var targetDb = csb.Database;
        csb.Database = "postgres";

        await using (var mConn = new NpgsqlConnection(csb.ConnectionString))
        {
            await mConn.OpenAsync();
            await using var checkCmd = new NpgsqlCommand($"SELECT 1 FROM pg_database WHERE datname = '{targetDb}'", mConn);
            var exists = await checkCmd.ExecuteScalarAsync();
            if (exists == null)
            {
                await using var createCmd = new NpgsqlCommand($"CREATE DATABASE \"{targetDb}\"", mConn);
                await createCmd.ExecuteNonQueryAsync();
            }
        }

        await using (var conn = new NpgsqlConnection(connection))
        {
            await conn.OpenAsync();
            await using var cmd = new NpgsqlCommand("DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;", conn);
            await cmd.ExecuteNonQueryAsync();
        }

        var factory = new Phase14ExamApiFactory(connection);

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await db.Database.MigrateAsync();
        }

        var client = factory.CreateAdminClient();
        return (factory, client, connection);
    }

    private static string GenerateSamplePassage(int sectionIndex, int wordCount = 800)
    {
        var text = sectionIndex switch
        {
            1 => "Recent empirical investigations in cognitive linguistics and neuroscience have uncovered remarkable insights into multilingual memory representation. Researchers at Cambridge University conducted a comprehensive seven-year longitudinal cohort study involving more than eight hundred bilingual subjects. The experimental framework deployed advanced functional neuroimaging techniques alongside standardized psychometric cognitive batteries. Primary analytical findings revealed that early acquisition of a secondary language significantly reinforces prefrontal cortical connectivity. Moreover structural MRI scans demonstrated measurable increases in gray matter density within both the left inferior parietal cortex and the hippocampus. Subsequent statistical modeling demonstrated that cognitive flexibility scores were approximately twenty-four percent higher among proficient bilingual individuals. Nevertheless some dissenting academic researchers have cautioned that socioeconomic confounding variables must be rigorously controlled in subsequent experimental trials. In particular cross-cultural observational datasets indicate that educational background and formal literacy levels exert substantial confounding effects. To address these methodological concerns the research team instituted stringent demographic stratification protocols across all experimental cohorts. The finalized data conclusively established that language switching exercises distinct executive control networks independent of educational attainment. These seminal discoveries hold profound implications for designing innovative pedagogical curricula and targeted clinical interventions for neurodegenerative decline.",
            2 => "Astronomical observations conducted using space-borne infrared observatories have revolutionized contemporary understanding of early stellar formation. Astrophysicists analyzing spectroscopic data from high-redshift galactic clusters discovered unexpected concentrations of heavy metallic elements. These anomalous chemical signatures suggest that the initial generation of massive stars underwent rapid nucleosynthesis and catastrophic supernova collapse. Theoretical astrophysicists had previously posited that primordial cosmic gas clouds consisted almost exclusively of hydrogen and neutral helium. However high-resolution interferometric arrays operating at sub-millimeter wavelengths revealed extensive dust grains dispersed throughout the interstellar medium. This unexpected abundance of interstellar dust indicates that carbon and oxygen were synthesized much earlier in the cosmic timeline than previously estimated. Cosmological simulations incorporating magnetohydrodynamic turbulence accurately reproduced the observed morphological structures of young spiral galaxies. Furthermore orbital telemetry from gravitational wave detectors provided corroborating evidence regarding intermediate-mass black hole coalescence rates. International collaborative research initiatives have consequently revised existing theoretical paradigms governing protogalactic accretion disk dynamics. Future observational campaigns scheduled on next-generation orbital platforms will investigate deep-space cosmic dawn ionization boundaries.",
            _ => "Marine biological assessments across tropical coral reef ecosystems demonstrate unprecedented physiological adaptations in response to ocean acidification. Marine ecologists from the Oceanographic Institute surveyed barrier reef formations along equatorial archipelagos over an extensive ten-year sampling timeline. Specimens of scleractinian corals exhibited selective upregulation of specialized bicarbonate transporter proteins within their calcifying epithelial tissues. This biochemical mechanism enables sustained calcium carbonate precipitation despite depressed ambient seawater pH levels. Concurrently photosynthetic endosymbionts belonging to the family Symbiodiniaceae demonstrated augmented thermal resilience under elevated temperature stress. Genomic sequencing of resilient coral colonies revealed distinct single-nucleotide polymorphisms correlated with heightened antioxidant enzyme expression. Ecological modeling predicts that targeted conservation frameworks prioritizing genetically resilient broodstocks could preserve critical reef biodiversity. Nonetheless persistent anthropogenic runoff and local overfishing continue to exert severe compounding pressures on juvenile coral recruitment. Comprehensive marine spatial planning and strictly enforced protective reserves remain indispensable prerequisites for long-term reef ecosystem persistence. The preservation of these intricate marine habitats remains fundamental for safeguarding global ocean food security and coastal geomorphic protection."
        };

        var words = text.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        var result = new List<string>();
        while (result.Count < wordCount)
        {
            result.AddRange(words);
        }
        return string.Join(' ', result.Take(wordCount));
    }

    private static List<ReadingGeneratedSection> CreateCanonicalThreeSections()
    {
        var s1Passage = GenerateSamplePassage(1, 800);
        var s2Passage = GenerateSamplePassage(2, 800);
        var s3Passage = GenerateSamplePassage(3, 800);

        var s1 = new ReadingGeneratedSection(
            "Section 1: Cognitive Linguistics",
            s1Passage,
            new ReadingSource("PMC1111111", "Linguistic Cognition", "10.1016/j.ling.001", "https://europepmc.org/articles/PMC1111111", "CC BY 4.0", 800),
            new List<ReadingGeneratedGroup>
            {
                new("TRUE_FALSE_NOT_GIVEN", "Do the statements agree with the passage?", new List<ReadingGeneratedQuestion>
                {
                    new(1, "Recent empirical investigations uncovered insights into memory representation.", "TRUE", new List<string>{"TRUE", "FALSE", "NOT GIVEN"}, "empirical investigations in cognitive linguistics", "Explanation for Q1 with verified evidence."),
                    new(2, "The Cambridge investigation spanned fifteen consecutive years.", "FALSE", new List<string>{"TRUE", "FALSE", "NOT GIVEN"}, "seven-year longitudinal cohort study", "Explanation for Q2 with verified evidence."),
                    new(3, "Functional neuroimaging was deployed alongside psychometric batteries.", "TRUE", new List<string>{"TRUE", "FALSE", "NOT GIVEN"}, "deployed advanced functional neuroimaging techniques", "Explanation for Q3 with verified evidence."),
                    new(4, "Secondary language acquisition weakened neural pathways across lobes.", "FALSE", new List<string>{"TRUE", "FALSE", "NOT GIVEN"}, "early acquisition of a secondary language significantly reinforces", "Explanation for Q4 with verified evidence."),
                    new(5, "Structural MRI revealed increased gray matter density in the hippocampus.", "TRUE", new List<string>{"TRUE", "FALSE", "NOT GIVEN"}, "measurable increases in gray matter density within both", "Explanation for Q5 with verified evidence."),
                    new(6, "Bilingual individuals achieved fifty percent higher flexibility scores.", "FALSE", new List<string>{"TRUE", "FALSE", "NOT GIVEN"}, "flexibility scores were approximately twenty-four percent higher", "Explanation for Q6 with verified evidence."),
                    new(7, "The research cohort included participants from four different continents.", "NOT GIVEN", new List<string>{"TRUE", "FALSE", "NOT GIVEN"}, "demographic stratification protocols across all experimental cohorts.", "Explanation for Q7 with verified evidence.")
                }),
                new("SENTENCE_COMPLETION", "Complete the sentences below.", new List<ReadingGeneratedQuestion>
                {
                    new(8, "Early acquisition of a secondary language reinforces prefrontal [8].", "cortical connectivity", new List<string>(), "early acquisition of a secondary language significantly reinforces prefrontal cortical connectivity", "Explanation for Q8 with verified evidence."),
                    new(9, "Structural MRI demonstrated measurable increases in gray [9] density.", "matter", new List<string>(), "measurable increases in gray matter density within both the left inferior", "Explanation for Q9 with verified evidence."),
                    new(10, "Cognitive flexibility scores were approximately twenty-four [10] higher.", "percent", new List<string>(), "flexibility scores were approximately twenty-four percent higher among proficient", "Explanation for Q10 with verified evidence."),
                    new(11, "Dissenting researchers warned about socioeconomic confounding [11].", "variables", new List<string>(), "socioeconomic confounding variables must be rigorously controlled in subsequent", "Explanation for Q11 with verified evidence."),
                    new(12, "Language switching exercises distinct executive [12] networks.", "control", new List<string>(), "language switching exercises distinct executive control networks independent of", "Explanation for Q12 with verified evidence."),
                    new(13, "Discoveries hold profound implications for designing innovative pedagogical [13].", "curricula", new List<string>(), "profound implications for designing innovative pedagogical curricula and targeted clinical", "Explanation for Q13 with verified evidence.")
                })
            }
        );

        var s2 = new ReadingGeneratedSection(
            "Section 2: Stellar Evolution",
            s2Passage,
            new ReadingSource("PMC2222222", "Astrophysical Observation", "10.1016/j.astro.002", "https://europepmc.org/articles/PMC2222222", "CC BY 4.0", 800),
            new List<ReadingGeneratedGroup>
            {
                new("MULTIPLE_CHOICE_SINGLE", "Choose the correct letter, A, B, C or D.", new List<ReadingGeneratedQuestion>
                {
                    new(14, "What did infrared observatories reveal regarding early stellar formation?", "A. Revolutionary findings", new List<string>{"A. Revolutionary findings", "B. Traditional theories", "C. Neutral helium", "D. Dark matter"}, "infrared observatories have revolutionized contemporary understanding", "Explanation for Q14 with verified evidence."),
                    new(15, "What did spectroscopic analyses of high-redshift galactic clusters discover?", "B. Unexpected elements", new List<string>{"A. Primordial gas", "B. Unexpected elements", "C. Spiral morphology", "D. Cosmic dawn"}, "discovered unexpected concentrations of heavy metallic elements", "Explanation for Q15 with verified evidence."),
                    new(16, "What mechanism caused rapid synthesis of heavy elements in massive stars?", "C. Supernova collapse", new List<string>{"A. Magnetic fields", "B. Orbital telemetry", "C. Supernova collapse", "D. Accretion disks"}, "initial generation of massive stars underwent rapid nucleosynthesis and catastrophic supernova collapse", "Explanation for Q16 with verified evidence."),
                    new(17, "What were primordial gas clouds theoretically hypothesized to contain?", "D. Hydrogen and helium", new List<string>{"A. Oxygen grains", "B. Carbon deposits", "C. Heavy metals", "D. Hydrogen and helium"}, "primordial cosmic gas clouds consisted almost exclusively of hydrogen and neutral helium", "Explanation for Q17 with verified evidence."),
                    new(18, "What did high-resolution interferometric arrays reveal throughout the medium?", "A. Dust grains", new List<string>{"A. Dust grains", "B. Plasma jets", "C. Black holes", "D. Magnetic loops"}, "interferometric arrays operating at sub-millimeter wavelengths revealed extensive dust grains", "Explanation for Q18 with verified evidence."),
                    new(19, "What corroborate intermediate-mass black hole coalescence rates?", "B. Gravitational detectors", new List<string>{"A. Optical lenses", "B. Gravitational detectors", "C. Solar flares", "D. Radio pulsars"}, "orbital telemetry from gravitational wave detectors provided corroborating evidence", "Explanation for Q19 with verified evidence.")
                }),
                new("SUMMARY_COMPLETION", "Complete the summary below.", new List<ReadingGeneratedQuestion>
                {
                    new(20, "Primordial cosmic gas clouds consisted almost exclusively of hydrogen and neutral [20].", "helium", new List<string>(), "almost exclusively of hydrogen and neutral helium", "Explanation for Q20 with verified evidence."),
                    new(21, "Interferometric arrays revealed extensive dust [21] throughout the medium.", "grains", new List<string>(), "revealed extensive dust grains dispersed throughout", "Explanation for Q21 with verified evidence."),
                    new(22, "Abundance of dust indicates carbon and [22] were synthesized much earlier.", "oxygen", new List<string>(), "indicates that carbon and oxygen were synthesized much earlier", "Explanation for Q22 with verified evidence."),
                    new(23, "Cosmological simulations incorporated magnetohydrodynamic [23] accurately.", "turbulence", new List<string>(), "incorporating magnetohydrodynamic turbulence accurately reproduced", "Explanation for Q23 with verified evidence."),
                    new(24, "Orbital telemetry provided evidence regarding black hole [24] rates.", "coalescence", new List<string>(), "evidence regarding intermediate-mass black hole coalescence rates", "Explanation for Q24 with verified evidence."),
                    new(25, "Collaborative initiatives revised protogalactic accretion [25] dynamics.", "disk", new List<string>(), "revised existing theoretical paradigms governing protogalactic accretion disk dynamics", "Explanation for Q25 with verified evidence."),
                    new(26, "Next-generation orbital platforms will investigate cosmic dawn [26] boundaries.", "ionization", new List<string>(), "will investigate deep-space cosmic dawn ionization boundaries", "Explanation for Q26 with verified evidence.")
                })
            }
        );

        var s3 = new ReadingGeneratedSection(
            "Section 3: Marine Ecology",
            s3Passage,
            new ReadingSource("PMC3333333", "Reef Ecosystem Resilience", "10.1016/j.marine.003", "https://europepmc.org/articles/PMC3333333", "CC BY 4.0", 800),
            new List<ReadingGeneratedGroup>
            {
                new("YES_NO_NOT_GIVEN", "Do the statements agree with the views of the writer?", new List<ReadingGeneratedQuestion>
                {
                    new(27, "Coral reef ecosystems demonstrate physiological adaptations to ocean acidification.", "YES", new List<string>{"YES", "NO", "NOT GIVEN"}, "tropical coral reef ecosystems demonstrate unprecedented physiological adaptations", "Explanation for Q27 with verified evidence."),
                    new(28, "The marine ecological survey along equatorial archipelagos spanned two years.", "NO", new List<string>{"YES", "NO", "NOT GIVEN"}, "surveyed barrier reef formations along equatorial archipelagos over an extensive ten-year", "Explanation for Q28 with verified evidence."),
                    new(29, "Scleractinian corals upregulated specialized cellular transport mechanisms.", "YES", new List<string>{"YES", "NO", "NOT GIVEN"}, "selective upregulation of specialized bicarbonate transporter proteins within", "Explanation for Q29 with verified evidence."),
                    new(30, "Elevated temperature stress completely eliminated photosynthetic endosymbionts.", "NO", new List<string>{"YES", "NO", "NOT GIVEN"}, "photosynthetic endosymbionts belonging to the family Symbiodiniaceae demonstrated augmented", "Explanation for Q30 with verified evidence."),
                    new(31, "Genomic sequencing revealed distinct genetic variants linked to enzymes.", "YES", new List<string>{"YES", "NO", "NOT GIVEN"}, "distinct single-nucleotide polymorphisms correlated with heightened antioxidant enzyme expression", "Explanation for Q31 with verified evidence."),
                    new(32, "Anthropogenic runoff has ceased to affect juvenile coral recruitment.", "NO", new List<string>{"YES", "NO", "NOT GIVEN"}, "persistent anthropogenic runoff and local overfishing continue to exert severe compounding", "Explanation for Q32 with verified evidence."),
                    new(33, "Deep sea hydrothermal vent ecosystems were also evaluated in this study.", "NOT GIVEN", new List<string>{"YES", "NO", "NOT GIVEN"}, "protective reserves remain indispensable prerequisites for long-term reef ecosystem persistence", "Explanation for Q33 with verified evidence.")
                }),
                new("SHORT_ANSWER", "Answer the questions below.", new List<ReadingGeneratedQuestion>
                {
                    new(34, "What transporter proteins were selectively upregulated by scleractinian corals?", "bicarbonate transporter", new List<string>(), "selective upregulation of specialized bicarbonate transporter proteins within their calcifying", "Explanation for Q34 with verified evidence."),
                    new(35, "What physiological process was sustained despite depressed seawater pH?", "calcium carbonate precipitation", new List<string>(), "enables sustained calcium carbonate precipitation despite depressed ambient seawater", "Explanation for Q35 with verified evidence."),
                    new(36, "Which photosynthetic endosymbionts demonstrated augmented thermal resilience?", "Symbiodiniaceae", new List<string>(), "photosynthetic endosymbionts belonging to the family Symbiodiniaceae demonstrated augmented", "Explanation for Q36 with verified evidence."),
                    new(37, "What genetic variations correlated with antioxidant enzyme expression?", "single-nucleotide polymorphisms", new List<string>(), "distinct single-nucleotide polymorphisms correlated with heightened antioxidant enzyme", "Explanation for Q37 with verified evidence."),
                    new(38, "What conservation framework prioritized genetically resilient broodstocks?", "ecological modeling", new List<string>(), "Ecological modeling predicts that targeted conservation frameworks prioritizing genetically", "Explanation for Q38 with verified evidence."),
                    new(39, "What human activity exerts compounding pressure on juvenile coral recruitment?", "local overfishing", new List<string>(), "persistent anthropogenic runoff and local overfishing continue to exert severe compounding pressures", "Explanation for Q39 with verified evidence."),
                    new(40, "What marine management framework is indispensable for long-term reef persistence?", "spatial planning", new List<string>(), "Comprehensive marine spatial planning and strictly enforced protective reserves", "Explanation for Q40 with verified evidence.")
                })
            }
        );

        return new List<ReadingGeneratedSection> { s1, s2, s3 };
    }

    private static async Task<(ArtifactEnvelope PaperEnvelope, List<EvaluationResult> ValidEvaluations)> SeedFullAcceptedPaperGraphAsync(
        ExamDbContext db, ReadingPaperRun run, List<ReadingGeneratedSection> sections)
    {
        var runId = run.RunId;
        var sources = sections.Select(s => s.Source).ToList();
        run.SourceRevisionsJson = JsonSerializer.Serialize(sources, ReadingPaperRules.Json);
        await db.SaveChangesAsync();

        // 1. Blueprint
        var bpId = $"art_blueprint_{runId[..Math.Min(8, runId.Length)]}";
        var bpPayload = new { totalQuestions = 40, targetWordCountMin = 2150, targetWordCountMax = 2750 };
        var bpDoc = JsonDocument.Parse(JsonSerializer.Serialize(bpPayload, ReadingPaperRules.Json));
        var bpHash = ArtifactEnvelope.ComputeContentHash(bpDoc.RootElement, Array.Empty<ArtifactRef>());
        var bpEnv = new ArtifactEnvelope(bpId, ArtifactType.ExamBlueprint, 1, runId, null, "2.0.0", bpHash, DateTime.UtcNow.AddMinutes(-5), "2.0.0", bpDoc.RootElement.Clone(), Array.Empty<ArtifactRef>());

        db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
        {
            Id = Guid.NewGuid(), RunId = runId, ArtifactId = bpId, ArtifactType = ArtifactType.ExamBlueprint.ToString(),
            Version = 1, ContentHash = bpHash, PayloadJson = bpDoc.RootElement.GetRawText(), ParentRefsJson = "[]",
            EnvelopeJson = JsonSerializer.Serialize(bpEnv, LoopEngineJson.Options), CreatedAt = bpEnv.CreatedAt
        });
        db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
        {
            Id = Guid.NewGuid(), RunId = runId, ArtifactId = bpId, AcceptedVersion = 1, AcceptedHash = bpHash, UpdatedAt = bpEnv.CreatedAt
        });

        var bpRef = bpEnv.ToRef();

        // 2. Passages & Questions for each section
        var passageRefs = new List<ArtifactRef>();
        var sectionRefs = new List<ArtifactRef>();
        var allQuestionRefs = new List<ArtifactRef>();
        var sectionEnvelopes = new List<ArtifactEnvelope>();

        for (int i = 0; i < 3; i++)
        {
            var secIdx = i + 1;
            var sec = sections[i];

            // Passage
            var pId = $"art_passage_s{secIdx}";
            var pPayload = new { text = sec.Passage, passage = sec.Passage, wordCount = ReadingPaperRules.WordCount(sec.Passage), source = sec.Source };
            var pDoc = JsonDocument.Parse(JsonSerializer.Serialize(pPayload, ReadingPaperRules.Json));
            var pParents = new List<ArtifactRef> { bpRef };
            var pHash = ArtifactEnvelope.ComputeContentHash(pDoc.RootElement, pParents);
            var pEnv = new ArtifactEnvelope(pId, ArtifactType.Passage, 1, runId, secIdx, "2.0.0", pHash, DateTime.UtcNow.AddMinutes(-4), "2.0.0", pDoc.RootElement.Clone(), pParents);

            db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
            {
                Id = Guid.NewGuid(), RunId = runId, ArtifactId = pId, ArtifactType = ArtifactType.Passage.ToString(),
                Version = 1, ContentHash = pHash, PayloadJson = pDoc.RootElement.GetRawText(),
                ParentRefsJson = JsonSerializer.Serialize(pParents, LoopEngineJson.Options),
                EnvelopeJson = JsonSerializer.Serialize(pEnv, LoopEngineJson.Options), CreatedAt = pEnv.CreatedAt
            });
            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                Id = Guid.NewGuid(), RunId = runId, ArtifactId = pId, AcceptedVersion = 1, AcceptedHash = pHash, UpdatedAt = pEnv.CreatedAt
            });

            var pRef = pEnv.ToRef();
            passageRefs.Add(pRef);

            // Questions in this section
            var secQuestionRefs = new List<ArtifactRef>();
            var secQuestions = sec.Groups.SelectMany(g => g.Questions).ToList();
            foreach (var q in secQuestions)
            {
                var qId = $"art_q_{q.Number}";
                var qPayload = new
                {
                    number = q.Number,
                    questionNumber = q.Number,
                    prompt = q.Prompt,
                    answer = q.Answer,
                    options = q.Options,
                    evidenceQuote = q.EvidenceQuote,
                    explanation = q.Explanation
                };
                var qDoc = JsonDocument.Parse(JsonSerializer.Serialize(qPayload, ReadingPaperRules.Json));
                var qParents = new List<ArtifactRef> { pRef, bpRef };
                var qHash = ArtifactEnvelope.ComputeContentHash(qDoc.RootElement, qParents);
                var qEnv = new ArtifactEnvelope(qId, ArtifactType.Question, 1, runId, secIdx, "2.0.0", qHash, DateTime.UtcNow.AddMinutes(-3), "2.0.0", qDoc.RootElement.Clone(), qParents);

                db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
                {
                    Id = Guid.NewGuid(), RunId = runId, ArtifactId = qId, ArtifactType = ArtifactType.Question.ToString(),
                    Version = 1, ContentHash = qHash, PayloadJson = qDoc.RootElement.GetRawText(),
                    ParentRefsJson = JsonSerializer.Serialize(qParents, LoopEngineJson.Options),
                    EnvelopeJson = JsonSerializer.Serialize(qEnv, LoopEngineJson.Options), CreatedAt = qEnv.CreatedAt
                });
                db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
                {
                    Id = Guid.NewGuid(), RunId = runId, ArtifactId = qId, AcceptedVersion = 1, AcceptedHash = qHash, UpdatedAt = qEnv.CreatedAt
                });

                var qRef = qEnv.ToRef();
                secQuestionRefs.Add(qRef);
                allQuestionRefs.Add(qRef);
            }

            // Section envelope
            var secId = $"art_section_{secIdx}";
            var secPayloadObj = new
            {
                sectionId = secIdx,
                title = sec.Title,
                passage = sec.Passage,
                source = sec.Source,
                passageRef = pRef,
                blueprintRef = bpRef,
                questionRefs = secQuestionRefs,
                groups = sec.Groups.Select(g => new
                {
                    type = g.Type,
                    instruction = g.Instruction,
                    questions = g.Questions.Select(q => new
                    {
                        number = q.Number,
                        questionNumber = q.Number,
                        prompt = q.Prompt,
                        answer = q.Answer,
                        options = q.Options,
                        evidenceQuote = q.EvidenceQuote,
                        explanation = q.Explanation
                    }).ToList()
                }).ToList()
            };
            var secDoc = JsonDocument.Parse(JsonSerializer.Serialize(secPayloadObj, ReadingPaperRules.Json));
            var secParents = new List<ArtifactRef> { pRef, bpRef }.Concat(secQuestionRefs).ToList();
            var secHash = ArtifactEnvelope.ComputeContentHash(secDoc.RootElement, secParents);
            var secEnv = new ArtifactEnvelope(secId, ArtifactType.Section, 1, runId, secIdx, "2.0.0", secHash, DateTime.UtcNow.AddMinutes(-2), "2.0.0", secDoc.RootElement.Clone(), secParents);

            db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
            {
                Id = Guid.NewGuid(), RunId = runId, ArtifactId = secId, ArtifactType = ArtifactType.Section.ToString(),
                Version = 1, ContentHash = secHash, PayloadJson = secDoc.RootElement.GetRawText(),
                ParentRefsJson = JsonSerializer.Serialize(secParents, LoopEngineJson.Options),
                EnvelopeJson = JsonSerializer.Serialize(secEnv, LoopEngineJson.Options), CreatedAt = secEnv.CreatedAt
            });
            db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
            {
                Id = Guid.NewGuid(), RunId = runId, ArtifactId = secId, AcceptedVersion = 1, AcceptedHash = secHash, UpdatedAt = secEnv.CreatedAt
            });

            var secRef = secEnv.ToRef();
            sectionRefs.Add(secRef);
            sectionEnvelopes.Add(secEnv);
        }

        // 3. Paper Envelope
        var paperId = $"art_paper_{runId[..Math.Min(8, runId.Length)]}";
        var paperPayloadObj = new
        {
            paperId = paperId,
            runId = runId,
            title = "IELTS Academic Reading Paper",
            totalQuestions = 40,
            blueprintRef = bpRef,
            sectionRefs = sectionRefs,
            passageRefs = passageRefs,
            questionRefs = allQuestionRefs,
            sections = sectionEnvelopes.Select(s => s.Payload).ToList()
        };
        var paperDoc = JsonDocument.Parse(JsonSerializer.Serialize(paperPayloadObj, ReadingPaperRules.Json));
        var paperParents = new List<ArtifactRef> { bpRef }.Concat(sectionRefs).Concat(passageRefs).Concat(allQuestionRefs).ToList();
        var paperHash = ArtifactEnvelope.ComputeContentHash(paperDoc.RootElement, paperParents);
        var paperEnv = new ArtifactEnvelope(paperId, ArtifactType.ReadingPaper, 1, runId, null, "2.0.0", paperHash, DateTime.UtcNow.AddMinutes(-1), "2.0.0", paperDoc.RootElement.Clone(), paperParents);

        db.ReadingPaperArtifacts.Add(new ReadingPaperArtifact
        {
            Id = Guid.NewGuid(), RunId = runId, ArtifactId = paperId, ArtifactType = ArtifactType.ReadingPaper.ToString(),
            Version = 1, ContentHash = paperHash, PayloadJson = paperDoc.RootElement.GetRawText(),
            ParentRefsJson = JsonSerializer.Serialize(paperParents, LoopEngineJson.Options),
            EnvelopeJson = JsonSerializer.Serialize(paperEnv, LoopEngineJson.Options), CreatedAt = paperEnv.CreatedAt
        });
        db.ReadingPaperArtifactHeads.Add(new ReadingPaperArtifactHead
        {
            Id = Guid.NewGuid(), RunId = runId, ArtifactId = paperId, AcceptedVersion = 1, AcceptedHash = paperHash, UpdatedAt = paperEnv.CreatedAt
        });

        await db.SaveChangesAsync();

        // 4. Default Valid Evaluations
        var validEvaluations = ReadingPaperFinalSnapshot.RequiredEvaluators.Select(kv => new EvaluationResult(
            EvaluationId: $"eval_{kv.Key}_{Guid.NewGuid():N}"[..24],
            EvaluatorId: kv.Key,
            EvaluatorVersion: kv.Value,
            TargetRef: paperEnv.ToRef(),
            Status: EvaluationStatus.PASS,
            Issues: new List<Issue>(),
            Score: 1.0,
            InputDependencyRefs: paperParents,
            Provider: "test-provider",
            Model: "test-model",
            PromptVersion: "1.0.0",
            ElapsedMs: 120.0,
            Usage: new UsageMetrics(100, 50, 150, 0.001),
            EvaluatedAt: DateTime.UtcNow
        )).ToList();

        return (paperEnv, validEvaluations);
    }

    private static async Task<(Guid ExamId, string RunId, Guid Owner, Guid JobId)> SeedGeneratedExamViaCheckpointAsync(ExamDbContext db)
    {
        var owner = Guid.NewGuid();
        var jobId = Guid.NewGuid();
        var runId = $"run_{jobId:N}";

        var job = new ReadingPaperJob
        {
            Id = jobId,
            ActiveRunId = runId,
            Topic = "Phase 14 Lineage Verification",
            Status = "Running",
            Epoch = 1,
            CancelVersion = 0,
            LeaseOwner = owner,
            LeaseUntil = DateTime.UtcNow.AddMinutes(10),
            SourcesJson = "[]",
            SectionsJson = "[]",
            CompletedSections = 0,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperJobs.Add(job);

        var run = new ReadingPaperRun
        {
            Id = Guid.NewGuid(),
            JobId = jobId,
            RunId = runId,
            Epoch = 1,
            Status = "RUNNING",
            LeaseOwner = owner,
            LeaseUntil = job.LeaseUntil,
            CancelVersion = 0,
            EngineVersion = "2.0.0",
            SchemaVersion = "2.0.0",
            PolicyVersion = "1.0.0",
            SourceRevisionsJson = "[]",
            BudgetCapCalls = 25,
            BudgetCapTokens = 150000,
            BudgetCapWallTimeSeconds = 900,
            BudgetProfileVersion = "v2.0.0",
            BudgetProfileSha256 = "0000000000000000000000000000000000000000000000000000000000000000",
            BudgetProfileSource = "TEST",
            BudgetProfileJson = "{}",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperRuns.Add(run);
        await db.SaveChangesAsync();

        var canonicalSections = CreateCanonicalThreeSections();
        var (paperEnv, validEvals) = await SeedFullAcceptedPaperGraphAsync(db, run, canonicalSections);

        // Execute BuildExamIdempotentAsync checkpoint integration
        var buildResult = await CheckpointService.BuildExamIdempotentAsync(
            db,
            new BuildExamInternalRequest(run.RunId, Epoch: 1, LeaseOwner: owner, JobId: job.Id, FinalEvaluations: validEvals),
            CancellationToken.None);

        return (buildResult.ExamId, runId, owner, jobId);
    }

    [Fact]
    public async Task T14_01_EditGeneratedExam_CapturesExactLineageDiffHashesAndOutbox()
    {
        var (factory, client, _) = await SetupTestServerAsync();
        await using var _ = factory;

        Guid examId;
        string runId;
        Guid q17Id;
        Guid q8Id;
        Guid section1Id;
        Guid optId;

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var seeded = await SeedGeneratedExamViaCheckpointAsync(db);
            examId = seeded.ExamId;
            runId = seeded.RunId;
            var q17 = await db.ExamQuestions.FirstAsync(q => q.Section.ExamId == examId && q.Idx == 17);
            q17Id = q17.Id;

            var q8 = await db.ExamQuestions.FirstAsync(q => q.Section.ExamId == examId && q.Idx == 8);
            q8Id = q8.Id;

            var sec1 = await db.ExamSections.FirstAsync(s => s.ExamId == examId && s.Idx == 1);
            section1Id = sec1.Id;

            var opt = await db.ExamOptions.FirstAsync(o => o.Question.Section.ExamId == examId && o.Question.Idx == 14);
            optId = opt.Id;

            // 1. Verify exact lineage records for Exam, 3 Sections, 3 Passages, 40 Questions, and Options
            var allLineage = await db.ReadingPaperEntityLineages.Where(l => l.RunId == runId).ToListAsync();
            Assert.Contains(allLineage, l => l.EntityType == "EXAM" && l.ExamId == examId && l.ArtifactType == "ReadingPaper");
            Assert.Equal(3, allLineage.Count(l => l.EntityType == "SECTION"));
            Assert.Equal(3, allLineage.Count(l => l.EntityType == "PASSAGE"));
            Assert.Equal(40, allLineage.Count(l => l.EntityType == "QUESTION"));
            Assert.True(allLineage.Count(l => l.EntityType == "OPTION") > 0);

            var q17Lineage = allLineage.Single(l => l.QuestionId == q17Id && l.EntityType == "QUESTION");
            Assert.Equal("Question", q17Lineage.ArtifactType);
            Assert.Equal("art_q_17", q17Lineage.ArtifactId);
            Assert.False(string.IsNullOrEmpty(q17Lineage.ContentHash));

            var pas1Lineage = allLineage.Single(l => l.SectionId == section1Id && l.EntityType == "PASSAGE");
            Assert.Equal("Passage", pas1Lineage.ArtifactType);
            Assert.Equal("art_passage_s1", pas1Lineage.ArtifactId);
        }

        // 2. Edit Question 17 (Prompt & Difficulty via HTTP PUT)
        Guid q17SectionId;
        int q17Idx;
        string q17Type;
        string q17Skill;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var q17 = await db.ExamQuestions.AsNoTracking().SingleAsync(q => q.Id == q17Id);
            q17SectionId = q17.SectionId;
            q17Idx = q17.Idx;
            q17Type = q17.Type;
            q17Skill = q17.Skill;
        }

        var updateDto17 = new DtoAdmin.AdminQuestionUpdate(
            SectionId: q17SectionId,
            Idx: q17Idx,
            Type: q17Type,
            Skill: q17Skill,
            Difficulty: 3,
            PromptMd: "What were primordial gas clouds theoretically hypothesized to contain? (Refined)",
            ExplanationMd: "Refined explanation detailing hydrogen and neutral helium evidence.",
            ImageUrl: null
        );

        using (var req = new HttpRequestMessage(HttpMethod.Put, $"/api/admin/question/update/{q17Id}"))
        {
            req.Content = JsonContent.Create(updateDto17);
            req.Headers.Add("Idempotency-Key", "idemp-q17-prompt-001");
            req.Headers.Add("X-Feedback-Reasons", $"{FeedbackReasons.Ambiguity},{FeedbackReasons.UnsupportedClaim}");
            req.Headers.Add("X-Feedback-Comment", "Clarified prompt wording regarding primordial gas composition.");

            var response = await client.SendAsync(req);
            var body = await response.Content.ReadAsStringAsync();
            Assert.True(response.IsSuccessStatusCode, $"Step 2 failed with {response.StatusCode}: {body}");
        }

        // Verify edit 1 in fresh DB scope
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var feedback = await db.ReadingPaperHumanFeedbacks.AsNoTracking().SingleAsync(f => f.QuestionId == q17Id);
            Assert.Equal("QUESTION", feedback.TargetEntityType);
            Assert.Equal(q17Id.ToString(), feedback.TargetEntityId);
            Assert.Equal(runId, feedback.RunId);
            Assert.Equal(examId, feedback.ExamId);
            Assert.Equal("editor-admin-test", feedback.EditorId);
            Assert.Equal("ADMIN", feedback.EditorRole);
            Assert.Equal("RAW", feedback.CurationStatus);
            Assert.Equal("idemp-q17-prompt-001", feedback.IdempotencyKey);
            Assert.False(string.IsNullOrEmpty(feedback.BeforeContentHash));
            Assert.False(string.IsNullOrEmpty(feedback.AfterContentHash));
            Assert.Equal(64, feedback.BeforeContentHash.Length);
            Assert.Equal(64, feedback.AfterContentHash.Length);
            Assert.NotEqual(feedback.BeforeContentHash, feedback.AfterContentHash);
            Assert.Equal(LineageService.ComputeSha256(feedback.BeforePayloadJson), feedback.BeforeContentHash);
            Assert.Equal(LineageService.ComputeSha256(feedback.AfterPayloadJson), feedback.AfterContentHash);

            // Assert payload and exact diff
            Assert.Contains("hypothesized to contain", feedback.AfterPayloadJson);
            Assert.Contains("promptMd", feedback.DiffJson);
            Assert.Contains("difficulty", feedback.DiffJson);
            Assert.Contains(FeedbackReasons.Ambiguity, feedback.ReasonsJson);
            Assert.Contains(FeedbackReasons.UnsupportedClaim, feedback.ReasonsJson);
            Assert.Contains("QuestionChanged", feedback.DownstreamImpactJson);
            Assert.Contains("RequiresRecheck", feedback.DownstreamImpactJson);
            Assert.Contains("InvalidatesRunEvaluation", feedback.DownstreamImpactJson);

            // Assert outbox event was emitted atomically with unique sequence
            var outbox = await db.ReadingPaperEventOutbox.AsNoTracking().SingleAsync(e => e.IdempotencyKey == "idemp-q17-prompt-001");
            Assert.Equal("HUMAN_FEEDBACK_CAPTURED", outbox.EventType);
            Assert.Equal(runId, outbox.RunId);
            Assert.True(outbox.Sequence > 0);
            Assert.Contains("editor-admin-test", outbox.PayloadJson);
            Assert.Contains(feedback.FeedbackId, outbox.PayloadJson);
            Assert.Contains(feedback.BeforeContentHash, outbox.PayloadJson);
            Assert.Contains(feedback.AfterContentHash, outbox.PayloadJson);
        }

        // 3. Edit Answer Key (SentenceCompletion BlankAcceptTexts via HTTP PUT)
        Guid q8SectionId;
        int q8Idx;
        string q8Type;
        string q8Skill;
        int q8Diff;
        string? q8Prompt;
        string? q8Expl;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var q8 = await db.ExamQuestions.AsNoTracking().SingleAsync(q => q.Id == q8Id);
            q8SectionId = q8.SectionId;
            q8Idx = q8.Idx;
            q8Type = q8.Type;
            q8Skill = q8.Skill;
            q8Diff = q8.Difficulty;
            q8Prompt = q8.PromptMd;
            q8Expl = q8.ExplanationMd;
        }

        var updateDto8 = new DtoAdmin.AdminQuestionUpdate(
            SectionId: q8SectionId,
            Idx: q8Idx,
            Type: q8Type,
            Skill: q8Skill,
            Difficulty: q8Diff,
            PromptMd: q8Prompt,
            ExplanationMd: q8Expl,
            BlankAcceptTexts: new Dictionary<string, string[]?> { ["8"] = new[] { "cortical connectivity", "prefrontal connectivity" } }
        );

        using (var req = new HttpRequestMessage(HttpMethod.Put, $"/api/admin/question/update/{q8Id}"))
        {
            req.Content = JsonContent.Create(updateDto8);
            req.Headers.Add("Idempotency-Key", "idemp-q8-answer-001");
            req.Headers.Add("X-Feedback-Reasons", FeedbackReasons.TypoOrFormatting);
            req.Headers.Add("X-Feedback-Comment", "Added accepted variant for blank 8.");

            var response = await client.SendAsync(req);
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        }

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var feedback = await db.ReadingPaperHumanFeedbacks.AsNoTracking().SingleAsync(f => f.QuestionId == q8Id);
            Assert.Equal("QUESTION", feedback.TargetEntityType);
            Assert.Contains("blankAcceptTexts", feedback.DiffJson);
            Assert.False(string.IsNullOrEmpty(feedback.BeforeContentHash));
            Assert.False(string.IsNullOrEmpty(feedback.AfterContentHash));
            Assert.NotEqual(feedback.BeforeContentHash, feedback.AfterContentHash);
            Assert.Contains("QuestionChanged", feedback.DownstreamImpactJson);
        }

        // 4. Edit Option (ContentMd and IsCorrect via HTTP PUT)
        Guid optQId;
        int optIdx;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var opt = await db.ExamOptions.AsNoTracking().SingleAsync(o => o.Id == optId);
            optQId = opt.QuestionId;
            optIdx = opt.Idx;
        }

        var updateOptDto = new DtoAdmin.AdminOptionUpdate(
            QuestionId: optQId,
            Idx: optIdx,
            ContentMd: "A. Revolutionary findings (calibrated)",
            IsCorrect: true
        );

        using (var req = new HttpRequestMessage(HttpMethod.Put, $"/api/admin/option/update/{optId}"))
        {
            req.Content = JsonContent.Create(updateOptDto);
            req.Headers.Add("Idempotency-Key", "idemp-opt-001");
            req.Headers.Add("X-Feedback-Reasons", FeedbackReasons.WeakDistractor);
            req.Headers.Add("X-Feedback-Comment", "Refined option wording.");

            var response = await client.SendAsync(req);
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        }

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var optFeedback = await db.ReadingPaperHumanFeedbacks.AsNoTracking().SingleAsync(f => f.OptionId == optId);
            Assert.Equal("OPTION", optFeedback.TargetEntityType);
            Assert.Contains("OptionChanged", optFeedback.DownstreamImpactJson);
            Assert.Contains("contentMd", optFeedback.DiffJson);
            Assert.False(string.IsNullOrEmpty(optFeedback.BeforeContentHash));
            Assert.False(string.IsNullOrEmpty(optFeedback.AfterContentHash));
        }

        // 5. Edit Section 1 (Passage text via HTTP PUT)
        int sec1Idx;
        string sec1Title;
        string? sec1Inst;
        string? sec1Passage;
        string? sec1Audio;
        string? sec1Trans;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var sec1 = await db.ExamSections.AsNoTracking().SingleAsync(s => s.Id == section1Id);
            sec1Idx = sec1.Idx;
            sec1Title = sec1.Title;
            sec1Inst = sec1.InstructionsMd;
            sec1Passage = sec1.PassageMd;
            sec1Audio = sec1.AudioUrl;
            sec1Trans = sec1.TranscriptMd;
        }

        var updateSecDto = new DtoAdmin.AdminSectionUpdate(
            ExamId: examId,
            Idx: sec1Idx,
            Title: "Section 1: Cognitive Linguistics (Revised Edition)",
            InstructionsMd: sec1Inst,
            PassageMd: sec1Passage + "\n\nAdditional scientific clarification on neural plasticity.",
            AudioUrl: sec1Audio,
            TranscriptMd: sec1Trans
        );

        using (var req = new HttpRequestMessage(HttpMethod.Put, $"/api/admin/section/update/{section1Id}"))
        {
            req.Content = JsonContent.Create(updateSecDto);
            req.Headers.Add("Idempotency-Key", "idemp-sec1-001");
            req.Headers.Add("X-Feedback-Reasons", FeedbackReasons.TypoOrFormatting);
            req.Headers.Add("X-Feedback-Comment", "Corrected passage wording.");

            var response = await client.SendAsync(req);
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        }

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var secFeedback = await db.ReadingPaperHumanFeedbacks.AsNoTracking().SingleAsync(f => f.TargetEntityType == "SECTION" && f.SectionId == section1Id);
            Assert.Equal("SECTION", secFeedback.TargetEntityType);
            Assert.Contains("PassageChanged", secFeedback.DownstreamImpactJson);
            Assert.Contains("AffectsAllSectionQuestions", secFeedback.DownstreamImpactJson);
            Assert.Contains("passageMd", secFeedback.DiffJson);
            Assert.False(string.IsNullOrEmpty(secFeedback.BeforeContentHash));
            Assert.False(string.IsNullOrEmpty(secFeedback.AfterContentHash));

            var outboxEvents = await db.ReadingPaperEventOutbox.AsNoTracking().Where(e => e.RunId == runId).OrderBy(e => e.Sequence).ToListAsync();
            Assert.True(outboxEvents.Count >= 4);
            Assert.Equal("HUMAN_FEEDBACK_CAPTURED", outboxEvents[^1].EventType);
            Assert.Equal(outboxEvents[^2].Sequence + 1, outboxEvents[^1].Sequence);
        }
    }

    [Fact]
    public async Task T14_02_RetryCommittedEdit_IsIdempotentAndNoDuplicateRows()
    {
        var (factory, client, _) = await SetupTestServerAsync();
        await using var _ = factory;

        Guid q1Id;
        Guid q1SectionId;
        int q1Idx;
        string q1Type;
        string q1Skill;

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var seeded = await SeedGeneratedExamViaCheckpointAsync(db);
            var q1 = await db.ExamQuestions.FirstAsync(q => q.Section.ExamId == seeded.ExamId && q.Idx == 1);
            q1Id = q1.Id;
            q1SectionId = q1.SectionId;
            q1Idx = q1.Idx;
            q1Type = q1.Type;
            q1Skill = q1.Skill;
        }

        var idempotencyKey = "idemp-test-retry-unique-key-999";

        // Call 1: Update Q1 via HTTP PUT
        var updateDto1 = new DtoAdmin.AdminQuestionUpdate(
            SectionId: q1SectionId,
            Idx: q1Idx,
            Type: q1Type,
            Skill: q1Skill,
            Difficulty: 1,
            PromptMd: "Recent empirical investigations uncovered insights into memory representation. (First Update)",
            ExplanationMd: "Updated explanation for question 1.",
            ImageUrl: null
        );

        using (var req1 = new HttpRequestMessage(HttpMethod.Put, $"/api/admin/question/update/{q1Id}"))
        {
            req1.Content = JsonContent.Create(updateDto1);
            req1.Headers.Add("Idempotency-Key", idempotencyKey);
            req1.Headers.Add("X-Feedback-Reasons", FeedbackReasons.TypoOrFormatting);

            var res1 = await client.SendAsync(req1);
            var body1 = await res1.Content.ReadAsStringAsync();
            Assert.True(res1.IsSuccessStatusCode, $"T14_02 call 1 failed with {res1.StatusCode}: {body1}");
        }

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var count = await db.ReadingPaperHumanFeedbacks.AsNoTracking().CountAsync(f => f.IdempotencyKey == idempotencyKey);
            Assert.Equal(1, count);
        }

        // Call 2: Replay with same Idempotency-Key header and altered prompt
        var updateDto2 = new DtoAdmin.AdminQuestionUpdate(
            SectionId: q1SectionId,
            Idx: q1Idx,
            Type: q1Type,
            Skill: q1Skill,
            Difficulty: 1,
            PromptMd: "Altered prompt attempt 2 that should NOT be applied due to idempotency!",
            ExplanationMd: "Updated explanation for question 1.",
            ImageUrl: null
        );

        using (var req2 = new HttpRequestMessage(HttpMethod.Put, $"/api/admin/question/update/{q1Id}"))
        {
            req2.Content = JsonContent.Create(updateDto2);
            req2.Headers.Add("Idempotency-Key", idempotencyKey);
            req2.Headers.Add("X-Feedback-Reasons", FeedbackReasons.TypoOrFormatting);

            var res2 = await client.SendAsync(req2);
            Assert.Equal(HttpStatusCode.OK, res2.StatusCode);
        }

        // Call 3: Third replay with same Idempotency-Key header
        using (var req3 = new HttpRequestMessage(HttpMethod.Put, $"/api/admin/question/update/{q1Id}"))
        {
            req3.Content = JsonContent.Create(updateDto2);
            req3.Headers.Add("Idempotency-Key", idempotencyKey);

            var res3 = await client.SendAsync(req3);
            Assert.Equal(HttpStatusCode.OK, res3.StatusCode);
        }

        // Verify across 3 requests: STILL exactly 1 feedback row and 1 outbox event
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

            var feedbackCount = await db.ReadingPaperHumanFeedbacks.AsNoTracking().CountAsync(f => f.IdempotencyKey == idempotencyKey);
            Assert.Equal(1, feedbackCount);

            var outboxCount = await db.ReadingPaperEventOutbox.AsNoTracking().CountAsync(e => e.IdempotencyKey == idempotencyKey);
            Assert.Equal(1, outboxCount);

            // Verify stored question prompt was NOT overwritten
            var storedQ1 = await db.ExamQuestions.AsNoTracking().SingleAsync(q => q.Id == q1Id);
            Assert.Equal("Recent empirical investigations uncovered insights into memory representation. (First Update)", storedQ1.PromptMd);
        }
    }

    [Fact]
    public async Task T14_03_TransactionRollback_ProducesZeroOrphanFeedbackAndZeroOutboxRecords()
    {
        var (factory, client, _) = await SetupTestServerAsync();
        await using var _ = factory;

        Guid q1Id;
        string runId;

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var seeded = await SeedGeneratedExamViaCheckpointAsync(db);
            runId = seeded.RunId;
            var q1 = await db.ExamQuestions.FirstAsync(q => q.Idx == 1);
            q1Id = q1.Id;
        }

        int baselineOutboxCount;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            baselineOutboxCount = await db.ReadingPaperEventOutbox.AsNoTracking().CountAsync();
            Assert.Equal(0, await db.ReadingPaperHumanFeedbacks.AsNoTracking().CountAsync());
        }

        // Attempt 1: Early validation failure (SentenceCompletion without [1] markers via HTTP PUT)
        Guid q1SecId;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var q1 = await db.ExamQuestions.AsNoTracking().SingleAsync(q => q.Id == q1Id);
            q1SecId = q1.SectionId;
        }

        var invalidDto = new DtoAdmin.AdminQuestionUpdate(
            SectionId: q1SecId,
            Idx: 1,
            Type: QuestionType.SentenceCompletion,
            Skill: "READING",
            Difficulty: 1,
            PromptMd: "Prompt without required bracket marker",
            ExplanationMd: "Explanation",
            BlankAcceptTexts: new Dictionary<string, string[]?> { ["1"] = new[] { "target" } }
        );

        using (var req = new HttpRequestMessage(HttpMethod.Put, $"/api/admin/question/update/{q1Id}"))
        {
            req.Content = JsonContent.Create(invalidDto);
            req.Headers.Add("Idempotency-Key", "idemp-err-001");

            var response = await client.SendAsync(req);
            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        }

        // Validation must reject before feedback creation
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var feedbackCount = await db.ReadingPaperHumanFeedbacks.AsNoTracking().CountAsync();
            Assert.Equal(0, feedbackCount);

            var outboxCount = await db.ReadingPaperEventOutbox.AsNoTracking().CountAsync();
            Assert.Equal(baselineOutboxCount, outboxCount);
        }

        // Attempt 2: Mid-transaction rollback on generated entity.
        // Simulate an explicit transaction failure after staging feedback & outbox.
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var q1 = await db.ExamQuestions.FirstAsync(q => q.Id == q1Id);

            var strategy = db.Database.CreateExecutionStrategy();
            await strategy.ExecuteAsync(async () =>
            {
                await using var tx = await db.Database.BeginTransactionAsync();
                try
                {
                    var before = new ExamQuestion
                    {
                        Id = q1.Id, SectionId = q1.SectionId, Idx = q1.Idx,
                        Type = q1.Type, Skill = q1.Skill, Difficulty = q1.Difficulty,
                        PromptMd = q1.PromptMd, ExplanationMd = q1.ExplanationMd
                    };

                    q1.PromptMd = "Fault-injected prompt";

                    // Stage feedback & outbox within transaction
                    await FeedbackService.RecordQuestionEditAsync(
                        db, before, q1, "editor-admin-test", "ADMIN", new[] { FeedbackReasons.Ambiguity },
                        "Fault test", "idemp-fault-001", CancellationToken.None);

                    await db.SaveChangesAsync();

                    // Force an intentional exception to trigger rollback
                    throw new InvalidOperationException("Simulated mid-transaction database failure");
                }
                catch
                {
                    await tx.RollbackAsync();
                }
            });
        }

        // Verify fresh context sees ZERO orphan feedback and ZERO extra outbox rows
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

            var feedbackCount = await db.ReadingPaperHumanFeedbacks.AsNoTracking().CountAsync();
            Assert.Equal(0, feedbackCount);

            var outboxCount = await db.ReadingPaperEventOutbox.AsNoTracking().CountAsync();
            Assert.Equal(baselineOutboxCount, outboxCount);

            // Ensure Q1 was not modified
            var reloadedQ1 = await db.ExamQuestions.AsNoTracking().SingleAsync(q => q.Id == q1Id);
            Assert.DoesNotContain("Fault-injected", reloadedQ1.PromptMd);
        }
    }

    [Fact]
    public async Task T14_04_ManualExam_AllowsNormalCrudWithoutCreatingFakeLineageOrFeedbackRows()
    {
        var (factory, client, _) = await SetupTestServerAsync();
        await using var _ = factory;

        Guid examId;
        Guid sectionId;
        Guid questionId;
        Guid optionId;

        // 1. Admin creates manual Exam via HTTP POST
        var createExamDto = new DtoAdmin.AdminExamCreate(
            Title: "Handcrafted Manual Practice Exam",
            Slug: null,
            DescriptionMd: "A purely manual test created by teachers without AI generation.",
            Category: "IELTS",
            Level: "C1",
            DurationMin: 60,
            ImageUrl: null
        );

        var resExam = await client.PostAsJsonAsync("/api/admin/exam/addexam", createExamDto);
        Assert.Equal(HttpStatusCode.OK, resExam.StatusCode);

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var exam = await db.Exams.AsNoTracking().SingleAsync(e => e.Title == "Handcrafted Manual Practice Exam");
            examId = exam.Id;
        }

        // 2. Admin adds Section via HTTP POST
        var createSecDto = new DtoAdmin.AdminSectionUpsert(
            ExamId: examId,
            Idx: 1,
            Title: "Manual Section 1: History of Architecture",
            InstructionsMd: "Read the passage and answer questions 1–5.",
            PassageMd: "Manual passage text describing ancient architecture...",
            AudioUrl: null,
            TranscriptMd: null
        );

        var resSec = await client.PostAsJsonAsync("/api/admin/section/add", createSecDto);
        Assert.Equal(HttpStatusCode.OK, resSec.StatusCode);

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var sec = await db.ExamSections.AsNoTracking().SingleAsync(s => s.ExamId == examId);
            sectionId = sec.Id;
        }

        // 3. Admin adds Question via HTTP POST
        var createQDto = new DtoAdmin.AdminQuestionUpsert(
            SectionId: sectionId,
            Idx: 1,
            Type: QuestionType.MultipleChoiceSingle,
            Skill: "READING",
            Difficulty: 1,
            PromptMd: "What was the primary material used in early structures?",
            ExplanationMd: "Paragraph 1 explicitly notes stone and clay."
        );

        var resQ = await client.PostAsJsonAsync("/api/admin/question/add", createQDto);
        Assert.Equal(HttpStatusCode.OK, resQ.StatusCode);

        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var question = await db.ExamQuestions.AsNoTracking().SingleAsync(q => q.SectionId == sectionId);
            questionId = question.Id;
        }

        // 4. Admin adds Option via HTTP POST
        var createOptDto = new DtoAdmin.AdminOptionUpsert(
            QuestionId: questionId,
            Idx: 1,
            ContentMd: "Stone and Clay",
            IsCorrect: true
        );

        var resOpt = await client.PostAsJsonAsync("/api/admin/option/add", createOptDto);
        Assert.Equal(HttpStatusCode.OK, resOpt.StatusCode);

        var createOptDto2 = new DtoAdmin.AdminOptionUpsert(
            QuestionId: questionId,
            Idx: 2,
            ContentMd: "Steel and Glass",
            IsCorrect: false
        );
        var resOpt2 = await client.PostAsJsonAsync("/api/admin/option/add", createOptDto2);
        Assert.Equal(HttpStatusCode.OK, resOpt2.StatusCode);
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var option = await db.ExamOptions.AsNoTracking().FirstAsync(o => o.QuestionId == questionId && o.Idx == 1);
            optionId = option.Id;
        }

        // 5. Admin updates manual Question via HTTP PUT
        var updateQDto = new DtoAdmin.AdminQuestionUpdate(
            SectionId: sectionId,
            Idx: 1,
            Type: QuestionType.MultipleChoiceSingle,
            Skill: "READING",
            Difficulty: 2,
            PromptMd: "What was the primary material used in early structures? (Revised)",
            ExplanationMd: "Paragraph 1 explicitly notes stone and clay as primary."
        );

        var resUpQ = await client.PutAsJsonAsync($"/api/admin/question/update/{questionId}", updateQDto);
        var qBody = await resUpQ.Content.ReadAsStringAsync();
        Assert.True(resUpQ.IsSuccessStatusCode, $"resUpQ failed: {resUpQ.StatusCode} - {qBody}");

        // 6. Admin updates manual Section via HTTP PUT
        var updateSecDto = new DtoAdmin.AdminSectionUpdate(
            ExamId: examId,
            Idx: 1,
            Title: "Manual Section 1: History of Architecture (Revised)",
            InstructionsMd: "Read the passage and answer questions 1–5.",
            PassageMd: "Manual passage text describing ancient architecture with revisions...",
            AudioUrl: null,
            TranscriptMd: null
        );
        var resUpSec = await client.PutAsJsonAsync($"/api/admin/section/update/{sectionId}", updateSecDto);
        var secBody = await resUpSec.Content.ReadAsStringAsync();
        Assert.True(resUpSec.IsSuccessStatusCode, $"resUpSec failed: {resUpSec.StatusCode} - {secBody}");

        // 7. Admin updates manual Option via HTTP PUT
        var updateOptDto = new DtoAdmin.AdminOptionUpdate(
            QuestionId: questionId,
            Idx: 1,
            ContentMd: "Stone, Timber and Clay",
            IsCorrect: true
        );
        var resUpOpt = await client.PutAsJsonAsync($"/api/admin/option/update/{optionId}", updateOptDto);
        var optBody = await resUpOpt.Content.ReadAsStringAsync();
        Assert.True(resUpOpt.IsSuccessStatusCode, $"resUpOpt failed: {resUpOpt.StatusCode} - {optBody}");

        // 8. Admin updates manual Exam to Published via HTTP PUT
        var updateExamDto = new DtoAdmin.AdminExamUpdate(
            Title: "Handcrafted Manual Practice Exam (Published)",
            DescriptionMd: "A purely manual test created by teachers without AI generation.",
            Category: "IELTS",
            Level: "C1",
            DurationMin: 60,
            ImageUrl: null,
            Status: ExamStatus.Published
        );
        var resUpExam = await client.PutAsJsonAsync($"/api/admin/exam/update/{examId}", updateExamDto);
        var examBody = await resUpExam.Content.ReadAsStringAsync();
        Assert.True(resUpExam.IsSuccessStatusCode, $"resUpExam failed: {resUpExam.StatusCode} - {examBody}");
        // 9. Verify Invariants: zero fake runs, zero lineage rows, zero feedback rows, zero outbox events
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

            var runCount = await db.ReadingPaperRuns.AsNoTracking().CountAsync();
            Assert.Equal(0, runCount);

            var lineageCount = await db.ReadingPaperEntityLineages.AsNoTracking().CountAsync();
            Assert.Equal(0, lineageCount);

            var feedbackCount = await db.ReadingPaperHumanFeedbacks.AsNoTracking().CountAsync();
            Assert.Equal(0, feedbackCount);

            var outboxCount = await db.ReadingPaperEventOutbox.AsNoTracking().CountAsync();
            Assert.Equal(0, outboxCount);

            var exam = await db.Exams.AsNoTracking().SingleAsync(e => e.Id == examId);
            Assert.Equal(ExamStatus.Published, exam.Status);
        }
    }
}
