table 50101 "Integra Sales Order Inbox"
{
    Caption = 'Integra Sales Order Inbox';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(11; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(12; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(13; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(14; City; Text[30])
        {
            Caption = 'City';
        }
        field(15; County; Text[30])
        {
            Caption = 'State / County';
        }
        field(16; "Post Code"; Code[20])
        {
            Caption = 'ZIP Code';
        }
        field(17; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
        }
        field(18; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
        }
        field(19; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
        }
        field(20; "Contact Name"; Text[100])
        {
            Caption = 'Contact Name';
        }
        field(30; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(31; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(32; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(33; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(34; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
        }
        field(35; Salesperson; Text[50])
        {
            Caption = 'Salesperson';
        }
        field(40; Status; Enum "Integra SO Inbox Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(41; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            Editable = false;
        }
        field(42; "Created Sales Order No."; Code[20])
        {
            Caption = 'Created Sales Order No.';
            Editable = false;
        }
        field(43; "Processed At"; DateTime)
        {
            Caption = 'Processed At';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Status; Status) { }
        key(ExtDocNo; "External Document No.") { }
    }

    trigger OnInsert()
    begin
        CheckDuplicateExternalDocNo();
    end;

    trigger OnDelete()
    var
        InboxLine: Record "Integra Sales Order Inbox Line";
    begin
        InboxLine.SetRange("Document Entry No.", Rec."Entry No.");
        InboxLine.DeleteAll();
    end;

    var
        DuplicateExtDocInboxErr: Label 'An inbox order with External Document No. %1 already exists (Entry No. %2, Status %3).', Comment = '%1 = external document no., %2 = entry no., %3 = status';
        DuplicateExtDocOrderErr: Label 'A sales order with External Document No. %1 already exists (Order %2).', Comment = '%1 = external document no., %2 = sales order no.';

    local procedure CheckDuplicateExternalDocNo()
    var
        Inbox: Record "Integra Sales Order Inbox";
        SalesHeader: Record "Sales Header";
    begin
        if Rec."External Document No." = '' then
            exit;

        Inbox.SetRange("External Document No.", Rec."External Document No.");
        Inbox.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
        if Inbox.FindFirst() then
            Error(DuplicateExtDocInboxErr, Rec."External Document No.", Inbox."Entry No.", Inbox.Status);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("External Document No.", Rec."External Document No.");
        if SalesHeader.FindFirst() then
            Error(DuplicateExtDocOrderErr, Rec."External Document No.", SalesHeader."No.");
    end;
}
