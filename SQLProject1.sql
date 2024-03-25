select*
from CovidDeaths
where continent is not Null


--select*
--from CovidVaccinations
--order by 3,4

--select data that we are going to be using 
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not Null
order by 1,2

--looking at total cases Vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%Australia%' and continent is not Null
order by 5 desc

--looking at total cases Vs Population
--shows what percentage of population got covid
select location, date, total_cases, population,(total_cases/population)*100 as CasesPercentage
from CovidDeaths
where location like '%Australia%' and continent is not Null
order by 5 desc

--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasesPercentage
from CovidDeaths
where continent is not Null
group by population, location
order by 4 desc

--Showing countries with highest death count per population

select location, population, MAX(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is not Null
group by location, population
order by 3 desc


--Breaking things down by continent

-- Showing continents with the highest death count per population

select location, MAX(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is Null
group by location
order by 2 desc



--Global Numbers

--Death percentage by date across the world

select date, SUM(new_cases) as totalcases, SUM(cast (new_deaths as int)) as totaldeaths, (SUM(cast (new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
Group by date
order by 1


--Total death percentage across the world

select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, (SUM(cast (new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1


--Looking at total population Vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (new_vaccinations as int)) OVER (partition by dea.location) as TotalVaccinationPerCountry
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Different way to convert data type in to int + Adding up vaccination count partition by country

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert (int,new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- To get total population Vs vaccination percentage(This will not work as RollingPeopleVaccinated is a newly created column)

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert (int,new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE to add RollingPeopleVaccinated into the Query

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert (int,new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null)
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100 as VacPercentage
From PopVsVac

--Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (250),
Location nvarchar (250),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert (int,new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100 as VacPercentage
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert (int,new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
From PercentPopulationVaccinated