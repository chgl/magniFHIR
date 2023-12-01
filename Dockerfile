# syntax=docker/dockerfile:1.4@sha256:9ba7531bd80fb0a858632727cf7a112fbfd19b17e94c4e84ced81e24ef1a0dbc
FROM mcr.microsoft.com/dotnet/nightly/aspnet:7.0-jammy-chiseled@sha256:1768d50efc593b58b0f4a0271be89d07e72adbae42ce25e4f9e717463ebcbf0d AS runtime
WORKDIR /opt/magnifhir
EXPOSE 8080/tcp 8081/tcp
USER 65532:65532
ENV DOTNET_ENVIRONMENT="Production" \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    ASPNETCORE_URLS="http://+:8080;http://+:8081"
ENTRYPOINT ["dotnet", "/opt/magnifhir/magniFHIR.dll"]

FROM mcr.microsoft.com/dotnet/sdk:7.0-jammy@sha256:1f03f2609039c9172458f1172e4646032f1894fbc8e0cc6dfdfa5373348ae6cc AS build
WORKDIR /build
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

COPY magniFHIR.sln .
COPY src/magniFHIR/magniFHIR.csproj src/magniFHIR/magniFHIR.csproj
COPY src/magniFHIR.Tests/magniFHIR.Tests.csproj src/magniFHIR.Tests/magniFHIR.Tests.csproj

RUN dotnet restore magniFHIR.sln

COPY . .

RUN <<EOF
dotnet build src/magniFHIR/magniFHIR.csproj \
    --no-restore \
    --configuration=Release

dotnet publish src/magniFHIR/magniFHIR.csproj \
    --no-restore \
    --no-build \
    --configuration=Release \
    -o /build/publish
EOF

FROM build AS test
RUN dotnet test src/magniFHIR.Tests/magniFHIR.Tests.csproj \
    --no-restore -p:CollectCoverage=true

FROM runtime
COPY --from=build /build/publish .
