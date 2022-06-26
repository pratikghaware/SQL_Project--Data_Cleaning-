select * 
from [data_clening ]..sheet


-- Observation in data - 
--				1.  in this data 'propertyAddress' is contain address and city name. if city name and address is in differant
--					columns that will better for visualization in Tablueau or Power BI and clean to look. 
--              2.  sale date contain date and time but time is zero not specified also time is not that important data by 
--					obervation or for visualization. so i will remove time from sale date. 

--in further obervation we will look into data whcih will important and try to clean it. like removing duplicates. 

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Cleaning Date and Time. 

--sale date contain date and time but time is zero not specified also time is not that important data by 
--obervation or for visualization. so i will remove time from sale date. 

select SaleDate
from [data_clening ]..Sheet

-- converting __>

select SaleDate, CONVERT(date, SaleDate)
from [data_clening ]..Sheet					 -- Convert into Date 
 
update Sheet
set SaleDate = CONVERT(date, SaleDate)		 -- Update into Data Sheet 

select SaleDate
from [data_clening ]..Sheet					 -- Not Converted 


-- from Upeer Querys i am trying to convert date and time into just date but it is not updateing. 
-- so Now i will create a new column and drop date and time column. 


-- Making New Column. -- > 
alter table sheet 
add Converted_date Date;   -- Adding table 

update Sheet
set Converted_date = CONVERT(Date, SaleDate)	 -- Updateing into new table 

select *
from [data_clening ]..Sheet		-- checking new column added or not with data. 

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--Populate Property Address Data. 

-- By looking at the data i found that some address having same ParsalID and Address and Owner Name but they are
--		 not filled there data. ...(( It is very hard to explain by word and complex to Understand)) 
-- Bacislly I fillded the Address by checking where it have same owner and ParselID. 


select *
from [data_clening ]..Sheet
where PropertyAddress is null 
order by ParcelID						-- Checking Null Values 

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [data_clening ]..Sheet a
join [data_clening ]..Sheet b
	on a.ParcelID = b.ParcelID
	and b.[UniqueID ] <> a.[UniqueID ]
where a.PropertyAddress is null			-- Creating Joints and how many dont have Address. 

update a
set  a.PropertyAddress = ISNULL( a.PropertyAddress,  b.PropertyAddress)
from [data_clening ]..Sheet a
join [data_clening ]..Sheet b
	on a.ParcelID = b.ParcelID
	and b.[UniqueID ] <> a.[UniqueID ]   -- Updating into PropertyAddress.

select *
from [data_clening ]..Sheet
where PropertyAddress is null			-- Sheet Updated no NUll values. 



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- Breaking Address into ( ADDRESS , CITY , STATE ) 

select PropertyAddress
from [data_clening ].. Sheet


select 
SUBSTRING (PropertyAddress, 1, CHARINDEX( ',', PropertyAddress)- 1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX( ',', PropertyAddress)+ 1, len(PropertyAddress)) as City 
from [data_clening ]..Sheet


-- Explination - From above code we subtracted address and city name. 
	
--in a code what we have done is used substring -- substring is nothing but substract string,
--			   - for example SUBSTRING( MY SQL , 1, 2) so answer will be "MY". 
--in Upper Query we have given Address and starting point is started from 1 and end point will be before "," comma sign . 

-- so to find comma sign we used CHARINDEX-- it will find perticular charater which we want and it will reaturn the index. 
			-- CHARINDEX( 'char', columns name )
			-- CHARINDEX ( ',', property address) 

-- so after that i will add this columns into sheet. 

alter table data_clening..sheet 
add property_address Nvarchar(255);           -- Adding data into Chart and what should be column name and type of data str, int, date

update data_clening..sheet  
set property_address = SUBSTRING (PropertyAddress, 1, CHARINDEX( ',', PropertyAddress)- 1)		--Updating property_address data 




alter table data_clening..sheet   
add Property_city nvarchar(255);				-- Adding data into Chart and what should be column name and type of data str, int, date

update data_clening..sheet   
set Property_city = substring (PropertyAddress, CHARINDEX( ',', PropertyAddress )+ 1, len(PropertyAddress)) --Updating property_city data 



 				--- Checking sheet is Updated or Not..

-- ADDRESS AND CITY IS HAVE DIFFERANT COLUMNS WHICH IS GOOD TO ANALYZE DATA. 


--SIMILARLY I WILL CLEANE OWERNE ADDRESS. 
-- AFTER DOING SERCHING ON INTERNET THERE IS ONE MORE METHODN thorugh which we can do this which is easy then previous method. 

select 
parsename(replace(OwnerAddress,',','.'), 3) as Owner_Address,
parsename(replace(OwnerAddress,',','.'), 2) as Owner_City,
parsename(replace(OwnerAddress,',','.'), 1)  as Owner_Sates
FROM [data_clening ]..sheet


--Above Query is also one of the method through which we can saperate address city and state name . 


alter table data_clening..sheet 
add Owner_Address nvarchar(255); 

update [data_clening ]..sheet
set Owner_Address = parsename(replace(OwnerAddress,',','.'), 3)  --- updating address



alter table data_clening..sheet 
add Owner_City nvarchar(255);

update [data_clening ]..sheet
set Owner_City = parsename(replace(OwnerAddress,',','.'), 2)  --- updating city


alter table data_clening..sheet 
add Owner_state nvarchar(255);

update [data_clening ]..sheet
set Owner_state = parsename(replace(OwnerAddress,',','.'), 1) ------ updating state


select * 
from [data_clening ]..sheet 


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- Obervation -- After lokking at data i oberverd that SoldAsVacant have distict values like ( YES, NO,Y, N) so we will clean that data 

select distinct(SoldAsVacant)
from [data_clening ]..sheet


-- looking at count of this 

select distinct(SoldAsVacant), count(SoldAsVacant)
from [data_clening ]..sheet
group by SoldAsVacant
order by 2 DESC					---- looking at count of this 


-- Obervation -- by looking at count i will convert ( Y/N ) into (Yes/No) becuase its having low count 
	--				whcih will take less computation power and done faster and obvious resosen data is less. 

select SoldAsVacant
, case when SoldAsVacant = 'y' then 'Yes'
	when SoldAsVacant = 'n' then 'No' 
	when SoldAsVacant = 'Nes' then 'Yes'-- for this line before this Query i actully miss typed Yes to Mes. so i nned to add this line of code.  
	else SoldAsVacant end 
From [data_clening ]..sheet				-- Query to Convert Y and N into YES and NO. 


update [data_clening ]..sheet
set SoldAsVacant =case when SoldAsVacant = 'y' then 'Yes'
	when SoldAsVacant = 'n' then 'No' 
	when SoldAsVacant = 'Nes' then 'Yes'
	else SoldAsVacant end							-- Upadating Data


select distinct(SoldAsVacant), count(SoldAsVacant)
from [data_clening ]..sheet
group by SoldAsVacant
order by 2 DESC					---- Checking data is cleaned or nOt 


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- Removing Duplicates. 

-- Bacisly i assume ParcalID, PropertyAddress, Saleprice, SaleDate, LegalRefrance are same then we can assume data is same, ( assumtion )
with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	order by 
		uniqueID
	)row_num 

from [data_clening ]..sheet

)
select * 
from RowNumCTE
where row_num > 1
order by property_address

-- from above query i found that all data is similer even sale date , address. 
-- so i will remove this data (104) rows. becuase its repeted. 

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	order by 
		uniqueID
	)row_num 

from [data_clening ]..sheet

)
delete
from RowNumCTE
where row_num > 1								--- Deleting Rows. 
--order by property_address 


------------------------------------------checking deleted or not ( Confirmation )

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	order by 
		uniqueID
	)row_num 

from [data_clening ]..sheet

)
select * 
from RowNumCTE
where row_num > 1
order by property_address				-- (confirmation)



---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- I will remove columns which i dont need to dont feel imortant. 


select * 
from [data_clening ]..sheet


alter table [data_clening ]..sheet
drop column OwnerAddress, TaxDistrict, PropertyAddress, Owner_sates						--- Removing Owner Sates Becuase of spelling mistake. 



select * 
from [data_clening ]..sheet					-- Confirmation columns are droped or not. 


