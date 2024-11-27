Select *
From PortoflioProject..Housing

-- Sales date 
Select SaleDate
From PortoflioProject..Housing

Alter table Housing  
Alter column SaleDate date;
-- SaleDate before fixing was a datetime data type

-- Property address

--Select PropertyAddress
--from PortoflioProject..Housing
--where PropertyAddress is null

--Select i.ParcelID, i.PropertyAddress, ii.ParcelID, ii.PropertyAddress, ISNULL(i.PropertyAddress,ii.PropertyAddress)
--from PortoflioProject..Housing i
--Join PortoflioProject..Housing ii
--	on i.ParcelID= ii.ParcelID and i.[UniqueID ]<>ii.[UniqueID ]
--where i.PropertyAddress is null

update  i
set PropertyAddress = ISNULL(i.PropertyAddress,ii.PropertyAddress)
from PortoflioProject..Housing i
Join PortoflioProject..Housing ii
	on i.ParcelID= ii.ParcelID and i.[UniqueID ]<>ii.[UniqueID ]
where i.PropertyAddress is null

--	dividing address into seperate coulmns 

-- Proberty address
--Select PropertyAddress
--from PortoflioProject..Housing

--select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) Address,
--	   SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) City
--from PortoflioProject..Housing

Alter table housing
add Addressplit Nvarchar(255);

update Housing
set Addressplit = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table housing
add Citysplit Nvarchar(255);

update Housing
set Citysplit = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
from PortoflioProject..Housing

-- Owner address 
--select OwnerAddress
--from PortoflioProject..Housing

--select PARSENAME(REPLACE(OwnerAddress,',','.'),3) address	,
--	   PARSENAME(REPLACE(OwnerAddress,',','.'),2) City,
--	   PARSENAME(REPLACE(OwnerAddress,',','.'),1) state
--from PortoflioProject..Housing

alter table housing
add OwnerAddressplit nvarchar(255),
	OwnerCiry nvarchar(255),
	OwnerState nvarchar(255);

update Housing
set OwnerAddressplit = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerCiry = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from PortoflioProject..Housing

--alter table housing 
--drop column PropertyAddress, OwnerAddress;  this drop was done after successfully splitting both PropertyAddress and OwnerAddress
--exec sp_rename 'housing.OwnerAddressplit','OwnerAdress','COLUMN';
--exec sp_rename 'housing.OwnerCiry','OwnerCity','COLUMN';
--exec sp_rename 'housing.Addressplit','PropertyAddress','COLUMN';
--exec sp_rename 'housing.Citysplit','PropertyCity','COLUMN';
-- this drop was done after successfully dropping both PropertyAddress and OwnerAddress

-- Sold As Vacant
select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortoflioProject..Housing 
group by SoldAsVacant
order by 2 desc
-- got four distinct values Yes , Y , NO ,N with Yes and No having highest count so will replace Y and N with Yes and No

--Select SoldAsVacant,
--CASE when SoldAsVacant = 'Y' then 'Yes'
--	 when SoldAsVacant = 'N' then 'No'
--	 else SoldAsVacant
--	 end
--from PortoflioProject..Housing

update  Housing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

-- remove doplicates

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

From PortoflioProject..Housing
--order by ParcelID
)
Select *	
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- dropping unused  data

alter table Housing
drop column TaxDistrict, SaleDate

select *
from PortoflioProject..Housing
