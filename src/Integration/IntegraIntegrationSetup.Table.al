table 50200 "Integra Integration Setup"
{
    Caption = 'Integra Integration Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Service Base URL"; Text[250])
        {
            Caption = 'Service Base URL';
            ExtendedDatatype = URL;
        }
        field(3; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(4; "API Key"; Text[100])
        {
            Caption = 'API Key';
            ExtendedDatatype = Masked;
        }
        field(5; "Def. Customer Posting Group"; Code[20])
        {
            Caption = 'Default Customer Posting Group';
            TableRelation = "Customer Posting Group";
        }
        field(6; "Def. Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Default Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(7; "Def. VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'Default VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
