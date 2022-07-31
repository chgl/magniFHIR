using Hl7.Fhir.Model;
using Hl7.Fhir.Rest;

namespace magniFHIR.Data
{
    public interface IFhirService
    {
        Task<Bundle> GetPatientsAsync(string serverNameSlug);
        Task<Patient?> GetPatientsByIdAsync(string serverNameSlug, string resourceId);
        Task<List<TResource>> GetResourcesByPatientIdAsync<TResource>(string serverNameSlug, string patientResourceId, string orderBy = "_lastUpdated") where TResource : Resource;
    }

    public class FhirService : IFhirService
    {
        private readonly IHttpClientFactory clientFactory;
        private readonly FhirServersOptions serversOptions;
        private readonly FhirClientSettings clientSettings;

        public FhirService(IHttpClientFactory clientFactory, FhirServersOptions serversOptions)
        {
            this.clientFactory = clientFactory;
            this.serversOptions = serversOptions;
            this.clientSettings = new FhirClientSettings()
            {
                PreferredFormat = ResourceFormat.Json,
            };
        }

        public Task<Bundle> GetPatientsAsync(string serverNameSlug)
        {
            var fhirClient = GetFhirClientFromServerNameSlug(serverNameSlug);

            var sp = new SearchParams()
                .OrderBy("_lastUpdated", SortOrder.Descending);
            return fhirClient.SearchAsync<Patient>(sp);
        }

        public async Task<List<TResource>> GetResourcesByPatientIdAsync<TResource>(string serverNameSlug, string patientResourceId, string orderBy = "_lastUpdated") where TResource : Resource
        {
            var fhirClient = GetFhirClientFromServerNameSlug(serverNameSlug);

            var resultList = new List<TResource>();
            var sp = new SearchParams("subject", $"Patient/{patientResourceId}").OrderBy(orderBy, SortOrder.Descending);
            var resultBundle = await fhirClient.SearchAsync<TResource>(sp);

            while (resultBundle != null)
            {
                resultList.AddRange(resultBundle.Entry.Select(entry => entry.Resource).Cast<TResource>());
                resultBundle = await fhirClient.ContinueAsync(resultBundle);
            }

            return resultList;
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
            var serverConfig = serversOptions.FindByNameSlug(serverNameSlug);

            if (serverConfig is null)
            {
                throw new InvalidOperationException($"No server found with name '{serverNameSlug}' in config.");
            }

            var httpClient = clientFactory.CreateClient(serverNameSlug);
            return new FhirClient(serverConfig.BaseUrl, httpClient, clientSettings);
        }
    }
}
