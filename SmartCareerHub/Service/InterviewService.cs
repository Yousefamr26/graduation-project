using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Entities.Interview;
using DataAccess.IRepository;
using SmartCareerHub.Contracts.Company.Interview;

namespace Business_Logic.Service
{
    public class InterviewService : IInterviewService
    {
        private readonly IUnitOfWork _unitOfWork;

        public InterviewService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<IEnumerable<InterviewResponse>> GetAllAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetAllWithDetailsAsync();
            if (result.IsFailure) return Enumerable.Empty<InterviewResponse>();

            return result.Value.Select(i => new InterviewResponse(
                i.Id,
                i.StudentName,
                i.RoadmapId,
                i.Roadmap?.Title ?? "",
                i.CV,
                i.IsAIPick,
                i.Date,
                i.Time,
                i.InterviewType,
                i.Location,
                i.InterviewerName,
                i.AdditionalNotes,
                i.Status,
                i.CreatedAt
            ));
        }

        public async Task<InterviewResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetByIdWithDetailsAsync(id);
            if (result.IsFailure) return null;

            var i = result.Value;
            return new InterviewResponse(
                i.Id,
                i.StudentName,
                i.RoadmapId,
                i.Roadmap?.Title ?? "",
                i.CV,
                i.IsAIPick,
                i.Date,
                i.Time,
                i.InterviewType,
                i.Location,
                i.InterviewerName,
                i.AdditionalNotes,
                i.Status,
                i.CreatedAt
            );
        }

        public async Task<IEnumerable<InterviewResponse>> GetByRoadmapAsync(int roadmapId, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetByRoadmapAsync(roadmapId);
            if (result.IsFailure) return Enumerable.Empty<InterviewResponse>();

            return result.Value.Select(i => new InterviewResponse(
                i.Id,
                i.StudentName,
                i.RoadmapId,
                i.Roadmap?.Title ?? "",
                i.CV,
                i.IsAIPick,
                i.Date,
                i.Time,
                i.InterviewType,
                i.Location,
                i.InterviewerName,
                i.AdditionalNotes,
                i.Status,
                i.CreatedAt
            ));
        }

        public async Task<IEnumerable<InterviewResponse>> GetByStatusAsync(string status, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetByStatusAsync(status);
            if (result.IsFailure) return Enumerable.Empty<InterviewResponse>();

            return result.Value.Select(i => new InterviewResponse(
                i.Id,
                i.StudentName,
                i.RoadmapId,
                i.Roadmap?.Title ?? "",
                i.CV,
                i.IsAIPick,
                i.Date,
                i.Time,
                i.InterviewType,
                i.Location,
                i.InterviewerName,
                i.AdditionalNotes,
                i.Status,
                i.CreatedAt
            ));
        }

        public async Task<IEnumerable<InterviewResponse>> GetAIRecommendedAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetAIRecommendedAsync();
            if (result.IsFailure) return Enumerable.Empty<InterviewResponse>();

            return result.Value.Select(i => new InterviewResponse(
                i.Id,
                i.StudentName,
                i.RoadmapId,
                i.Roadmap?.Title ?? "",
                i.CV,
                i.IsAIPick,
                i.Date,
                i.Time,
                i.InterviewType,
                i.Location,
                i.InterviewerName,
                i.AdditionalNotes,
                i.Status,
                i.CreatedAt
            ));
        }

        public async Task<IEnumerable<InterviewResponse>> GetTodayInterviewsAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetTodayInterviewsAsync();
            if (result.IsFailure) return Enumerable.Empty<InterviewResponse>();

            return result.Value.Select(i => new InterviewResponse(
                i.Id,
                i.StudentName,
                i.RoadmapId,
                i.Roadmap?.Title ?? "",
                i.CV,
                i.IsAIPick,
                i.Date,
                i.Time,
                i.InterviewType,
                i.Location,
                i.InterviewerName,
                i.AdditionalNotes,
                i.Status,
                i.CreatedAt
            ));
        }

        public async Task<IEnumerable<InterviewResponse>> SearchInterviewsAsync(string searchTerm, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.SearchInterviewsAsync(searchTerm);
            if (result.IsFailure) return Enumerable.Empty<InterviewResponse>();

            return result.Value.Select(i => new InterviewResponse(
                i.Id,
                i.StudentName,
                i.RoadmapId,
                i.Roadmap?.Title ?? "",
                i.CV,
                i.IsAIPick,
                i.Date,
                i.Time,
                i.InterviewType,
                i.Location,
                i.InterviewerName,
                i.AdditionalNotes,
                i.Status,
                i.CreatedAt
            ));
        }

        public async Task<InterviewResponse> AddAsync(InterviewRequest request, CancellationToken cancellationToken = default)
        {
            await _unitOfWork.BeginTransactionAsync();
            try
            {
                var roadmapResult = await _unitOfWork.Roadmaps.GetByIdWithDetailsAsync(request.RoadmapId);
                if (roadmapResult.IsFailure)
                    throw new InvalidOperationException("Roadmap not found");

                var interview = new InterviewSchedule
                {
                    StudentName = request.StudentName,
                    RoadmapId = request.RoadmapId,
                    CV = request.CV,
                    IsAIPick = request.IsAIPick,
                    Date = request.Date,
                    Time = request.Time,
                    InterviewType = request.InterviewType,
                    Location = request.Location,
                    InterviewerName = request.InterviewerName,
                    AdditionalNotes = request.AdditionalNotes,
                    CreatedAt = DateTime.UtcNow,
                    Status = "Scheduled"
                };

                var addResult = await _unitOfWork.Interviews.AddInterviewAsync(interview);
                if (addResult.IsFailure)
                    throw new InvalidOperationException(addResult.Error.Description);

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                var fullResult = await _unitOfWork.Interviews.GetByIdWithDetailsAsync(addResult.Value.Id);
                var i = fullResult.Value;

                return new InterviewResponse(
                    i.Id,
                    i.StudentName,
                    i.RoadmapId,
                    i.Roadmap?.Title ?? "",
                    i.CV,
                    i.IsAIPick,
                    i.Date,
                    i.Time,
                    i.InterviewType,
                    i.Location,
                    i.InterviewerName,
                    i.AdditionalNotes,
                    i.Status,
                    i.CreatedAt
                );
            }
            catch
            {
                await _unitOfWork.RollbackTransactionAsync();
                throw;
            }
        }

        public async Task<bool> UpdateAsync(int id, InterviewRequest request, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetByIdWithDetailsAsync(id);
            if (result.IsFailure) return false;

            var interview = result.Value;

            interview.StudentName = request.StudentName;
            interview.RoadmapId = request.RoadmapId;
            interview.CV = request.CV;
            interview.IsAIPick = request.IsAIPick;
            interview.Date = request.Date;
            interview.Time = request.Time;
            interview.InterviewType = request.InterviewType;
            interview.Location = request.Location;
            interview.InterviewerName = request.InterviewerName;
            interview.AdditionalNotes = request.AdditionalNotes;

            var updateResult = await _unitOfWork.Interviews.UpdateAsync(interview);
            if (updateResult.IsFailure) return false;

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UpdateStatusAsync(int id, string status, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.UpdateStatusAsync(id, status);
            if (result.IsFailure) return false;

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BulkUpdateStatusAsync(List<int> ids, string status, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.BulkUpdateStatusAsync(ids, status);
            if (result.IsFailure) return false;

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.DeleteAsync(id);
            if (result.IsFailure) return false;

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BulkDeleteAsync(List<int> ids, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.BulkDeleteAsync(ids);
            if (result.IsFailure) return false;

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<int> GetTotalCountAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetTotalCountAsync();
            return result.IsFailure ? 0 : result.Value;
        }

        public async Task<int> GetTodayCountAsync(CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetTodayCountAsync();
            return result.IsFailure ? 0 : result.Value;
        }

        public async Task<IEnumerable<InterviewResponse>> GetLatestInterviewsAsync(int count, CancellationToken cancellationToken = default)
        {
            var result = await _unitOfWork.Interviews.GetLatestInterviewsAsync(count);
            if (result.IsFailure) return Enumerable.Empty<InterviewResponse>();

            return result.Value.Select(i => new InterviewResponse(
                i.Id,
                i.StudentName,
                i.RoadmapId,
                i.Roadmap?.Title ?? "",
                i.CV,
                i.IsAIPick,
                i.Date,
                i.Time,
                i.InterviewType,
                i.Location,
                i.InterviewerName,
                i.AdditionalNotes,
                i.Status,
                i.CreatedAt
            ));
        }
    }
}