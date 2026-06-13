namespace SmartCareerHub.Contracts.Auth
{
    public record RegisterCompanyRequest(
       string Email,
       string Password,
       string FirstName,
       string LastName,
       string OrganizationName,
       IFormFile? OrganizationLogo, 
       string Country,
       string City
   );
}
