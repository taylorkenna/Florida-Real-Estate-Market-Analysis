SELECT TOP 10 *
FROM dbo.zillow_properties_florida


----Pricing trends & market activity----

--Average property price by city (shows high-cost vs affordable cities)
SELECT city,
	AVG(Property_price_USD) AS avg_price_by_city
FROM dbo.zillow_properties_florida
GROUP BY city
ORDER BY AVG(Property_price_USD) DESC;

--Average days on Zillow by city (reveals market velocity; how fast properties move)
SELECT city,
	AVG(Number_of_days_on_Zillow) AS avg_days_on_zillow_by_city
FROM dbo.zillow_properties_florida
GROUP BY city
ORDER BY AVG(Number_of_days_on_Zillow) DESC; 

----Price per Square Foot Insights---- (highlights expensive markets relative to home size)
SELECT city,
	ROUND(AVG(Price_per_living_area_unit_USD),2) AS avg_price_per_sqft_by_city
FROM dbo.zillow_properties_florida
GROUP BY city
ORDER BY ROUND(AVG(Price_per_living_area_unit_USD),2) DESC;

----Property type distribution----
SELECT Property_type,
COUNT(*) AS count_property_types -- total listings
FROM dbo.zillow_properties_florida
GROUP BY Property_type
ORDER BY COUNT(*) DESC;

----Bedrooms/Bathrooms and Pricing---- (use a heatmap or matrix)
SELECT Bedrooms,
	Bathrooms,
	AVG(Property_price_USD) AS avg_prop_price
FROM dbo.zillow_properties_florida
GROUP BY Bedrooms, Bathrooms
ORDER BY AVG(Property_price_USD) DESC;

-- Time on Market vs Price Brackets (use line chart or clustered column)
SELECT price_bracket,
	AVG(Number_of_days_on_Zillow) AS avg_days
FROM (
	SELECT Number_of_days_on_Zillow,
		CASE
			WHEN Property_price_USD < 295000 THEN '<295k'
			WHEN Property_price_USD BETWEEN 295000 AND 6265000 THEN '$295k-$626.5k'
			ELSE '>626.5k'
		END AS price_bracket
	FROM dbo.zillow_properties_florida
	) AS t
GROUP BY price_bracket
ORDER BY avg_days DESC;

----Market tier segmentation---- (use a stacked bar chart or map shading)
	WITH PriceStats AS (
		SELECT
			City,
			AVG(Property_price_USD) AS avg_prop_price,
			PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY AVG(Property_price_USD)) OVER () AS Q1,
			PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY AVG(Property_price_USD)) OVER () AS Q2,
			PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY AVG(Property_price_USD)) OVER () AS Q3
		FROM dbo.zillow_properties_florida
		GROUP BY City
	)

SELECT City,
	avg_prop_price,
	CASE 
		WHEN avg_prop_price < Q1 THEN 'Low Tier'
		WHEN avg_prop_price BETWEEN Q1 AND Q3 THEN 'Mid Tier'
		ELSE 'High Tier'
	END AS price_tier
FROM PriceStats;

----Lot size impact (scatter + trendline, table)
SELECT City,
	    ROUND((AVG(Property_price_USD * lot_land_area)
     - AVG(Property_price_USD) * AVG(lot_land_area))
    / (STDEV(Property_price_USD) * STDEV(lot_land_area)),3) AS lot_price_correlation
FROM dbo.zillow_properties_florida
WHERE Lot_land_area IS NOT NULL
GROUP BY City
HAVING STDEV(Property_price_USD) <> 0 AND STDEV(lot_land_area) <> 0
ORDER BY lot_price_correlation DESC;


----Top fastest selling cities
/*
SELECT TOP 10 City,
	AVG(Number_of_days_on_Zillow) AS avg_days_on_zillow
FROM dbo.zillow_properties_florida
GROUP BY City
ORDER BY AVG(Number_of_days_on_Zillow) ASC;
*/

/*
min_price   max_price	  Q1	    Q2	       Q3
5000	   285,000,000	295,000	  415,000	626,500
*/