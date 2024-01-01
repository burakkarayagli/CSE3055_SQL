create procedure ExitGuestMovement 
    @GuestCardID int,
    @GuestMovementLeaveDate datetime = NULL
as 

begin
	if (@GuestMovementLeaveDate = NULL)
		begin
			set @GuestMovementLeaveDate = GETDATE()
		end

    --Get the guest movement id
    declare @GuestMovementID int
    set @GuestMovementID = (select gc.issued from GUEST_CARD gc where gc.issued = @GuestCardID)

    --Set guest card status to available
    --Set guest card issued to null
    update gc
    set gc.CardStatus = 'Available',
        gc.issued = null
    from GUEST_CARD gc
    where gc.ID = @GuestCardID

    --Set guest movement leave datetime
    update gm
    set gm.LeaveDate = @GuestMovementLeaveDate
    from GUEST_MOVEMENT gm
    where gm.ID = @GuestMovementID

    --empty the vehicle parking slot
    update ps
    set ps.status = 'Available',
        ps.VehicleID = null
    from PARKING_SLOT ps
    where ps.VehicleID = @GuestMovementID
end