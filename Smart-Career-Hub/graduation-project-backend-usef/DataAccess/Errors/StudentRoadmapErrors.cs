using DataAccess.Abstractions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Errors
{
    public static class StudentRoadmapErrors
    {
        public static readonly Error StudentRoadmapNotFound =
            new("StudentRoadmap.NotFound", "No student roadmap was found with the given ID");

        public static readonly Error StudentRoadmapCreationFailed =
            new("StudentRoadmap.CreationFailed", "Failed to create student roadmap");

        public static readonly Error StudentRoadmapUpdateFailed =
            new("StudentRoadmap.UpdateFailed", "Failed to update student roadmap");

        public static readonly Error StudentRoadmapDeleteFailed =
            new("StudentRoadmap.DeleteFailed", "Failed to delete student roadmap");

        public static readonly Error StudentRoadmapInvalidRequest =
            new("StudentRoadmap.InvalidRequest", "Invalid student roadmap request data");
        public static readonly Error StudentAlreadyJoined =
            new("StudentRoadmap.AlreadyJoined", "The student has already joined this roadmap");
    }
}
