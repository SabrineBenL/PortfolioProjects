-- Cleaning data in SQL Queries
Select * from [dbo].[NashvilleHousing]

-- Standardize Date format

Alter Table [dbo].[NashvilleHousing]
Add SaleDateConverted date

Update [dbo].[NashvilleHousing]
Set SaleDateConverted=convert(date, SaleDate)

Select SaleDate
from [dbo].[NashvilleHousing]

Select SaleDate, SaleDateConverted
from [dbo].[NashvilleHousing]

-- Populate Property Adress data

Select *
from [dbo].[NashvilleHousing]
--where PropertyAddress is not null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.propertyAddress)
from [dbo].[NashvilleHousing] a
Join [dbo].[NashvilleHousing] b
 on a.ParcelID= b.ParcelID
 AND a.UniqueID <> b.UniqueID
 Where a.PropertyAddress is null

 Update a
 Set PropertyAddress = isnull(a.PropertyAddress, b.propertyAddress)
 from [dbo].[NashvilleHousing] a
Join [dbo].[NashvilleHousing] b
 on a.ParcelID= b.ParcelID
 AND a.UniqueID <> b.UniqueID
 Where a.PropertyAddress is null


 -- Breaking out Address info Individual Columns (Address, City, State)

 Select PropertyAddress
 from [dbo].[NashvilleHousing]


 Select
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
 ,SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress)) as Address
 From [dbo].[NashvilleHousing]


Alter Table [dbo].[NashvilleHousing]
Add PropertySplitAddress nvarchar(255)

Update [dbo].[NashvilleHousing]
Set PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table [dbo].[NashvilleHousing]
Add PropertySplitbyCity nvarchar(255)

Update [dbo].[NashvilleHousing]
Set PropertySplitbyCity=SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress))

Select owneraddress from [dbo].[NashvilleHousing]

Select
Parsename(replace(owneraddress,',','.') ,3)
,Parsename(replace(owneraddress,',','.') ,2)
,Parsename(replace(owneraddress,',','.') ,1)
From [dbo].[NashvilleHousing]

Alter Table [dbo].[NashvilleHousing]
Add Ownersplitaddress nvarchar(255)

Update [dbo].[NashvilleHousing]
Set Ownersplitaddress =Parsename(replace(owneraddress,',','.') ,3)


Alter Table [dbo].[NashvilleHousing]
Add OwnerSplitCity nvarchar(255)

Update [dbo].[NashvilleHousing]
Set OwnerSplitCity=Parsename(replace(owneraddress,',','.') ,2)

Alter Table [dbo].[NashvilleHousing]
Add Ownersplitstate nvarchar(255)

Update [dbo].[NashvilleHousing]
Set Ownersplitstate=Parsename(replace(owneraddress,',','.') ,1)


-- Change Y and N to Yes and No in "Sold as vacant" field
Select distinct (SoldAsVacant), count(SoldAsVacant)
from [dbo].[NashvilleHousing]
Group by SoldAsVacant
order by 2 

Select SoldAsVacant
, CASE when SoldAsVacant='Y' then 'Yes'
	   when SoldAsVacant='N' then 'No'
	   ELSE SoldAsVacant
	   END
from [dbo].[NashvilleHousing]

Update [dbo].[NashvilleHousing]
Set SoldAsVacant=CASE when SoldAsVacant='Y' then 'Yes'
	   when SoldAsVacant='N' then 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates
With RowNumCTE AS(
Select *,
	ROW_NUMBER() over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num

from [dbo].[NashvilleHousing]
--order by ParcelID
)

-- Remove duplicates

Delete from RowNumCTE
Where row_num > 1 
--order by PropertyAddress

-- Delete Unused Columns
Select * 
from [dbo].[NashvilleHousing]

Alter table [dbo].[NashvilleHousing]
Drop Column owneraddress, TaxDistrict, PropertyAddress

Alter table [dbo].[NashvilleHousing]
Drop Column Saledate

