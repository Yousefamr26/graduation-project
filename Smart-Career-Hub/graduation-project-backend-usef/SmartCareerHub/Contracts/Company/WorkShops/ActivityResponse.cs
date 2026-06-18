namespace SmartCareerHub.Contracts.Company.WorkShops
{
    public record ActivityResponse(
        string Id,
        string Name,
        string Description,
        string Difficulty,
        int Points,
        DateTime CreatedAt
    );
}
