--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


--Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,((total_deaths/total_cases)*100) as Death_Percentage
from PortfolioProject..CovidDeaths
where location like '%india'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percenatge of population has got Covid
select location,date,total_cases,population,((total_cases/population)*100) as Percent_Population_Infected
from PortfolioProject..CovidDeaths
--where location like '%india'
where continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population
select location,population,MAX(total_cases) as Highest_Inection_Count, MAX(total_cases/population)*100 as Max_Percent_Population_Infected
from PortfolioProject..CovidDeaths
--where location like '%india'
where continent is not null
group by location,population
order by Max_Percent_Population_Infected desc


-- Shwoing Countries with Highest Death count Per Population
select location,MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
--where location like '%india'
where continent is not null
group by location
order by Total_Death_Count desc


-- Let's break things down by continent


-- Showing continents with highest death count per population
select continent,MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
--where location like '%india'
where continent is not null
group by continent
order by Total_Death_Count desc


-- Global Number
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
--where location like '%india'
where continent is not null
order by 1,2


--				COVID Vaccinations       

-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) 
as Rolling_People_Vaccinated, (Rolling_People_Vaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3



-- Use CTE

With PopulationVsVaccination (Continent, Location, Date, Population,New_Vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) 
as Rolling_People_Vaccinated 
--(Rolling_People_Vaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rolling_People_Vaccinated/Population) as Rolling_Vaccination_Percentage
from PopulationVsVaccination


-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) 
as Rolling_People_Vaccinated 
--(Rolling_People_Vaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (Rolling_People_Vaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) 
as Rolling_People_Vaccinated 
--(Rolling_People_Vaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated