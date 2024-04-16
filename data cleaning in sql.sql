-- CLEANING DATA IN SQL QUERIES


select *
from PortfolioProject..NashvilleHousing

-----------------------------------------

-- 1) standardise date format

select saleDateConverted, convert (date, saledate) as newSaleDate
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, saledate)

alter table nashvillehousing
add saleDateConverted date;

update NashvilleHousing
set saleDateConverted = CONVERT(date, saledate)

select *
from PortfolioProject..NashvilleHousing


-- 2) populate property address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- 3) breaking out address into individual columns  

--a. longer way to split

select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1 , LEN(PropertyAddress)) as address
from PortfolioProject.dbo.NashvilleHousing

alter table nashvillehousing
add propertySplitAddress nvarchar(255);

update NashvilleHousing
set propertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1)

alter table nashvillehousing
add propertySplitCity nvarchar(255);

update NashvilleHousing
set propertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1 , LEN(PropertyAddress))


select *
from PortfolioProject.dbo.NashvilleHousing


-- b. simpler way to split

select OwnerAddress
from PortfolioProject..NashvilleHousing

select 
PARSENAME(replace(owneraddress, ',', '.'), 3),
PARSENAME(replace(owneraddress, ',', '.'), 2),
PARSENAME(replace(owneraddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

-- i. for parsename 3
alter table nashvillehousing
add ownerSplitAddress nvarchar(255);

update NashvilleHousing
set ownerSplitAddress = PARSENAME(replace(owneraddress, ',', '.'), 3)

-- ii. for parsename 2
alter table nashvillehousing
add ownerSplitCity nvarchar(255);

update NashvilleHousing
set ownerSplitCity = PARSENAME(replace(owneraddress, ',', '.'), 2)

-- iii. for parsename 1
alter table nashvillehousing
add ownerSplitState nvarchar(255);

update NashvilleHousing
set ownerSplitState = PARSENAME(replace(owneraddress, ',', '.'), 1)


select *
from PortfolioProject..NashvilleHousing

-- 4) change y and n to yes and no in "sold as vacant" field

select distinct(SoldAsVacant), count(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case	when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject..NashvilleHousing

-- a. update to count the number of yes and no
update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end


-- 5) remove duplicates

with rowNumCTE as(
select *, 
	ROW_NUMBER() 
	over (
	partition by parcelID,
				 propertyAddress,
				 salePrice,
				 saleDate,
				 legalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
/*
delete
from rowNumCTE
where row_num > 1
*/

select *
from rowNumCTE
where row_num > 1
--order by PropertyAddress

select *
from PortfolioProject..NashvilleHousing

-- 6) delete unused columns

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table PortfolioProject..NashvilleHousing
drop column saledate