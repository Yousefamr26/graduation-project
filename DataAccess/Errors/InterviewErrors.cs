using DataAccess.Abstractions;

namespace Business_Logic.Errors
{
    public static class InterviewErrors
    {
        public static readonly Error InterviewNotFound =
            new("Interview.NotFound", "No interview was found with the given ID");

        public static readonly Error InterviewNoIdsProvided =
            new("Interview.NoIds", "No interview IDs were provided");

        public static readonly Error InterviewBulkNotFound =
            new("Interview.BulkNotFound", "No interviews found with the provided IDs");

        public static readonly Error InterviewCreationFailed =
            new("Interview.CreationFailed", "Failed to create interview");

        public static readonly Error InterviewUpdateFailed =
            new("Interview.UpdateFailed", "Failed to update interview");

        public static readonly Error InterviewDeleteFailed =
            new("Interview.DeleteFailed", "Failed to delete interview");

        public static readonly Error InterviewInvalidType =
            new("Interview.InvalidType", "Invalid interview type. Must be Online, On-site, or Hybrid");

        public static readonly Error InterviewInvalidStatus =
            new("Interview.InvalidStatus", "Invalid interview status. Must be Scheduled, Completed, or Cancelled");

        public static readonly Error InterviewInvalidRequest =
            new("Interview.InvalidRequest", "Invalid interview request data");

        public static readonly Error InterviewRoadmapNotFound =
            new("Interview.RoadmapNotFound", "The specified roadmap does not exist");

        public static readonly Error InterviewDateInPast =
            new("Interview.DateInPast", "Interview date must be in the future");
    }
}