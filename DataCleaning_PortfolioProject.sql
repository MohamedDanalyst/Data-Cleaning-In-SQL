/*

-- Cleaning Data in SQL Queries

*/

select * 
from NashvilleHousing
where PropertyAddress is null


-- Standarize Date Format

select NashvilleHousing.SaleDateConverted, convert(date, SaleDate)
from NashvilleHousing

alter table NashvilleHousing
add saledateconverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

-- Prepare Property Address Data

select a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID,
isnull(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


-- Breaking out address into individual columns (address, city, state) using substring

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as address

from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

-- Breaking out address into individual columns (address, city, state) using parsename


select 
parsename(replace(OwnerAddress, ',','.'), 3),
parsename(replace(OwnerAddress, ',','.'), 2),
parsename(replace(OwnerAddress, ',','.'), 1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',','.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = parsename(replace(OwnerAddress, ',','.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',','.'), 1)


-- change y and n to yes and no in "sold as vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)

from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
END
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
END



-- remove duplications

with RowNumCTE as (

select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					uniqueID
					) row_num
from NashvilleHousing
--order by ParcelID
)
select * from RowNumCTE
where row_num >1
order by propertyaddress


-- Delete Unused Columns

select top 100 *
from NashvilleHousing

alter table nashvillehousing
drop column SaleDate, PropertyAddress, TaxDistrict, OwnerAddress



