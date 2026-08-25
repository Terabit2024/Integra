page 50101 "Integra Integration Setup"
{
    PageType = Card;
    Caption = 'Integra Integration Setup';
    SourceTable = "Integra Integration Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                }
                field("Service Base URL"; Rec."Service Base URL")
                {
                    ApplicationArea = All;
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                }
            }
            group(NewCustomerDefaults)
            {
                Caption = 'New Customer Defaults';

                field("Def. Customer Posting Group"; Rec."Def. Customer Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Def. Gen. Bus. Posting Group"; Rec."Def. Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Def. VAT Bus. Posting Group"; Rec."Def. VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                Caption = 'Test Connection';
                ApplicationArea = All;
                Image = TestReport;

                trigger OnAction()
                var
                    IntegrationMgt: Codeunit "Integra Integration Mgt.";
                begin
                    IntegrationMgt.TestConnection();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
