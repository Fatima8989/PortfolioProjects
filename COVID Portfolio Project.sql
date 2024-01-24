
Select * 
From PortfolioProject..CovidDeaths 
Where continent is not null
order by 3,4


--Select Data that we are going to be using 
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (convert(float, total_deaths)/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Azerbaijan%'
order by 1,2


--Looking at Total Cases and Population 
--Shows percentage of population got to Covid 
Select Location, date, total_cases, population, (convert(float, total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Azerbaijan%'
order by 1,2

--Looking at Countries with Hoighest Infection Rate compared to Population 
Select Location, date
From PortfolioProject..CovidVaccinations
Where location like '%Azerbaijan%'
Group by Location,  date
order by 1,2

--Population Case 
Select Location, Population, date, MIN(total_cases) as DeathtPercentage, MIN(convert(float, total_cases)/population)*100 as DeathByPercent  
From PortfolioProject..CovidDeaths
Where Location like '%Azerbaijan%'
Group by Location, Population, date 
Order by 1,2 


Select Location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths 
Where location like '%Azerbaijan%'
Group by Location
Order by TotalDeathCount desc


Select Location, Population, MAX(total_cases) as HighestIngfectionCount, MAx(convert(float, total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population 
order by PercentPopulationInfected desc


--Showing countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--Where location like '%Azerbaijan%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Let's break down by continent 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--Where location like '%Azerbaijan%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100  DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date 
order by 1,2 


Select*
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations2 vac
     On dea.location = vac.location
	 and dea.date = vac.date

--Looking a Total Population vs Vaccinations Azerbaijan 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations2 vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null and dea.location like '%Azerbaijan%'
order by 1, 2, 3

--PeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
--, convert(float,(RollingPeopleVaccinated/population))*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations2 vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null and dea.location like '%Azerbaijan%'
order by 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, PeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
--convert(float,(RollingPeopleVaccinated/population))*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations2 vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null and dea.location like '%Azerbaijan%'
--order by 2,3
)
Select*, (PeopleVaccinated/Population)*100
From PopvsVac


--Temp table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date DATETIME,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
--, convert(float,(RollingPeopleVaccinated/population))*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations2 vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null and dea.location like '%Azerbaijan%'
order by 2,3
Select*, convert(float, (PeopleVaccinated/NULLIF(Population, 0))*100 AS PercentPopulationVaccinated
From #PercentPopulationVaccinated;

DROP TABLE #PercentPopulationVaccinated


-- Drop the temporary table when done
DROP TABLE if exists #PercentPopulationVaccinated;
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
--, convert(float,(RollingPeopleVaccinated/population))*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations2 vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null and dea.location like '%Azerbaijan%'
--order by 2,3

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later vizualizations

USE PortfolioProject
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
--, convert(float,(RollingPeopleVaccinated/population))*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations2 vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null --and dea.location like '%Azerbaijan%'
--order by 2,3

Select*
From PercentPopulationVaccinated
