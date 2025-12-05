using System.ComponentModel.DataAnnotations;
using DataAccess.Entities.Users;

namespace DataAccess.Entities.Users
{
    public class CompanyUser
    {
        public string Id { get; set; }  

        public string OrganizationName { get; set; }
        public string? OrganizationLogo { get; set; }
        public string Country { get; set; }
        public string City { get; set; }

        public ApplicationUser User { get; set; } 
    }
}
