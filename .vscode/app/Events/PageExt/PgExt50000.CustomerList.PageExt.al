/// <summary>
/// PageExtension Customer List Ext. (ID 50000) extends Page Customer List.
/// </summary>
pageextension 50000 "Customer List Ext." extends "Customer List"
{
    actions
    {
        addafter(ShipToAddresses)
        {
            action(TestEvents)
            {
                Caption = 'Test Events';
                RunObject = codeunit IsolatedEventsSample;
                Image = Attach;
                ApplicationArea = All;
            }
        }
    }
}