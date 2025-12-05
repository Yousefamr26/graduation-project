using DataAccess.Abstractions;

namespace Business_Logic.Errors
{
    public static class MaterialErrors
    {
        public static readonly Error MaterialNotFound =
            new("Material.NotFound", "No material was found with the given ID");

        public static readonly Error MaterialInvalidType =
            new("Material.InvalidType", "Invalid material type. Must be Video, PDF, or Assignment");

        public static readonly Error MaterialCreationFailed =
            new("Material.CreationFailed", "Failed to create material");

        public static readonly Error MaterialUpdateFailed =
            new("Material.UpdateFailed", "Failed to update material");

        public static readonly Error MaterialDeleteFailed =
            new("Material.DeleteFailed", "Failed to delete material");

        public static readonly Error MaterialInvalidRequest =
            new("Material.InvalidRequest", "Invalid material request data");
    }
}
