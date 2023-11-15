/// <summary>
/// Codeunit ODABS Management (ID 50000)
/// </summary>
codeunit 50003 "ODABS Management"
{
    /// <summary>
    /// UploadImage
    /// </summary>
    /// <param name="Cust">VAR Record Customer</param>
    procedure UploadImage(var Cust: Record Customer)
    var
        TempBlob: Codeunit "Temp Blob";
        Filename: Text;
        StorageAccount: Text;   //Should be setup....
        ContainerName: Text[2048];  //Should be setup....
    begin
        StorageAccount := 'odftpclient';    //Should be setup....
        ContainerName := 'test230928';      //Should be setup....

        /*if(CustAzureFileExists(Cust)) then
            Confirm*/

        Filename := GetFileForUpload(TempBlob, CreateGuid());
        if (Filename = '') then
            exit;
        PerformBlobStorageUpload(TempBlob, Filename, StorageAccount, ContainerName);
        SetCustAzureFilename(Cust, Filename);
    end;

    /// <summary>
    /// DownloadImage
    /// </summary>
    /// <param name="Cust">VAR Record Customer</param>
    procedure DownloadImage(var Cust: Record Customer)
    var
        StorageAccount: Text;   //Should be setup....
        ContainerName: Text[2048];  //Should be setup....
    begin
        StorageAccount := 'odftpclient';    //Should be setup....
        ContainerName := 'test230928';      //Should be setup....

        if (not CustAzureFileExists(Cust)) then
            exit;

        PerformBlobStorageDownload(StorageAccount, ContainerName, GetCustAzureFilename(Cust));
    end;

    local procedure PerformBlobStorageUpload(var TempBlob: Codeunit "Temp Blob"; Filename: Text; StorageAccount: Text; ContainerName: Text[2048])
    var
        ContainerClient: Codeunit "ABS Container Client";
        BlobClient: Codeunit "ABS Blob Client";
        iStorageServerAuth: Interface "Storage Service Authorization";
    begin
        InitialiseAzureStorage(ContainerClient, BlobClient, iStorageServerAuth, StorageAccount, ContainerName);
        PutBlobBlockStream(BlobClient, TempBlob, iStorageServerAuth, StorageAccount, ContainerName, Filename);  //TODO
    end;

    local procedure PerformBlobStorageDownload(StorageAccount: Text; ContainerName: Text[2048]; Filename: Text)
    var
        TempContainerContent: Record "ABS Container Content";
        TempBlob: Codeunit "Temp Blob";
        ContainerClient: Codeunit "ABS Container Client";
        BlobClient: Codeunit "ABS Blob Client";
        iStorageServerAuth: Interface "Storage Service Authorization";
    begin
        InitialiseAzureStorage(ContainerClient, BlobClient, iStorageServerAuth, StorageAccount, ContainerName);
        ListContainerContent(BlobClient, TempContainerContent);
        if (not ContainerContentFileExists(TempContainerContent, Filename)) then
            exit;

        GetBlobAsStream(BlobClient, TempBlob, Filename);
        //TODO TempBlob is possibly <blank>.  Do we retrieve as a file 1st?
    end;

    local procedure InitialiseAzureStorage(var ContainerClient: Codeunit "ABS Container Client"; var BlobClient: Codeunit "ABS Blob Client"; var iStorageServerAuth: Interface "Storage Service Authorization"; StorageAccount: Text; ContainerName: Text[2048])
    begin
        iStorageServerAuth := GetStorageServerAuth();
        ContainerClient.Initialize(StorageAccount, iStorageServerAuth);
        InitialiseContainer(ContainerClient, ContainerName);
        BlobClient.Initialize(StorageAccount, ContainerName, iStorageServerAuth);
    end;

    local procedure InitialiseContainer(var ContainerClient: Codeunit "ABS Container Client"; ContainerName: Text[2048])
    var
        TempContainer: Record "ABS Container";  //Temp by default....
    begin
        ListContainers(TempContainer, ContainerClient);
        CreateContainer(TempContainer, ContainerClient, ContainerName);
    end;

    local procedure ListContainers(var TempContainer: Record "ABS Container"; ContainerClient: Codeunit "ABS Container Client")
    begin
        VerifyOperationResponse(ContainerClient.ListContainers(TempContainer));
    end;

    local procedure CreateContainer(var TempContainer: Record "ABS Container"; ContainerClient: Codeunit "ABS Container Client"; ContainerName: Text[2048])
    begin
        if (not TempContainer.Get(ContainerName)) then
            VerifyOperationResponse(ContainerClient.CreateContainer(ContainerName));
    end;

    local procedure PutBlobBlockStream(var BlobClient: Codeunit "ABS Blob Client"; TempBlob: Codeunit "Temp Blob"; iStorageServerAuth: Interface "Storage Service Authorization"; StorageAccount: Text; ContainerName: Text[2048]; Filename: Text)
    var
        InStr: InStream;
    begin
        TempBlob.CreateInStream(InStr);
        PutBlobBlockStream(BlobClient, InStr, iStorageServerAuth, StorageAccount, ContainerName, Filename);
    end;

    local procedure PutBlobBlockStream(var BlobClient: Codeunit "ABS Blob Client"; TempBlob: Codeunit "Temp Blob"; iStorageServerAuth: Interface "Storage Service Authorization"; StorageAccount: Text; ContainerName: Text[2048]; Filename: Text; Encoding: TextEncoding)
    var
        InStr: InStream;
    begin
        TempBlob.CreateInStream(InStr, Encoding);
        PutBlobBlockStream(BlobClient, InStr, iStorageServerAuth, StorageAccount, ContainerName, Filename);
    end;

    local procedure PutBlobBlockStream(var BlobClient: Codeunit "ABS Blob Client"; InStr: InStream; iStorageServerAuth: Interface "Storage Service Authorization"; StorageAccount: Text; ContainerName: Text[2048]; Filename: Text)
    begin
        if (Filename = '') then
            exit;
        //TODO **HERE VerifyOperationResponse(BlobClient.PutBlobBlockBlobStream(Filename, InStr, FileMgmt.GetFileNameMimeType(Filename)));
    end;

    local procedure ListContainerContent(var BlobClient: Codeunit "ABS Blob Client"; var ContainerContent: Record "ABS Container Content")
    begin
        VerifyOperationResponse(BlobClient.ListBlobs(ContainerContent));
    end;

    local procedure GetBlobAsStream(var BlobClient: Codeunit "ABS Blob Client"; var TempBlob: Codeunit "Temp Blob"; BlobName: Text)
    var
        InStr: InStream;
    begin
        TempBlob.CreateInStream(InStr);
        GetBlobAsStream(BlobClient, InStr, BlobName);
    end;

    local procedure GetBlobAsStream(var BlobClient: Codeunit "ABS Blob Client"; var TempBlob: Codeunit "Temp Blob"; BlobName: Text; Encoding: TextEncoding)
    var
        InStr: InStream;
    begin
        TempBlob.CreateInStream(InStr, Encoding);
        GetBlobAsStream(BlobClient, InStr, BlobName);
    end;

    local procedure GetBlobAsStream(var BlobClient: Codeunit "ABS Blob Client"; InStr: InStream; BlobName: Text)
    var
        TempTempBlob: Codeunit "Temp Blob";
        TempInStr: InStream;
    begin
        VerifyOperationResponse(BlobClient.GetBlobAsStream(BlobName, InStr));
    end;

    local procedure ProcessPDF(var TempBlob: Codeunit "Temp Blob"): Text
    begin
        if (not ProcessPDF(TempBlob, Report::"Customer - Top 10 List")) then
            exit('');
        exit(GetFilenameWithExtension(CreateGuid(), 'pdf'));
    end;

    local procedure ProcessPDF(var TempBlob: Codeunit "Temp Blob"; ReportId: Integer): Boolean
    begin
        if (not GetAttachmentAsOutStream(TempBlob, ReportId)) then
            exit(false);
    end;

    local procedure GetFileForUpload(var TempBlob: Codeunit "Temp Blob"; UniqueFileID: Guid): Text
    var
        Filename: Text;
    begin
        Filename := GetBlobFromFile(TempBlob, ImportFileCaptionLbl, FileTypeList, FileFilterTxt);
        if (Filename = '') then
            exit('');
        exit(StrSubstNo('%1.%2.%3',
            FileMgmt.GetFileNameWithoutExtension(Filename), DelChr(UniqueFileID, '=', '{}'), FileMgmt.GetExtension(Filename)));
    end;

    /*local procedure ProcessImage(var TempBlob: Codeunit "Temp Blob"; RecordVariant: Variant; FieldID: Integer): Boolean
    var
        RecRef1: RecordRef;
        Result: Boolean;
    begin
        if (GetRecordRef(RecRef1, RecordVariant)) then begin
            Result := GetImageAsInStr(TempBlob, RecRef1, FieldID);
            RecRef1.Close;
        end;
        exit(Result);
    end;*/

    local procedure GetBlobFromFile(var TempBlob: Codeunit "Temp Blob"; DialogCaption: Text; FileFilter: Text; ExtFilter: Text): Text
    var
        Filename: Text;
    begin
        exit(FileMgmt.BLOBImportWithFilter(TempBlob, DialogCaption, Filename, FileFilter, ExtFilter));
    end;

    local procedure GetAttachmentAsOutStream(TempBlob: Codeunit "Temp Blob"; ReportID: Integer): Boolean
    var
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);
        exit(GetAttachmentAsOutStream(OutStr, ReportID));
    end;

    local procedure GetAttachmentAsOutStream(TempBlob: Codeunit "Temp Blob"; ReportID: Integer; Encoding: TextEncoding): Boolean
    var
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr, Encoding);
        exit(GetAttachmentAsOutStream(OutStr, ReportID));
    end;

    local procedure GetAttachmentAsOutStream(OutStr: OutStream; ReportID: Integer): Boolean
    var
        Cust: Record Customer;
        CustomLayoutReporting: Codeunit "Custom Layout Reporting";
        RecRef1: RecordRef;
        Result: Boolean;
    begin
        if (GetRecordRef(RecRef1, Cust)) then begin
            Result :=
                Report.SaveAs(
                    ReportID, CustomLayoutReporting.GetReportRequestPageParameters(ReportID), ReportFormat::Pdf, OutStr, RecRef1);
            RecRef1.Close();
        end;
        exit(Result);
    end;

    /*local procedure GetImageAsInStr(var TempBlob: Codeunit "Temp Blob"; RecRef1: RecordRef; FieldNo: Integer): Boolean
    var
        TempMediaRepository: Record "Media Repository" temporary;
        FieldRef1: FieldRef;
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);
        //Assuming Media.....
        FieldRef1 := RecRef1.Field(FieldNo);
        TempMediaRepository.Image := FieldRef1.Value;
        TempMediaRepository.Image.ExportStream(OutStr);
        exit(TempBlob.HasValue());
    end;*/

    local procedure GetStorageServerAuth(): Interface "Storage Service Authorization"
    var
        StorageServerAuth: Codeunit "Storage Service Authorization";
    begin
        exit(StorageServerAuth.CreateSharedKey('8IbNRV4E+z+QCdSMdxOJr5c5zTJnVO7fRaiaZBr3jTFD5Ppnx1RgDZgDzanUBBY7YuL3+R/4whLa+AStVdiWrA=='));
    end;

    local procedure VerifyOperationResponse(OperationResponse: Codeunit "ABS Operation Response")
    begin
        if (OperationResponse.IsSuccessful()) then
            exit;
        Error('ABS Error: %1', OperationResponse.GetError());
    end;

    local procedure GetRecordRef(var RecRef1: RecordRef; RecordVariant: Variant): Boolean
    var
        DataTypeMgmt: Codeunit "Data Type Management";
    begin
        exit(DataTypeMgmt.GetRecordRef(RecordVariant, RecRef1));
    end;

    local procedure GetFilenameWithExtension(FilenameWithoutExtension: Text; FileExtension: Text): Text
    begin
        exit(FileMgmt.CreateFileNameWithExtension(FilenameWithoutExtension, FileExtension));
    end;

    local procedure SetCustAzureFilename(var Cust: Record Customer; NewAzureFilename: Text)
    var
        OutStr: OutStream;
    begin
        Clear(Cust."Azure Filename");
        Cust."Azure Filename".CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(NewAzureFilename);
        Cust.Modify(false);
    end;

    local procedure GetCustAzureFilename(Cust: Record Customer): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStr: InStream;
        Filename: Text;
    begin
        if (CustAzureFileExists(Cust)) then begin
            Cust."Azure Filename".CreateInStream(InStr, TEXTENCODING::UTF8);
            Filename := TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStr, TypeHelper.LFSeparator(), Cust.FieldName("Azure Filename"));
        end;
        exit(Filename);
    end;

    local procedure CustAzureFileExists(var Cust: Record Customer): Boolean
    begin
        Cust.CalcFields("Azure Filename");
        exit(Cust."Azure Filename".HasValue);
    end;

    local procedure ContainerContentFileExists(var TempContainerContent: Record "ABS Container Content"; Filename: Text): Boolean
    begin
        TempContainerContent.SetRange("Full Name", Filename);
        exit(not TempContainerContent.IsEmpty);
    end;

    var
        FileMgmt: Codeunit "File Management";
        ImportFileCaptionLbl: Label 'Import File';
        //FileTypeList: Label '"Image files (*.bmp, *.jpg)|*.bmp;*.jpg|All files (*.*)|*.*"';
        FileTypeList: Label '"Text files (*.txt)|*.txt|Image files (*.bmp, *.jpg)|*.bmp;*.jpg|All files (*.*)|*.*"';
        //FileFilterTxt: Label 'bmp,jpg,*.*', Locked = true;
        FileFilterTxt: Label 'txt,bmp,jpg,*.*', Locked = true;
}