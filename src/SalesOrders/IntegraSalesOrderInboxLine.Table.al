table 50102 "Integra Sales Order Inbox Line"
{
    Caption = 'Integra Sales Order Inbox Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document Entry No."; Integer)
        {
            Caption = 'Document Entry No.';
            TableRelation = "Integra Sales Order Inbox";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            AutoIncrement = true;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(12; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(13; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(14; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(15; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DecimalPlaces = 2 : 5;
        }
        field(16; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
        }
        field(20; "Item Exists"; Boolean)
        {
            Caption = 'Item Exists';
            FieldClass = FlowField;
            CalcFormula = exist(Item where("No." = field("Item No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
