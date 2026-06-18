using System.Text;
using System.Text.Json;

public class GeminiClient
{
    private readonly HttpClient _httpClient;
    private readonly string _apiKey;

    public GeminiClient(HttpClient httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _apiKey = configuration["Gemini:ApiKey"]
                  ?? throw new Exception("Gemini API Key not found");
    }

    public async Task<string> GenerateContentAsync(string userInput)
    {
        string systemPrompt = """
You are a professional programming career chatbot.

Your tasks:
1. Analyze the user's programming skills or interests.
2. Determine the MOST suitable programming track.
3. Explain the reason clearly.
4. Ask ONE follow-up question if needed.
5. Provide a short beginner roadmap.

IMPORTANT RULES:
- Respond ONLY in valid JSON.
- Do NOT include markdown.
- Do NOT include explanations outside JSON.

JSON FORMAT:
{
  "track": "string",
  "reason": "string",
  "follow_up_question": "string or null",
  "roadmap": ["string", "string"]
}
""";

        var requestBody = new
        {
            contents = new[]
            {
                new
                {
                    parts = new[]
                    {
                        new { text = systemPrompt },
                        new { text = $"User description: {userInput}" }
                    }
                }
            }
        };

        var json = JsonSerializer.Serialize(requestBody);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        var response = await _httpClient.PostAsync(
            $"https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key={_apiKey}",
            content
        );

        var responseText = await response.Content.ReadAsStringAsync();

        if (!response.IsSuccessStatusCode)
            throw new Exception($"Gemini API Error: {responseText}");

        using var doc = JsonDocument.Parse(responseText);
        return doc.RootElement
            .GetProperty("candidates")[0]
            .GetProperty("content")
            .GetProperty("parts")[0]
            .GetProperty("text")
            .GetString()!;
    }
}
