namespace SmartCareerHub.Contracts.Auth
{
    public record LoginRequest(
        string Email,
        string Password,
        string AccountType, 
        bool RememberMe = false
    );
}