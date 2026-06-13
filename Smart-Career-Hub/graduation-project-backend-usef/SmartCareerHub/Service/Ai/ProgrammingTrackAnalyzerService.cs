using System.Text.Json;

public class ProgrammingTrackAnalyzerService
{
    private readonly GeminiClient _geminiClient;

    public ProgrammingTrackAnalyzerService(GeminiClient geminiClient)
    {
        _geminiClient = geminiClient;
    }

    public async Task<ProgrammingTrackAnalyzerResponse> AnalyzeAsync(string userDescription)
    {
        // 1️⃣ Gemini بيرجع JSON string
        string jsonText = await _geminiClient.GenerateContentAsync(userDescription);

        JsonDocument doc;
        try
        {
            doc = JsonDocument.Parse(jsonText);
        }
        catch
        {
            throw new Exception("Gemini returned invalid JSON:\n" + jsonText);
        }

        var root = doc.RootElement;

        // 2️⃣ Extract fields
        string track = root.GetProperty("track").GetString() ?? "Unknown";
        string reason = root.GetProperty("reason").GetString() ?? "";

        string? followUp = null;
        if (root.TryGetProperty("follow_up_question", out var fq) &&
            fq.ValueKind != JsonValueKind.Null)
        {
            followUp = fq.GetString();
        }

        var roadmap = root.GetProperty("roadmap")
                          .EnumerateArray()
                          .Select(x => x.GetString()!)
                          .ToList();

        // 3️⃣ Return clean response
        return new ProgrammingTrackAnalyzerResponse(
            Track: track,
            Reason: reason,
            FollowUpQuestion: followUp,
            Roadmap: roadmap
        );
    }
}
