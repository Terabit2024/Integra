codeunit 50101 "Integra Sales Order Processor"
{
    TableNo = "Integra Sales Order Inbox";

    trigger OnRun()
    begin
        if Rec."Entry No." <> 0 then
            CreateSalesOrder(Rec)
        else
            ProcessAllPending();
    end;

    var
        NoLinesErr: Label 'The inbox order has no lines.';
        MissingItemsErr: Label 'The following items do not exist in the system: %1. The items must be created manually before this order can be processed.', Comment = '%1 = comma-separated list of item numbers';
        AlreadyProcessedErr: Label 'Inbox entry %1 is already processed (Sales Order %2).', Comment = '%1 = entry no., %2 = sales order no.';

    procedure ProcessAllPending()
    var
        Inbox: Record "Integra Sales Order Inbox";
    begin
        Inbox.SetRange(Status, Inbox.Status::Pending);
        if Inbox.FindSet(true) then
            repeat
                ProcessEntry(Inbox);
            until Inbox.Next() = 0;
    end;

    procedure ProcessEntry(var Inbox: Record "Integra Sales Order Inbox"): Boolean
    begin
        if Inbox.Status = Inbox.Status::Processed then
            Error(AlreadyProcessedErr, Inbox."Entry No.", Inbox."Created Sales Order No.");

        Commit();
        if Codeunit.Run(Codeunit::"Integra Sales Order Processor", Inbox) then
            exit(true);

        Inbox.Status := Inbox.Status::Error;
        Inbox."Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(Inbox."Error Message"));
        Inbox.Modify();
        Commit();
        exit(false);
    end;

    procedure ShowErrorEntries(ErrorNotification: Notification)
    var
        Inbox: Record "Integra Sales Order Inbox";
    begin
        Inbox.SetRange(Status, Inbox.Status::Error);
        Page.Run(Page::"Integra SO Inbox List", Inbox);
    end;

    local procedure CreateSalesOrder(var Inbox: Record "Integra Sales Order Inbox")
    var
        InboxLine: Record "Integra Sales Order Inbox Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        InboxLine.SetRange("Document Entry No.", Inbox."Entry No.");
        if InboxLine.IsEmpty() then
            Error(NoLinesErr);

        CheckItemsExist(Inbox);

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", GetOrCreateCustomer(Inbox));
        if Inbox."Order Date" <> 0D then
            SalesHeader.Validate("Order Date", Inbox."Order Date");
        if Inbox."Posting Date" <> 0D then
            SalesHeader.Validate("Posting Date", Inbox."Posting Date");
        if Inbox."Document Date" <> 0D then
            SalesHeader.Validate("Document Date", Inbox."Document Date");
        if Inbox."External Document No." <> '' then
            SalesHeader.Validate("External Document No.", Inbox."External Document No.");
        if Inbox."Salesperson Code" <> '' then
            SalesHeader.Validate("Salesperson Code", Inbox."Salesperson Code");
        SalesHeader.Modify(true);

        InboxLine.FindSet();
        repeat
            LineNo += 10000;
            SalesLine.Init();
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." := LineNo;
            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Validate("No.", InboxLine."Item No.");
            if InboxLine."Location Code" <> '' then
                SalesLine.Validate("Location Code", InboxLine."Location Code");
            if InboxLine."Unit of Measure Code" <> '' then
                SalesLine.Validate("Unit of Measure Code", InboxLine."Unit of Measure Code");
            SalesLine.Validate(Quantity, InboxLine.Quantity);
            if InboxLine."Unit Price" <> 0 then
                SalesLine.Validate("Unit Price", InboxLine."Unit Price");
            if InboxLine."Line Discount %" <> 0 then
                SalesLine.Validate("Line Discount %", InboxLine."Line Discount %");
            SalesLine.Insert(true);
        until InboxLine.Next() = 0;

        Inbox.Status := Inbox.Status::Processed;
        Inbox."Error Message" := '';
        Inbox."Created Sales Order No." := SalesHeader."No.";
        Inbox."Processed At" := CurrentDateTime();
        Inbox.Modify();
    end;

    local procedure CheckItemsExist(Inbox: Record "Integra Sales Order Inbox")
    var
        InboxLine: Record "Integra Sales Order Inbox Line";
        Item: Record Item;
        MissingItems: TextBuilder;
    begin
        InboxLine.SetRange("Document Entry No.", Inbox."Entry No.");
        InboxLine.FindSet();
        repeat
            if not Item.Get(InboxLine."Item No.") then begin
                if MissingItems.Length() > 0 then
                    MissingItems.Append(', ');
                MissingItems.Append(InboxLine."Item No.");
            end;
        until InboxLine.Next() = 0;

        if MissingItems.Length() > 0 then
            Error(MissingItemsErr, MissingItems.ToText());
    end;

    local procedure GetOrCreateCustomer(Inbox: Record "Integra Sales Order Inbox"): Code[20]
    var
        Customer: Record Customer;
        Setup: Record "Integra Integration Setup";
    begin
        if Inbox."Customer No." <> '' then
            if Customer.Get(Inbox."Customer No.") then
                exit(Customer."No.");

        if Inbox."Customer Name" <> '' then begin
            Customer.SetRange(Name, Inbox."Customer Name");
            if Customer.FindFirst() then
                exit(Customer."No.");
        end;

        Setup.GetSetup();
        Customer.Reset();
        Customer.Init();
        Customer."No." := Inbox."Customer No.";
        Customer.Insert(true);
        Customer.Validate(Name, Inbox."Customer Name");
        Customer.Address := Inbox.Address;
        Customer."Address 2" := Inbox."Address 2";
        Customer.City := Inbox.City;
        Customer.County := Inbox.County;
        Customer."Post Code" := Inbox."Post Code";
        if Inbox."Country/Region Code" <> '' then
            Customer.Validate("Country/Region Code", Inbox."Country/Region Code");
        Customer."Phone No." := Inbox."Phone No.";
        Customer."E-Mail" := Inbox."E-Mail";
        Customer.Contact := Inbox."Contact Name";
        if Setup."Def. Customer Posting Group" <> '' then
            Customer.Validate("Customer Posting Group", Setup."Def. Customer Posting Group");
        if Setup."Def. Gen. Bus. Posting Group" <> '' then
            Customer.Validate("Gen. Bus. Posting Group", Setup."Def. Gen. Bus. Posting Group");
        if Setup."Def. VAT Bus. Posting Group" <> '' then
            Customer.Validate("VAT Bus. Posting Group", Setup."Def. VAT Bus. Posting Group");
        Customer.Modify(true);
        exit(Customer."No.");
    end;
}
