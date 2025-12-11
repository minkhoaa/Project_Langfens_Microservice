
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["services/chatbot-service/chatbot-service.csproj", "services/chatbot-service/"]
RUN dotnet restore "services/chatbot-service/chatbot-service.csproj"
ARG NUGET_CACHE_ID=nuget-chatbot
RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages,sharing=locked,id=${NUGET_CACHE_ID} \
    dotnet restore services/chatbot-service/chatbot-service.csproj

# copy toàn bộ source sau khi resore
COPY . .
WORKDIR /src/services/chatbot-service
RUN dotnet publish -c Release -o /out \
    -r linux-musl-x64 \
    --self-contained true \
    /p:PublishSingleFile=true \
    /p:EnableCompressionInSingleFile=true \
    /p:DebugType=none

# Runtime siêu gọn
FROM mcr.microsoft.com/dotnet/runtime-deps:10.0-alpine
WORKDIR /app
ENV ASPNETCORE_URLS=http://0.0.0.0:8080;http://+:8081 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    Swagger__Enabled=true
COPY --from=build /out /app
EXPOSE 8080 8081
ENTRYPOINT ["./chatbot-service"]   