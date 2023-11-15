/// <summary>
/// Report MyWordReport (ID 50000).
/// </summary>
report 50000 MyWordReport
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = MyWordLayout;

    dataset
    {
        dataitem(Customer; Customer)
        {
            column(Name; Customer.Name)
            {
            }
        }
    }

    /*requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(Name; SourceExpression)
                    {
                        ApplicationArea = All;

                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }*/

    rendering
    {
        layout(MyWordLayout)
        {
            Type = Word;
            LayoutFile = '.vscode\app\WordLayout\Layouts\MyWordReport.docx';
        }
    }

    var
        myInt: Integer;
}