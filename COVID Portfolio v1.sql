Select *
FROM PortfolioProject..CovidDeaths

--Select *
--FROM PortfolioProject..CovidDeaths
--Where continent like 'North America'

--Select population
--FROM PortfolioProject..CovidDeaths
--group by population 



Select *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--- Select Data that we are going to be using

Select location, date, total_cases, new_cases, cast(total_deaths as int), population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Select location, date, new_cases,  population
--FROM PortfolioProject..CovidDeaths
--Where location like '%Afgh%'
--order by 2


-- Analysing Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in England
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM  PortfolioProject..CovidDeaths
where location like '%Eng%'
order by 1,2

---Looking at Total Cases vs Population
---Shows what percentage of population got covid(infection rate)

Select location, date, population, total_cases, (total_cases/population) * 100 AS CovidPercentage
FROM  PortfolioProject..CovidDeaths
where location like '%Canada%' and continent is not null
order by 1,2

--- Looking at countries with the Highest Infection Rate compared to population
--- Shows that Cyprus had the highest covid infection rate

Select location, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population)) * 100 AS CovidPercentage
FROM  PortfolioProject..CovidDeaths
--where location like '%Canada%'
Where continent is not null
group by location, population
order by CovidPercentage desc

---Let's break things down by continent

Select continent, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population)) * 100 AS CovidPercentage
FROM  PortfolioProject..CovidDeaths
--where location like '%Canada%'
Where continent is not null
group by continent, population
order by CovidPercentage desc

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM  PortfolioProject..CovidDeaths
--where location like '%Canada%'
Where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

Select date, SUM(new_cases) as TotalCases, sum(Cast(new_deaths as int))
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


---Total Case globally

Select SUM(new_cases) as TotalCases
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1

---looking at Total Population vs Vaccinations

--select *
--From PortfolioProject..CovidDeaths  dea
--Join PortfolioProject..CovidVaccinations vac
--    on dea.location = vac.location
--	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--- you can use Convert or Cast function to change a data type
--- syntax convert(int, new_vaccinations) or cast(new_vaccinations as int)

--- to add the sum of new vaccinations by location, the following query is used:

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100, you can't use a created column for calculations - you need a CTE or Temp Table
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

---USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

---Temp Table
DROP Table if exists #PercentPopulationVaccinated     ---always add drop table, if you intend on making alterations
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


---Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create View TotalCases as
Select SUM(new_cases) as TotalCases
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
--Order by 1

Select * 
from TotalCases


