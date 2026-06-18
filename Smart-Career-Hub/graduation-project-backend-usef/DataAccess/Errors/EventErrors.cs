using DataAccess.Abstractions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess.Errors
{
    public static class EventErrors
    {
        public static readonly Error EventNotFound =
            new("Event.NotFound", "No event was found with the given ID");

        public static readonly Error EventTitleExists =
            new("Event.TitleExists", "An event with this title already exists");

        public static readonly Error EventNoIdsProvided =
            new("Event.NoIds", "No event IDs were provided");

        public static readonly Error EventBulkNotFound =
            new("Event.BulkNotFound", "No events found with the provided IDs");

        public static readonly Error EventCreationFailed =
            new("Event.CreationFailed", "Failed to create event");

        public static readonly Error EventUpdateFailed =
            new("Event.UpdateFailed", "Failed to update event");

        public static readonly Error EventDeleteFailed =
            new("Event.DeleteFailed", "Failed to delete event");

        public static readonly Error EventInvalidMode =
            new("Event.InvalidMode", "Invalid event mode. Must be Online, Onsite, or Hybrid");

        public static readonly Error EventInvalidRequest =
            new("Event.InvalidRequest", "Invalid event request data");

        public static readonly Error EventMaxCapacityExceeded =
            new("Event.MaxCapacityExceeded", "The number of registrants exceeds the maximum capacity");

        public static readonly Error EventBannerInvalid =
            new("Event.BannerInvalid", "Invalid banner file. Must be jpg, jpeg, or png and under 5MB");

    }
}
