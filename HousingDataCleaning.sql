--Clean Data Project


SELECT *
FROM Project..NashvilleHousing



--Standardize Date Format

SELECT SaleDateConv, CONVERT(Date,SaleDate)
FROM Project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConv Date;

UPDATE NashvilleHousing
SET SaleDateConv = CONVERT(Date,SaleDate)


--Populating the proper addres


SELECT *
FROM Project..NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project..NashvilleHousing as a
JOIN Project..NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project..NashvilleHousing as a
JOIN Project..NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking out address as Street, City


SELECT PropertyAddress
FROM Project..NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
FROM Project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT *
FROM Project..NashvilleHousing


SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerStreet nvarchar(255);
UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCity nvarchar(255);
UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255);
UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)





--Yes and No ? Y/N


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project..NashvilleHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM Project..NashvilleHousing


UPDATE Project..NashvilleHousing
SET 
	SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END



--Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate
				 ORDER BY 
					UniqueID
					) ROW_NUM
FROM Project..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1


--UNUSED COLUMNS

SELECT *
FROM Project..NashvilleHousing

ALTER TABLE Project..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE Project..NashvilleHousing
DROP COLUMN SaleDate