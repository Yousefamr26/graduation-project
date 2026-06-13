using DataAccess.Entities.Interview;
using DataAccess.Entities.Users;
using System;
using System.Collections.Generic;

public class Student
{
    public int Id { get; set; } 
    public string UserId { get; set; }  
    public ApplicationUser User { get; set; }

    public string Major { get; set; }
    public string Degree { get; set; }
    public string University { get; set; }
    public string GitHub { get; set; }
    public string LinkedIn { get; set; }
    public DateTime? ExpectedGraduation { get; set; }

    public string? ProfileImage { get; set; }

    public virtual ICollection<UserRoadmap> userRoadmaps { get; set; } = new List<UserRoadmap>();
   

}
