Select * 
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location,date, total_cases, new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying of you contract covid in your country

Select location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Canada%'
and continent is not null 
order by 1,2

-- Looking at the Total Cases Vs the Population
-- Shows what percentage of population got Covid

Select location,date,population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
order by 1,2

--   Countries with Highest Infection Rate compared to Population 

Select location,population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
Group by location,population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count Per Population 

Select location,Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
WHERE continent IS NOT NULL
Group by location
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT
-- Showing continents with highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

	
--GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as  DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
WHERE continent IS not null
--Group By date
order by 1,2


--- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
 On  dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
order by 2,3

-- USE CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
 On  dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
--order by 2,3

)

SELECT *,
       (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac;


--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated  numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
 On  dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
--order by 2,3

SELECT *,
       (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
 On  dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3


 Select *
 From PercentPopulationVaccinated


 /*

Queries used for Tableau Project

*/


 -- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc



















