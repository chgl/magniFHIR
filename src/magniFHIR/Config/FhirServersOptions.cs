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
    public string Name { get; init; } = "Unnamed FHIR server";
    public Uri? BaseUrl { get; init; }
    public string NameSlug => Slugify(Name);
    public FhirServerAuthConfig? Auth { get; init; }

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
    private static string Slugify(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentNullException(nameof(value));
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
    public FhirServerBasicAuthConfig? Basic { get; init; }
}

public class FhirServerBasicAuthConfig
{
    public string? Username { get; init; }
    public string? Password { get; init; }
}
