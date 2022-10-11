# syntax=docker/dockerfile:1.4
FROM mcr.microsoft.com/dotnet/aspnet:6.0.9-bullseye-slim@sha256:3fb88dac384cabbd07146cfb5317f90eaadb2b19e3b928bb03f8992f7342ae4a AS base
WORKDIR /app
EXPOSE 8080/tcp 8081/tcp
ENV ASPNETCORE_URLS="http://+:8080;http://+:8081"
USER 65532:65532
CMD ["dotnet", "magniFHIR.dll"]

FROM mcr.microsoft.com/dotnet/sdk:6.0.401-bullseye-slim@sha256:37741f68682f5c69da8e805cdcf64d2279611e92b15edbaee87b819b12e9db29 AS build
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
