/*
Cleaning Data in SQL Queries
*/

select*
from PortfolioProjects..[Nashville_Housing _Data_for_Data_Cleaning]
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


select saleDateconverted, convert (date, SaleDate) as updaed_date
from PortfolioProjects..[Nashville_Housing _Data_for_Data_Cleaning]

update [Nashville_Housing _Data_for_Data_Cleaning]
set SaleDate = convert (date, SaleDate) 

alter table [Nashville_Housing _Data_for_Data_Cleaning] 
add saleDateconverted date;

update [Nashville_Housing _Data_for_Data_Cleaning]
set saleDateconverted = convert (date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select PropertyAddress
from PortfolioProjects..[Nashville_Housing _Data_for_Data_Cleaning]



select a1.ParcelID, a1.PropertyAddress, b2.ParcelID, b2.PropertyAddress, Isnull(a1.PropertyAddress,b2.PropertyAddress)
from PortfolioProjects..[Nashville_Housing _Data_for_Data_Cleaning] a1
join PortfolioProjects..[Nashville_Housing _Data_for_Data_Cleaning] b2
	on  a1.ParcelID = b2.ParcelID
	and a1.[UniqueID ] <> b2.[UniqueID ]

	where a1.PropertyAddress is  null


	update a1
	Set PropertyAddress = Isnull(a1.PropertyAddress,b2.PropertyAddress)
	from PortfolioProjects..[Nashville_Housing _Data_for_Data_Cleaning] a1
join PortfolioProjects..[Nashville_Housing _Data_for_Data_Cleaning] b2
	on  a1.ParcelID = b2.ParcelID
	and a1.[UniqueID ] <> b2.[UniqueID ]
	where a1.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

from PortfolioProjects..[Nashville_Housing _Data_for_Data_Cleaning]


ALTER TABLE [Nashville_Housing _Data_for_Data_Cleaning]
Add PropertySplitAddress Nvarchar(255);

Update [Nashville_Housing _Data_for_Data_Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


alter table [Nashville_Housing _Data_for_Data_Cleaning]  
Add PropertySplitCity Nvarchar(255);

Update [Nashville_Housing _Data_for_Data_Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From PortfolioProjects..[Nashville_Housing _Data_for_Data_Cleaning]




Select OwnerAddress
From PortfolioProjects..[Nashville_Housing _Data_for_Data_Cleaning]

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProjects..[Nashville_Housing _Data_for_Data_Cleaning]


ALTER TABLE [Nashville_Housing _Data_for_Data_Cleaning]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville_Housing _Data_for_Data_Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Nashville_Housing _Data_for_Data_Cleaning]
Add OwnerSplitCity Nvarchar(255);

Update [Nashville_Housing _Data_for_Data_Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Nashville_Housing _Data_for_Data_Cleaning]
Add OwnerSplitState Nvarchar(255);

Update [Nashville_Housing _Data_for_Data_Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


























--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Nashville_Housing _Data_for_Data_Cleaning]
Group by SoldAsVacant
order by 2





Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Nashville_Housing _Data_for_Data_Cleaning]


Update [Nashville_Housing _Data_for_Data_Cleaning]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


	 




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Nashville_Housing _Data_for_Data_Cleaning]
--order by ParcelID
)
select* 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress






---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From [Nashville_Housing _Data_for_Data_Cleaning]

alter table [Nashville_Housing _Data_for_Data_Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO



