public record CreatePartnershipRequest(
    Guid CompanyId,          // required ✅
    int UniversityId,        // required ✅
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