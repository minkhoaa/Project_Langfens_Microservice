model dùng CPU
curl -sS http://localhost:8080/v1/audio/transcriptions \
-F "file=@/path/to/audio16k.wav" \
-F "response_format=json" \
-F "language=vi"
// model dùng GPU, model có thể thay bằng base, base.en, tiny.en, tiny
curl -sS -X POST http://localhost:8001/v1/audio/transcriptions   
-F "file=@/home/khoa/RiderProjects/Project_Langfens_Microservice/services/speaking-service/Helper/whisper/input/jfk.wav;type=audio/wav"   
-F "model=tiny.en"   -F "response_format=json"   
-w '\n__TIMING__ ttfb=%{time_starttransfer}s total=%{time_total}s code=%{http_code}\n'