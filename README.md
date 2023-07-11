# magniFHIR

[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/chgl/magniFHIR/badge)](https://api.securityscorecards.dev/projects/github.com/chgl/magniFHIR)
[![SLSA 3](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev)

Visibility into your FHIR server.

## Running

<!-- x-release-please-start-version -->

```sh
docker run --rm -it -p 8080:8080 \
    -e FhirServers__0__Name="HAPI FHIR Test Server" \
    -e FhirServers__0__BaseUrl="https://hapi.fhir.org/baseR4" \
    ghcr.io/chgl/magnifhir:v1.4.0
```

<!-- x-release-please-end -->

Open <http://localhost:8080/> in your browser, select the `HAPI FHIR Test Server` in the server selection and click on `Patient Browser` in the left-hand menu.

## Screenshots

![Screenshot showing the server selection](/docs/img/screenshots/server-selection.png "Configure multiple FHIR servers to connect to")

![Screenshot showing the patient browser](/docs/img/screenshots/patient-browser.png "List all Patient resources stored in the server")

![Screenshot showing the patient record conditions tab](/docs/img/screenshots/patient-record-conditions.png "See a Patient's conditions, observations, and medications")

## Configuration

Multiple FHIR servers can be configured including support for basic authentication.
You can use environment variables to set each entry in the `FhirServers` key, as done above,
or mount a file called `appsettings.Production.json` inside the container as `/app/appsettings.Production.json`.

The basic structure and available configuration options is shown here:

```json
{
  "FhirServers": [
    {
      "Name": "HAPI FHIR JPA Server",
      "BaseUrl": "http://hapi-fhir-server.127.0.0.1.nip.io/fhir"
    },
    {
      "Name": "Linux4Health FHIR Server (empty)",
      "BaseUrl": "http://l4h-fhir-server.127.0.0.1.nip.io/fhir-server/api/v4",
      "Auth": {
        "Basic": {
          "Username": "fhiruser",
          "Password": "change-user-password"
        }
      }
    }
  ]
}
```

## Customizing Resource Browsers

> **Warning**
> This is an experimental feature. No guarantees that there won't be changes to the default
> resource tables or the way data is displayed.

It is possible to customize the tables displaying FHIR resources in the `Patient Record` view.
This allows changing the type of resources displayed and the path within each resource to show as a column in the table.
See the `ResourceBrowsers` key in [appsettings.json](./src/magniFHIR/appsettings.json) for the defaults.

It's easiest to define a custom `appsettings.Production.json` and mount it inside the container.
See the [configuration section](#configuration) above.

## Development

### Docker Compose

Start all prerequisite services for development by running:

```sh
docker compose -f hack/compose.yaml --profile=l4h --profile=azure up
```

This will start three FHIR servers and their corresponding databases. The servers are running behind Traefik as a
reverse proxy to provide nice URLs that are resolved to `localhost`:

| Type                                                                                    | Base URL                                                     |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| [HAPI FHIR JPA Server Starter](https://github.com/hapifhir/hapi-fhir-jpaserver-starter) | <http://hapi-fhir-server.127.0.0.1.nip.io/fhir>              |
| [Linux4Health FHIR Server](https://github.com/LinuxForHealth/FHIR)                      | <http://l4h-fhir-server.127.0.0.1.nip.io/fhir-server/api/v4> |
| [FHIR Server for Azure](https://github.com/microsoft/fhir-server)                       | <http://azure-fhir-server.127.0.0.1.nip.io/>                 |

The HAPI FHIR JPA Server is pre-filled with sample Synthea data. To only start the HAPI FHIR server, you can remove the `--profile=l4h --profile=azure` flags
from the `docker compose` invocation.

Install the packages and launch the server in [Hot-Reload mode](https://docs.microsoft.com/en-us/aspnet/core/test/hot-reload?view=aspnetcore-6.0):

```sh
dotnet restore
dotnet watch --project=src/magniFHIR
```

### Kubernetes (KinD)

Prerequisites:

- [KinD](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Kustomize](https://kustomize.io/)
- [Skaffold](https://skaffold.dev/)
- [Helm](https://helm.sh/)

Create a cluster for testing using KinD:

```sh
kind create cluster --name=magnifhir-dev
```

Build the container image and deploy to the cluster in development mode:

```sh
skaffold dev
```

This includes a HAPI FHIR server deployed via Helm and the same set of sample data as used
by the Docker Compose setup.

Skaffold is used to re-build the container image whenever the source code changes, deploy the HAPI FHIR server as a test-dependency, and also build and deploy the job used to load sample data into the server. See [skaffold.yaml](./skaffold.yaml) and the contents of the `hack/k8s` directory for details.
