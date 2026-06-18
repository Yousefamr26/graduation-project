public record UploadTemplateRequest(
    IFormFile TemplateFile,
    string Title,
    string Description
);