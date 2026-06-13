using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
public class ProgrammingTrackAnalyzerController : ControllerBase
{
    private readonly ProgrammingTrackAnalyzerService _service;

    public ProgrammingTrackAnalyzerController(ProgrammingTrackAnalyzerService service)
    {
        _service = service;
    }

    [HttpPost("analyze")]
    public async Task<IActionResult> Analyze([FromBody] ProgrammingTrackAnalyzerRequest request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var result = await _service.AnalyzeAsync(request.UserDescription);

        return Ok(result);
    }
}
