
--data to be used

SELECT location,date,total_cases, new_cases, total_deaths,population
FROM Portfolio_Project..Covid_deaths$
ORDER BY 1,2

--looking for total deaths over total cases
SELECT location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project..Covid_deaths$
WHERE location LIKE '%STATE%'
ORDER BY 1,2


--looking at total cases vs population

SELECT location,date,total_cases, total_deaths,population, (total_cases/population)*100 as CovidPercentage, (total_deaths/population)*100 as DeathPercent
FROM Portfolio_Project..Covid_deaths$
ORDER BY 1,2


--Looking at countries with Highest Infection rate compared to Population

SELECT location, population, Max(total_cases) as HigestInfectionCount, MAX(total_cases/population)*100 as Population_Percentage 
FROM Portfolio_Project..Covid_deaths$
group by location, population
order by Population_Percentage desc


--SHowing Countries with Highest Death Count per Population
SELECT location, Max(cast(total_deaths as bigint)) as TotalDeathCount
from Portfolio_Project..Covid_deaths$
where continent is not null
group by location
order by TotalDeathCount desc

SELECT location, Max(cast(total_deaths as bigint)) as TotalDeathCount
from Portfolio_Project..Covid_deaths$
where continent is null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_Project..Covid_deaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


select * from Portfolio_Project..Covid_deaths$ dea
join Portfolio_Project..Covid_vaccinations$ vac
on dea.location = vac.location
and dea.date= vac.date


--Looking for total Population vs Vaccinations
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations from Portfolio_Project..Covid_deaths$ dea
join Portfolio_Project..Covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- with CTE

with PopVsVac(continent, locaton, date, population, new_vaccinations, rolling_people_vaccinations) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..Covid_deaths$ dea
join Portfolio_Project..Covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinations/population)*100 as VaccinationPercentage
from PopVsVac


-- Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255)
, location nvarchar(255)
, date datetime
, population numeric
, new_vaccinations numeric
, RollingPeopleVaccinated numeric
)

insert into	#PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..Covid_deaths$ dea
join Portfolio_Project..Covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated

-- Creating view PercentPopulationVaccinated
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..Covid_deaths$ dea
join Portfolio_Project..Covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
