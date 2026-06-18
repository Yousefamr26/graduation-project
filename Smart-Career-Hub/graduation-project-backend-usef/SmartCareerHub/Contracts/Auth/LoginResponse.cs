namespace SmartCareerHub.Contracts.Auth
{
    public record LoginResponse<T>(
        string Token,
        T UserProfile
    );
}
