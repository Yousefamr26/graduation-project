using DataAccess.Abstractions;

namespace Business_Logic.Errors
{
    public static class WorkshopErrors
    {
        public static readonly Error WorkshopNotFound =
            new("Workshop.NotFound", "No workshop was found with the given ID");

        public static readonly Error WorkshopTitleExists =
            new("Workshop.TitleExists", "A workshop with this title already exists");

        public static readonly Error WorkshopNoIdsProvided =
            new("Workshop.NoIds", "No workshop IDs were provided");

        public static readonly Error WorkshopBulkNotFound =
            new("Workshop.BulkNotFound", "No workshops found with the provided IDs");

        public static readonly Error WorkshopCreationFailed =
            new("Workshop.CreationFailed", "Failed to create workshop");

        public static readonly Error WorkshopUpdateFailed =
            new("Workshop.UpdateFailed", "Failed to update workshop");

        public static readonly Error WorkshopDeleteFailed =
            new("Workshop.DeleteFailed", "Failed to delete workshop");

        public static readonly Error WorkshopInvalidRequest =
            new("Workshop.InvalidRequest", "Invalid workshop request data");
    }
}
