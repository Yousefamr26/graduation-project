using DataAccess.Abstractions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Business_Logic.Errors
{
    public static class RoadmapErrors
    {
        public static readonly Error RoadmapNotFound =
            new("Roadmap.NotFound", "No roadmap was found with the given ID");

        public static readonly Error RoadmapTitleExists =
            new("Roadmap.TitleExists", "A roadmap with this title already exists");

        public static readonly Error RoadmapNoIdsProvided =
            new("Roadmap.NoIds", "No roadmap IDs were provided");

        public static readonly Error RoadmapBulkNotFound =
            new("Roadmap.BulkNotFound", "No roadmaps found with the provided IDs");

        public static readonly Error RoadmapCreationFailed =
            new("Roadmap.CreationFailed", "Failed to create roadmap");

        public static readonly Error RoadmapUpdateFailed =
            new("Roadmap.UpdateFailed", "Failed to update roadmap");

        public static readonly Error RoadmapDeleteFailed =
            new("Roadmap.DeleteFailed", "Failed to delete roadmap");

        public static readonly Error RoadmapInvalidTargetRole =
            new("Roadmap.InvalidTargetRole", "Invalid target role. Must be Student, Graduate, or Both");

        public static readonly Error RoadmapInvalidRequest =
            new("Roadmap.InvalidRequest", "Invalid roadmap request data");
    }

}
