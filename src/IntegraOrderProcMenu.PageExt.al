pageextension 50101 "Integra Order Proc. RC" extends "Order Processor Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group(IntegraMenu)
            {
                Caption = 'Integra';

                action(IntegraSOInbox)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Order Inbox';
                    ToolTip = 'Shiko porosite e ardhura nga API dhe statusin e procesimit te tyre.';
                    RunObject = page "Integra SO Inbox List";
                }
                action(IntegraSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Integration Setup';
                    ToolTip = 'Konfiguro parametrat e integrimit Integra.';
                    RunObject = page "Integra Integration Setup";
                }
            }
        }
    }
}
