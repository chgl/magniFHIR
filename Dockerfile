# syntax=docker/dockerfile:1.4
FROM mcr.microsoft.com/dotnet/aspnet:6.0.7-bullseye-slim AS base
WORKDIR /app
EXPOSE 8080/tcp 8081/tcp
ENV ASPNETCORE_URLS="http://+:8080;http://+:8081"
USER 65532:65532
CMD ["dotnet", "magniFHIR.dll"]

FROM mcr.microsoft.com/dotnet/sdk:6.0.302-bullseye-slim AS build
WORKDIR /build
COPY magniFHIR.sln .
COPY src/magniFHIR/magniFHIR.csproj src/magniFHIR/magniFHIR.csproj
COPY src/magniFHIR.Tests/magniFHIR.Tests.csproj src/magniFHIR.Tests/magniFHIR.Tests.csproj

RUN --mount=type=cache,target=/root/.nuget/packages \
    dotnet restore magniFHIR.sln

FROM build AS publish-release
COPY src/ src/
RUN --mount=type=cache,target=/root/.nuget/packages \
    dotnet publish --no-restore -c Release -o /out/release

FROM publish-release AS test
RUN --mount=type=cache,target=/root/.nuget/packages \
    dotnet test src/magniFHIR.Tests/magniFHIR.Tests.csproj \
    --no-restore -p:CollectCoverage=true

FROM base AS release
ENV ASPNETCORE_ENVIRONMENT="Production"
COPY --from=publish-release /out/release .
