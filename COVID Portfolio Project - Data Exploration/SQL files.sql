SELECT *
FROM publicquerydataset.portfolio.Covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

/* SELECT
   FROM publicquerydataset.portfolio.Covid_vaccinations
   WHERE continent IS NOT NULL
   ORDER BY 3,4 */

-- Select Data that we are going to be using

SELECT location 
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
FROM publicquerydataset.portfolio.Covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country

SELECT location,
       date,
       total_cases,
       total_deaths,
       (total_deaths/total_cases)*100 AS DeathPercentage
FROM publicquerydataset.portfolio.Covid_deaths
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
FROM publicquerydataset.portfolio.Covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location,
       population,
       MAX(total_cases) AS HighestInfectionCount
       MAX (total_cases/population)*100 AS PercentPopulationInfected
FROM publicquerydataset.portfolio.Covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Popolation

SELECT location,
        MAX(CAST(total_deaths AS integer)) AS TotalDeathCount
FROM publicquerydataset.portfolio.Covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Shoing continent with the highest death count per population

SELECT continent,
        MAX(CAST(total_deaths AS integer)) AS TotalDeathCount
FROM publicquerydataset.portfolio.Covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases,
       SUM(CAST(new_deaths AS integer))AS total_deaths,
       SUM(CAST(new_deaths AS integer))/SUM(new_cases)*100 AS DeathPercentage
FROM publicquerydataset.portfolio.Covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
-- USE CTE
WITH PopvsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(integer, vac.new_vaccinations)) OVER (PARTITION BY location ORDER BY  dea.location,dea.date) AS RollingPeopleVaccinated
      --  (RollingPeopleVaccinated/population)*100
FROM publicquerydataset.portfolio.Covid_deaths dea
JOIN publicquerydataset.portfolio.Covid_vaccinations vac
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
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(integer, vac.new_vaccinations)) OVER (PARTITION BY location ORDER BY  dea.location,dea.date) AS RollingPeopleVaccinated
      --  (RollingPeopleVaccinated/population)*100
FROM publicquerydataset.portfolio.Covid_deaths dea
JOIN publicquerydataset.portfolio.Covid_vaccinations vac
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
        SUM(CONVERT(integer, vac.new_vaccinations)) OVER (PARTITION BY location ORDER BY  dea.location,dea.date) AS RollingPeopleVaccinated
      --  (RollingPeopleVaccinated/population)*100
FROM publicquerydataset.portfolio.Covid_deaths dea
JOIN publicquerydataset.portfolio.Covid_vaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3



SELECT *
FROM PercentPopulationVaccinated