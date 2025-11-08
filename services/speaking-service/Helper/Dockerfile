# ===== Build =====
FROM alpine:3.20 AS build
RUN apk add --no-cache build-base cmake git curl openblas-dev
WORKDIR /src
RUN git clone --depth=1 https://github.com/ggml-org/whisper.cpp.git .
RUN cmake -B build -DCMAKE_BUILD_TYPE=Release \
    -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS -DBLA_VENDOR=OpenBLAS \
 && cmake --build build -j"$(nproc)" --target whisper-server

# lấy 1 model
ARG MODEL=tiny.en
RUN mkdir -p /src/models \
 && curl -L -o /src/models/ggml-${MODEL}.bin \
    https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-${MODEL}.bin

# ===== Runtime =====
FROM alpine:3.20
# runtime deps: C++ + OpenMP + OpenBLAS
RUN apk add --no-cache libstdc++ libgomp openblas ffmpeg
WORKDIR /app

# copy MỌI thứ cần thiết từ build
COPY --from=build /src/build    /opt/build        
COPY --from=build /src/models   /app/models

ENV LD_LIBRARY_PATH="/usr/lib:/opt/build:/opt/build/src:/opt/build/bin:/opt/build/ggml:/opt/build/ggml/src:/opt/build/ggml/src/ggml-base:/opt/build/ggml/src/ggml-cpu:/opt/build/ggml/src/ggml-blas"
ENV GGML_LIBRARY_PATH="/usr/lib:/opt/build:/opt/build/src:/opt/build/ggml/src:/opt/build/ggml/src/ggml-base:/opt/build/ggml/src/ggml-cpu:/opt/build/ggml/src/ggml-blas"

EXPOSE 8080
ENTRYPOINT ["/opt/build/bin/whisper-server"]
CMD ["--model","/app/models/ggml-tiny.en.bin","--host","0.0.0.0","--port","8080","--inference-path","/v1/audio/transcriptions", "--processors","6","--threads","8","--convert"]
