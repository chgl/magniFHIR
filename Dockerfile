# syntax=docker/dockerfile:1.4
FROM mcr.microsoft.com/dotnet/aspnet:6.0.8-bullseye-slim@sha256:03443189eeada54025e32f6c608243919bf414da47bd8ff583c0e11b5a39c299 AS base
WORKDIR /app
EXPOSE 8080/tcp 8081/tcp
ENV ASPNETCORE_URLS="http://+:8080;http://+:8081"
USER 65532:65532
CMD ["dotnet", "magniFHIR.dll"]

FROM mcr.microsoft.com/dotnet/sdk:6.0.400-bullseye-slim@sha256:0de6abdd99ed2d5ed770f77e8ed18bf99f10e5efce92c5fc2c013ec87ed04d26 AS build
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
