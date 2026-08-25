page 50105 "Integra SO Inbox Lines"
{
    PageType = List;
    Caption = 'Integra Sales Order Inbox Lines';
    SourceTable = "Integra Sales Order Inbox Line";
    UsageCategory = None;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field("Document Entry No."; Rec."Document Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    StyleExpr = ItemStyle;
                }
                field("Item Exists"; Rec."Item Exists")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        ItemStyle: Text;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Item Exists");
        if Rec."Item Exists" then
            ItemStyle := 'Standard'
        else
            ItemStyle := 'Unfavorable';
    end;
}
