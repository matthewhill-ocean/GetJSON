/// <summary>
/// PageExtension Customer List Ext. (ID 50000) extends Page Customer List.
/// </summary>
pageextension 50000 "ODCustomer List" extends "Customer List"
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
            action(UploadImage)
            {
                Caption = 'Upload Image';
                Image = Import;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    ABSMgmt.UploadImage(Rec);
                end;
            }
            action(MyWordReport)
            {
                Caption = 'My Word Report';
                Image = Customer;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Report.Run(Report::MyWordReport);
                end;
            }
        }
    }
    var
        ABSMgmt: Codeunit "ODABS Management";
}