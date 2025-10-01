# Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY services/attempt-service/attempt-service.csproj services/attempt-service/
COPY services/_shared/Shared.ExamDto/Shared.ExamDto.csproj services/_shared/Shared.ExamDto/
COPY services/_shared/Shared.Grpc/Shared.Grpc.csproj services/_shared/Shared.Grpc/
RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages \
    dotnet restore services/attempt-service/attempt-service.csproj

# copy toàn bộ source sau khi restore
COPY . .
WORKDIR /src/services/attempt-service
RUN dotnet publish -c Release -o /out \
    -r linux-musl-x64 \
    --self-contained true \
    /p:PublishSingleFile=true \
    /p:EnableCompressionInSingleFile=true \
    /p:DebugType=none

# Runtime siêu gọn
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine
WORKDIR /app
ENV ASPNETCORE_URLS=http://0.0.0.0:8080 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    Swagger__Enabled=true
COPY --from=build /out /app
EXPOSE 8080
ENTRYPOINT ["./attempt-service"]   
