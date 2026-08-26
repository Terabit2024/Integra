codeunit 50200 "Integra Integration Mgt."
{
    var
        SetupMissingErr: Label 'Integration is not enabled. Open the Integra Integration Setup page and configure it first.';
        ConnectionOkMsg: Label 'Connection successful (HTTP %1).', Comment = '%1 = HTTP status code';
        ConnectionFailedErr: Label 'Connection failed: %1', Comment = '%1 = error text';

    procedure TestConnection()
    var
        Setup: Record "Integra Integration Setup";
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        Setup.GetSetup();
        if not Setup.Enabled or (Setup."Service Base URL" = '') then
            Error(SetupMissingErr);

        if not Client.Get(Setup."Service Base URL", Response) then
            Error(ConnectionFailedErr, GetLastErrorText());

        Message(ConnectionOkMsg, Response.HttpStatusCode());
    end;
}
