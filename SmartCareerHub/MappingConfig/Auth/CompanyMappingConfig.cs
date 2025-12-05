using DataAccess.Entities.Users;
using Mapster;
using SmartCareerHub.Contracts.Auth;

namespace Business_Logic.Mappings
{
    public static class CompanyMappingConfig
    {
        public static void RegisterMappings()
        {
            TypeAdapterConfig<RegisterCompanyRequest, ApplicationUser>.NewConfig()
                .Map(dest => dest.UserName, src => src.Email)
                .Map(dest => dest.Email, src => src.Email)
                .Map(dest => dest.FirstName, src => src.FirstName)
                .Map(dest => dest.LastName, src => src.LastName)
                .Map(dest => dest.CreatedAt, src => DateTime.UtcNow);

            TypeAdapterConfig<RegisterCompanyRequest, CompanyUser>.NewConfig()
                .Map(dest => dest.OrganizationName, src => src.OrganizationName)
                .Map(dest => dest.Country, src => src.Country)
                .Map(dest => dest.City, src => src.City)
                .Ignore(dest => dest.OrganizationLogo)
                .Ignore(dest => dest.Id); 
        }
    }
}
