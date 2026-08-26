permissionset 50200 "Integra - All"
{
    Assignable = true;
    Caption = 'Integra - All';

    Permissions =
        table "Integra Integration Setup" = X,
        tabledata "Integra Integration Setup" = RIMD,
        table "Integra Sales Order Inbox" = X,
        tabledata "Integra Sales Order Inbox" = RIMD,
        table "Integra Sales Order Inbox Line" = X,
        tabledata "Integra Sales Order Inbox Line" = RIMD,
        codeunit "Integra Integration Mgt." = X,
        codeunit "Integra Sales Order Processor" = X,
        page "Integra Integration Setup" = X,
        page "Integra Sales Orders API" = X,
        page "Integra Sales Order Lines API" = X,
        page "Integra SO Inbox List" = X,
        page "Integra SO Inbox Lines" = X;
}
