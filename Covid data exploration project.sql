use PortfolioProject

select *
from..CovidDeaths$





select*
from..CovidVaccinations$
order by 3,4

select location, date, total_cases, new_cases,total_deaths,population
from..CovidDeaths$
order by 1,2

-- total cases vs total deaths

select location, date, total_cases,total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from..CovidDeaths$
where location like '%states%'
order by 1,2 

--looking at Total cases vs Population 

select location, date, total_cases,population, (total_cases/population) *100 as DeathPercentage
from..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate vs population 

select location, population, max( total_cases)as HighestInfectionCount, max((total_cases/population)) *100 as PercentPopulationInfected
from..CovidDeaths$
--where location like '%states%'
group by location, population
order by 1,2



-- breaking it down by continent 

-- showing countries with highest death count per population


select continent, max(cast (Total_deaths as int)) as TotalDeathCount
from..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS OF TOTAL CASES & TOTAL DEATHS PER DAY
 select date, SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases ) * 100 as DeathPercentage
from..CovidDeaths$
--where location like '%states%'
where continent is not null
GROUP by date
order by 1,2 


--GLOBAL NUMBERS 
 select  SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases ) * 100 as DeathPercentage
from..CovidDeaths$
--where location like '%states%'
where continent is not null
--GROUP by date
order by 1,2 





--looking at total poultion vs vaccacination
-- using CTE


With PopvsVac (continent, location, date, population, new_vaccinations, CummulativePeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as CummulativePeopleVaccinated
from CovidDeaths$ dea
join CovidDeaths$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3)
)
select*, (CummulativePeopleVaccinated/population) * 100
from PopvsVac





--looking at total poultion vs vaccacination
-- using TEMP TABLE
drop table if exists #PercentPeopleVaccinated
create table  #PercentPeopleVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
CummulativePeopleVaccinated numeric
)




Insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as CummulativePeopleVaccinated
from CovidDeaths$ dea
join CovidDeaths$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3)

select*, (CummulativePeopleVaccinated/population) * 100
from #PercentPeopleVaccinated


-- creating views to store data for later visualization 

  create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as CummulativePeopleVaccinated
from CovidDeaths$ dea
join CovidDeaths$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3)