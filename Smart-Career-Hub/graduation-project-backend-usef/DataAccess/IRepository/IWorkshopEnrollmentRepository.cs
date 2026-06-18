using DataAccess.Entities.Workshop;
using Business_Logic.Errors;
using System.Collections.Generic;
using System.Threading.Tasks;

public interface IWorkshopEnrollmentRepository
{
    Task<bool> IsUserEnrolledAsync(int workshopId, string userId);
    Task<WorkshopEnrollment> AddAsync(WorkshopEnrollment enrollment);
    Task<IEnumerable<WorkshopEnrollment>> GetEnrollmentsByUserAsync(string userId);
    Task<IEnumerable<WorkshopEnrollment>> GetEnrollmentsByWorkshopAsync(int workshopId);
    Task<WorkshopEnrollment?> GetEnrollmentAsync(int workshopId, string userId);

    Task<bool> DeleteEnrollmentAsync(int workshopId, string userId);
}
