using Business_Logic.IService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace SmartCareerHub.Api.Controllers
{
    [ApiController]
    [Route("api/certificates")]
    [Authorize]
    public class CertificateController : ControllerBase
    {
        private readonly ICertificateService _certificateService;

        public CertificateController(ICertificateService certificateService)
        {
            _certificateService = certificateService;
        }

        [HttpPost("request")]
        [Authorize(Roles = "Student,Graduate")]
        public async Task<IActionResult> RequestCertificate([FromQuery] int roadmapId, CancellationToken cancellationToken)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { Message = "User not found" });

            var result = await _certificateService.RequestCertificateAsync(
                userId,
                roadmapId,
                cancellationToken);

            if (result.IsFailure)
                return BadRequest(new
                {
                    result.Error.Code,
                    result.Error.Description
                });

            return Ok(result.Value);
        }

        [HttpGet("{certificateId:guid}/download")]
        [Authorize(Roles = "Student,Graduate")]
        public async Task<IActionResult> DownloadCertificate(Guid certificateId, CancellationToken cancellationToken)
        {
            var url = await _certificateService.GetDownloadUrlAsync(certificateId, cancellationToken);

            if (string.IsNullOrEmpty(url))
                return NotFound(new { Message = "Certificate file not found" });

            return Ok(new
            {
                DownloadUrl = url
            });
        }

        // ================= GENERATE PDF (direct stream optional) =================
        [HttpGet("{certificateId:guid}/pdf")]
        [Authorize(Roles = "Student,Graduate,Company")]
        public async Task<IActionResult> GetCertificatePdf(Guid certificateId, CancellationToken cancellationToken)
        {
            var pdfBytes = await _certificateService.GenerateCertificatePdfAsync(certificateId, cancellationToken);

            if (pdfBytes == null || pdfBytes.Length == 0)
                return NotFound(new { Message = "Certificate not found" });

            return File(pdfBytes, "application/pdf", $"certificate_{certificateId}.pdf");
        }

        // ================= GET CERTIFICATE INFO =================
        [HttpGet("{certificateId:guid}")]
        [Authorize(Roles = "Student,Graduate,Company")]
        public async Task<IActionResult> GetById(Guid certificateId)
        {
            var certificate = await _certificateService.GetByIdAsync(certificateId);

            if (certificate == null)
                return NotFound(new { Message = "Certificate not found" });

            return Ok(certificate);
        }
    }
}
