# syntax=docker/dockerfile:1.6@sha256:ac85f380a63b13dfcefa89046420e1781752bab202122f8f50032edf31be0021
FROM mcr.microsoft.com/dotnet/nightly/aspnet:7.0-jammy-chiseled@sha256:48ac5dada6bcc77c6c803909b8766d484594077c30d66da04d844a0fb980765c AS runtime
WORKDIR /opt/magnifhir
EXPOSE 8080/tcp 8081/tcp
USER 65532:65532
ENV DOTNET_ENVIRONMENT="Production" \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    ASPNETCORE_URLS="http://+:8080;http://+:8081"
ENTRYPOINT ["dotnet", "/opt/magnifhir/magniFHIR.dll"]

FROM mcr.microsoft.com/dotnet/sdk:7.0-jammy@sha256:9db41721e58ac92cea1b5cbdb6080cd033a66a6f83521eaf0e1e561e9971efa7 AS build
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
