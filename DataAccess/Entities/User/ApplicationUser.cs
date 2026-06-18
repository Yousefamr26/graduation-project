using Microsoft.AspNetCore.Identity;
using System;
using DataAccess.Entities.Users;

public class ApplicationUser : IdentityUser
{
    public string FirstName { get; set; }
    public string LastName { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    public bool IsActive { get; set; } = true;
    public bool IsEmailVerified { get; set; } = false;

    public string UserType { get; set; }
    public string Country { get; set; }
    public string City { get; set; }

    public CompanyUser CompanyProfile { get; set; } 
}
