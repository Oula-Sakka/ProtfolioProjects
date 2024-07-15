
Select *
from [Portfolio Project]..CovidDeaths
where continent is not null
Order by 3,4

--Select *
--from [Portfolio Project]..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
where continent is not null
Order by 1,2

--Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, cast(total_deaths as float) /cast(total_cases as float)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location like '%state%'
where continent is not null
Order by 1,2

--Looking at total cases vs population
--show what percentage of population got covid  

Select location, date, population, total_cases, cast(total_cases as float) /cast( population as float)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%state%'
where continent is not null
Order by 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

Select location, population, Max(total_cases)as HighestInfectionCount , Max(cast(total_cases as float) /cast( population as float))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%state%'
where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population 

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%state%'
where continent is not null
Group by location
Order by TotalDeathCount desc

--LET's Break Things Down By Continent

-- Showing Continents with the Highest Death Count per population 

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%state%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers

Select Sum(new_cases) as total_cases , Sum(new_deaths) as total_deaths , Sum(new_deaths)/Sum(CAST(CASE new_cases when 0 then 1 else new_cases end as float))*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent IS NOT NULL and new_deaths IS NOT NULL and new_cases IS NOT NULL 
--Group by date
--Order by 1,2

--Looking at Tatol Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum (convert(Numeric,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent IS NOT NULL 
Order by 2,3

--Use CTE

with PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum (convert(Numeric,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent IS NOT NULL 
--Order by 2,3
) 
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp Table


Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum (convert(Numeric,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent IS NOT NULL 
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from  #PercentPopulationVaccinated

--Creating View to store data for later visualisations 

Create view Percent_Population_Vaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum (convert(Numeric,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent IS NOT NULL 
--Order by 2,3

Select*
from Percent_Population_Vaccinated