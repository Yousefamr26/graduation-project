namespace SmartCareerHub.Contracts.Company.WorkShops
{
    public record ActivityRequest(
        string Name,
        string Description,
        string Difficulty,
        int Points
    );
}
