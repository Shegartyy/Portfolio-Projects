SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

--Selecting data we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2

-- Total Cases vs Population
SELECT location, date, population, total_cases, (Total_cases/population)*100 CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%canada%'
ORDER BY 1, 2

-- Countries with highest infection rate vs population
SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX((Total_cases/population))*100 InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

-- Countries with highest amount of deaths
SELECT location, MAX(CAST(total_deaths AS INT)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location LIKE '%canada%'
GROUP BY location
ORDER BY 2 DESC;


-- Continent
--SELECT location, MAX(CAST(total_deaths AS INT)) TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NULL
---- WHERE location LIKE '%canada%'
--GROUP BY location
--ORDER BY 2 DESC;

SELECT continent, MAX(CAST(total_deaths AS INT)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location LIKE '%canada%'
GROUP BY continent
ORDER BY 2 DESC;


--Continents with the highest death count

--SELECT location, MAX(CAST(total_deaths AS INT)) TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NULL
---- WHERE location LIKE '%canada%'
--GROUP BY location
--ORDER BY 2 DESC;


SELECT continent, MAX(CAST(total_deaths AS INT)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location LIKE '%canada%'
GROUP BY continent
ORDER BY 2 DESC;


-- Global Numbers including death percentage against cases
SELECT SUM(new_cases) Total_Cases, SUM(CAST(new_deaths AS INT)) Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


-- Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rolling_Total_Vaccinations
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- CTE
WITH VacVSPop (Continent, Location, Date, Population, New_Vaccinations, Rolling_Total_Vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rolling_Total_Vaccinations
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (Rolling_Total_Vaccinations/Population)*100 RollingPercentagePopVacc
FROM VacVSPop

-- Temp Table
DROP TABLE IF EXISTS #VacVSPopVaccinated
CREATE TABLE #VacVSPopVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Total_Vaccinations numeric
)

INSERT INTO #VacVSPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rolling_Total_Vaccinations
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM #VacVSPopVaccinated



-- Views for Visualization
CREATE VIEW VacVSPopVaccinated
AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rolling_Total_Vaccinations
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM VacVSPopVaccinated

-- 

SELECT location, MAX(CAST(total_deaths AS INT)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
-- WHERE location LIKE '%canada%'
GROUP BY location
ORDER BY 2 DESC;

-- 

SELECT location, MAX(CAST(total_deaths AS INT)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location LIKE '%canada%'
GROUP BY location
ORDER BY 2 DESC;

--

SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX((Total_cases/population))*100 InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;