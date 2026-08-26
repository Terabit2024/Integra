page 50203 "Integra Sales Order Lines API"
{
    PageType = API;
    Caption = 'Integra Sales Order Lines API';
    APIPublisher = 'Integra';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'salesOrderLine';
    EntitySetName = 'salesOrderLines';
    SourceTable = "Integra Sales Order Inbox Line";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(documentEntryNo; Rec."Document Entry No.")
                {
                    Caption = 'Document Entry No.';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                    Editable = false;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                }
                field(lineDiscountPercent; Rec."Line Discount %")
                {
                    Caption = 'Line Discount %';
                }
            }
        }
    }
}
