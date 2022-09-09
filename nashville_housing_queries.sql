
/*
Data Cleaning Project
*/

SELECT *
FROM dbo.NashvilleHousing




-- Change Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM dbo.NashvilleHousing


UPDATE dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
-- this didn't work, try Alter


ALTER TABLE dbo.NashvilleHousing
ADD SaleDateConverted Date


UPDATE dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM dbo.NashvilleHousing




-- Populate Property Address Data

SELECT *
FROM dbo.NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL




-- Breaking Address into Seperate Columns (Address, City, State)

SELECT PropertyAddress
FROM dbo.NashvilleHousing
-- WHERE PropertyAddress IS NULL
-- ORDER BY ParcelID

-- Get address and city seperate
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM dbo.NashvilleHousing

-- Create and populate address and city columns
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT *
FROM dbo.NashvilleHousing




SELECT OwnerAddress
FROM dbo.NashvilleHousing


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




-- Change Y and N to Yes and No in SoldAsVacant Column

SELECT 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM dbo.NashvilleHousing


UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END




-- Remove Duplicates

WITH RowNumCTE as (
SELECT
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

FROM dbo.NashvilleHousing
-- ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress




-- Delete Unused Columns

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate


SELECT *
FROM dbo.NashvilleHousing