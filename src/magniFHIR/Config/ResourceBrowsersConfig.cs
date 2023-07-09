using Hl7.Fhir.Model;

namespace magniFHIR.Config;


public class ResourceBrowsersOptions
{
    public IDictionary<ResourceType, ResourceBrowserConfig> ResourceBrowsers { get; set; }

    public ResourceBrowsersOptions()
    {
        ResourceBrowsers = new Dictionary<ResourceType, ResourceBrowserConfig>();
        foreach (var resourceType in Enum.GetValues<ResourceType>())
        {
            ResourceBrowsers.Add(resourceType, new ResourceBrowserConfig());
        }
    }
}

public class ResourceBrowserConfig
{
    public int PageSize { get; set; } = 50;
    public List<ResourceTableColumn> Columns { get; set; } = new();
}

public class ResourceTableColumn
{
    public string Header { get; set; }
    public string Path { get; set; }
}
