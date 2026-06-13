using Business_Logic.Errors;
using DataAccess.Abstractions;

namespace Business_Logic.Errors
{
    public static class PartnershipErrors
    {
        public static readonly Error PartnershipNotFound =
            new("Partnership.NotFound", "Partnership not found");

        public static readonly Error PartnershipNull =
            new("Partnership.Null", "Partnership is null");

        public static readonly Error PartnershipBulkNotFound =
            new("Partnership.BulkNotFound", "No partnerships found");
    }
}