select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..coviddeaths
order by 1,2

--looking at Total Cases vs Total Deaths
--shows % chance of dying from covid in select country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
where location like '%states%'
order by 1,2

--looking at total cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..coviddeaths
where location like '%states%'
order by 1,2


--looking at what countries highest infection rate is compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..coviddeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


--showing the countries with the highest death count per population

select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--showing data by continent

select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--showing continents with highest death count, global count

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null --and total_deaths >1
--group by date
order by 1,2

-- use cte


with PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


--temp table

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--creating view

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated