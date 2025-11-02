FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY gateway/api-gateway/api-gateway.csproj gateway/api-gateway/
COPY services/_shared/Shared.PublicContracts/Shared.PublicContracts.csproj services/_shared/Shared.PublicContracts/
COPY services/_shared/Shared.Grpc/Shared.Grpc.csproj services/_shared/Shared.Grpc/
COPY services/_shared/Shared.Security/Shared.Security.csproj services/_shared/Shared.Security/

ARG NUGET_CACHE_ID=nuget-gateway
RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages,sharing=locked,id=${NUGET_CACHE_ID} \
    dotnet restore gateway/api-gateway/api-gateway.csproj

COPY . .
WORKDIR /src/gateway/api-gateway
RUN dotnet publish -c Release -o /app/publish \
    -r linux-musl-x64 \
    --self-contained true \
    /p:PublishSingleFile=true \
    /p:EnableCompressionInSingleFile=true \
    /p:DebugType=none

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://0.0.0.0:8080 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    Swagger__Enabled=true
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["./api-gateway"]
