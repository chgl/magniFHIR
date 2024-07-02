# syntax=docker/dockerfile:1.8@sha256:e87caa74dcb7d46cd820352bfea12591f3dba3ddc4285e19c7dcd13359f7cefd
FROM mcr.microsoft.com/dotnet/nightly/aspnet:7.0-jammy-chiseled@sha256:48ac5dada6bcc77c6c803909b8766d484594077c30d66da04d844a0fb980765c AS runtime
WORKDIR /opt/magnifhir
EXPOSE 8080/tcp 8081/tcp
USER 65532:65532
ENV DOTNET_ENVIRONMENT="Production" \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    ASPNETCORE_URLS="http://+:8080;http://+:8081"
ENTRYPOINT ["dotnet", "/opt/magnifhir/magniFHIR.dll"]

FROM mcr.microsoft.com/dotnet/sdk:7.0-jammy@sha256:4c39056f947fdcbcb2701ccf4124b25cec194717876b70544b3edce5179c7381 AS build
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
