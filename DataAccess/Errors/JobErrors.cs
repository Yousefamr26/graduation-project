using DataAccess.Abstractions;

namespace Business_Logic.Errors
{
    public static class JobErrors
    {
        public static readonly Error JobNotFound =
            new("Job.NotFound", "No job was found with the given ID");

        public static readonly Error JobTitleExists =
            new("Job.TitleExists", "A job with this title already exists");

        public static readonly Error JobNoIdsProvided =
            new("Job.NoIds", "No job IDs were provided");

        public static readonly Error JobBulkNotFound =
            new("Job.BulkNotFound", "No jobs found with the provided IDs");

        public static readonly Error JobCreationFailed =
            new("Job.CreationFailed", "Failed to create job");

        public static readonly Error JobUpdateFailed =
            new("Job.UpdateFailed", "Failed to update job");

        public static readonly Error JobDeleteFailed =
            new("Job.DeleteFailed", "Failed to delete job");

        public static readonly Error JobInvalidExperienceLevel =
            new("Job.InvalidExperienceLevel", "Invalid experience level. Must be Early Level, Mid Level, Senior Level, or Senior Manager");

        public static readonly Error JobInvalidJobType =
            new("Job.InvalidJobType", "Invalid job type. Must be Remote, On-site, or Hybrid");

        public static readonly Error JobInvalidRequest =
            new("Job.InvalidRequest", "Invalid job request data");

        public static readonly Error JobLogoUploadFailed =
            new("Job.LogoUploadFailed", "Failed to upload company logo");
    }
}