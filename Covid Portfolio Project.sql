
select * 
from [Portfolio Project]..covid_death 
order by 1,2;

select location,date, total_cases,new_cases,total_deaths,population from [Portfolio Project]..covid_death order by 1,2;

--Total Cases VS Total Deaths
-- Shows likelihood of dying if contract uopu contact covid in United states 

select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from [Portfolio Project]..covid_death 
where location like '%united states%'
order by 1,2;


-- Looking at Total Cases VS Populations
--Shows whta percentage of population got covid
select location,date, total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..covid_death 
--where location like '%india%'
where continent is not null
order by 1,2;

--Looking at country's with highest infectiuon rate compared to Population 
select location,population, max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..covid_death 
--where location like '%india%'
group by location,population
order by PercentPopulationInfected desc;


--Show countries with Hoghest death count per population

select location, max(cast(total_deaths as int )) as HighestDeathCount
from [Portfolio Project]..covid_death 
where continent is not null
group by location
order by HighestDeathCount desc;


--SAhowing continent with highest death count

select continent, max(cast(total_deaths as int )) as HighestDeathCount
from [Portfolio Project]..covid_death 
where continent is not null
group by continent
order by HighestDeathCount desc;

-- Global Numbers 

select date,sum(new_cases) as TotalCases, sum(cast(new_deaths as int)),(sum(cast(new_deaths as int))/sum(
(cast(new_cases as int)))*100 as Deathpercentage
from [Portfolio Project]..covid_death 
where continent is not null
--where location like'%india%'
group by date,new_cases
order by 1,2 


-- JOINING both dataset COVID_vaccianation & Covid_Death

select *
from [Portfolio Project]..covid_death dea join
 [Portfolio Project]..covid_vaccination vac 
 on dea.location = vac.location and dea.date = vac.date

 --Looking at Total Population VS Vaccination

 select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations 
 , sum(cast(vac.new_vaccinations as float )) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
  --(RollingPeopleVaccinated/dea.population)*100 as PeopleVaccinatedpercentage
from [Portfolio Project]..covid_death dea join
 [Portfolio Project]..covid_vaccination vac 
 on dea.location = vac.location and 
 dea.date = vac.date
 where dea.continent is not null 
 order by 2,3

-- Use CTE
with PopVsVAc (continent, date ,location,population, new_vaccinations , rollongpeoplevaccinated ) 
as
 (
 select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations 
 , sum(cast(vac.new_vaccinations as float )) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
  --(RollingPeopleVaccinated/dea.population)*100 as PeopleVaccinatedpercentage
from [Portfolio Project]..covid_death dea join
 [Portfolio Project]..covid_vaccination vac 
 on dea.location = vac.location and 
 dea.date = vac.date
 where dea.continent is not null 
 )
  select * ,(rollongpeoplevaccinated/population)*100  as  PeopleVaccinatedpercentage
  from PopVsVAc


 -- TEMP Table

 drop  table if exists #percentPeopleVaccinated
 create table #percentPeopleVaccinated (
 continent nvarchar(255) ,
 date datetime ,
 location nvarchar(255) ,
 population numeric ,
 new_vaccinations numeric , 
 RollingPeopleVaccinated numeric
 )
  insert into #percentPeopleVaccinated
   select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations 
 , sum(cast(vac.new_vaccinations as float )) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
  --(RollingPeopleVaccinated/dea.population)*100 as PeopleVaccinatedpercentage
from [Portfolio Project]..covid_death dea join
 [Portfolio Project]..covid_vaccination vac 
 on dea.location = vac.location and 
 dea.date = vac.date
 --where dea.continent is not null 

 select * ,(RollingPeopleVaccinated/population)*100  as  PeopleVaccinatedpercentage
  from #percentPeopleVaccinated 

 -- Creating store for data Visualization later

 create view percentPeopleVaccinated as
 select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations 
 , sum(cast(vac.new_vaccinations as float )) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
  --(RollingPeopleVaccinated/dea.population)*100 as PeopleVaccinatedpercentage
from [Portfolio Project]..covid_death dea join
 [Portfolio Project]..covid_vaccination vac 
 on dea.location = vac.location and 
 dea.date = vac.date
 --where dea.continent is not null 
