SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


SELECT *
FROM PortfolioProjects..CovidVaccinations
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows Likelyhood of dying if you are contracted by covid in Canada

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
Where location LIKE '%canada%'
ORDER BY 1,2


--Looking at Total Cases s Population
--Shows what percentage of population got covid in Canada

SELECT location,date,population,total_cases, (total_cases/population)*100 AS PercetagePopulationInfected
FROM PortfolioProjects..CovidDeaths
Where location LIKE '%canada%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercetagePopulationInfected
FROM PortfolioProjects..CovidDeaths
--Where location LIKE '%canada%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercetagePopulationInfected DESC

-- Showing countries with highest death per population 

SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeaths
FROM PortfolioProjects..CovidDeaths
--Where location LIKE '%canada%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths DESC


-- Continents with highest death count

SELECT continent,MAX(CONVERT(INT,total_deaths)) AS TotalDeaths
FROM PortfolioProjects..CovidDeaths
--Where location LIKE '%canada%'
WHERE continent IS  NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC

/*

SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeaths
FROM PortfolioProjects..CovidDeaths
--Where location LIKE '%canada%'
WHERE continent IS  NULL
GROUP BY location
ORDER BY TotalDeaths DESC
*/


--Global numbers based on date

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
--Where location LIKE '%canada%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Total Population VS Vaccination
--CTE

WITH PopvsVac(Continent,Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS (

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM PopvsVac
ORDER BY 2,3

--Total Population s Vaccination
--Temp Tables

DROP Table If exists #PopulationVaccinatedPercentage
CREATE Table #PopulationVaccinatedPercentage
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccination numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PopulationVaccinatedPercentage
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM #PopulationVaccinatedPercentage


--Creating View

CREATE View PopulationVaccinatedPercentages AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3