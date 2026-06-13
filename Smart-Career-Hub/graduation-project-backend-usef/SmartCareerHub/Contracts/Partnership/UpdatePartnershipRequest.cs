public record UpdatePartnershipRequest(
     Guid CompanyId,
    int Id,
    string CompanyName,
    string Industry,
    string PartnershipType,
    string ContactPerson,
    string Email,
    string Phone,
    string Website,
    string Location,
    string Details
);