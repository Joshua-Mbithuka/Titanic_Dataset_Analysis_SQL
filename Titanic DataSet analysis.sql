/* Understand your data set first*/
Select top(5) * from dbo.titanic


SELECT COUNT(*) AS total_rows
FROM dbo.titanic;
--from this data, i'm interested in analysis based on this columns Survived, Sex, Age, Pclass
---we will rename the column Embarked to Boarding destination for better understanding */
EXEC sp_rename 'titanic.Embarked', 'Boarding_Destination', 'COLUMN';


---understand column type using information schema
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'titanic' 

---Dive into analysis

--- how many people survived the titanic
SELECT COUNT(*) FROM dbo.titanic
WHERE Survived = 1

-- No of men who survived during the titanic
Select COUNT(Sex) FROM dbo.titanic
Where Survived = 1 AND Sex = 'male'  --109 men survived the titanic out of the total population

--no of women who survived the titanic
Select COUNT(Sex) FROM dbo.titanic
Where Survived = 1 AND Sex = 'female'  --233 men survived the titanic out of the total population

---To find the percentages I will need to first declare  Scalar Variables to hold the datas
Declare @Men FLOAT =  (Select COUNT(Sex) FROM dbo.titanic AS male Where Survived = 1 AND Sex = 'male')
Declare @Women FLOAT =  (Select COUNT(Sex) FROM dbo.titanic AS male Where Survived = 1 AND Sex = 'female')
Declare @total FLOAT = (SELECT COUNT(Sex) FROM dbo.titanic  AS total WHERE Survived = 1)

---------------finding the percetage of men who survived
Declare @AVG_MEN FLOAT = 100* @Men/@total
print(@AVG_MEN)

Declare @AVG_Women FLOAT = 100* @Women/@total
print(@AVG_Women)

-----from the above a larger number of women survived


----Lets now Dive into data cleaning
---we are not interested in the Cabin column ticket and Fare. I will drop them
ALTER TABLE titanic
DROP COLUMN Cabin, Fare, Ticket


--- from our data we can see null values on AGE Column, We will replace this with the average age of the people in the crew.
UPDATE dbo.titanic
set Age = (select AVG(Age) from dbo.titanic)
Where Age is null



----let's see the values now
Select *
FROM dbo.titanic

----The null Values have been corrected but they have decimal places. Let's correct that

UPDATE dbo.titanic
set Age = ROUND(Age, 0) 


------now that we have this data we can find out the following
---1.Which Passenger class had the highest number of survivors
Select COUNT(Pclass) FROM dbo.titanic WHERE Survived = 1 AND Pclass = 1
   
DECLARE @P1Class INT, @P2Class INT, @P3Class INT

SELECT @P1Class = COUNT(*) 
FROM dbo.titanic 
WHERE Survived = 1 AND Pclass = 1


SELECT @P2Class = COUNT(*) 
FROM dbo.titanic 
WHERE Survived = 1 AND Pclass = 2


SELECT @P3Class = COUNT(*) 
FROM dbo.titanic 
WHERE Survived = 1 AND Pclass = 3


IF @P1Class > @P2Class AND @P1Class > @P3Class
    BEGIN
        PRINT('Pclass 1 had the most survivors which are: ' + CAST(@P1Class AS NVARCHAR(10)))
    END

ELSE IF @P2Class > @P1Class AND @P2Class > @P3Class
    BEGIN
        PRINT('Pclass 2 had the most survivors which are: ' + CAST(@P2Class AS NVARCHAR(10)))
    END

ELSE IF @P3Class > @P1Class AND @P3Class > @P2Class
    BEGIN
        PRINT('Pclass 3 had the most survivors which are: ' + CAST(@P3Class AS NVARCHAR(10)))
    END
ELSE
    BEGIN
        PRINT('No clear winner among the passenger classes')
    END

---The Age demographics of Survivors
---Number of Kids that survived
Select count(*) as ADULTS
FROM dbo.titanic
where Survived = 1 and Age > = 18

---Number of Adults that survived
Select count(*) as Kids
FROM dbo.titanic
where Survived = 1 and Age <18

----Order By Age in Descending order
Select *
FROM dbo.titanic
where Boarding_Destination IS NOT NULL 
Order by Age DESC

----------The oldest Survivor on the boat
Select *
FROM dbo.titanic
where Survived = 1
AND Age= (Select MAX(Age) from dbo.titanic)

----------The Youngest Survivor on the boat
Select *
FROM dbo.titanic
where Survived = 1
AND Age= (Select MIN(Age) from dbo.titanic)


------------Finnally we create a view we can use for
CREATE VIEW Transformed_data AS  
Select PassengerId, Survived, Pclass, Name, Sex,  Round(Age, 0) AS Age, Boarding_Destination
FROM dbo.titanic
where Boarding_Destination IS NOT NULL
