-- Database - PortfolioProject
-- Tables - i) CovidDeaths$  ii)  CovidVaccinations



SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL  -- So that Location(Country) don't show the name of Continent where the value of continent is NULL
order by 3,4  --Location and Date

--SELECT *Select 
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Total cases vs population

SELECT Location, date, total_cases, new_cases, total_deaths, [ population]
FROM PortfolioProject..CovidDeaths$
order by 1, 2


--Shows liklihood of dying if you contract covid in your country
 SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE location like'%india%'
order by 1, 2

--Looking at Countries with Highest infection rate compared to population
SELECT Location, date, total_cases, new_cases, total_deaths,[ population], (total_cases/[ population])*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
order by 1, 2

-- Looking at countries with highest Infection Rate compared to population
SELECT Location, [ population], MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/[ population]))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY Location, [ population]
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count
SELECT Location, MAX( cast(total_deaths as int) ) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- Let's Break things by Continent

--Showing the Continent with Highest Death Counts
SELECT continent, MAX( cast(total_deaths as int) ) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(CAST(new_deaths as int))/sum(new_cases) *100 as DeathPerecentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
order by 1, 2

--New Cases vs Deaths by Date (GLOBAL NUMBERS)
SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(CAST(new_deaths as int))/sum(new_cases) *100 as DeathPerecentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
order by 1, 2

--Looking at Total Population vs Vacccinations
SELECT ded.continent, ded.location, ded.date, ded.[ population], vac.new_vaccinations
, SUM( CAST (vac.new_vaccinations AS INT)) OVER(PARTITION BY ded.location ORDER BY 
  ded.location, ded.date) AS TotalPeopleVaccinated
 -- , (TotalPeopleVaccinated/[ population])*100

FROM PortfolioProject..CovidDeaths$ ded
JOIN PortfolioProject..CovidVaccinations vac
	ON ded.location=vac.location
	AND ded.date = vac.date
WHERE ded.continent is NOT NULL
ORDER BY 2, 3



--Percent of people getting vaccinated 
--We can do it using two method : i) Using CTE		ii)Using Temp Table

--i) Using CTE

WITH PopvsVac (continent, Location, Date , Population, new_vaccinations, TotalPeopleVaccinated)
AS
(
SELECT ded.continent, ded.location, ded.date, ded.[ population], vac.new_vaccinations
, SUM( CAST (vac.new_vaccinations AS INT)) OVER(PARTITION BY ded.location ORDER BY 
  ded.location, ded.date) AS TotalPeopleVaccinated
 -- , (TotalPeopleVaccinated/[ population])*100

FROM PortfolioProject..CovidDeaths$ ded
JOIN PortfolioProject..CovidVaccinations vac
	ON ded.location=vac.location
	AND ded.date = vac.date 
WHERE ded.continent is NOT NULL
--ORDER BY 2, 3

)
SELECT *, (TotalPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM PopvsVac

 
 --ii) Temp Table 

DROP TABLE IF EXISTS #PercentPopulationVaccinatedhere
CREATE TABLE #PercentPopulationVaccinatedhere
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinatedhere
SELECT ded.continent, ded.location, ded.date, ded.[ population], vac.new_vaccinations
, SUM( CAST (vac.new_vaccinations AS INT)) OVER(PARTITION BY ded.location ORDER BY 
  ded.location, ded.date) AS TotalPeopleVaccinated
 -- , (TotalPeopleVaccinated/[ population])*100

FROM PortfolioProject..CovidDeaths$ ded
JOIN PortfolioProject..CovidVaccinations vac
	ON ded.location=vac.location
	AND ded.date = vac.date 
WHERE ded.continent is NOT NULL
--ORDER BY 2, 3

SELECT *, (TotalPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM #PercentPopulationVaccinatedhere



Drop View if exists PercentPopulationVaccinatedView


CREATE VIEW PercentPopulationVaccinatedView AS
SELECT ded.continent, ded.location, ded.date, ded.[ population], vac.new_vaccinations
, SUM( CAST (vac.new_vaccinations AS INT)) OVER(PARTITION BY ded.location ORDER BY 
  ded.location, ded.date) AS TotalPeopleVaccinated
 -- , (TotalPeopleVaccinated/[ population])*100

FROM PortfolioProject..CovidDeaths$ ded
JOIN PortfolioProject..CovidVaccinations vac
	ON ded.location=vac.location
	AND ded.date = vac.date 
WHERE ded.continent is NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinatedView
 