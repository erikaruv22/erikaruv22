--cleaing  data in SQL Queries

select *
from portfolioproject.dbo.NashvilleHousing

--standardize date fromat

select SaleDateConverted, convert(Date,SaleDate)
from portfolioproject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
SET	SaleDateConverted = convert(Date,SaleDate)


--populate property address data

select *
from portfolioproject.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject.dbo.NashvilleHousing a
join portfolioproject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject.dbo.NashvilleHousing a
join portfolioproject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--breaking out Address into individual columns (Address, City, State)

select PropertyAddress
from portfolioproject.dbo.NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , len(PropertyAddress)) as Address

from portfolioproject.dbo.NashvilleHousing


ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update portfolioproject.dbo.NashvilleHousing
SET	PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

update portfolioproject.dbo.NashvilleHousing
SET	PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , len(PropertyAddress)) 






select *
from portfolioproject.dbo.NashvilleHousing


select OwnerAddress
from portfolioproject.dbo.NashvilleHousing

select

parsename(replace(OwnerAddress, ',', '.') ,3)
,parsename(replace(OwnerAddress, ',', '.') ,2)
,parsename(replace(OwnerAddress, ',', '.') ,1)

from portfolioproject.dbo.NashvilleHousing

ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update portfolioproject.dbo.NashvilleHousing
SET	OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.') ,3)

ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update portfolioproject.dbo.NashvilleHousing
SET	OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.') ,2)

ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

update portfolioproject.dbo.NashvilleHousing
SET	OwnerSplitState = parsename(replace(OwnerAddress, ',', '.') ,1)


select *
from portfolioproject.dbo.NashvilleHousing






-- change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant), count(SoldAsVacant)
from portfolioproject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No' 
	else SoldAsVacant
	end
from portfolioproject.dbo.NashvilleHousing

update portfolioproject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No' 
	else SoldAsVacant
	end




--remove duplicates

with rownumCTE AS(
select *
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num

from portfolioproject.dbo.NashvilleHousing
--order by ParcelID 
)
delete 
from RowNumCTE
where Row_Num > 1
--order by PropertyAddress





--delete unused columns


select *
from portfolioproject.dbo.NashvilleHousing

alter table portfolioproject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table portfolioproject.dbo.NashvilleHousing
drop column SaleDate


