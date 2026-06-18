using DataAccess.Entities.Users;
using System;
using System.Collections.Generic;

public class Graduates
{
    public int Id { get; set; }

    public string UserId { get; set; }
    public ApplicationUser User { get; set; }

    public string Major { get; set; }
    public string Degree { get; set; }
    public string University { get; set; }
    public int GraduationYear { get; set; }  

   
    public int YearsOfExperience { get; set; } 
    public string? ExperienceSummary { get; set; } 

    public string? GitHub { get; set; }
    public string? LinkedIn { get; set; }

    public string? ProfileImage { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
