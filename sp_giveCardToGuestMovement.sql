CREATE PROCEDURE GiveCardToGuestMovement

    @GuestMovementID INT,
    @GuestMovementStartDate DATETIME = NULL
	

AS
BEGIN
	IF(@GuestMovementStartDate = NULL)
		begin
			set @GuestMovementStartDate = GETDATE()
		end

    DECLARE @GuestCardID INT

    IF (EXISTS (SELECT * FROM GUEST_CARD gc WHERE gc.CardStatus = 'Available'))
    BEGIN
        -- Get the first available card and set status 'Issued' and set Issued = @GuestMovementID
        UPDATE TOP(1) gc
        SET gc.CardStatus = 'Issued',
            gc.Issued = @GuestMovementID,
			@GuestCardID = gc.ID
        FROM GUEST_CARD gc
        WHERE gc.CardStatus = 'Available';

        -- Set the guest movement start date and guest card ID
        UPDATE gm
        SET gm.EnterDate = @GuestMovementStartDate,
            gm.CardNumber = (select CardNumber from GUEST_CARD gc where gc.ID = @GuestCardID)
        FROM GUEST_MOVEMENT gm
        WHERE gm.ID = @GuestMovementID;

        -- Give parking slot to guest movement
        -- get vehicle id from guest movement
        DECLARE @VehicleID INT
        SET @VehicleID = (SELECT gm.ID FROM GUEST_MOVEMENT gm WHERE gm.ID = @GuestMovementID)

        exec GiveParkingSlotToVehicle @VehicleID
    END
END;
