public interface IInternshipService
{
    Task<Internship> CreateInternshipAsync(
        Internship internship,
        string userId,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<InternshipCardResponse>> GetAllInternshipsAsync(
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<InternshipDetailsResponse> GetInternshipByIdAsync(
        int id,
        string userId = null,
        CancellationToken cancellationToken = default);

    Task<Internship> UpdateInternshipAsync(
        Internship internship,
        CancellationToken cancellationToken = default);

    Task DeleteInternshipAsync(
        int id,
        CancellationToken cancellationToken = default);

    Task ApplyAsync(
        int internshipId,
        string userId,
        CancellationToken cancellationToken = default);

    Task<bool> HasUserAppliedAsync(
        int internshipId,
        string userId,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<InternshipApplicantResponse>> GetApplicantsByInternshipIdAsync(
        int internshipId,
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<InternshipCardResponse>> SearchAsync(
        string? keyword,
        string? type,
        string? status,
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<bool> UpdateApplicantStatusAsync(
        string applicationId,
        ApplicationStatu status,
        CancellationToken cancellationToken = default);

    Task<PagedResponse<InternshipApplicationResponse>> GetMyApplicationsAsync(
        string userId,
        QueryParameters query,
        CancellationToken cancellationToken = default);

    Task<bool> WithdrawAsync(
        string userId,
        int applicationId,
        CancellationToken cancellationToken = default);
}