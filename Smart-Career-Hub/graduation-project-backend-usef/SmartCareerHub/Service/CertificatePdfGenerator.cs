using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using DataAccess.Entities.RoadMap;

public class CertificatePdfGenerator
{
    public byte[] Generate(Certificate certificate)
    {
        QuestPDF.Settings.License = LicenseType.Community;

        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(40);

                page.Content().Column(col =>
                {
                    col.Spacing(15);

                    col.Item().AlignCenter().Text("CERTIFICATE OF COMPLETION")
                        .FontSize(28).Bold().FontColor(Colors.Blue.Medium);

                    col.Item().AlignCenter().Text("Smart Career Hub")
                        .FontSize(14).FontColor(Colors.Grey.Darken2);

                    col.Item().PaddingVertical(20);

                    col.Item().AlignCenter().Text("This is to certify that")
                        .FontSize(12);

                    col.Item().AlignCenter().Text($"{certificate.User.FirstName} {certificate.User.LastName}")
                        .FontSize(22).Bold();

                    col.Item().AlignCenter().Text("has successfully completed")
                        .FontSize(12);

                    col.Item().AlignCenter().Text(certificate.Roadmap.Title)
                        .FontSize(18).Bold().FontColor(Colors.Green.Medium);

                    col.Item().PaddingVertical(20);

                    col.Item().AlignCenter().Text($"Issued By: {certificate.IssuedBy?.OrganizationName ?? "Smart Career Hub"}");
                    col.Item().AlignCenter().Text($"Date: {certificate.IssuedAt:yyyy-MM-dd}");
                    col.Item().AlignCenter().Text($"Certificate ID: {certificate.CertificateCode}")
                        .Bold();

                    col.Item().PaddingTop(30);

                    col.Item().AlignCenter().Text("QR CODE PLACEHOLDER");
                });
            });
        });

        return document.GeneratePdf();
    }
}