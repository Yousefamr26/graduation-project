using DataAccess.Abstractions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Errors
{
    public static class StudentProgressErrors
    {
        public static readonly Error StudentProgressNotFound =
            new("StudentProgress.NotFound", "No student progress item was found with the given ID");

        public static readonly Error StudentProgressCreationFailed =
            new("StudentProgress.CreationFailed", "Failed to create student progress item");

        public static readonly Error StudentProgressUpdateFailed =
            new("StudentProgress.UpdateFailed", "Failed to update student progress item");

        public static readonly Error StudentProgressDeleteFailed =
            new("StudentProgress.DeleteFailed", "Failed to delete student progress item");

        public static readonly Error StudentProgressMarkCompletedFailed =
            new("StudentProgress.MarkCompletedFailed", "Failed to mark progress item as completed");

        public static readonly Error StudentProgressInvalidRequest =
            new("StudentProgress.InvalidRequest", "Invalid student progress request data");
    }
}
