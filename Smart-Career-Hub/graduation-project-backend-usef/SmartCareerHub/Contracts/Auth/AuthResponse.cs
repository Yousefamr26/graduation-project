namespace SmartCareerHub.Contracts.Auth
{
    public record AuthResponse<T>(
        bool Success,
        string Message,
        T? Data = default
    );
}