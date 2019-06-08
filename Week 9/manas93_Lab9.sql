USE manas93_Lab9

-- 1. Write the stored procedure to populate one row in PLANE_MAINTENANCE table using the following:
-- a) Nested stored procedures to obtain FKs PlaneID and MaintenanceID
-- b) Error-handling for any required values that are NULL
-- c) Explicit transaction

CREATE PROCEDURE getPlaneID(
    @PlaneName VARCHAR(50),
    @PlaneID INT OUTPUT
)
AS
    SET @PlaneID = (SELECT PlaneID FROM Plane WHERE PlaneName = @PlaneName)
GO


CREATE PROCEDURE getMaintenanceID (
    @MaintenanceName VARCHAR(50),
    @MaintenanceID INT OUTPUT
)
AS
    SET @MaintenanceID = (SELECT MaintenanceID FROM Maintenance WHERE MaintenanceName = @MaintenanceName)
GO

CREATE PROCEDURE ins_plane_maintenance(
    @Plane_Name VARCHAR(50),
    @Maintenance_Name VARCHAR(50),
    @MaintenanceDate DATE
)
AS
DECLARE @P_ID INT
DECLARE @M_ID INT

EXEC getPlaneID
@PlaneName = @Plane_Name,
@PlaneID = @P_ID OUTPUT

    IF @P_ID IS NULL
    BEGIN
    RAISERROR('Plane ID IS NULL',11,1)
    RETURN
    END

EXEC getMaintenanceID
@MaintenanceName = @Maintenance_Name,
@MaintenanceID = @M_ID OUTPUT

    IF @M_ID IS NULL
    BEGIN
    RAISERROR('Maintenance ID IS NULL',11,1)
    RETURN
    END

BEGIN TRAN T1
    INSERT INTO PLANE_MAINTENANCE(PlaneID, MaintenanceID, MaintenanceDate)
    VALUES (@P_ID, @M_ID, @MaintenanceDate)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1

-- 2. Write the SQL code to create a computed column to track the total number of bookings for each customer

CREATE FUNCTION Total_Booking_Cust (@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Ret INT = (SELECT COUNT(B.BookingID)
            FROM CUSTOMER C JOIN Booking B ON C.CustomerID=B.CustomerID
            WHERE C.CustomerID = @PK_ID
            GROUP BY C.CustomerID)
    
    RETURN @Ret
END
GO

ALTER TABLE Customer
ADD TotalBookings AS (dbo.Total_Booking_Cust (CustomerID))

-- 3. Write the SQL code to enforce the following business rule:
-- "No employee younger than 21 may be scheduled on a flight as crew chief"

CREATE FUNCTION Age_Chief_Crew()
RETURNS INT
AS
BEGIN
    DECLARE @Ret INT = 0
    IF EXISTS(
        SELECT *
        FROM EMPLOYEE E JOIN FLIGHT_EMPLOYEE flte ON flte.EmployeeID = E.EmployeeID
                        JOIN ROLE R ON R.RoleID = flte.RoleID
        WHERE E.EmpDOB > (SELECT GETDATE() - (365.25*21))
        AND R.RoleName = 'Crew Chief'
    )
        BEGIN
            SET @Ret = 1
        END
    RETURN @Ret
END
GO

ALTER TABLE EMPLOYEE
ADD CONSTRAINT lessThan21Crew_Chief
CHECK(dbo.Age_Chief_Crew()=0)

-- 4. Write the SQL code to determine which customers meet all four of the following conditions:
-- a) have had at least 3 flights arriving into SEATAC airport since May 4, 2011
-- b) have had no more than 7 flights departing from Seoul/Inchon since November 12, 2010 
-- c) have booked flights with more than $10,750 in fares in 2017
-- d) have booking fees of less than $3,300 for 'excessive luggage' between June and September 2014 

WITH firstCTE ( CustomerID, CustomerFname, CustomerLname, bcount )AS
(SELECT C.CustomerID, C.CustomerFname, C.CustomerLname, COUNT(B.BookingID) as cnt
FROM Customer C JOIN Booking B ON C.CustomerID = B.CustomerID
                JOIN Flight F ON F.FlightID = B.FlightID
                JOIN Airport A ON A.AirportID = F.ArrivalAirportID
WHERE A.AirportName = 'SEATAC'
AND F.ScheduledArrival > '2011-05-04'
GROUP BY C.CustomerID, C.CustomerFname, C.CustomerLname
HAVING COUNT(B.BookingID) >= 3), 

secondCTE ( Customer2ID, Customer2Fname, Customer2Lname, b2count )
AS
(SELECT C.CustomerID, C.CustomerFname, C.CustomerLname, COUNT(B.BookingID) as cnt
FROM Customer C JOIN Booking B ON C.CustomerID=B.CustomerID
                JOIN Flight F ON F.FlightID=B.FlightID
                JOIN Airport A ON A.AirportID=F.DepartAirportID
WHERE A.AirportName='Seoul/Inchon'
AND F.ScheduledDepart > '2010-11-12'
GROUP BY C.CustomerID, C.CustomerFname, C.CustomerLname
HAVING COUNT(B.BookingID) <= 7), 

thirdCte ( Customer3ID, Customer3Fname, Customer3Lname, b3FEEAMOUNT )
AS
(SELECT C.CustomerID, C.CustomerFname, C.CustomerLname, SUM(F.FeeAmount) as Total
FROM Customer C JOIN Booking B ON C.CustomerID = B.CustomerID
                JOIN Booking_Fee BF ON BF.BookingID=B.BookingID
                JOIN Fee F ON BF.FeeID=F.FeeID
WHERE B.BookDateTime BETWEEN '2017-01-01' AND '2017-12-31'
GROUP BY C.CustomerID, C.CustomerFname, C.CustomerLname
HAVING SUM(F.FeeAmount) > 10750),

fourthCTE ( Customer4ID, Customer4Fname, Customer4Lname, b4FEEAMOUNT )
AS
(SELECT C.CustomerID, C.CustomerFname, C.CustomerLname, SUM(F.FeeAmount) as Total
FROM Customer C JOIN Booking B ON C.CustomerID = B.CustomerID
                JOIN Booking_Fee BF ON BF.BookingID=B.BookingID
                JOIN Fee F ON BF.FeeID=F.FeeID
WHERE F.FeeName = 'Excessive Luggage'
AND B.BookingDateTime BETWEEN '2014-06-01' AND '2014-09-31'
GROUP BY C.CustomerID, C.CustomerFname, C.CustomerLname
HAVING SUM(F.FeeAmount) < 3300)

SELECT *
FROM firstCTE INNER JOIN secondCTE ON firstCTE.CustomerID = secondCTE.Customer2ID 
         INNER JOIN thirdCTE ON CTE2.Customer2ID = CTE3.Customer3ID 
         INNER JOIN fourthCTE ON fourthCTE.Customer4ID = thirdCTE.Customer3ID 
GO



 --5. Write the SQL code to enforce the following business rule:
--"Pilots under 35 years old cannot fly into North American airports more than 21 times in any given year."

CREATE FUNCTION complex_rule()
RETURNS INT
AS
BEGIN
    DECLARE @Ret INT = 0
    IF EXISTS(
        SELECT COUNT(E.FlightID)
        FROM EMPLOYEE E JOIN FLIGHT_EMPLOYEE FE ON FE.EmployeeID=E.EmployeeID
                        JOIN ROLE R ON R.RoleID = FE.RoleID
                        JOIN FLIGHT F ON F.FlightID=FE.FlightID
                        JOIN AIRPORT A ON F.ArrivalAirportID=A.AirportID
                        JOIN CITY C ON C.CityID=A.CityID
                        JOIN COUNTRY CO ON CO.CountryID=C.CountryID
                        JOIN REGION RE ON RE.RegionID=CO.RegionID  
        WHERE R.RoleName = 'Pilot'
        AND RE.RegionName = 'North America'
        AND E.EmpDOB > (SELECT GETDATE() - (365.25*35))
        GROUP BY E.EmployeeName, YEAR (F.ScheduledArrival) 
        HAVING (COUNT(E.FlightID)) >21
    )
    BEGIN
        SET @Ret = 1
    END
RETURN @Ret
END
GO


ALTER TABLE FLIGHT
ADD CONSTRAINT Younger_Than_35
CHECK(dbo.complex_rule()=0)
GO

-- 6. Write the SQL code to divide customers into quartiles by the number of total flights booked in the past 9 years. 

SELECT C.CustomerID, C.CustomerFname, C.CustomerLname, NTILE(9) OVER (ORDER BY COUNT(B.BookingID) DESC)
FROM Customer C JOIN Booking B ON C.CustID=B.CustID
WHERE B.BookDateTime BETWEEN (SELECT (GETDATE()-(365.25*9))) AND (SELECT GETDATE())

