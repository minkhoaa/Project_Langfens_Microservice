FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["services/gamification-service/gamification-service.csproj", "services/gamification-service/"]
COPY ["services/_shared/Shared.Security/Shared.Security.csproj", "services/_shared/Shared.Security/"]
COPY ["services/_shared/Shared.PublicContracts/Shared.PublicContracts.csproj", "services/_shared/Shared.PublicContracts/"]
RUN dotnet restore "services/gamification-service/gamification-service.csproj"
COPY . .
WORKDIR "/src/services/gamification-service"
RUN dotnet build "gamification-service.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "gamification-service.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "gamification-service.dll"]
