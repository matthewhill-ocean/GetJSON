/// <summary>
/// Page Get User Information (ID 50000).
/// </summary>
page 50000 "Get User Information"
{
    Caption = 'Get User Information';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = Customer;
    UsageCategory = Documents;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            field(Name; Rec.Name)
            {
                ApplicationArea = All;
            }
            field(Phone; Rec."Phone No.")
            {
                ApplicationArea = All;
            }
            field(Email; Rec."E-Mail")
            {
                ApplicationArea = All;
            }
            field(CompanyName; Rec."Name 2")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetInfo)
            {
                Caption = 'Get Information';
                ApplicationArea = All;

                trigger OnAction();
                begin
                    JsonPlaceholderMgmt.GetUserInformation(Rec, 5);
                end;
            }
        }
    }

    var
        JsonPlaceholderMgmt: Codeunit "Json Placeholder Mgmt.";
}