# syntax=docker/dockerfile:1.4
FROM mcr.microsoft.com/dotnet/aspnet:6.0.11-bullseye-slim@sha256:165383be8dc96734d5841f9c465ae8ddacb4896061a9f9eab9f67b0077883e25 AS base
WORKDIR /app
EXPOSE 8080/tcp 8081/tcp
ENV ASPNETCORE_URLS="http://+:8080;http://+:8081"
USER 65532:65532
CMD ["dotnet", "magniFHIR.dll"]

FROM mcr.microsoft.com/dotnet/sdk:6.0.403-bullseye-slim@sha256:df73027d1ba103388b3ab14f00e7abde5b58ff68d1e9ff9ec82198af7f27232b AS build
WORKDIR /build
COPY magniFHIR.sln .
COPY src/magniFHIR/magniFHIR.csproj src/magniFHIR/magniFHIR.csproj
COPY src/magniFHIR.Tests/magniFHIR.Tests.csproj src/magniFHIR.Tests/magniFHIR.Tests.csproj

RUN dotnet restore magniFHIR.sln

FROM build AS publish-release
COPY src/ src/
ARG BUILD_VERSION=0.0.0
RUN dotnet publish -p:Version=${BUILD_VERSION} --no-restore -c Release -o /out/release

FROM publish-release AS test
RUN dotnet test src/magniFHIR.Tests/magniFHIR.Tests.csproj \
    --no-restore -p:CollectCoverage=true

FROM base AS release
ENV ASPNETCORE_ENVIRONMENT="Production"
COPY --from=publish-release /out/release .
