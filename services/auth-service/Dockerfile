# Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src


COPY services/auth-service/auth-service.csproj services/auth-service/
COPY services/_shared/Shared.PublicContracts/Shared.PublicContracts.csproj services/_shared/Shared.PublicContracts/
COPY services/_shared/Shared.Grpc/Shared.Grpc.csproj services/_shared/Shared.Grpc/
ARG NUGET_CACHE_ID=nuget-auth
RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages,sharing=locked,id=${NUGET_CACHE_ID} \
    dotnet restore services/auth-service/auth-service.csproj

COPY . .
WORKDIR /src/services/auth-service
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
ENTRYPOINT ["./auth-service"]
