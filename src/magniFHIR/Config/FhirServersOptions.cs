using System.Globalization;
using System.Text;
using Hl7.Fhir.Model;

public class FhirServersOptions
{
    public List<FhirServerConfig> FhirServers { get; init; } = new List<FhirServerConfig>();

    public FhirServerConfig? FindByNameSlug(string slugName) =>
        FhirServers.Find(s => s.NameSlug == slugName);
}

public class FhirServerConfig
{
    public string? Name { get; init; }
    public Uri? BaseUrl { get; init; }
    public string? NameSlug => Slugify(Name);
    public FhirServerAuthConfig? Auth { get; set; }
    public IDictionary<ResourceType, ResourceBrowserConfig> ResourceBrowsers { get; set; }

    public FhirServerConfig()
    {
        ResourceBrowsers = new Dictionary<ResourceType, ResourceBrowserConfig>();
        foreach (var resourceType in Enum.GetValues<ResourceType>())
        {
            ResourceBrowsers.Add(resourceType, new ResourceBrowserConfig());
        }
    }

    public override string ToString()
    {
        return Name;
    }

    public override bool Equals(object? obj)
    {
        if (obj is not FhirServerConfig other)
        {
            return false;
        }

        return other.Name == this.Name;
    }

    // code based on <https://docs.microsoft.com/en-us/aspnet/core/fundamentals/routing?view=aspnetcore-6.0#parameter-transformers>
    private static string? Slugify(string? value)
    {
        if (value is null)
        {
            return null;
        }

        var normalizedTitle = value.Normalize(NormalizationForm.FormD);
        var slug = normalizedTitle
            .Where(c => CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark)
            .Aggregate(
                new StringBuilder(),
                (sb, c) =>
                {
                    if (char.IsLetterOrDigit(c))
                    {
                        return sb.Append(c);
                    }

                    if (char.IsWhiteSpace(c))
                    {
                        return sb.Append('-');
                    }

                    return sb.Append("");
                }
            );

        return slug.ToString().Trim().ToLowerInvariant();
    }

    public override int GetHashCode()
    {
        return this.Name?.GetHashCode() ?? 0;
    }
}

public class FhirServerAuthConfig
{
    public FhirServerBasicAuthConfig? Basic { get; set; }
}

public class FhirServerBasicAuthConfig
{
    public string? Username { get; set; }
    public string? Password { get; set; }
}

public class ResourceBrowserConfig
{
    public int PageSize { get; set; } = 50;
}
