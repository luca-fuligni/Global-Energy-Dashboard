/*
	1. Total Energy Production by Country
	
	Calculate the total energy production for a specific country
	or a set of countries from the dataset.
*/

SELECT country
	,SUM(CONVERT(FLOAT, primary_energy_consumption)) AS total_energy_production
FROM EnergyProject.dbo.EnergyUse
WHERE primary_energy_consumption IS NOT NULL
GROUP BY country;


/*
	2. Annual Coal Consumption in a Specific Country
	
	Assess the annual coal consumption for a particular country
	over a given period.
*/

SELECT country
	,year
	,coal_consumption
FROM EnergyProject.dbo.EnergyUse
WHERE country = 'Italy'
	AND coal_consumption IS NOT NULL;

/*
	3. Per Capita Oil Consumption in Selected Countries
	
	Calculate and compare the per capita oil consumption
	in a few selected countries.
*/

SELECT country
	,year
	,population
	,oil_energy_per_capita
FROM EnergyProject.dbo.EnergyUse
WHERE country = 'Italy'
	AND oil_energy_per_capita IS NOT NULL;


/*
	4. Yearly Nuclear Energy Production
	
	Determine the annual nuclear energy production
	for a specific country or a set of countries.
*/

SELECT country
	,year
	,nuclear_electricity
FROM EnergyProject.dbo.EnergyUse
WHERE country IN (
		'Italy'
		,'Germany'
		,'France'
		)
	AND nuclear_electricity IS NOT NULL;


/*
	5. Comparison of Electricity Generation from
	Different Sources in One Country
	
	Compare the different sources of electricity generation
	(like coal, gas, hydro) within a single country for a specific year.
*/

SELECT country
	,year
	,coal_electricity
	,gas_electricity
	,hydro_electricity
FROM EnergyProject.dbo.EnergyUse
WHERE country = 'Italy'
	AND year = 1998;


/*
	6. Trends in Renewable Energy Usage

	Analyze the growth of renewable energy (solar, wind, hydro)
	consumption over the last decade in different countries
*/

SELECT country
	,year
	,solar_consumption
	,wind_consumption
	,hydro_consumption
FROM EnergyProject.dbo.EnergyUse
WHERE iso_code IS NOT NULL
	AND solar_consumption IS NOT NULL
	AND wind_consumption IS NOT NULL
	AND hydro_consumption IS NOT NULL
	AND year BETWEEN 2010
		AND 2020
ORDER BY country
	,year;


/*
	7. Comparative Analysis of Fossil Fuel and Renewable Energy

	Compare the share of fossil fuels vs. renewable energy sources
	in total energy consumption for different regions.
*/

SELECT country
	,year
	,fossil_share_elec
	,low_carbon_share_elec -- includes nuclear and renewables
FROM EnergyProject.dbo.EnergyUse
WHERE iso_code IS NOT NULL
	AND fossil_share_elec IS NOT NULL
	AND low_carbon_share_elec IS NOT NULL
	AND year >= 2000
ORDER BY country
	,year;


/*
	8. Impact of GDP on Energy Consumption

	Investigate the correlation between a country's GDP and
	its energy consumption or energy per capita.
*/

SELECT country
	,year
	,population
	,gdp
	,energy_per_gdp
FROM EnergyProject.dbo.EnergyUse
WHERE gdp IS NOT NULL
	AND energy_per_gdp IS NOT NULL
	AND year >= 2000
ORDER BY country
	,year;


/*
	9. Biofuel Usage Trends

	Examine the trends in biofuel consumption and production
	across different countries and how it has evolved over time.
*/

SELECT country
	,year
	,population
	,biofuel_consumption
	,biofuel_electricity   -- generation from biofuel
	,biofuel_cons_per_capita
	,biofuel_elec_per_capita
FROM EnergyProject.dbo.EnergyUse
WHERE biofuel_consumption IS NOT NULL
	AND biofuel_electricity IS NOT NULL
ORDER BY country
	,year;

/*
	10. Carbon Intensity of Electricity Production

	Analyze the carbon intensity of electricity production in various
	countries and identify the least and most carbon-intensive electricity grids.
*/

SELECT country
	,AVG(carbon_intensity_elec) AS avg_carbon_intensity_2010_2020
FROM EnergyProject.dbo.EnergyUse
WHERE carbon_intensity_elec IS NOT NULL
	AND year BETWEEN 2010
		AND 2020
GROUP BY country
ORDER BY avg_carbon_intensity_2010_2020;


/*
	11. Energy Consumption and Population Growth

	Explore the relationship between population growth and changes
	in energy consumption in different countries.
*/

SELECT year
	,country
	,population
	,biofuel_cons_per_capita
	,coal_cons_per_capita
	,energy_per_capita   -- primary energy consumption per capita
	,fossil_energy_per_capita
	,gas_energy_per_capita
	,hydro_energy_per_capita
	,low_carbon_energy_per_capita
	,nuclear_energy_per_capita
	,oil_energy_per_capita
	,other_renewables_energy_per_capita
	,renewables_energy_per_capita
	,solar_energy_per_capita
	,wind_energy_per_capita
FROM EnergyProject.dbo.EnergyUse
WHERE country IN (
		'Italy'
		,'Germany'
		,'France'
		)
	AND year >= 1945
ORDER BY year
	,country;

/* 
	12. Shifts in Oil and Gas Production

	Look at the trends in oil and gas production and consumption over the years,
	focusing on major producers and consumers.
*/

SELECT year
	,country
	,gas_electricity
	,oil_electricity
FROM EnergyProject.dbo.EnergyUse
WHERE country IN (
		'United States'
		,'Russia'
		,'China'
		,'India'
		)
	AND gas_electricity IS NOT NULL
	AND oil_electricity IS NOT NULL
ORDER BY year
	,country;


/*
	13. Low-Carbon Energy Consumption Growth:

	Analyze the growth of low-carbon energy consumption, including renewables and nuclear,
	in countries leading the way in low-carbon initiatives.
*/

SELECT country
	,year
	,population
	,low_carbon_consumption
	,low_carbon_elec_per_capita
	,low_carbon_cons_change_pct
FROM EnergyProject.dbo.EnergyUse
WHERE country IN (
		'Sweden'
		,'Germany'
		,'Denmark'
		,'Norway'
		,'Iceland'
		,'Costa Rica'
		,'United Kingdom'
		,'France'
		,'China'
		,'India'
		)
	AND low_carbon_consumption IS NOT NULL
	AND low_carbon_elec_per_capita IS NOT NULL
	AND low_carbon_cons_change_pct IS NOT NULL
ORDER BY country
	,year;


/*
	14. Grouped Analysis of Per Capita Energy Consumption

	Segment countries into different income groups based on GDP, then
	compare their average per capita energy consumption.
*/

WITH GDPData
AS (
	SELECT country
		,year
		,population
		,gdp
		,(CAST(REPLACE(gdp, ',', '') AS FLOAT) / population) AS gdp_per_capita
	FROM EnergyProject.dbo.EnergyUse
	WHERE gdp IS NOT NULL
		AND ISNUMERIC(REPLACE(gdp, ',', '')) = 1
	)
SELECT GDPData.country
	,GDPData.year
	,GDPData.population
	,GDPData.gdp
	,GDPData.gdp_per_capita
	,AVG(CAST(REPLACE(EU.energy_per_capita, ',', '') AS FLOAT)) AS avg_energy_per_capita
	,CASE 
		WHEN GDPData.gdp_per_capita <= 1035
			THEN 'Low-Income Country'
		WHEN GDPData.gdp_per_capita > 1035
			AND GDPData.gdp_per_capita <= 4045
			THEN 'Lower-Middle-Income Country'
		WHEN GDPData.gdp_per_capita > 4045
			AND GDPData.gdp_per_capita <= 12535
			THEN 'Upper-Middle-Income Country'
		ELSE 'High-Income Country'
		END AS income_classification
FROM GDPData
INNER JOIN EnergyProject.dbo.EnergyUse EU ON GDPData.country = EU.country
	AND GDPData.year = EU.year
GROUP BY GDPData.country
	,GDPData.year
	,GDPData.population
	,GDPData.gdp
	,GDPData.gdp_per_capita;


/*
	15. Time-Series Analysis of Greenhouse Gas Emissions:

	Perform a year-over-year analysis of greenhouse gas emissions
	from electricity generation for selected countries.
	Use window functions in SQL to calculate the rate of change and trend over a specified period.
*/

SELECT country
	,year
	,greenhouse_gas_emissions
	,LAG(greenhouse_gas_emissions, 1) OVER (
		PARTITION BY country ORDER BY year
		) AS prev_year_emissions
	,greenhouse_gas_emissions - LAG(greenhouse_gas_emissions, 1) OVER (
		PARTITION BY country ORDER BY year
		) AS yoy_change
	,AVG(greenhouse_gas_emissions) OVER (
		PARTITION BY country ORDER BY year ROWS BETWEEN 2 PRECEDING
				AND CURRENT ROW
		) AS moving_avg_3yr
FROM EnergyProject.dbo.EnergyUse
WHERE country IN (
		'Italy'
		,'Germany'
		,'France'
		)
		AND year > 2000
ORDER BY country
	,year;