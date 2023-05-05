
select *
from PortfolioProject.dbo.NVHouses

--Custormising Date Format
select SaleDateConverted, convert(Date, SaleDate)
from PortfolioProject.dbo.NVHouses

update NVHouses
set SaleDate = convert(Date,SaleDate)

alter table NVHouses
add SaleDateConverted Date;

update NVHouses
set SaleDateConverted = convert(Date, SaleDate)

--Property address data populating
select *
from PortfolioProject.dbo.NVHouses
where PropertyAddress is null
order by ParcelID

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NVHouses a
join PortfolioProject.dbo.NVHouses b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is not null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NVHouses a
join PortfolioProject.dbo.NVHouses b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Dividing the PropertyAddress into sub columns (Address, city, state) using substring & Charindex

select PropertyAddress
from PortfolioProject.dbo.NVHouses
--where PropertyAddress is null
--order by ParcelID

select
substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address
,substring(PropertyAddress, charindex(',',PropertyAddress) +1,len(PropertyAddress))

from PortfolioProject.dbo.NVHouses

alter table NVHouses
add PropertySplitAddress nvarchar(250);

update NVHouses
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1)

alter table NVHouses
add PropertySplitCity nvarchar(250);

update NVHouses
set PropertySplitCity = substring(PropertyAddress, charindex(',',PropertyAddress) +1,len(PropertyAddress))

select *
from PortfolioProject.dbo.NVHouses

--owner address using parsename

select OwnerAddress
from PortfolioProject.dbo.NVHouses

select 
parsename(replace(OwnerAddress, ',', '.'),3) as Address
,parsename(replace(OwnerAddress, ',', '.'),2) as City
,parsename(replace(OwnerAddress, ',', '.'),1) as State
from PortfolioProject.dbo.NVHouses

alter table NVHouses
add OwnerSplitAddress nvarchar(250);

update NVHouses
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'),3)

alter table NVHouses
add OwnerSplitCity nvarchar(250);

update NVHouses
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'),2)

alter table NVHouses
add OwnerSplitState nvarchar(250);

update NVHouses
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'),1)

select *
from PortfolioProject.dbo.NVHouses

-- Fixing soldasvacant format to only yes and no 

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NVHouses
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant= 'Y' then 'Yes'
       when	SoldAsVacant= 'N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject.dbo.NVHouses

update NVHouses
set SoldAsVacant = case when SoldAsVacant= 'Y' then 'Yes'
       when	SoldAsVacant= 'N' then 'No'
	   else SoldAsVacant
	   end 

--Remove Duplicates
with RowNumCTE as (
select *,
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num

from PortfolioProject.dbo.NVHouses
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1

--Delete unused data

alter table PortfolioProject.dbo.NVHouses
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NVHouses
drop column SaleDate
