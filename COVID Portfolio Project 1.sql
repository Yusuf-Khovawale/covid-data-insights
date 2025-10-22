Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, Population
From PortfolioProject.. CovidDeaths
where location like '%states%'
and continent is not null
Order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likekihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.. CovidDeaths
where location like '%states%'
and continent is not null
Order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of population got covid


Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.. CovidDeaths
--where location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate Compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.. CovidDeaths
--where location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc


--Showing Countries WIth Highest Death Count per Population


Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject.. CovidDeaths
--where location like '%states%'
where continent is null
Group by Location
Order by TotalDeathCount desc

--Let's BREAK THINGS DOWN BY CONTINENT


--Showing Continents with the HIghest death count per population

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject.. CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS


Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject.. CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
Order by 1,2

--Looking at Total Poplutaion vs Vaccinations
--USE CTE 

--With PopvsVac ( Continent, Location, Date, Population ,New_vaccinations, RollingPeopleVaccinated)

--(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/ population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
Order by 2,3
--)

--USE CTE

WITH PopvsVac AS
(
  SELECT
      dea.continent,
      dea.location,
      dea.[date],
      dea.population,
      vac.new_vaccinations,
      SUM(TRY_CONVERT(bigint, vac.new_vaccinations))
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.[date])
        AS RollingPeopleVaccinated
  FROM PortfolioProject.dbo.CovidDeaths       AS dea
  JOIN PortfolioProject.dbo.CovidVaccinations AS vac
    ON dea.location = vac.location
   AND dea.[date]   = vac.[date]
  WHERE dea.continent IS NOT NULL
)
SELECT  *,
        100.0 * RollingPeopleVaccinated / NULLIF(population,0) AS PctVaccinated
FROM PopvsVac
ORDER BY location, [date];



--TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVacinated--, (RollingPeopleVacinated/ population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
     and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVacinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVacinated--, (RollingPeopleVacinated/ population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated