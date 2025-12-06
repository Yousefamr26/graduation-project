namespace SmartCareerHub.Contracts.Company.WorkShops
{
    public record MaterialResponse(
           int Id,
        string Type,
        string Title,
        string? FileUrl,
        int? Duration,
        int? PageCount,
        int Points,
        DateTime CreatedAt



        );
    
}
