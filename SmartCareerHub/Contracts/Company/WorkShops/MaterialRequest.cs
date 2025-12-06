using System.Globalization;

namespace SmartCareerHub.Contracts.Company.WorkShops
{
    public record MaterialRequest(


         string Type ,
     string? TitleVideo ,
     string? TitlePdf ,
     string? TitleAssignment ,
     int? PageCount ,
     int Points ,
     int  Duration,
    IFormFile? FilePath 
        );
    
}
