/// <summary>
/// TableExtension ODCustomer (ID 50000) extends Record Customer.
/// </summary>
tableextension 50000 ODCustomer extends Customer
{
    fields
    {
        field(50000; "Azure Filename"; Blob)
        {
            Caption = 'Azure Filename';
            DataClassification = ToBeClassified;
        }
    }
}