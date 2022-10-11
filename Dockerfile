# syntax=docker/dockerfile:1.4
FROM mcr.microsoft.com/dotnet/aspnet:6.0.10-bullseye-slim@sha256:9e89c7ac0544f59d06e74b68e4147a74a1d3e8bf64d8d72df4829347c2c4ed1d AS base
WORKDIR /app
EXPOSE 8080/tcp 8081/tcp
ENV ASPNETCORE_URLS="http://+:8080;http://+:8081"
USER 65532:65532
CMD ["dotnet", "magniFHIR.dll"]

FROM mcr.microsoft.com/dotnet/sdk:6.0.402-bullseye-slim@sha256:aaec85c808fc279aa2f81f6771208607fe3d6b56edf3dc6109272b8de5fa39a7 AS build
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
