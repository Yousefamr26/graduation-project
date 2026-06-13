using DataAccess.Abstractions;

namespace Business_Logic.Errors
{
    public static class ActivityErrors
    {
        public static readonly Error ActivityNotFound =
            new("Activity.NotFound", "No activity was found with the given ID");

        public static readonly Error ActivityCreationFailed =
            new("Activity.CreationFailed", "Failed to create activity");

        public static readonly Error ActivityUpdateFailed =
            new("Activity.UpdateFailed", "Failed to update activity");

        public static readonly Error ActivityDeleteFailed =
            new("Activity.DeleteFailed", "Failed to delete activity");

        public static readonly Error ActivityInvalidRequest =
            new("Activity.InvalidRequest", "Invalid activity request data");
    }
}
