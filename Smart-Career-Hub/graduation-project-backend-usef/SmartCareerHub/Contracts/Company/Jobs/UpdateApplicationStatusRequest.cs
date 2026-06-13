using DataAccess.Entities.Job;

public record UpdateApplicationStatusRequest(
    ApplicationStatus Status
);