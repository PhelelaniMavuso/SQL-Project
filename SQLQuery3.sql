select*
from CovidDeaths
order by 3,4

select *
from CovidVaccinations
order by 3,4

--Showing the death percentage by country
select location, date, total_deaths, total_cases, (cast(total_deaths as numeric)/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'United%'
order by 1,2

--Showing population percentage of infected by countries on daily basis
select location, date, total_cases, population, (total_cases/population)*100 as PopulationInfectedPercentage
from CovidDeaths
order by 1,2

--Showing countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as PopulationInfectedPercentage
from CovidDeaths
group by location, population
order by PopulationInfectedPercentage desc

--Showing countries with highest death rate by population
select location, max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Showing continents with highest death rate
select continent, max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing global new total cases, total deaths and death rate on each day
select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, 
sum(cast(new_deaths as int))/sum(nullif(new_cases,0))*100 as deathpercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2
 
 -- Showing population against new vaccinations per day
 with PeoVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
 as
 (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by 
dea.date) as PeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (PeopleVaccinated/population)*100 as VaccinatedPercentage
from PeoVac

--Temp Table
drop table if exists #PopulationVaccinationPercentage
create table #PopulationVaccinationPercentage (
continent nvarchar(300),
location nvarchar(300),
date datetime,
population numeric,
new_vaccination numeric,
PeopleVaccinated numeric
)
insert into #PopulationVaccinationPercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by 
dea.date) as PeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*, (PeopleVaccinated/population)*100 as VaccinatedPercentage
from #PopulationVaccinationPercentage

--Views to store data for visualisation
create view DeathPercentage as
select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, 
sum(cast(new_deaths as int))/sum(nullif(new_cases,0))*100 as deathpercentage
from CovidDeaths
where continent is not null
group by date
--order by 1,2

select*
from DeathPercentage

create view PopulationVacPercentage as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by 
dea.date) as PeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PopulationVacPercentage