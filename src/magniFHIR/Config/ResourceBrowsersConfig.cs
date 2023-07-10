using Hl7.Fhir.Model;

namespace magniFHIR.Config;

public class ResourceBrowsersOptions
{
    public IDictionary<ResourceType, ResourceBrowserConfig> ResourceBrowsers { get; set; } =
        new Dictionary<ResourceType, ResourceBrowserConfig>();
}

public class ResourceBrowserConfig
{
    public int PageSize { get; set; } = 50;
    public string SortBy { get; set; } = "_lastUpdated";
    public List<ResourceTableColumn> Columns { get; set; } = new();
}

public class ResourceTableColumn
{
    public string Header { get; set; }
    public string Path { get; set; }
}
