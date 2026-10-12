using System.Net;
using System.Security.Cryptography;
using System.Text.Json;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.PublicEndpoint;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace exam_service.Tests;
[Collection("DatabaseTests")]
public class Phase12PaperLoopTests
{
    private const string DefaultConn = "Host=localhost;Port=5433;Database=exam_test_phase12;Username=exam;Password=exam";
    private static string ConnectionString =>
        Environment.GetEnvironmentVariable("READING_TEST_POSTGRES")
        ?? Environment.GetEnvironmentVariable("ConnectionStrings__exam-db")
        ?? DefaultConn;

    private static ServiceProvider CreateTestProvider(string? connection = null)
    {
        var services = new ServiceCollection();
        services.AddDbContext<ExamDbContext>(options => options.UseNpgsql(connection ?? ConnectionString, npg =>
        {
            npg.ConfigureDataSource(dataSource => dataSource.EnableDynamicJson());
            npg.EnableRetryOnFailure();
        }));
        return services.BuildServiceProvider();
    }

    private static async Task<(ReadingPaperJob Job, ReadingPaperRun Run)> CreateJobAndRunAsync(
        ExamDbContext db,
        Guid owner,
        int epoch = 1)
    {
        await db.Database.MigrateAsync();

        var job = new ReadingPaperJob
        {
            Id = Guid.NewGuid(),
            Topic = "Phase 12 Paper Loop Verification",
            Status = "Running",
            Epoch = epoch,
            CancelVersion = 0,
            LeaseOwner = owner,
            LeaseUntil = DateTime.UtcNow.AddMinutes(5),
            SourcesJson = "[]",
            SectionsJson = "[]",
            CompletedSections = 0,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        db.ReadingPaperJobs.Add(job);

        var runId = $"run_{job.Id:N}";
        job.ActiveRunId = runId;
        var run = new ReadingPaperRun
        {
            Id = Guid.NewGuid(),
            JobId = job.Id,
            RunId = runId,
            Epoch = epoch,
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

        return (job, run);
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

    // ── T12-01: Numbering, Ordinals, and Section Counts ──────────────────────

    [Fact]
    public void T12_01_Validate_ValidThreeSections_Succeeds()
    {
        var sections = CreateCanonicalThreeSections();
        ReadingPaperRules.Validate(sections); // Must not throw
    }

    [Fact]
    public void T12_01_Validate_NonContiguousQuestions_Throws()
    {
        var sections = CreateCanonicalThreeSections();
        // Alter Q14 in Section 2 to be Q15 (creating gap and duplicate)
        var s2 = sections[1];
        var badQuestions = new List<ReadingGeneratedQuestion>(s2.Groups[0].Questions);
        badQuestions[0] = new ReadingGeneratedQuestion(15, badQuestions[0].Prompt, badQuestions[0].Answer, badQuestions[0].Options, badQuestions[0].EvidenceQuote, badQuestions[0].Explanation);
        sections[1] = new ReadingGeneratedSection(s2.Title, s2.Passage, s2.Source, new List<ReadingGeneratedGroup>
        {
            new(s2.Groups[0].Type, s2.Groups[0].Instruction, badQuestions),
            s2.Groups[1]
        });

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Contains("Question numbers must be continuous", ex.Message);
    }

    // ── T12-02: Word Policy Parity & Bounds ──────────────────────────────────

    [Fact]
    public void T12_02_Validate_ShortPassage_Throws()
    {
        var sections = CreateCanonicalThreeSections();
        var shortPassage = GenerateSamplePassage(1, 650); // < 720
        sections[0] = new ReadingGeneratedSection(sections[0].Title, shortPassage, sections[0].Source, sections[0].Groups);

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Contains("Passage length must be 720–915 words", ex.Message);
    }

    [Fact]
    public void T12_02_Validate_InvalidShortAnswer_ThrowsTypeAwareMessage()
    {
        var sections = CreateCanonicalThreeSections();
        // In Section 3 Group 2 (SHORT_ANSWER), alter Q34 answer to word not in passage
        var s3 = sections[2];
        var badQuestions = new List<ReadingGeneratedQuestion>(s3.Groups[1].Questions);
        badQuestions[0] = new ReadingGeneratedQuestion(34, badQuestions[0].Prompt, "nonexistent word", badQuestions[0].Options, badQuestions[0].EvidenceQuote, badQuestions[0].Explanation);
        sections[2] = new ReadingGeneratedSection(s3.Title, s3.Passage, s3.Source, new List<ReadingGeneratedGroup>
        {
            s3.Groups[0],
            new(s3.Groups[1].Type, s3.Groups[1].Instruction, badQuestions)
        });

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Equal("Question 34 has an invalid short answer", ex.Message);
    }

    // ── T12-03: Shingle Overlap Rejection ────────────────────────────────────

    [Fact]
    public void T12_03_Validate_HighPassageShingleOverlap_Throws()
    {
        var sections = CreateCanonicalThreeSections();
        // Set Section 2 passage identical to Section 1 passage
        sections[1] = new ReadingGeneratedSection(sections[1].Title, sections[0].Passage, sections[1].Source, sections[1].Groups);

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Contains("Passages contain duplicated text", ex.Message);
    }

    // ── T12-04: Question Prompt Uniqueness ───────────────────────────────────

    [Fact]
    public void T12_04_Validate_DuplicateQuestionPrompt_Throws()
    {
        var sections = CreateCanonicalThreeSections();
        // In Section 2, make Q14 prompt identical to Q1 prompt in Section 1
        var s2 = sections[1];
        var badQuestions = new List<ReadingGeneratedQuestion>(s2.Groups[0].Questions);
        badQuestions[0] = new ReadingGeneratedQuestion(14, sections[0].Groups[0].Questions[0].Prompt, badQuestions[0].Answer, badQuestions[0].Options, badQuestions[0].EvidenceQuote, badQuestions[0].Explanation);
        sections[1] = new ReadingGeneratedSection(s2.Title, s2.Passage, s2.Source, new List<ReadingGeneratedGroup>
        {
            new(s2.Groups[0].Type, s2.Groups[0].Instruction, badQuestions),
            s2.Groups[1]
        });

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Contains("Duplicate question prompt", ex.Message);
    }

    // ── T12-05: Fencing, Epoch, and Lease CAS Locks ──────────────────────────

    [Fact]
    public async Task T12_05_BuildExam_StaleEpochOrOwner_ThrowsFencingViolation()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);

        var sections = CreateCanonicalThreeSections();
        job.SectionsJson = JsonSerializer.Serialize(sections, ReadingPaperRules.Json);
        job.CompletedSections = 3;
        await db.SaveChangesAsync();

        var (paperEnv, validEvals) = await SeedFullAcceptedPaperGraphAsync(db, run, sections);

        // Stale epoch (e.g. 0 != 1) must be rejected
        var exStaleEpoch = await Assert.ThrowsAsync<CheckpointValidationException>(async () =>
        {
            await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
                run.RunId, Epoch: 0, LeaseOwner: owner, JobId: job.Id, FinalEvaluations: validEvals
            ), CancellationToken.None);
        });
        Assert.Equal(409, exStaleEpoch.StatusCode);

        // Stale lease owner mismatch must be rejected
        var otherOwner = Guid.NewGuid();
        var exOtherOwner = await Assert.ThrowsAsync<CheckpointValidationException>(async () =>
        {
            await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
                run.RunId, Epoch: 1, LeaseOwner: otherOwner, JobId: job.Id, FinalEvaluations: validEvals
            ), CancellationToken.None);
        });
        Assert.Equal(409, exOtherOwner.StatusCode);
    }

    // ── T12-06: Atomic Transaction Failure and Rollback ─────────────────────

    [Fact]
    public async Task T12_06_BuildExam_FaultInjection_RollsBackEntireTransaction()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);

        var sections = CreateCanonicalThreeSections();
        job.SectionsJson = JsonSerializer.Serialize(sections, ReadingPaperRules.Json);
        job.CompletedSections = 3;
        await db.SaveChangesAsync();

        var (paperEnv, validEvals) = await SeedFullAcceptedPaperGraphAsync(db, run, sections);

        var expectedSlug = $"reading-{job.Id:N}";

        // Inject fault before transaction completion
        await Assert.ThrowsAsync<InvalidOperationException>(async () =>
        {
            await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
                run.RunId, Epoch: 1, LeaseOwner: owner, JobId: job.Id, FinalEvaluations: validEvals
            ), CancellationToken.None, onBeforeTransaction: () => throw new InvalidOperationException("Simulated Injected Fault"));
        });

        // Verify zero half-written exam rows in DB
        var orphanedExam = await db.Exams.AsNoTracking().FirstOrDefaultAsync(e => e.Slug == expectedSlug);
        Assert.Null(orphanedExam);

        var reloadedJob = await db.ReadingPaperJobs.AsNoTracking().FirstAsync(j => j.Id == job.Id);
        Assert.Equal("Running", reloadedJob.Status);
        Assert.Null(reloadedJob.ExamId);
    }

    // ── T12-07: Idempotent Replay After Commit ───────────────────────────────

    [Fact]
    public async Task T12_07_BuildExam_ReplayAfterCommit_ReturnsSameExamId()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);

        var sections = CreateCanonicalThreeSections();
        job.SectionsJson = JsonSerializer.Serialize(sections, ReadingPaperRules.Json);
        job.CompletedSections = 3;
        await db.SaveChangesAsync();

        var (paperEnv, validEvals) = await SeedFullAcceptedPaperGraphAsync(db, run, sections);

        // 1. Initial successful build
        var firstResult = await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
            run.RunId, Epoch: 1, LeaseOwner: owner, JobId: job.Id, FinalEvaluations: validEvals
        ), CancellationToken.None);

        Assert.False(firstResult.IsExisting);
        Assert.NotEqual(Guid.Empty, firstResult.ExamId);

        // 2. Replay with identical parameters returns same ExamId with IsExisting: true
        var replayResult = await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
            run.RunId, Epoch: 1, LeaseOwner: owner, JobId: job.Id, FinalEvaluations: validEvals
        ), CancellationToken.None);

        Assert.True(replayResult.IsExisting);
        Assert.Equal(firstResult.ExamId, replayResult.ExamId);
        Assert.Equal(firstResult.Slug, replayResult.Slug);
    }

    // ── T12-08: Complete E2E Exam Graph Creation & Contract Parity ───────────

    [Fact]
    public async Task T12_08_BuildExam_CompleteGraphCreation_SucceedsWithAllQuestionsAndOptions()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);

        var sections = CreateCanonicalThreeSections();
        job.SectionsJson = JsonSerializer.Serialize(sections, ReadingPaperRules.Json);
        job.CompletedSections = 3;
        await db.SaveChangesAsync();

        var (paperEnv, validEvals) = await SeedFullAcceptedPaperGraphAsync(db, run, sections);

        var buildResult = await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
            run.RunId, Epoch: 1, LeaseOwner: owner, JobId: job.Id, FinalEvaluations: validEvals
        ), CancellationToken.None);
        Assert.False(buildResult.IsExisting);

        // Load full created Exam graph from database
        var createdExam = await db.Exams
            .Include(e => e.Sections)
                .ThenInclude(s => s.QuestionGroups)
                    .ThenInclude(g => g.Questions)
                        .ThenInclude(q => q.Options)
            .FirstOrDefaultAsync(e => e.Id == buildResult.ExamId);

        Assert.NotNull(createdExam);
        Assert.Equal(ExamStatus.Draft, createdExam.Status);
        Assert.Equal(60, createdExam.DurationMin);
        Assert.Equal("IELTS", createdExam.Category);
        Assert.Equal(3, createdExam.Sections.Count);

        // Verify total questions across sections is exactly 40
        var totalQuestions = createdExam.Sections.SelectMany(s => s.QuestionGroups).SelectMany(g => g.Questions).ToList();
        Assert.Equal(40, totalQuestions.Count);

        // Verify contiguous numbering 1 to 40
        var ordinals = totalQuestions.Select(q => q.Idx).OrderBy(x => x).ToList();
        Assert.Equal(Enumerable.Range(1, 40).ToList(), ordinals);

        // Verify Section 1 question types and answers
        var sec1Questions = createdExam.Sections[0].QuestionGroups.SelectMany(g => g.Questions).ToList();
        Assert.Equal(13, sec1Questions.Count);
        Assert.Equal(7, sec1Questions.Count(q => q.Type == "TRUE_FALSE_NOT_GIVEN"));
        Assert.Equal(6, sec1Questions.Count(q => q.Type == "SENTENCE_COMPLETION"));

        // Verify Section 2 Multiple Choice Options
        var sec2Mcq = createdExam.Sections[1].QuestionGroups[0].Questions;
        Assert.Equal(6, sec2Mcq.Count);
        foreach (var mcq in sec2Mcq)
        {
            Assert.Equal(4, mcq.Options.Count);
            Assert.Equal(1, mcq.Options.Count(o => o.IsCorrect));
        }

        // Verify Section 3 Short Answer
        var sec3ShortAns = createdExam.Sections[2].QuestionGroups[1].Questions;
        Assert.Equal(7, sec3ShortAns.Count);
        foreach (var sa in sec3ShortAns)
        {
            Assert.NotNull(sa.ShortAnswerAcceptTexts);
            Assert.NotEmpty(sa.ShortAnswerAcceptTexts);
        }

        // Verify Job and Run completed status
        var reloadedJob = await db.ReadingPaperJobs.AsNoTracking().FirstAsync(j => j.Id == job.Id);
        Assert.Equal("Completed", reloadedJob.Status);
        Assert.Equal(createdExam.Id, reloadedJob.ExamId);

        var reloadedRun = await db.ReadingPaperRuns.AsNoTracking().FirstAsync(r => r.RunId == run.RunId);
        Assert.Equal("COMPLETED", reloadedRun.Status);
    }

    // ── T12-09: Admin Publish Workflow (Draft → Published Visibility) ─────────

    [Fact]
    public async Task T12_09_Admin_PublishDraftExam_IsVisibleToStudents_WhileDraftIsHidden()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);

        var sections = CreateCanonicalThreeSections();
        job.SectionsJson = JsonSerializer.Serialize(sections, ReadingPaperRules.Json);
        job.CompletedSections = 3;
        await db.SaveChangesAsync();
        var (paperEnv, validEvals) = await SeedFullAcceptedPaperGraphAsync(db, run, sections);

        // 1. Build the exam graph (initially Draft)
        var buildResult = await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
            run.RunId, Epoch: 1, LeaseOwner: owner, JobId: job.Id, FinalEvaluations: validEvals
        ), CancellationToken.None);

        var createdExam = await db.Exams.AsNoTracking().FirstAsync(e => e.Id == buildResult.ExamId);
        Assert.Equal(ExamStatus.Draft, createdExam.Status);

        // 2. While Draft, students cannot see this exam (ListPublished filter rejects it)
        var draftList = await db.Exams.AsNoTracking()
            .Where(x => x.Status == ExamStatus.Published && x.Slug == createdExam.Slug)
            .ToListAsync();
        Assert.Empty(draftList);

        // 3. Admin publishes the exam: flip Status Draft -> Published
        var examToPublish = await db.Exams.FirstAsync(e => e.Id == createdExam.Id);
        examToPublish.Status = ExamStatus.Published;
        examToPublish.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync();
        // 4. After publish, students can now see the exam via the published filter
        var publishedList = await db.Exams.AsNoTracking()
            .Where(x => x.Status == ExamStatus.Published && x.Slug == createdExam.Slug)
            .ToListAsync();
        Assert.Single(publishedList);
        Assert.Equal(createdExam.Id, publishedList[0].Id);

        // 5. The published exam is retrievable by slug from a student-payload perspective
        //    (mirrors ExamService.GetBySlugAsync in PublicEndpoint which filters on Published)
        var studentVisible = await db.Exams.AsNoTracking()
            .FirstOrDefaultAsync(x => x.Slug == createdExam.Slug && x.Status == ExamStatus.Published);
        Assert.NotNull(studentVisible);
        Assert.Equal(createdExam.Title, studentVisible.Title);
    }

    // ── T12-10: Manual CRUD Operations (sections, questions, options, deletes) ──

    [Fact]
    public async Task T12_10_Crud_UpdatesSectionsQuestionsOptions_DeleteMaintainsCascade()
    {
        using var provider = CreateTestProvider();
        Guid examId;

        // Step 1: Provision and Build Exam
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var owner = Guid.NewGuid();
            var (job, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);

            var sections = CreateCanonicalThreeSections();
            job.SectionsJson = JsonSerializer.Serialize(sections, ReadingPaperRules.Json);
            job.CompletedSections = 3;
            await db.SaveChangesAsync();
            var (paperEnv, validEvals) = await SeedFullAcceptedPaperGraphAsync(db, run, sections);

            var buildResult = await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
                run.RunId, Epoch: 1, LeaseOwner: owner, JobId: job.Id, FinalEvaluations: validEvals
            ), CancellationToken.None);
            examId = buildResult.ExamId;
        }

        // Step 2: UPDATE section instructions on Section 1
        var newInstructions = $"Updated instructions for Section 1 ({DateTime.UtcNow.Ticks})";
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var sec1 = await db.ExamSections.FirstAsync(s => s.ExamId == examId && s.Idx == 1);
            sec1.InstructionsMd = newInstructions;
            await db.SaveChangesAsync();
        }
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var sec1 = await db.ExamSections.AsNoTracking().FirstAsync(s => s.ExamId == examId && s.Idx == 1);
            Assert.Equal(newInstructions, sec1.InstructionsMd);
        }

        // Step 3: ADD a new question to Section 1's second group (SENTENCE_COMPLETION)
        var addedQuestionId = Guid.NewGuid();
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var sec1 = await db.ExamSections.Include(s => s.QuestionGroups).FirstAsync(s => s.ExamId == examId && s.Idx == 1);
            var group2 = sec1.QuestionGroups.OrderBy(g => g.Idx).Skip(1).First();
            var addedQuestion = new ExamQuestion
            {
                Id = addedQuestionId,
                SectionId = sec1.Id,
                GroupId = group2.Id,
                Idx = 99,
                Type = "SENTENCE_COMPLETION",
                Skill = "READING",
                Difficulty = 1,
                PromptMd = "Additional sentence completion question [99].",
                ExplanationMd = "Explanation for Q99 with verified evidence.",
                BlankAcceptTexts = new Dictionary<string, string[]?> { ["99"] = new[] { "answer" } }
            };
            db.ExamQuestions.Add(addedQuestion);
            await db.SaveChangesAsync();
        }
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var q = await db.ExamQuestions.AsNoTracking().FirstOrDefaultAsync(x => x.Id == addedQuestionId);
            Assert.NotNull(q);
            Assert.Equal(99, q.Idx);
        }

        // Step 4: MODIFY an existing option: change the correct option in Section 2 Group 1 (MCQ) Q14
        Guid modifiedOptionId;
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var sec2 = await db.ExamSections
                .Include(s => s.QuestionGroups)
                    .ThenInclude(g => g.Questions)
                        .ThenInclude(q => q.Options)
                .FirstAsync(s => s.ExamId == examId && s.Idx == 2);
            var q14 = sec2.QuestionGroups.SelectMany(g => g.Questions).First(q => q.Idx == 14);
            var oldCorrect = q14.Options.First(o => o.IsCorrect);
            var newCorrect = q14.Options.First(o => !o.IsCorrect);
            oldCorrect.IsCorrect = false;
            newCorrect.IsCorrect = true;
            modifiedOptionId = newCorrect.Id;
            await db.SaveChangesAsync();
        }
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var opt = await db.ExamOptions.AsNoTracking().FirstAsync(o => o.Id == modifiedOptionId);
            Assert.True(opt.IsCorrect);
        }

        // Step 5: DELETE the newly added question and verify cascade
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var qToDelete = await db.ExamQuestions.FirstAsync(x => x.Id == addedQuestionId);
            db.ExamQuestions.Remove(qToDelete);
            await db.SaveChangesAsync();
        }
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var orphanCheck = await db.ExamQuestions.AsNoTracking().FirstOrDefaultAsync(o => o.Id == addedQuestionId);
            Assert.Null(orphanCheck);

            // Verify parent/child relationships and totals without orphans
            var reloadedFullGraph = await db.Exams
                .Include(e => e.Sections)
                    .ThenInclude(s => s.QuestionGroups)
                        .ThenInclude(g => g.Questions)
                            .ThenInclude(q => q.Options)
                .FirstAsync(e => e.Id == examId);

            var totalQs = reloadedFullGraph.Sections.SelectMany(s => s.QuestionGroups).SelectMany(g => g.Questions).Count();
            Assert.Equal(40, totalQs);
            Assert.Equal(3, reloadedFullGraph.Sections.Count);
            var s1 = reloadedFullGraph.Sections.First(s => s.Idx == 1);
            Assert.Equal(13, s1.QuestionGroups.SelectMany(g => g.Questions).Count());
            var s3 = reloadedFullGraph.Sections.First(s => s.Idx == 3);
            Assert.Equal(14, s3.QuestionGroups.SelectMany(g => g.Questions).Count());
        }
    }

    // ── T12-08 Complete E2E: Source → Draft → Admin Publish → CRUD → Student Isolation ──

    [Fact]
    public async Task T12_08_EndToEnd_SourceToDraftPublishCrudStudentPayloadIsolation()
    {
        using var provider = CreateTestProvider();
        Guid examId;
        string examSlug;

        // 1. SOURCE -> Build Draft from canonical sources
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var owner = Guid.NewGuid();
            var (job, run) = await CreateJobAndRunAsync(db, owner, epoch: 1);

            var sources = new List<ReadingSource>
            {
                new("PMC1111111", "Linguistic Cognition", "10.1016/j.ling.001",
                    "https://europepmc.org/articles/PMC1111111", "CC BY 4.0", 800),
                new("PMC2222222", "Astrophysical Observation", "10.1016/j.astro.002",
                    "https://europepmc.org/articles/PMC2222222", "CC BY 4.0", 800),
                new("PMC3333333", "Reef Ecosystem Resilience", "10.1016/j.marine.003",
                    "https://europepmc.org/articles/PMC3333333", "CC BY 4.0", 800),
            };
            job.SourcesJson = JsonSerializer.Serialize(sources, ReadingPaperRules.Json);

            var sections = CreateCanonicalThreeSections();
            job.SectionsJson = JsonSerializer.Serialize(sections, ReadingPaperRules.Json);
            job.CompletedSections = 3;
            await db.SaveChangesAsync();
            var (paperEnv, validEvals) = await SeedFullAcceptedPaperGraphAsync(db, run, sections);

            var buildResult = await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
                run.RunId, Epoch: 1, LeaseOwner: owner, JobId: job.Id, FinalEvaluations: validEvals
            ), CancellationToken.None);
            Assert.False(buildResult.IsExisting);
            examId = buildResult.ExamId;
            examSlug = buildResult.Slug;

            var draft = await db.Exams.AsNoTracking().FirstAsync(e => e.Id == examId);
            Assert.Equal(ExamStatus.Draft, draft.Status);
        }

        // 2. DRAFT VISIBILITY: students cannot see Draft exam
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var draftVisibility = await db.Exams.AsNoTracking()
                .Where(x => x.Slug == examSlug && x.Status == ExamStatus.Published)
                .ToListAsync();
            Assert.Empty(draftVisibility);
        }

        // 3. ADMIN PUBLISH: admin transitions Draft -> Published
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var draft = await db.Exams.FirstAsync(e => e.Id == examId);
            draft.Status = ExamStatus.Published;
            draft.UpdatedAt = DateTime.UtcNow;
            await db.SaveChangesAsync();
        }

        // 4. CRUD: Admin makes edits
        var newQId = Guid.NewGuid();
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var publishedExam = await db.Exams
                .Include(e => e.Sections)
                    .ThenInclude(s => s.QuestionGroups)
                .FirstAsync(e => e.Id == examId);

            // a) Update Section 1 instructions
            publishedExam.Sections[0].InstructionsMd = "Admin-updated section instructions for Section 1.";

            // b) Add a temporary question to Section 2 Group 2
            var sec2 = publishedExam.Sections[1];
            var group2S2 = sec2.QuestionGroups[1];
            var newQ = new ExamQuestion
            {
                Id = newQId,
                SectionId = sec2.Id,
                GroupId = group2S2.Id,
                Idx = 99,
                Type = "SUMMARY_COMPLETION",
                Skill = "READING",
                Difficulty = 2,
                PromptMd = "Additional summary completion [99].",
                ExplanationMd = "Explanation for Q99 with verified evidence.",
                BlankAcceptTexts = new Dictionary<string, string[]?> { ["99"] = new[] { "answer" } }
            };
            db.ExamQuestions.Add(newQ);
            await db.SaveChangesAsync();
        }

        // Delete the temporary question
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var q = await db.ExamQuestions.FirstAsync(x => x.Id == newQId);
            db.ExamQuestions.Remove(q);
            await db.SaveChangesAsync();
        }

        // 5. STUDENT PAYLOAD ISOLATION: students only see the Published exam with its full graph;
        //    Draft is excluded, deleted question is gone, edits are persisted.
        using (var scope = provider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var studentVisibleExam = await db.Exams
                .Include(e => e.Sections)
                    .ThenInclude(s => s.QuestionGroups)
                        .ThenInclude(g => g.Questions)
                            .ThenInclude(q => q.Options)
                .AsNoTracking()
                .FirstAsync(x => x.Slug == examSlug && x.Status == ExamStatus.Published);

            Assert.Equal(ExamStatus.Published, studentVisibleExam.Status);
            Assert.Equal(3, studentVisibleExam.Sections.Count);
            Assert.Equal("Admin-updated section instructions for Section 1.", studentVisibleExam.Sections[0].InstructionsMd);
            Assert.DoesNotContain(studentVisibleExam.Sections.SelectMany(s => s.QuestionGroups).SelectMany(g => g.Questions),
                q => q.Id == newQId);

            var totalQuestions = studentVisibleExam.Sections.SelectMany(s => s.QuestionGroups).SelectMany(g => g.Questions).Count();
            Assert.Equal(40, totalQuestions);
        }
    }
    [Fact]
    public async Task T12_QueuedCase_ReprovisionPreservesInputsFenceAndUsage()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();
        var caps = R03CapsProfileTests.ApprovedFromDeployEnvFile();
        var campaignId = "runtime_queue_" + Guid.NewGuid().ToString("N");
        await BenchmarkCampaignService.CreateAsync(db, new BenchmarkCampaignCreateRequest(
            campaignId, "automatic", "runtime-tests", new string('a', 64), new string('b', 64), -1, -1, -1), CancellationToken.None);
        var sources = CreateCanonicalThreeSections().Select(s => s.Source with { Content = s.Passage }).ToList();
        var request = new BenchmarkCaseProvisionRequest(campaignId, "paper", "claim", Guid.NewGuid(),
            new BenchmarkWorkerInput("Runtime source-bound paper", sources));
        var first = await BenchmarkCampaignService.ProvisionCaseAsync(db, request, caps, CancellationToken.None);
        var job = await db.ReadingPaperJobs.AsNoTracking().SingleAsync(j => j.Id == first.JobId);
        Assert.Equal("Pending", job.Status);
        Assert.Null(job.LeaseOwner);
        Assert.Null(job.LeaseUntil);
        Assert.Equal(3, JsonSerializer.Deserialize<List<ReadingSource>>(job.SourcesJson, ReadingPaperRules.Json)!.Count);
        var run = await db.ReadingPaperRuns.SingleAsync(r => r.RunId == first.RunId);
        Assert.Equal(-1, run.BudgetCapCalls);
        run.BudgetUsedCalls = 2;
        await db.SaveChangesAsync();
        var replay = await BenchmarkCampaignService.ProvisionCaseAsync(db, request, caps, CancellationToken.None);
        Assert.Equal(first.RunId, replay.RunId);
        Assert.Equal(first.Epoch, replay.Epoch);
        Assert.Equal(2, (await db.ReadingPaperRuns.AsNoTracking().SingleAsync(r => r.RunId == first.RunId)).BudgetUsedCalls);
        await Assert.ThrowsAsync<CheckpointValidationException>(() => BenchmarkCampaignService.ProvisionCaseAsync(
            db, request with { WorkerInput = request.WorkerInput! with { Topic = "Changed topic" } }, caps, CancellationToken.None));
    }
    [Fact]
    public async Task T12_Finalizer_RejectsSectionsJsonWithoutAcceptedPaper()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);
        job.SectionsJson = JsonSerializer.Serialize(CreateCanonicalThreeSections(), ReadingPaperRules.Json);
        await db.SaveChangesAsync();
        await db.ReadingPaperArtifactHeads.Where(h => h.RunId == run.RunId).ExecuteDeleteAsync();
        await Assert.ThrowsAsync<CheckpointValidationException>(() => CheckpointService.BuildExamIdempotentAsync(
            db, new BuildExamInternalRequest(run.RunId, run.Epoch, owner, job.Id), CancellationToken.None));
        Assert.False(await db.Exams.AnyAsync(e => e.Slug == $"reading-{job.Id:N}"));
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

    // ── G12 Unit Tests: LoadAsync & Evaluator Verification ───────────────────

    [Fact]
    public async Task T12_G12_00_AcceptedPaperWithFreshEvaluations_LoadsSuccessfully()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);
        var canonicalSections = CreateCanonicalThreeSections();

        var (paperEnv, validEvaluations) = await SeedFullAcceptedPaperGraphAsync(db, run, canonicalSections);

        var loadedSections = await ReadingPaperFinalSnapshot.LoadAsync(db, run, job, validEvaluations, CancellationToken.None);

        Assert.NotNull(loadedSections);
        Assert.Equal(3, loadedSections.Count);
        Assert.Equal(40, loadedSections.Sum(s => s.Groups.Sum(g => g.Questions.Count)));
    }

    [Fact]
    public async Task T12_G12_01_RejectsMissingRequiredEvaluator()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);
        var canonicalSections = CreateCanonicalThreeSections();

        var (paperEnv, validEvaluations) = await SeedFullAcceptedPaperGraphAsync(db, run, canonicalSections);

        // Remove eval_paper_monotony
        var mutatedEvaluations = validEvaluations.Where(e => e.EvaluatorId != "eval_paper_monotony").ToList();

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, mutatedEvaluations, CancellationToken.None));

        Assert.Equal(409, ex.StatusCode);
        Assert.Contains("Required fresh paper evaluation rejected: eval_paper_monotony", ex.Message);
    }

    [Fact]
    public async Task T12_G12_02_RejectsStaleEvaluatorVersion()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);
        var canonicalSections = CreateCanonicalThreeSections();

        var (paperEnv, validEvaluations) = await SeedFullAcceptedPaperGraphAsync(db, run, canonicalSections);

        // Mutate eval_paper_structure to stale version "1.0.0" instead of "2.0.0"
        var mutatedEvaluations = validEvaluations.Select(e =>
            e.EvaluatorId == "eval_paper_structure" ? e with { EvaluatorVersion = "1.0.0" } : e).ToList();

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, mutatedEvaluations, CancellationToken.None));

        Assert.Equal(409, ex.StatusCode);
        Assert.Contains("Required fresh paper evaluation rejected: eval_paper_structure", ex.Message);
    }

    [Fact]
    public async Task T12_G12_03_RejectsOpenCriticalOrMajorIssue()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);
        var canonicalSections = CreateCanonicalThreeSections();

        var (paperEnv, validEvaluations) = await SeedFullAcceptedPaperGraphAsync(db, run, canonicalSections);

        // Mutate eval_paper_cross_section with open MAJOR issue
        var majorIssue = new Issue(
            "iss_maj_01",
            IssueCode.CROSS_SECTION_DUPLICATE_CONTENT,
            IssueSeverity.MAJOR,
            IssueScope.PAPER,
            new List<ArtifactRef> { paperEnv.ToRef() },
            "Cross-section duplicate prompt detected across Section 1 and Section 2.",
            null,
            "Regenerate duplicate prompt in Section 2",
            IssueStatus.OPEN,
            "fp_major_01",
            DateTime.UtcNow,
            null,
            "eval_paper_cross_section"
        );

        var mutatedWithMajor = validEvaluations.Select(e =>
            e.EvaluatorId == "eval_paper_cross_section" ? e with { Issues = new List<Issue> { majorIssue } } : e).ToList();

        var exMajor = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, mutatedWithMajor, CancellationToken.None));

        Assert.Equal(409, exMajor.StatusCode);
        Assert.Contains("Required fresh paper evaluation rejected: eval_paper_cross_section", exMajor.Message);

        // Mutate with open CRITICAL issue
        var criticalIssue = majorIssue with { IssueId = "iss_crit_01", Severity = IssueSeverity.CRITICAL, Fingerprint = "fp_crit_01" };
        var mutatedWithCritical = validEvaluations.Select(e =>
            e.EvaluatorId == "eval_paper_cross_section" ? e with { Issues = new List<Issue> { criticalIssue } } : e).ToList();

        var exCrit = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, mutatedWithCritical, CancellationToken.None));

        Assert.Equal(409, exCrit.StatusCode);
        Assert.Contains("Required fresh paper evaluation rejected: eval_paper_cross_section", exCrit.Message);
    }

    [Fact]
    public async Task T12_G12_04_RejectsParentReferenceClosureMismatch()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();

        var owner = Guid.NewGuid();
        var (job, run) = await CreateJobAndRunAsync(db, owner);
        var canonicalSections = CreateCanonicalThreeSections();

        var (paperEnv, validEvaluations) = await SeedFullAcceptedPaperGraphAsync(db, run, canonicalSections);

        // Mutate eval_paper_leakage to omit the first parent ref (blueprintRef)
        var mutatedDeps = paperEnv.ParentRefs.Skip(1).ToList();
        var mutatedEvaluations = validEvaluations.Select(e =>
            e.EvaluatorId == "eval_paper_leakage" ? e with { InputDependencyRefs = mutatedDeps } : e).ToList();

        var ex = await Assert.ThrowsAsync<CheckpointValidationException>(() =>
            ReadingPaperFinalSnapshot.LoadAsync(db, run, job, mutatedEvaluations, CancellationToken.None));

        Assert.Equal(409, ex.StatusCode);
        Assert.Contains("Exact parent/evaluation dependency closure mismatch", ex.Message);
    }

    [Fact]
    public async Task T12_11_Admin_UpdateStatus_CaseInsensitiveNormalizationAndValidation()
    {
        using var provider = CreateTestProvider();
        using var scope = provider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        await db.Database.MigrateAsync();
        IAdminExamService adminService = new AdminExamService(db);
        IExamService publicService = new exam_service.Features.Exams.PublicEndpoint.ExamService(db);

        // 1. Create a draft exam
        var uniqueSuffix = Guid.NewGuid().ToString("N")[..8];
        var createDto = new DtoAdmin.AdminExamCreate(
            Title: $"Status Normalization Test {uniqueSuffix}",
            Slug: $"status-norm-test-{uniqueSuffix}",
            DescriptionMd: "Test description",
            Category: "IELTS",
            Level: "Academic",
            DurationMin: 60,
            ImageUrl: null
        );
        var createRes = await adminService.AddAsync(createDto);
        Assert.IsType<Ok<ApiResultDto>>(createRes);

        var exam = await db.Exams.FirstAsync(e => e.Slug == createDto.Slug);
        Assert.Equal(ExamStatus.Draft, exam.Status);

        // 2. Update status with lowercase "published" -> normalized to "PUBLISHED"
        var updatePublishedDto = new DtoAdmin.AdminExamUpdate(
            Title: exam.Title,
            DescriptionMd: exam.DescriptionMd,
            Category: exam.Category,
            Level: exam.Level,
            DurationMin: exam.DurationMin,
            ImageUrl: exam.ImageUrl,
            Status: "published"
        );
        var updateRes = await adminService.UpdateAsync(exam.Id, updatePublishedDto);
        Assert.IsType<Ok<ApiResultDto>>(updateRes);

        var updatedExam = await db.Exams.AsNoTracking().FirstAsync(e => e.Id == exam.Id);
        Assert.Equal(ExamStatus.Published, updatedExam.Status, StringComparer.OrdinalIgnoreCase);
        // 3. Verify public retrieval by slug sees the published exam
        var getResult = await publicService.GetBySlugAsync(exam.Slug, CancellationToken.None);
        Assert.IsType<Ok<ApiResultDto>>(getResult);

        // 4. Update status with mixed case "dRaFt" -> normalized to "DRAFT"
        var updateDraftDto = updatePublishedDto with { Status = "dRaFt" };
        var updateDraftRes = await adminService.UpdateAsync(exam.Id, updateDraftDto);
        Assert.IsType<Ok<ApiResultDto>>(updateDraftRes);

        var draftedExam = await db.Exams.AsNoTracking().FirstAsync(e => e.Id == exam.Id);
        Assert.Equal(ExamStatus.Draft, draftedExam.Status, StringComparer.OrdinalIgnoreCase);
        // 5. Public retrieval by slug now returns NotFound for draft
        var getDraftResult = await publicService.GetBySlugAsync(exam.Slug, CancellationToken.None);
        Assert.IsType<NotFound<ApiResultDto>>(getDraftResult);

        // 6. Update with invalid status -> returns BadRequest
        var updateInvalidDto = updatePublishedDto with { Status = "INVALID_STATUS_VALUE" };
        var updateInvalidRes = await adminService.UpdateAsync(exam.Id, updateInvalidDto);
        Assert.IsType<BadRequest<ApiResultDto>>(updateInvalidRes);
    }
}
