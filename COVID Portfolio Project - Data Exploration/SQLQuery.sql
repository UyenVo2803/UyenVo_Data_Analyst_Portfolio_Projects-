/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT *
FROM PortfolioProject..Covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

/* SELECT *
   FROM PortfolioProject..Covid_vaccinations
   WHERE continent IS NOT NULL
   ORDER BY 3,4 */

-- Select Data that we are going to be using

SELECT location 
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
FROM PortfolioProject..Covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country

SELECT location,
       date,
       total_cases,
       total_deaths,
       (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..Covid_deaths
WHERE location like '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location,
       date,
       total_cases,
       population,
       (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..Covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location,
       population,
       MAX(total_cases) AS HighestInfectionCount,
       MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..Covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Popolation

SELECT location,
        MAX(CAST(total_deaths AS integer)) AS TotalDeathCount
FROM PortfolioProject..Covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continent with the highest death count per population

SELECT continent,
        MAX(CAST(total_deaths AS integer)) AS TotalDeathCount
FROM PortfolioProject..Covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases,
       SUM(CAST(new_deaths AS int))AS total_deaths,
       SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..Covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated