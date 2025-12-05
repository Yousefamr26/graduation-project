namespace SmartCareerHub.Contracts.Company.WorkShops
{
    public record ActivityResponse(
        int Id,
        string Name,
        string Description,
        string Difficulty,
        int Points,
        DateTime CreatedAt
    );
}
