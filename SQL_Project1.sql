Select *
From POrtfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From POrtfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From POrtfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your conntry
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From POrtfolioProject..CovidDeaths
where location like '%canada%' and continent is not null
order by 1,2


--Looking at total Cases VS Polulation
--Shows whtat percentage of population got Covid
Select Location, date,population, total_cases,  total_deaths, (total_cases/population)*100 as PercentPopulationInfected
From POrtfolioProject..CovidDeaths
where location like '%canada%' and continent is not null
order by 1,2

--Looking at countries with hightest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From POrtfolioProject..CovidDeaths
--where location like '%canada%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

--Showing Countries with highest death count per population
Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


--Let's Break things down by continent

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc


--showing continents with the highest death count per population
Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From POrtfolioProject..CovidDeaths
--where location like '%canada%' and
where continent is not null
order by 1,2

--Global numbers by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From POrtfolioProject..CovidDeaths
--where location like '%canada%' and
where continent is not null
Group By date
order by 1,2


--Looking at Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum( Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
Drop table if exists #PercentPopulationVaciinated
Create Table #PercentPopulationVaciinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaciinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaciinated


--Creating View to store data for later visualizations
Create View PercentPopulationVaciinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaciinated