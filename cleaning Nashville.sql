Select * 
From Nashville

--Quitar hora de SaleDate, no cumple con ningún propósito
Alter Table Nashville
Add SaleDateConverted Date

Update Nashville 
Set SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From Nashville

Select *
From Nashville
Order by ParcelID

--Llenar campo PropertyAddress, utilizando ParcelID como referencia

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.Propertyaddress,b.PropertyAddress)
From Nashville a
Join Nashville b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
 
Update a
SET PropertyAddress = ISNULL(a.Propertyaddress,b.PropertyAddress)
From Nashville a
Join Nashville b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Eliminar ','

Select *
From Nashville
--Where PropertyAddress is null

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From Nashville

Alter Table Nashville
Add PropertySplitAddress NVARCHAR(255);

Update Nashville 
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter Table Nashville
Add PropertySplitCity NVARCHAR(255);

Update Nashville 
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress))


--OwnerAddress

Select 
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
From Nashville

Alter Table Nashville
Add OwnerSplitAddress NVARCHAR(255);

Update Nashville 
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3)

Alter Table Nashville
Add OwnerSplitCity NVARCHAR(255);

Update Nashville 
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2)

Alter Table Nashville
Add OwnerSplitState NVARCHAR(255);

Update Nashville 
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)

Select *
From Nashville

--Y, N en SoldAsVacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
From Nashville

Update Nashville
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END

--Remover columnas duplicadas
With Row_num_CTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SaleDateConverted, SalePrice, LegalReference
	Order By UniqueID) row_num
From Nashville)
DELETE
From Row_num_CTE
Where row_num > 1

--Remover columnas no usadas

Alter Table Nashville 
Drop column TaxDistrict, OwnerAddress, PropertyAddress, SaleDate

