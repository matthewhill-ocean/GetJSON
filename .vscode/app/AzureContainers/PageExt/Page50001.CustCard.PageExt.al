/// <summary>
/// PageExtension ODCustomer Card (ID 50001) extends Record Customer Card.
/// </summary>
pageextension 50001 "ODCustomer Card" extends "Customer Card"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter(ShipToAddresses)
        {
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
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ABSMgmt.DownloadImage(Rec);
    end;

    var
        ABSMgmt: Codeunit "ODABS Management";
}