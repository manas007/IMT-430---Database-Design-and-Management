USE UNIVERSITY

--Q1 : RANK using CTE
WITH RANK_GPA 
AS
(SELECT TOP 300 (SUM(C.Credits * CLL.Grade)) / (SUM(C.Credits)) as GPA, S.StudentID, S.StudentFname, S.StudentLname, s.StudentPermState
FROM tblCOURSE C JOIN tblCLASS CL ON C.CourseID=CL.CourseID 
                 JOIN tblCLASS_LIST CLL ON CLL.ClassID=CL.ClassID
                 JOIN tblSTUDENT S ON S.StudentID = CLL.StudentID
WHERE CL.YEAR BETWEEN '1975' AND '1981'
GROUP BY S.StudentID, S.StudentFname, S.StudentLname, s.StudentPermState
ORDER BY GPA) 

SELECT StudentID, StudentFname, StudentLname, GPA, StudentPermState, RANK() OVER (PARTITION BY StudentPermState ORDER BY GPA) AS Rankk
FROM RANK_GPA

-- Using temp table
SELECT TOP 300 (SUM(C.Credits * CLL.Grade)) / (SUM(C.Credits)) as GPA, S.StudentID, S.StudentFname, S.StudentLname, s.StudentPermState
INTO #temp_table
FROM tblCOURSE C JOIN tblCLASS CL ON C.CourseID=CL.CourseID 
                 JOIN tblCLASS_LIST CLL ON CLL.ClassID=CL.ClassID
                 JOIN tblSTUDENT S ON S.StudentID = CLL.StudentID
WHERE CL.YEAR BETWEEN '1975' AND '1981'
GROUP BY S.StudentID, S.StudentFname, S.StudentLname, s.StudentPermState
ORDER BY GPA

SELECT StudentID, StudentFname, StudentLname, GPA, StudentPermState, RANK() OVER (PARTITION BY StudentPermState ORDER BY GPA) AS Rankk
FROM #temp_table


--Using table variable
DECLARE @Rank_TABLE TABLE (
    GPA NUMERIC(3,2) NOT NULL,
    StudentID INT NOT NULL,
    StudentFname VARCHAR(50),
    StudentLname VARCHAR(50),
	StudentPermState VARCHAR(100)
)
INSERT INTO @RANK_TABLE (GPA, StudentID, StudentFname, StudentLname, StudentPermState)
SELECT TOP 300 (SUM(C.Credits * CLL.Grade)) / (SUM(C.Credits)) as GPA, S.StudentID, S.StudentFname, S.StudentLname, S.StudentPermState
FROM tblCOURSE C JOIN tblCLASS CL ON C.CourseID=CL.CourseID 
                 JOIN tblCLASS_LIST CLL ON CLL.ClassID=CL.ClassID
                 JOIN tblSTUDENT S ON S.StudentID = CLL.StudentID
WHERE CL.YEAR BETWEEN '1975' AND '1981'
GROUP BY S.StudentID, S.StudentFname, S.StudentLname, S.StudentPermState
ORDER BY GPA

SELECT StudentID, StudentFname, StudentLname, GPA, StudentPermState, RANK() OVER (PARTITION BY StudentPermState ORDER BY GPA) AS Rankk
FROM @Rank_TABLE

--  Q2 DENSE_RANK using CTE
WITH BusinessGPA_CTE 
AS ( 
select tblSt.StudentFname, 
tblSt.StudentLname, 
tblSt.StudentID,
tblCLst.ClassID,
SUM(tblCour.Credits * tblCLst.Grade) / SUM(tblCour.Credits) As GPA,
DENSE_RANK() OVER (ORDER BY (SUM(tblCour.Credits * tblCLst.Grade) / SUM(tblCour.Credits)) DESC) AS GPArank
from tblCOLLEGE tblCol
join tblDEPARTMENT tblDept 
ON tblCol.CollegeID = tblDept.CollegeID
join tblCOURSE tblCour
ON tblCour.DeptID = tblDept.DeptID
join tblCLASS tblCl
ON tblCour.CourseID = tblCl.CourseID
join tblCLASS_LIST tblCLst
ON tblCLst.ClassID = tblCl.ClassID
join tblSTUDENT tblSt
ON tblSt.StudentID = tblCLst.StudentID
WHERE tblCol.CollegeName = 'Business (Foster)'
AND tblCl.YEAR BETWEEN '1970' AND '1979'
GROUP BY
tblSt.StudentFname, 
tblSt.StudentLname, 
tblSt.StudentID,
tblCLst.ClassID
)
Select bcte.StudentFname, 
bcte.StudentLname,
bcte.GPA 
from BusinessGPA_CTE bcte
Where bcte.GPArank = 26


-- Using a Temp Table
select tblSt.StudentFname, 
tblSt.StudentLname, 
tblSt.StudentID,
tblCLst.ClassID,
SUM(tblCour.Credits * tblCLst.Grade) / SUM(tblCour.Credits) As GPA,
DENSE_RANK() OVER (ORDER BY (SUM(tblCour.Credits * tblCLst.Grade) / SUM(tblCour.Credits)) DESC) AS GPArank
INTO #TempBusGPA
from tblCOLLEGE tblCol
join tblDEPARTMENT tblDept 
ON tblCol.CollegeID = tblDept.CollegeID
join tblCOURSE tblCour
ON tblCour.DeptID = tblDept.DeptID
join tblCLASS tblCl
ON tblCour.CourseID = tblCl.CourseID
join tblCLASS_LIST tblCLst
ON tblCLst.ClassID = tblCl.ClassID
join tblSTUDENT tblSt
ON tblSt.StudentID = tblCLst.StudentID
WHERE tblCol.CollegeName = 'Business (Foster)'
AND tblCl.YEAR BETWEEN '1970' AND '1979'
GROUP BY
tblSt.StudentFname, 
tblSt.StudentLname, 
tblSt.StudentID,
tblCLst.ClassID

SELECT temp.StudentFname, 
temp.StudentLname,
temp.GPA 
from #TempBusGPA temp
Where temp.GPArank = 26


-- Using a Table Variable
Declare @BusinessGPA table(
StudentID INT NOT NULL,
StudentFName Varchar(30),
StudentLName Varchar(30),
ClassID INT NOT NULL,
GPA Numeric(3,2) NOT NULL,
GPArank INT NOT NULL
)
INSERT INTO @BusinessGPA (StudentID,StudentFName,StudentLName,ClassID,GPA,GPArank)
select 
tblSt.StudentID,
tblSt.StudentFname, 
tblSt.StudentLname, 
tblCLst.ClassID,
SUM(tblCour.Credits * tblCLst.Grade) / SUM(tblCour.Credits) As GPA,
DENSE_RANK() OVER (ORDER BY (SUM(tblCour.Credits * tblCLst.Grade) / SUM(tblCour.Credits)) DESC) AS GPArank
from tblCOLLEGE tblCol
join tblDEPARTMENT tblDept 
ON tblCol.CollegeID = tblDept.CollegeID
join tblCOURSE tblCour
ON tblCour.DeptID = tblDept.DeptID
join tblCLASS tblCl
ON tblCour.CourseID = tblCl.CourseID
join tblCLASS_LIST tblCLst
ON tblCLst.ClassID = tblCl.ClassID
join tblSTUDENT tblSt
ON tblSt.StudentID = tblCLst.StudentID
WHERE tblCol.CollegeName = 'Business (Foster)'
AND tblCl.YEAR BETWEEN '1970' AND '1979'
GROUP BY
tblSt.StudentFname, 
tblSt.StudentLname, 
tblSt.StudentID,
tblCLst.ClassID

Select bg.StudentFName, bg.StudentLName, bg.GPA from @BusinessGPA bg
Where bg.GPArank = 26


--Q3 NTILE using CTE
WITH CTE_GPA
AS
(SELECT (SUM(C.Credits * CLL.Grade)) / (SUM(C.Credits)) as GPA, S.StudentID, S.StudentFname, S.StudentLname
FROM tblCollege CG JOIN tblDepartment D ON CG.CollegeID=D.CollegeID
                 JOIN tblCOURSE C ON D.DeptID=C.DeptID
                 JOIN tblCLASS CL ON C.CourseID=CL.CourseID 
                 JOIN tblCLASS_LIST CLL ON CLL.ClassID=CL.ClassID
                 JOIN tblSTUDENT S ON S.StudentID = CLL.StudentID
WHERE CL.YEAR BETWEEN '1980' AND '1989'
AND CG.CollegeName='Arts and Sciences'
GROUP BY S.StudentID, S.StudentFname, S.StudentLname)

SELECT StudentID, StudentFname, StudentLname, GPA, NTILE(100) OVER(ORDER BY GPA) AS NTILE_GROUP
FROM CTE_GPA


-- Using a temp table
SELECT (SUM(C.Credits * CLL.Grade)) / (SUM(C.Credits)) as GPA, S.StudentID, S.StudentFname, S.StudentLname
INTO #temp_ntile_table
FROM tblCollege CG JOIN tblDepartment D ON CG.CollegeID=D.CollegeID
                 JOIN tblCOURSE C ON D.DeptID=C.DeptID
                 JOIN tblCLASS CL ON C.CourseID=CL.CourseID 
                 JOIN tblCLASS_LIST CLL ON CLL.ClassID=CL.ClassID
                 JOIN tblSTUDENT S ON S.StudentID = CLL.StudentID
WHERE CL.YEAR BETWEEN '1980' AND '1989'
AND CG.CollegeName='Arts and Sciences'
GROUP BY S.StudentID, S.StudentFname, S.StudentLname

SELECT StudentID, StudentFname, StudentLname, GPA, NTILE(100) OVER(ORDER BY GPA) AS NTILE_GROUP
FROM #temp_ntile_table

-- Using a table variable
DECLARE @NTILE_TABLE_VAR TABLE (
    GPA NUMERIC(3,2) NOT NULL,
    StudentID INT NOT NULL,
    StudentFname VARCHAR(50),
    StudentLname VARCHAR(50)
)
INSERT INTO @NTILE_TABLE_VAR (GPA, StudentID, StudentFname, StudentLname)
SELECT (SUM(C.Credits * CLL.Grade)) / (SUM(C.Credits)) as GPA, S.StudentID, S.StudentFname, S.StudentLname
FROM tblCollege CG JOIN tblDepartment D ON CG.CollegeID=D.CollegeID
                 JOIN tblCOURSE C ON D.DeptID=C.DeptID
                 JOIN tblCLASS CL ON C.CourseID=CL.CourseID 
                 JOIN tblCLASS_LIST CLL ON CLL.ClassID=CL.ClassID
                 JOIN tblSTUDENT S ON S.StudentID = CLL.StudentID
WHERE CL.YEAR BETWEEN '1980' AND '1989'
AND CG.CollegeName='Arts and Sciences'
GROUP BY S.StudentID, S.StudentFname, S.StudentLname

SELECT StudentID, StudentFname, StudentLname, GPA, NTILE(100) OVER(ORDER BY GPA) AS NTILE_GROUP
FROM @NTILE_TABLE_VAR