--Select location, date, total_cases, new_cases, total_deaths, population
--From CovidDeaths
--order by 1,2

--Turkey table

SELECT Location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From CovidDeaths
Where location like 'Turkey'
ORDER BY 1,2

-- Only the total cases in Turkey

SELECT Location, date, total_cases, population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as CasePercentage
From CovidDeaths
Where location like 'Turkey' and total_cases is not null
ORDER BY 1,2

-- General

SELECT Location, date, total_cases, population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as CasePercentage
From CovidDeaths
Where total_cases is not null
ORDER BY 1,2

-- Max perc of cases

Select Location, population, MAX(total_cases) as HighInfCount, 
MAX(total_cases)/(population)*100 InfectedPerc
From CovidDeaths
GROUP BY location, population
ORDER BY InfectedPerc DESC

--Highest death percentage

SELECT Location, population, MAX(total_deaths) as MaxDeaths, 
MAX(total_deaths)/(population)*100 as HighestDeathPerc
From CovidDeaths
GROUP BY location, population
ORDER BY HighestDeathPerc DESC

-- Highest death counts

SELECT Location, MAX(cast (total_deaths as int)) as MaxDeaths 
From CovidDeaths
GROUP BY location
ORDER BY MaxDeaths DESC

--Only the countries

SELECT Location, MAX(cast (total_deaths as int)) as MaxDeaths 
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY MaxDeaths DESC

-- Death counts at continents

SELECT location, MAX(cast (total_deaths as int)) as MaxDeaths 
FROM CovidDeaths
WHERE continent is null
GROUP BY location -- the continents are listed as countries in the dataset
ORDER BY MaxDeaths DESC


-- Highest death count on populations for every continent

SELECT Location, MAX(cast (total_deaths as int)) as MaxDeaths 
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY MaxDeaths DESC


--GLOBAL NUMBERS


SELECT date,
	SUM(cast (new_deaths as int)) as Deaths,
	SUM(cast (new_cases as int)) as Cases
FROM CovidDeaths
WHERE continent is not null and new_deaths is not null
GROUP BY date
ORDER BY date DESC


--
--Vaccinations part
--


--Total populations vs vaccinations

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
FROM CovidDeaths as deaths
JOIN CovidVaccinations$ as vacc
	ON deaths.location = vacc.location
	and vacc.date = deaths.date
WHERE deaths.continent is not null 
and vacc.new_vaccinations is not null
ORDER BY location

--

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
FROM CovidDeaths as deaths
JOIN CovidVaccinations$ as vacc
	ON deaths.location = vacc.location
	and vacc.date = deaths.date
WHERE deaths.continent is not null 
and vacc.new_vaccinations is not null
ORDER BY location

--

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
	, SUM(CAST (vacc.new_vaccinations AS BIGINT)) OVER (PARTITION BY deaths.location ORDER BY deaths.location
	,deaths.date) AS TotalVaccinations
FROM CovidDeaths as deaths
JOIN CovidVaccinations$ as vacc
	ON deaths.location = vacc.location
	and vacc.date = deaths.date
WHERE deaths.continent is not null 
and vacc.new_vaccinations is not null
ORDER BY location

--TEMP for above

DROP TABLE IF EXISTS #PercentagePopulationVacc
CREATE TABLE #PercentagePopulationVacc
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
TotalVaccinations numeric
)

INSERT INTO #PercentagePopulationVacc
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
	, SUM(CAST (vacc.new_vaccinations AS BIGINT)) OVER (PARTITION BY deaths.location ORDER BY deaths.location
	,deaths.date) AS TotalVaccinations
	FROM CovidDeaths as deaths
	JOIN CovidVaccinations$ as vacc
		ON deaths.location = vacc.location
	and vacc.date = deaths.date
	WHERE deaths.continent is not null 
	and vacc.new_vaccinations is not null

SELECT  Location, (TotalVaccinations/population)*100 AS PercentageVaccinated
FROM #PercentagePopulationVacc



--CTE for above

WITH PopsvsVacc (Continent, Location, Date, Population, New_vaccinations, TotalVaccinations)
	as
	(
	SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
	, SUM(CAST (vacc.new_vaccinations AS BIGINT)) OVER (PARTITION BY deaths.location ORDER BY deaths.location
	,deaths.date) AS TotalVaccinations
	FROM CovidDeaths as deaths
	JOIN CovidVaccinations$ as vacc
		ON deaths.location = vacc.location
	and vacc.date = deaths.date
	WHERE deaths.continent is not null 
	and vacc.new_vaccinations is not null
	)
SELECT *, (TotalVaccinations/population)*100 AS PercentageVaccinated
FROM PopsvsVacc
ORDER BY PercentageVaccinated DESC

--VIEW TO TABLEAU

CREATE VIEW PercentagePopulationVacc2 as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
	, SUM(CAST (vacc.new_vaccinations AS BIGINT)) OVER (PARTITION BY deaths.location ORDER BY deaths.location
	,deaths.date) AS TotalVaccinations
	FROM CovidDeaths as deaths
	JOIN CovidVaccinations$ as vacc
		ON deaths.location = vacc.location
	and vacc.date = deaths.date
	WHERE deaths.continent is not null 
	and vacc.new_vaccinations is not null
