using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Entities.Job;
using DataAccess.IRepository;
using Microsoft.EntityFrameworkCore;
using SmartCareerHub.Contracts.Company.Jobs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Business_Logic.Service
{
    public class JobApplicationService : IJobApplicationService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IRealTimeNotificationService _realTimeNotificationService;

        public JobApplicationService(IUnitOfWork unitOfWork, IRealTimeNotificationService realTimeNotificationService)
        {
            _unitOfWork = unitOfWork;
            _realTimeNotificationService = realTimeNotificationService;
        }

        // ================== APPLY ==================
        public async Task<Result<JobApplicantResponse>> ApplyAsync(string userId, int jobId, CancellationToken cancellationToken = default)
        {
            var jobResult = await _unitOfWork.Jobs.GetByIdAsync(jobId); // موجود في JobRepository
            if (jobResult.IsFailure)
                return Result.Failure<JobApplicantResponse>(new Error("Job.NotFound", "Job not found"));

            var exists = await _unitOfWork.jobApplicationRepository.ExistsAsync(userId, jobId);
            if (exists)
                return Result.Failure<JobApplicantResponse>(new Error("JobApplication.Exists", "You already applied for this job"));

            var application = new JobApplication
            {
                UserId = userId,
                JobId = jobId,
                Status = ApplicationStatus.Applied,
                AppliedAt = DateTime.UtcNow,
                LastUpdatedAt = DateTime.UtcNow
            };

            var addResult = await _unitOfWork.jobApplicationRepository.AddApplicationAsync(application, cancellationToken);
            if (!addResult.IsSuccess)
                return Result.Failure<JobApplicantResponse>(addResult.Error);

            // إشعار للمتقدم
            await _realTimeNotificationService.SendToUserAsync(
                userId,
                "Application Submitted ✅",
                $"You successfully applied to '{jobResult.Value.Title}'."
            );

            // إشعار للشركة
            if (jobResult.Value.CompanyUserId != null)
            {
                await _realTimeNotificationService.SendToUserAsync(
                    jobResult.Value.CompanyUserId,
                    "New Job Application 📄",
                    $"A new applicant has applied for your job '{jobResult.Value.Title}'."
                );
            }

            var response = new JobApplicantResponse(
                ApplicationId: addResult.Value.Id,
                ApplicantName: "", // يملى لاحقًا من الكونترولر
                JobTitle: jobResult.Value.Title,
                CompanyName: jobResult.Value.CompanyUser?.OrganizationName ?? "N/A",
                JobId: jobResult.Value.Id,
                AppliedDate: application.AppliedAt,
                Status: application.Status.ToString(),
                UserId: application.UserId
            );

            return Result.Success(response);
        }

        // ================== GET MY APPLICATIONS ==================
        public async Task<Result<IEnumerable<JobApplicationListResponse>>> GetMyApplicationsAsync(string userId, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.jobApplicationRepository.GetByUserIdAsync(userId, cancellationToken);
            if (!result.IsSuccess)
                return Result.Failure<IEnumerable<JobApplicationListResponse>>(result.Error);

            var list = result.Value.Select(a => new JobApplicationListResponse(
                ApplicationId: a.Id,
                JobTitle: a.Job?.Title ?? "N/A",
                CompanyName: a.Job?.CompanyUser?.OrganizationName ?? "N/A",
                CompanyLogo: a.Job?.CompanyLogo ?? a.Job?.CompanyUser?.OrganizationLogo,
                Status: a.Status,
                AppliedAt: a.AppliedAt
            ));

            return Result.Success(list);
        }

        // ================== DASHBOARD STATS ==================
        public async Task<Result<JobApplicationStatsDto>> GetDashboardStatsAsync(string userId, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.jobApplicationRepository.GetByUserIdAsync(userId, cancellationToken);
            if (!result.IsSuccess)
                return Result.Failure<JobApplicationStatsDto>(result.Error);

            var apps = result.Value;

            var stats = new JobApplicationStatsDto(
                TotalApplications: apps.Count(),
                Active: apps.Count(a => a.Status == ApplicationStatus.Applied || a.Status == ApplicationStatus.UnderReview),
                Interviews: apps.Count(a => a.Status == ApplicationStatus.InterviewScheduled),
                Offers: apps.Count(a => a.Status == ApplicationStatus.OfferReceived)
            );

            return Result.Success(stats);
        }

        // ================== UPDATE STATUS ==================
        public async Task<Result> UpdateStatusAsync(int applicationId, ApplicationStatus status, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.jobApplicationRepository.GetByIdWithDetailsAsync(applicationId, cancellationToken);
            if (!result.IsSuccess)
                return Result.Failure(result.Error);

            var application = result.Value;
            application.Status = status;
            application.LastUpdatedAt = DateTime.UtcNow;

            await _unitOfWork.jobApplicationRepository.UpdateApplicationAsync(application, cancellationToken);

            // إشعار للمتقدم
            await _realTimeNotificationService.SendToUserAsync(
                application.UserId,
                "Application Status Updated 🔔",
                $"Your application for '{application.Job?.Title ?? "N/A"}' is now '{status}'."
            );

            // إشعار للشركة
            if (application.Job?.CompanyUserId != null)
            {
                await _realTimeNotificationService.SendToUserAsync(
                    application.Job.CompanyUserId,
                    "Applicant Status Changed 📄",
                    $"The status of applicant '{application.User?.FirstName} {application.User?.LastName}' for '{application.Job.Title}' has been updated to '{status}'."
                );
            }

            return Result.Success();
        }

        // ================== BULK UPDATE ==================
        public async Task<Result> BulkUpdateStatusAsync(List<int> applicationIds, ApplicationStatus status, CancellationToken cancellationToken = default)
        {
            var applicationsResult = await Task.WhenAll(applicationIds.Select(id => _unitOfWork.jobApplicationRepository.GetByIdWithDetailsAsync(id, cancellationToken)));
            var failed = applicationsResult.FirstOrDefault(r => !r.IsSuccess);
            if (failed != null)
                return Result.Failure(failed.Error);

            var applications = applicationsResult.Select(r => r.Value).ToList();
            foreach (var app in applications)
            {
                app.Status = status;
                app.LastUpdatedAt = DateTime.UtcNow;

                // إشعارات
                await _realTimeNotificationService.SendToUserAsync(
                    app.UserId,
                    "Application Status Updated 🔔",
                    $"Your application for '{app.Job?.Title ?? "N/A"}' is now '{status}'."
                );

                if (app.Job?.CompanyUserId != null)
                {
                    await _realTimeNotificationService.SendToUserAsync(
                        app.Job.CompanyUserId,
                        "Applicant Status Changed 📄",
                        $"The status of applicant '{app.User?.FirstName} {app.User?.LastName}' for '{app.Job.Title}' has been updated to '{status}'."
                    );
                }
            }

            await _unitOfWork.jobApplicationRepository.BulkUpdateStatusAsync(applicationIds, status, cancellationToken);
            return Result.Success();
        }

        // ================== BULK DELETE ==================
        public async Task<Result> BulkDeleteAsync(List<int> applicationIds, CancellationToken cancellationToken = default)
        {
            return await _unitOfWork.jobApplicationRepository.BulkDeleteAsync(applicationIds, cancellationToken);
        }

        // ================== GET APPLICANTS BY JOB ==================
        public async Task<IEnumerable<JobApplicantResponse>> GetApplicantsByJobIdAsync(int jobId, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.jobApplicationRepository.GetByJobIdAsync(jobId, cancellationToken);
            if (!result.IsSuccess)
                return Enumerable.Empty<JobApplicantResponse>();

            return result.Value.Select(a => new JobApplicantResponse(
                ApplicationId: a.Id,
                ApplicantName: $"{a.User.FirstName} {a.User.LastName}",
                JobTitle: a.Job?.Title ?? "N/A",
                CompanyName: a.Job?.CompanyUser?.OrganizationName ?? "N/A",
                JobId: a.JobId,
                AppliedDate: a.AppliedAt,
                Status: a.Status.ToString(),
                UserId: a.UserId
            )).ToList();
        }
        public async Task<Result> WithdrawAsync(string userId, int applicationId, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.jobApplicationRepository.GetByIdWithDetailsAsync(applicationId, cancellationToken);
            if (!result.IsSuccess)
                return Result.Failure(new Error("JobApplication.NotFound", "Application not found."));

            var application = result.Value;

            // التأكد إن الـ application دي بتاعت الـ user ده
            if (application.UserId != userId)
                return Result.Failure(new Error("JobApplication.Unauthorized", "You are not allowed to withdraw this application."));

            // مينفعش تسحب لو Interview Scheduled
            if (application.Status == ApplicationStatus.InterviewScheduled)
                return Result.Failure(new Error("JobApplication.CannotWithdraw", "Cannot withdraw after interview is scheduled."));

            _unitOfWork.jobApplicationRepository.Delete(application);
            await _unitOfWork.SaveChangesAsync();

            // 🔔 Notifications
            await _realTimeNotificationService.SendToUserAsync(
                userId,
                "Application Withdrawn ❌",
                $"You withdrew your application for '{application.Job?.Title}'."
            );

            if (application.Job?.CompanyUserId != null)
            {
                await _realTimeNotificationService.SendToUserAsync(
                    application.Job.CompanyUserId,
                    "Applicant Withdrew 📄",
                    $"An applicant withdrew their application for '{application.Job.Title}'."
                );
            }

            return Result.Success();
        }
        public async Task<Result<PagedResponse<JobApplicantResponse>>> GetMyApplicationsAsync(
string userId,
QueryParameters query,
CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.jobApplicationRepository.GetByUserIdAsync(userId, cancellationToken);
            if (result.IsFailure)
                return Result.Failure<PagedResponse<JobApplicantResponse>>(result.Error);

            var applications = result.Value.AsEnumerable();

            // Filtering
            if (!string.IsNullOrWhiteSpace(query.Search))
                applications = applications.Where(a =>
                    a.Job?.Title.Contains(query.Search, StringComparison.OrdinalIgnoreCase) == true ||
                    a.Job?.CompanyUser?.OrganizationName.Contains(query.Search, StringComparison.OrdinalIgnoreCase) == true);

            // Sorting
            applications = query.SortBy?.ToLower() switch
            {
                "title" => query.SortDirection == "asc"
                    ? applications.OrderBy(a => a.Job?.Title)
                    : applications.OrderByDescending(a => a.Job?.Title),
                "status" => query.SortDirection == "asc"
                    ? applications.OrderBy(a => a.Status)
                    : applications.OrderByDescending(a => a.Status),
                _ => applications.OrderByDescending(a => a.AppliedAt)
            };

            var mapped = applications.Select(a => new JobApplicantResponse(
                ApplicationId: a.Id,
                ApplicantName: $"{a.User?.FirstName} {a.User?.LastName}",
                JobTitle: a.Job?.Title ?? "N/A",
                CompanyName: a.Job?.CompanyUser?.OrganizationName ?? "N/A",
                JobId: a.JobId,
                AppliedDate: a.AppliedAt,
                Status: a.Status.ToString(),
                UserId: a.UserId
            ));

            return Result.Success(
                PagedResponse<JobApplicantResponse>.Create(mapped, query.Page, query.PageSize));
        }
    }
}