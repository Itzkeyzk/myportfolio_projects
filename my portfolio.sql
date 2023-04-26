select *
from PortfolioProjects..CovidDeaths
where continent is not  null
order by 3, 4



--select *
--from PortfolioProjects..COVIDVACCINATION
--order by 3, 4


--I will be carefully curating and selecting the specific data that is essential for my project

select location,date, total_cases,new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
where continent is not  null
order by 1, 2

--looking for the total cases and the total death
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercemtage 
from PortfolioProjects..CovidDeaths
where location like '%nigeria%'

order by 1, 2

-- looking at the total cases vs the population
-- and showing what percentage of population covid got

select location,date, population,  total_cases, (total_cases/population)*100 as covid_population
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
where continent is not  null
order by 1, 2



--checking for country with the highest population rate
select location, population,  MAX(total_cases) as highest_Infected_Count, MAX((total_cases/population))*100 as  percent_population_infected
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
group by location, population
order by  percent_population_infected desc


--checking for country with the highest covid death
select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
where continent is not  null
group by location 
order by  total_death_count desc


--BREAKING THINGS DOWN BY CONTINENT

select continent, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
where continent is not  null
group by continent 
order by  total_death_count desc

--SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION

select continent, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
where continent is not  null
group by continent 
order by  total_death_count desc

--GLOBAL NUMBERS
select  SUM(new_cases) as tota_cases ,  Sum(cast(new_deaths as int)) as total_death, Sum(cast(new_deaths as int))/ sum(new_cases)* 100 as Deathpercemtage 
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
where continent is not null 
--group by date
order by 1, 2

-- looking at total population vs  total vacination
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) rolling_people_vacinenations
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..COVIDVACCINATION vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
order by 2, 3


--USE CTE
WITH PopvsVac (continent, location, date, population,new_vaccinations,rolling_people_vacinenations) 
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) rolling_people_vacinenations
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..COVIDVACCINATION vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
--order by 2, 3
)
select *, rolling_people_vacinenations/population* 100
from PopvsVac

--TEMP TABLE

drop table if exists #percent_population_vaccination
Create table #percent_population_vaccination
(continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_people_vacinenations numeric

)

insert into #percent_population_vaccination

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) rolling_people_vacinenations
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..COVIDVACCINATION vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
--order by 2, 3

select *, rolling_people_vacinenations/population* 100
from #percent_population_vaccination

--creating views to store data later

create view percent_population_vaccination as 


select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) rolling_people_vacinenations
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..COVIDVACCINATION vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
--order by 2, 3

select *
from percent_population_vaccination
