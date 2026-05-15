using System.Net.WebSockets;
using System.Text.Json;
using CloudinaryDotNet.Actions;
using MassTransit;
using Shared.ExamDto.Contracts.Speaking;
using speaking_service.Contracts;
using speaking_service.Features.Helper;
using speaking_service.Features.Services.Helper;

namespace speaking_service.Features.RabbitMq
{
    public class SpeakingGradingConsumer : IConsumer<SpeakingGradingRequestMessage>
    {
        private readonly ILogger<SpeakingGradingConsumer> _logger;
        private readonly IPublishEndpoint _bus;
        private readonly IAudioDownloader _audioDownloader;
        private readonly IWhisperService _whisper;
        private readonly ISpeakingGrader _grader;
        public SpeakingGradingConsumer(ILogger<SpeakingGradingConsumer> logger,
            IPublishEndpoint bus,
            IAudioDownloader audioDownloader,
            IWhisperService whisper,

            ISpeakingGrader grader
            )
        {
            _grader = grader;
            _logger = logger;
            _bus = bus;
            _audioDownloader = audioDownloader;
            _whisper = whisper;
        }
        public async Task Consume(ConsumeContext<SpeakingGradingRequestMessage> context)
        {
            var request = context.Message;
            _logger.LogInformation(JsonSerializer.Serialize(request));
            var taskText = request.Prompt ?? "";
            var (audioFile, audioStream) = await _audioDownloader.GetAudioStreamAsync(request.AudioUrl, context.CancellationToken);
            string answerText;
            await using (audioStream)
            {
                answerText = await _whisper.Transcript(audioFile);
            }
            var contentSubmission = new ContentSubmission
            {
                Task = taskText,
                Transcript = answerText
            };
            var gradeResult = await _grader.GradeAsync(contentSubmission, context.CancellationToken);
            var res = gradeResult.Response;
            var gradingResponse = new SpeakingGradingResponseMessage
            {
                AttemptId = request.AttemptId,
                UserId = request.UserId,
                QuestionId = request.QuestionId,
                TaskText = taskText,
                TranscriptRaw = answerText,
                TranscriptNormalized = answerText,
                WordCount = res.WordCount,
                OverallBand = res.OverallBand,
                FluencyAndCoherence = res.FluencyAndCoherence,
                LexicalResource = res.LexicalResource,
                GrammaticalRangeAndAccuracy = res.GrammaticalRangeAndAccuracy,
                Pronunciation = res.Pronunciation,
                Suggestions = res.Suggestions,
                ImprovedAnswer = res.ImprovedAnswer
            };
            _logger.LogInformation(JsonSerializer.Serialize(res));

            await _bus.Publish(gradingResponse);

        }
    }
}