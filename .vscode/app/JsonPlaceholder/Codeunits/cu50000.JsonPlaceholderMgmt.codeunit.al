/// <summary>
/// Codeunit Json Placeholder Mgmt. (ID 50000).
/// </summary>
codeunit 50000 "Json Placeholder Mgmt."
{
    /// <summary>
    /// GetUserInformation.
    /// </summary>
    /// <param name="Customer">VAR Record Customer.</param>
    /// <param name="UserNumber">Integer.</param>
    procedure GetUserInformation(var Customer: Record Customer; UserNumber: Integer)
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ResponseJson: Text;
        JToken: JsonToken;
    begin
        if not Client.Get(
            StrSubstNo('https://jsonplaceholder.typicode.com/users/%1', UserNumber), ResponseMessage)
        then
            Error('The call to the web service failed.');

        if not ResponseMessage.IsSuccessStatusCode() then
            Error('The web service returned an error message:\\' +
                  'Status code: ' + Format(ResponseMessage.HttpStatusCode()) +
                  'Description: ' + ResponseMessage.ReasonPhrase());

        ResponseMessage.Content().ReadAs(ResponseJson);

        if not JToken.ReadFrom(ResponseJson) then
            Error('Invalid JSON document.');
        if not JToken.IsObject() then
            Error('Expected a JSON object.');

        Customer.Init();
        Customer."No." := Format(UserNumber);
        Customer.Name := GetJTokenValue(JToken.AsObject(), 'name');
        Customer."Phone No." := GetJTokenValue(JToken.AsObject(), 'phone');
        Customer."E-Mail" := GetJTokenValue(JToken.AsObject(), 'email');

        JToken.AsObject.Get('company', JToken);
        if not JToken.IsObject() then
            Error('Expected a JSON object.');

        Customer."Name 2" := GetJTokenValue(JToken.AsObject(), 'name');
        Customer.Insert();
    end;

    local procedure GetJTokenValue(JObject: JsonObject; TokenID: Text): Text
    var
        JToken: JsonToken;
    begin
        if not JObject.Get(TokenID, JToken) then
            Error('Value for key name not found.');
        if not JToken.IsValue then
            Error('Expected a JSON value.');
        exit(JToken.AsValue().AsText());
    end;

    /// <summary>
    /// CreatePost.
    /// </summary>
    procedure CreatePost()
    var
        Client: HttpClient;
        Content: HttpContent;
        ResponseMessage: HttpResponseMessage;
        ResponseString: Text;
        JObject: JsonObject;
        JsonText: Text;
    begin

        JObject.Add('userId', 2);
        JObject.Add('id', 101);
        JObject.Add('title', 'Microsoft Dynamics 365 Business Central Post Test');
        JObject.Add('body', 'This is a MS Dynamics 365 Business Central Post Test');
        JObject.WriteTo(JsonText);

        Content.WriteFrom(JsonText);

        if not Client.Post('https://jsonplaceholder.typicode.com/posts', Content,
                           ResponseMessage) then
            Error('The call to the web service failed.');

        if not ResponseMessage.IsSuccessStatusCode() then
            Error('The web service returned an error message:\\' +
                    'Status code: ' + Format(ResponseMessage.HttpStatusCode()) +
                    'Description: ' + ResponseMessage.ReasonPhrase());

        ResponseMessage.Content().ReadAs(ResponseString);

        Message(ResponseString);
    end;

    /// <summary>
    /// AddHttpBasicAuthHeader.
    /// </summary>
    /// <param name="UserName">Text[50].</param>
    /// <param name="Password">Text[50].</param>
    /// <param name="HttpClient">VAR HttpClient.</param>
    procedure AddHttpBasicAuthHeader(var HttpClient: HttpClient; UserName: Text[50]; Password: Text[50]);
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        HttpClient.DefaultRequestHeaders().Add(
            'Authorization', STRSUBSTNO('Basic %1', Base64Convert.ToBase64(STRSUBSTNO('%1:%2', UserName, Password), TextEncoding::UTF8)));
    end;
}