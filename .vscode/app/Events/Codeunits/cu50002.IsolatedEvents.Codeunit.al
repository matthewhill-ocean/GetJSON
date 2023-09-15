/// <summary>
/// Codeunit IsolatedEventsSample (ID 50145).
/// </summary>
codeunit 50002 IsolatedEventsSample
{
    trigger OnRun()
    var
        Counter: Integer;
        cust: Record Customer;
    begin
        // Precondition: Customer table isn't empty.
        if (cust.IsEmpty) then
            Error('Customer table is empty.');

        MyIsolatedEvent(Counter);

        // Code only reaches this point because the above event is isolated and error thrown in FailingEventSubscriber is caught.
        if (Counter <> 2) then
            Error('Both event subscribers should have incremented the counter.');

        // Post-condition: Customer table hasn't been truncated.
        if (cust.IsEmpty) then
            Error('Customer table was truncated, failing event subscriber was not rolled back.');
    end;

    [InternalEvent(false, true)]
    local procedure MyIsolatedEvent(var Counter: Integer)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IsolatedEventsSample, 'MyIsolatedEvent', '', false, false)]
    local procedure FailingEventSubscriber(var Counter: Integer)
    var
        cust: Record Customer;
    begin
        Counter += 1; // Change will persist even after throwing. Only database changes will be rolled back.

        cust.DeleteAll(); // Database changes will be rolled back upon error.

        Error('Fail!');

        // Code below won't be reached!
        Counter += 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IsolatedEventsSample, 'MyIsolatedEvent', '', false, false)]
    local procedure IncreasingEventSubscriber(var Counter: Integer)
    begin
        Counter += 1;
    end;

    /*[EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    local procedure MyProcedure()
    begin
    end;*/
}