# Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY services/speaking-service/speaking-service.csproj services/speaking-service/
COPY services/_shared/Shared.PublicContracts/Shared.PublicContracts.csproj services/_shared/Shared.PublicContracts/
COPY services/_shared/Shared.Grpc/Shared.Grpc.csproj services/_shared/Shared.Grpc/
COPY services/_shared/Shared.Security/Shared.Security.csproj services/_shared/Shared.Security/


ARG NUGET_CACHE_ID=nuget-speaking
RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages,sharing=locked,id=${NUGET_CACHE_ID} \
    dotnet restore services/speaking-service/speaking-service.csproj

# copy toàn bộ source sau khi restore
COPY . .
WORKDIR /src/services/speaking-service
RUN dotnet publish -c Release -o /out \
    -r linux-x64 \
    --self-contained true \
    /p:PublishSingleFile=true \
    /p:EnableCompressionInSingleFile=true \
    /p:DebugType=none

# Runtime siêu gọn
# Runtime (Debian, glibc – compatible với whisper.net)
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0
WORKDIR /app

# 👇 Cài dependency mà whisper.net yêu cầu trên Linux: libstdc++6, glibc, libgomp1 
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libstdc++6 \
        libgomp1 && \
        ffmpeg && \
    rm -rf /var/lib/apt/lists/*

ENV ASPNETCORE_URLS=http://0.0.0.0:8080 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    Swagger__Enabled=true

COPY --from=build /out /app

EXPOSE 8080
ENTRYPOINT ["./speaking-service"]
