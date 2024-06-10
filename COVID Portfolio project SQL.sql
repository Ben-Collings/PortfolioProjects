SELECT *
FROM PortfolioProject.dbo.CovidDeaths1
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccines
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths1
ORDER BY 1,2;

ALTER TABLE CovidVaccines
ALTER COLUMN date date;

ALTER TABLE CovidDeaths1
ALTER COLUMN total_deaths float;

ALTER TABLE CovidDeaths1
ALTER COLUMN total_cases float;

ALTER TABLE CovidDeaths1
ALTER COLUMN date date;

ALTER TABLE CovidDeaths1
ALTER COLUMN population float;

SELECT * 
FROM PortfolioProject..CovidDeaths1
WHERE total_cases = 0;

--Looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)* 100,2) as DeathPercentage
FROM PortfolioProject..CovidDeaths1
WHERE total_cases <> 0 AND continent <> ' '
ORDER BY location, date;

--Looking at total cases vs population

SELECT location, date, total_cases, population, ROUND((total_cases/population)* 100,2) as PopulationInfected
FROM PortfolioProject..CovidDeaths1
WHERE population <> 0 AND continent <> ' '
ORDER BY location, date;

--Looking at countries with highest infection rates

SELECT location, MAX(total_cases) as HighestInfectionCount, population, ROUND(MAX((total_cases/population)* 100),2) as PercentInfected
FROM PortfolioProject..CovidDeaths1
WHERE population <> 0 AND continent <> ' '
GROUP BY Location, population
ORDER BY PercentInfected DESC;


--Looking at how many people hva died by country

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths1
WHERE continent <> ' '
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Breaking it down by continent

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths1
WHERE continent = ' '
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Global Numbers

SELECT date, SUM(cast(new_cases as int)) AS TotalCases, SUM(cast(new_deaths as float)) AS TotalDeaths, 
	ROUND(SUM(cast(new_deaths as float))/SUM(cast(new_cases as int))*100, 2) AS DeathPercentage  
FROM PortfolioProject..CovidDeaths1
WHERE continent <> ' ' AND new_cases <> 0
GROUP BY date
ORDER BY 1,2;

--Looking at Total Pop Vs Vaccinations

SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths1 AS dea
JOIN PortfolioProject..CovidVaccines AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent <> ' '
ORDER BY 2,3;

--CTE 

WITH PopVsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths1 AS dea
JOIN PortfolioProject..CovidVaccines AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent <> ' '
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac
WHERE population <> 0

-- Creating a view to store data for later vizualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS Float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths1 AS dea
JOIN PortfolioProject..CovidVaccines AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ' ' 

SELECT *
FROM PercentPopulationVaccinated
