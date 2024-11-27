Select *
From PortoflioProject..CovidDeaths
where continent is not null
Order by 3,4

-- total Cases Vs total deaths

Select location,
	   date,
	   total_cases,
	   total_deaths,
	   (total_deaths/total_cases)*100 DeathPercentageCase
From PortoflioProject..CovidDeaths
Where location like 'Egypt'
Order by 1,2

-- total cases vs population 
Select location,
	   date,
	   total_cases,
	   population,
	   (total_cases/population)*100 CasePercentagePopulation
From PortoflioProject..CovidDeaths
--Where location like 'Egypt'
where continent is not null
Order by 1,2

-- highest infection rate per population
Select location,
	   population,max(total_cases) HighestInfictionCount, 
	   max((total_cases/population))*100 PopulationInfected
From PortoflioProject..CovidDeaths
where continent is not null
group  by population,location
Order by 4 desc

--highest death count per population
Select location,
	   max(CAST(total_deaths as int)) HighestDeathCount
From PortoflioProject..CovidDeaths
where continent is not null
group by location
Order by 2 desc

--highest death count per continent
Select continent,
	   max(CAST(total_deaths as int)) HighestDeathCount
From PortoflioProject..CovidDeaths
where continent is not null
group by continent
Order by 2 desc

-- Global numbers
Select date,
	   sum(new_cases) totalCases,
	   SUM(cast(new_deaths as int)) Totaldeaths, 
	   (SUM(Cast(new_deaths as int))/SUM(new_cases))*100 DeathPercentageCase
From PortoflioProject..CovidDeaths
Where continent is not null
group by date
Order by 1,2

Select sum(new_cases) totalCases,
	   SUM(cast(new_deaths as int)) Totaldeaths,
	   (SUM(Cast(new_deaths as int))/SUM(new_cases))*100 DeathPercentageCase
From PortoflioProject..CovidDeaths
Where continent is not null
Order by 1,2

-----------------------------

select *
from PortoflioProject..CovidDeaths CDs
join PortoflioProject..CovidVaccinations CVs
	on CDs.location = CVs.location and CDs.date = CVs.date

-- total Population Vs Vaccinations

-- CTE
with POPvsVAC (Continent, Location, Date, Population, New_Vaccinations, RvaccinationsC)
as
(
select CDs.continent,
	   CDs.location,
	   CDs.date,
	   CDs.population,
	   CVs.new_vaccinations,
	   SUM(Cast(CVs.new_vaccinations as int)) OVER ( PARTITION BY CDs.location order by CDs.location, CDs.date) RvaccinationsC
from PortoflioProject..CovidDeaths CDs
join PortoflioProject..CovidVaccinations CVs
	on CDs.location = CVs.location and CDs.date = CVs.date
where CDs.continent is not null
)
select * , (RvaccinationsC/Population)*100 VccinationsPercentage
from POPvsVAC
order by 2,3

-- Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select CDs.continent, CDs.location, CDs.date, CDs.population, VCs.new_vaccinations
, SUM(CONVERT(int,VCs.new_vaccinations)) OVER (Partition by CDs.Location Order by CDs.location, CDs.Date) as RvaccinationsC
--, (RollingPeopleVaccinated/population)*100
From PortoflioProject..CovidDeaths CDs
Join PortoflioProject..CovidVaccinations VCs
	On CDs.location = VCs.location
	and CDs.date = VCs.date
where CDs.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 VccinationsPercentage
From #PercentPopulationVaccinated
order by 2,3

-- Views for later Visulaizations

-- Vaccination percent per population

create View Vaccinated_Population_Percent as

select CDs.continent,
	   CDs.location,
	   CDs.date,
	   CDs.population,
	   CVs.new_vaccinations,
	   SUM(Cast(CVs.new_vaccinations as int)) OVER ( PARTITION BY CDs.location order by CDs.location, CDs.date) RvaccinationsC
from PortoflioProject..CovidDeaths CDs
join PortoflioProject..CovidVaccinations CVs
	on CDs.location = CVs.location and CDs.date = CVs.date
where CDs.continent is not null

-- total Cases Vs total deaths
create view Case_vS_Death as

Select location,
	   date,
	   total_cases,
	   total_deaths,
	   (total_deaths/total_cases) Death_Percentage_per_totalCases
From PortoflioProject..CovidDeaths
where continent is not null

-- Deaths per continent 
create view D_Continent as

Select location,
	   SUM(cast(new_deaths as int)) Total_Death
From PortoflioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location

-- Global Numbers
create view G_numbers as

Select sum(new_cases) total_Cases,
	   SUM(cast(new_deaths as int)) Total_deaths,
	   (SUM(Cast(new_deaths as int))/SUM(new_cases)) Death_Percentage_per_totalCases
From PortoflioProject..CovidDeaths
Where continent is not null

-- Highest Infiction 
create view H_infection as

Select location,
	   population,
	   max(total_cases) Highest_Infiction_Count, 
	   max((total_cases/population)) Population_Infected_percentage
From PortoflioProject..CovidDeaths
where continent is not null
group  by population,location

-- Deaths per Country 
create view D_Country as

Select location,
	   SUM(cast(new_deaths as int)) Total_Death
From PortoflioProject..CovidDeaths
Where continent is not null 
Group by location
