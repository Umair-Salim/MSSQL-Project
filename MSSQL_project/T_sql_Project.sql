SELECT * 
FROM PortfolioProject_1..CovidDeaths
WHERE continent is not null
Order by 3,4

--SELECT * 
--FROM PortfolioProject_1..CovidVaccinations
--Order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_1..CovidDeaths
Order by 1,2


-- Looking at Total Cases Vs Total Deaths
-- Shows Llikelihood of dying if you contract covid in any specific country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercent
FROM PortfolioProject_1..CovidDeaths
Order by 1,2

-- Looking at Total casaes vs Population
-- Shows what percent of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 CovidPercent
FROM PortfolioProject_1..CovidDeaths
Order by 1,2

-- Looking at countries with highest infection rate 

SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 Percentpopulationinfected
FROM PortfolioProject_1..CovidDeaths
Group by location, population
Order by 4 DESC


-- Showing Countries With Highest death count 

SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject_1..CovidDeaths
WHERE continent is not null
Group by location
Order by 2 DESC

-- Breaking this down by continent
SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject_1..CovidDeaths
WHERE continent is null
Group by location
Order by 2 DESC

-- Global Numbers

SELECT date, SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 GolbalDeathPrecent
FROM PortfolioProject_1..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Total Global Numbers

SELECT  SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 GolbalDeathPrecent
FROM PortfolioProject_1..CovidDeaths
Where continent is not null
Order by 1,2


-- Bringing in the vaccination data
SELECT * 
FROM PortfolioProject_1..CovidDeaths death
JOIN PortfolioProject_1..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date

-- Looking at total population vs vacination 
SELECT death.continent, death.location, death.date, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location order by death.location, death.date) RollingCountOfVaccination
FROM PortfolioProject_1..CovidDeaths death
JOIN PortfolioProject_1..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
order by 2,3


-- Using CTE to add calculate vaccination Percent

With PopvsVac (continent,location,Date,Population,NewVaccination,RollingCountOfVaccination)
as
(
SELECT death.continent, death.location, death.date,death.population ,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location order by death.location, death.date) RollingCountOfVaccination
FROM PortfolioProject_1..CovidDeaths death
JOIN PortfolioProject_1..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--order by 2,3
)
SELECT location,Population, MAX(RollingCountOfVaccination/Population)*100 vaccinationPercent
FROM  PopvsVac
Group by location,Population 
Order by 3 DESC


-- Using TEMP table
CREATE TABLE #PercentpopVac
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
peopleVaccinated numeric
)

Insert Into #PercentpopVac
SELECT death.continent, death.location, death.date,death.population ,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location order by death.location, death.date) RollingCountOfVaccination
FROM PortfolioProject_1..CovidDeaths death
JOIN PortfolioProject_1..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--order by 2,3

SELECT location,Population, MAX(peopleVaccinated/Population)*100 vaccinationPercent
FROM  #PercentpopVac
Group by location,Population 
Order by 3 DESC


-- Creating View to store data for later visualization

Create View PercentpopVac as
SELECT death.continent, death.location, death.date,death.population ,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location order by death.location, death.date) RollingCountOfVaccination
FROM PortfolioProject_1..CovidDeaths death
JOIN PortfolioProject_1..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--order by 2,3

CREATE VIEW TotalDeathByContinent as
SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject_1..CovidDeaths
WHERE continent is null
Group by location


Create view GlobalNumbers as
SELECT date, SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 GolbalDeathPrecent
FROM PortfolioProject_1..CovidDeaths
Where continent is not null
Group by date
