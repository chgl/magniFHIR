using Hl7.Fhir.Model;

public static class PatientExtensions
{
    private const string IdentifierTypeSystem = "http://terminology.hl7.org/CodeSystem/v2-0203";
    private const string IdentifierTypeMR = "MR";

    public static string DisplayName(this Patient @this)
    {
        var name = @this.Name.Find(name => name.Use == HumanName.NameUse.Usual) ?? @this.Name.FirstOrDefault();
        if (name is null)
        {
            return "N/A";
        }

        return $"{string.Join(" ", name.Given)} {name.Family}";
    }

    public static IEnumerable<string> MedicalRecordNumbers(this Patient @this)
    {
        return @this.Identifier
            .Where(id => id.Type?.Coding?.Any(coding => coding.System == IdentifierTypeSystem &&
                                                        coding.Code == IdentifierTypeMR) ?? false)
            .Select(id => id.Value);
    }
}
