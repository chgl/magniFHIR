# syntax=docker/dockerfile:1.4
FROM mcr.microsoft.com/dotnet/aspnet:6.0.10-bullseye-slim@sha256:3117930715937a3b9f285f36b830184bbf16699325f16ea10c9bb5680b698321 AS base
WORKDIR /app
EXPOSE 8080/tcp 8081/tcp
ENV ASPNETCORE_URLS="http://+:8080;http://+:8081"
USER 65532:65532
CMD ["dotnet", "magniFHIR.dll"]

FROM mcr.microsoft.com/dotnet/sdk:6.0.402-bullseye-slim@sha256:ed3105b69dc4c1fbb638b672debbdd498f7beebb5159e4c5e27d7c910a32ccfe AS build
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
