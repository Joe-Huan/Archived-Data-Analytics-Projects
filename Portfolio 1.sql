--Select *
--From PortfolioProject..CovidDeaths$
--order by 3,4;

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4;

-- External Data in CSV/Excel format successfully imported into SQL

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2;

-- We are looking at total cases vs total deaths at this point!

-- Total Cases VS Total Deaths
-- This shows the mortality rate when being infected by Covid-19
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From PortfolioProject..CovidDeaths$
Where Location like '%states%'
order by 1,2;

-- Total Cases VS Population
Select location, date, total_cases, population, (total_cases/population)*100 as Infection_rate_per_population
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2;

-- Countries with the highest infection rate per population
Select location, population, MAX(total_cases) as infection_rate, (MAX(total_cases)/population)*100 as Infection_rate_per_population
From PortfolioProject..CovidDeaths$
--Where Location like '%states%'
Group By continent, population
order by Infection_rate_per_population desc

-- Looking for highest death count per population
Select location, MAX(cast(total_deaths as INT)) as Total_death_count
From PortfolioProject..CovidDeaths$
--Where Location like '%states%'
Where continent is not null
Group By continent
order by Total_death_count desc

Select continent, MAX(cast(total_deaths as INT)) as Total_death_count
From PortfolioProject..CovidDeaths$
--Where Location like '%states%'
Where continent is not null
Group By continent
order by Total_death_count desc

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as Total_new_cases, SUM(cast(new_deaths as INT)) as Total_new_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as Death_percentage
From PortfolioProject..CovidDeaths$
--Where location like ''
Where continent is not null
Group by date
order by 1,2

-- Joining tables to compare total population that is vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USING CTE
With Population_VS_Vaccination (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From Population_VS_Vaccination

-- TEMP TABLE

Drop Table if exists #Percent_Of_People_Vaccinated

Create Table #Percent_Of_People_Vaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #Percent_Of_People_Vaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #Percent_Of_People_Vaccinated

-- Creating a view

Create View Percent_Of_People_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select *
From Percent_Of_People_Vaccinated

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

