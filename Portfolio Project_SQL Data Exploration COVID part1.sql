select * from [dbo].[coviddeaths]
Where continent is not null

-- select data we'll be using 
Select Location, date, total_cases, New_cases, Total_deaths, population
From [dbo].[coviddeaths]
Order by 1,2

-- looking at total cases vs total deaths
-- Show likelihood of dying if you contract covid in your country
Select Location, date, total_cases,Total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From [dbo].[coviddeaths]
Where Location like '%states%'
Order by 1,2

-- looking at total cases vs Population
-- Show what population percentage got covid
Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopInfected
From [dbo].[coviddeaths]
--Where Location like '%states%'
Order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population
Select Location,Population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/Population)*100) as PercentPopInfected
From [dbo].[coviddeaths]
--Where Location like '%states%'
Group by Location, population
Order by PercentPopInfected DESC

--Showing countries with highest death count per country
Select Location, Max(cast(total_deaths as int)) as HighestdeadCount --, MAX((total_deaths/Population)*100) as Percentdead
From [dbo].[coviddeaths]
--Where Location like '%states%'
Where continent is not null
Group by Location
Order by HighestdeadCount DESC

-- Let's break things down by continent
c
 
-- showing continents with highest death count per population

Select continent,population --, Max(cast(total_deaths as int)) as TotaldeathCount
, MAX((total_deaths/Population)*100) as Percentdead
From [dbo].[coviddeaths]
--Where Location like '%states%'
Where continent is not null
Group by continent, population
Order by Percentdead DESC

-- Global Numbers
Select date,sum(new_cases) as TotalNewCases,sum(cast(new_deaths as int)) as TotalnewDeaths , sum(cast(new_deaths as int))/sum(new_cases) as PerDeath
from [dbo].[coviddeaths]
--Where Location like '%states%'
Where continent is not null
Group by date
Order by PerDeath DESC

--looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)
from [dbo].[coviddeaths] dea	
Join [dbo].[covidvaccination] vac
	On dea.[location]=vac.[location]
	and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--use CTE

With PepvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)
from [dbo].[coviddeaths] dea	
Join [dbo].[covidvaccination] vac
	On dea.[location]=vac.[location]
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select * from PepvsVac

--temp table
Create table #Percentpopulationvaccinated
(
 Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 New_vaccination numeric,
 RollingPeopleVaccination numeric
)

Insert into #Percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)
from [dbo].[coviddeaths] dea	
Join [dbo].[covidvaccination] vac
	On dea.[location]=vac.[location]
	and dea.date=vac.date
where dea.continent is not null

select * from #Percentpopulationvaccinated

--creating view to store data for later visualization

create view Percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)
from [dbo].[coviddeaths] dea	
Join [dbo].[covidvaccination] vac
	On dea.[location]=vac.[location]
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


-- test views creation

create view UScoviddeath as
Select location, population, new_deaths
from [dbo].[coviddeaths]
where location like '%states%'