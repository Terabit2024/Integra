page 50104 "Integra SO Inbox List"
{
    PageType = List;
    Caption = 'Integra Sales Order Inbox';
    SourceTable = "Integra Sales Order Inbox";
    UsageCategory = Lists;
    ApplicationArea = All;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field(Salesperson; Rec.Salesperson)
                {
                    ApplicationArea = All;
                }
                field("Created Sales Order No."; Rec."Created Sales Order No.")
                {
                    ApplicationArea = All;
                }
                field("Processed At"; Rec."Processed At")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
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
            action(ProcessSelected)
            {
                Caption = 'Process';
                ApplicationArea = All;
                Image = Process;
                ToolTip = 'Create the sales order for the selected inbox entry. The customer is created if it does not exist; items are matched by No. 2 and must already exist.';

                trigger OnAction()
                var
                    Processor: Codeunit "Integra Sales Order Processor";
                begin
                    if Processor.ProcessEntry(Rec) then
                        Message(ProcessedMsg, Rec."Created Sales Order No.")
                    else
                        Message(ProcessFailedMsg, Rec."Error Message");
                    CurrPage.Update(false);
                end;
            }
            action(ProcessAllPending)
            {
                Caption = 'Process All Pending';
                ApplicationArea = All;
                Image = PostBatch;
                ToolTip = 'Create sales orders for all pending inbox entries.';

                trigger OnAction()
                var
                    Processor: Codeunit "Integra Sales Order Processor";
                begin
                    Processor.ProcessAllPending();
                    CurrPage.Update(false);
                end;
            }
            action(ShowLines)
            {
                Caption = 'Lines';
                ApplicationArea = All;
                Image = AllLines;
                ToolTip = 'View the lines of the selected inbox entry.';

                trigger OnAction()
                var
                    InboxLine: Record "Integra Sales Order Inbox Line";
                begin
                    InboxLine.SetRange("Document Entry No.", Rec."Entry No.");
                    Page.Run(Page::"Integra SO Inbox Lines", InboxLine);
                end;
            }
            action(DeleteEntry)
            {
                Caption = 'Delete Entry';
                ApplicationArea = All;
                Image = Delete;
                ToolTip = 'Delete the selected inbox entries together with their lines. Entries that are already processed cannot be deleted.';

                trigger OnAction()
                var
                    Inbox: Record "Integra Sales Order Inbox";
                begin
                    CurrPage.SetSelectionFilter(Inbox);
                    if Inbox.IsEmpty() then
                        exit;
                    if not Confirm(DeleteConfirmQst, false, Inbox.Count()) then
                        exit;
                    Inbox.DeleteAll(true);
                    CurrPage.Update(false);
                end;
            }
            action(OpenSalesOrder)
            {
                Caption = 'Open Sales Order';
                ApplicationArea = All;
                Image = Document;
                ToolTip = 'Open the sales order that was created from this inbox entry.';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    Rec.TestField("Created Sales Order No.");
                    SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Created Sales Order No.");
                    Page.Run(Page::"Sales Order", SalesHeader);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(ProcessSelected_Promoted; ProcessSelected) { }
                actionref(ProcessAllPending_Promoted; ProcessAllPending) { }
                actionref(ShowLines_Promoted; ShowLines) { }
                actionref(DeleteEntry_Promoted; DeleteEntry) { }
                actionref(OpenSalesOrder_Promoted; OpenSalesOrder) { }
            }
        }
    }

    views
    {
        view(Pending)
        {
            Caption = 'Pending';
            Filters = where(Status = const(Pending));
        }
        view(Errors)
        {
            Caption = 'Errors';
            Filters = where(Status = const(Error));
        }
        view(Processed)
        {
            Caption = 'Processed';
            Filters = where(Status = const(Processed));
        }
    }

    var
        StatusStyle: Text;
        ProcessedMsg: Label 'Sales Order %1 was created.', Comment = '%1 = sales order no.';
        ProcessFailedMsg: Label 'Processing failed: %1', Comment = '%1 = error message';
        DeleteConfirmQst: Label 'Delete %1 selected inbox entr(y/ies) together with their lines?', Comment = '%1 = number of selected entries';
        MissingItemsNotificationMsg: Label '%1 inbox order(s) could not be processed because of errors (e.g. items that do not exist in the system). Check the entries with status Error.', Comment = '%1 = number of error entries';
        ShowErrorsLbl: Label 'Show errors';

    trigger OnOpenPage()
    begin
        SendErrorNotification();
    end;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Error:
                StatusStyle := 'Unfavorable';
            Rec.Status::Processed:
                StatusStyle := 'Favorable';
            else
                StatusStyle := 'Ambiguous';
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.Editable(Rec.Status <> Rec.Status::Processed);
    end;

    local procedure SendErrorNotification()
    var
        Inbox: Record "Integra Sales Order Inbox";
        ErrorNotification: Notification;
    begin
        Inbox.SetRange(Status, Inbox.Status::Error);
        if Inbox.IsEmpty() then
            exit;

        ErrorNotification.Message(StrSubstNo(MissingItemsNotificationMsg, Inbox.Count()));
        ErrorNotification.Scope := NotificationScope::LocalScope;
        ErrorNotification.AddAction(ShowErrorsLbl, Codeunit::"Integra Sales Order Processor", 'ShowErrorEntries');
        ErrorNotification.Send();
    end;
}
