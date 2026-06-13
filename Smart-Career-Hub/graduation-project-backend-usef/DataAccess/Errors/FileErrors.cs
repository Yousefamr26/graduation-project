using DataAccess.Abstractions;

namespace Business_Logic.Errors
{
    public static class FileErrors
    {
        public static readonly Error FileUploadFailed =
            new("File.UploadFailed", "Failed to upload file");

        public static readonly Error FileInvalidFormat =
            new("File.InvalidFormat", "Invalid file format");

        public static readonly Error FileTooLarge =
            new("File.TooLarge", "File size exceeds the maximum allowed size");

        public static readonly Error FileNotProvided =
            new("File.NotProvided", "File was not provided");
    }
}
