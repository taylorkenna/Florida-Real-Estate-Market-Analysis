-- Average Property Price by City
SELECT city,
       AVG(Property_price_USD) AS avg_price_by_city
FROM dbo.zillow_properties_florida
GROUP BY city
ORDER BY AVG(Property_price_USD) DESC;

-- Average Days on Market by City
SELECT city,
       AVG(Number_of_days_on_Zillow) AS avg_days_on_zillow_by_city
FROM dbo.zillow_properties_florida
GROUP BY city
ORDER BY AVG(Number_of_days_on_Zillow) DESC;

-- Average Price per Square Foot by City
SELECT city,
       ROUND(AVG(Price_per_living_area_unit_USD),2) AS avg_price_per_sqft_by_city
FROM dbo.zillow_properties_florida
GROUP BY city
ORDER BY ROUND(AVG(Price_per_living_area_unit_USD),2) DESC;

-- Property Type Distribution
SELECT Property_type,
       COUNT(*) AS count_property_types
FROM dbo.zillow_properties_florida
GROUP BY Property_type
ORDER BY COUNT(*) DESC;

-- Market Tier Segmentation (Low, Mid, High Tier)
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

