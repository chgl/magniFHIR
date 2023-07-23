using Hl7.Fhir.Model;
using Hl7.Fhir.Rest;
using magniFHIR.Config;

namespace magniFHIR.Data
{
    public interface IFhirService
    {
        Task<Patient?> GetPatientsByIdAsync(string serverNameSlug, string resourceId);

        Task<Bundle> GetPatientsAsync(string serverNameSlug, Bundle? currentPage = null);

        Task<Bundle> GetResourcesByPatientIdAsync(
            string serverNameSlug,
            string patientResourceId,
            ResourceType resourceType,
            Bundle? currentPage = null
        );
    }

    public class FhirService : IFhirService
    {
        private readonly IHttpClientFactory clientFactory;
        private readonly FhirServersOptions serversOptions;
        private readonly ResourceBrowsersOptions browsersOptions;
        private readonly FhirClientSettings clientSettings;

        public FhirService(
            IHttpClientFactory clientFactory,
            FhirServersOptions serversOptions,
            ResourceBrowsersOptions browsersOptions
        )
        {
            this.clientFactory = clientFactory;
            this.serversOptions = serversOptions;
            this.browsersOptions = browsersOptions;
            this.clientSettings = new FhirClientSettings()
            {
                PreferredFormat = ResourceFormat.Json,
            };
        }

        // TODO: instead of using serverName everywhere, create a FhirServiceFactory
        //       which internally manages FhirService instances with a HTTP/FHIR client
        //       already set.
        public async Task<Bundle> GetPatientsAsync(
            string serverNameSlug,
            Bundle? currentPage = null
        )
        {
            var fhirClient = GetFhirClientFromServerNameSlug(serverNameSlug);

            var pageSize = browsersOptions.ResourceBrowsers[ResourceType.Patient].PageSize;
            var orderBy = browsersOptions.ResourceBrowsers[ResourceType.Patient].SortBy;

            if (currentPage is not null)
            {
                return await fhirClient.ContinueAsync(currentPage, PageDirection.Next);
            }
            else
            {
                var sp = new SearchParams()
                    .OrderBy(orderBy, SortOrder.Descending)
                    .LimitTo(pageSize);
                return await fhirClient.SearchAsync<Patient>(sp);
            }
        }

        public async Task<Bundle> GetResourcesByPatientIdAsync(
            string serverNameSlug,
            string patientResourceId,
            ResourceType resourceType,
            Bundle? currentPage = null
        )
        {
            var fhirClient = GetFhirClientFromServerNameSlug(serverNameSlug);

            var pageSize = browsersOptions.ResourceBrowsers[resourceType].PageSize;
            var orderBy = browsersOptions.ResourceBrowsers[resourceType].SortBy;

            if (currentPage is not null)
            {
                return await fhirClient.ContinueAsync(currentPage, PageDirection.Next);
            }
            else
            {
                var sp = new SearchParams("subject", $"Patient/{patientResourceId}")
                    .OrderBy(orderBy, SortOrder.Descending)
                    .LimitTo(pageSize);
                return await fhirClient.SearchAsync(sp, resourceType.ToString());
            }
        }

        public async Task<Patient?> GetPatientsByIdAsync(string serverNameSlug, string resourceId)
        {
            var fhirClient = GetFhirClientFromServerNameSlug(serverNameSlug);

            SearchParams sp;
            if (resourceId.Contains('|'))
            {
                var splitted = resourceId.Split("|");
                sp = new SearchParams("identifier", $"{splitted[0]}|{splitted[1]}");
            }
            else
            {
                sp = new SearchParams("_id", resourceId);
            }

            var results = await fhirClient.SearchAsync<Patient>(sp);

            return results.Entry.Select(entry => entry.Resource).Cast<Patient>().FirstOrDefault();
        }

        private FhirClient GetFhirClientFromServerNameSlug(string serverNameSlug)
        {
            var serverConfig =
                serversOptions.FindByNameSlug(serverNameSlug)
                ?? throw new InvalidOperationException(
                    $"No server found with name '{serverNameSlug}' in config."
                );
            var httpClient = clientFactory.CreateClient(serverNameSlug);
            return new FhirClient(serverConfig.BaseUrl, httpClient, clientSettings);
        }
    }
}
