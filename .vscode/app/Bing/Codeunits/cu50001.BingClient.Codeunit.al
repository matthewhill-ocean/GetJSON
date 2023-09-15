/// <summary>
/// Codeunit Bing Client (ID 50001).
/// </summary>
codeunit 50001 "Bing Client"
{
    /// <summary>
    /// Returns a bing-ready HttpClient
    /// </summary>
    /// <returns>Bing HttpClient</returns>
    procedure GetBingClient() Result: HttpClient;
    begin
        Result.SetBaseAddress('https://www.bing.com');
    end;

    /// <summary>
    /// Get the response from a request to bing.
    /// </summary>
    /// <returns>The response message</returns>
    procedure GetBingResponse() Response: HttpResponseMessage
    begin
        GetBingClient().Get('', Response)
    end;

    /// <summary>
    /// Get the response from www.bing.com as an html-string. 
    /// </summary>
    /// <returns>string with html</returns>
    procedure GetBingHtml() Result: Text;
    begin
        GetBingResponse().Content().ReadAs(Result);
    end;
}