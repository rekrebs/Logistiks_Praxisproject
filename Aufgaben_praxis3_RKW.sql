/* Question B, Rebecca Krebs 08.07.2026

B1 Welche Trucks haben die höchsten Wartungskosten? Gibt es Baujahre, die auffällig oft in die Werkstatt
müssen?
B2 Wie unterscheidet sich der durchschnittliche Kraftstoffverbrauch zwischen verschiedenen Baujahren oder
Kraftstoffarten?
B3 Welcher Anteil der Flotte (Trucks, Trailer) ist aktuell außer Betrieb? Gibt es Standorte mit auffällig hohem
Ausfallanteil?
B4 Gibt es einen Zusammenhang zwischen dem Alter eines Trucks und der Ausfallzeit durch Wartung?
B5 ★ Welche Trucks liegen bei den Wartungskosten pro gefahrener Meile deutlich über dem
Flottendurchschnitt?*\
 */

 --B1 Which trucks have the highest maintenance costs? are there years (makes to) that are more often in
--the shop?

--We need to answer this question:
--frequency year and make in shop

--attempt 1 (total cost by model year)-- this shows the sum of maintenance costs per year model (not taking into account number of trucks in each year)
SELECT SUM(mr.total_cost),
       tr.model_year
FROM Logistik.maintenance_records as mr
JOIN logistik.trucks as tr ON mr.truck_id = tr.truck_id
GROUP BY tr.model_year; --most money on 2015, but I already know the most trucks are from this year too, so it isn´t surprising

-----attempt 2 --- just year, but now corrected for times visited the shop, total cost and cost per visit.
--I must do the same for make and then I want to try make and model (for interaction if that is possible)
--in R
-- total visits, total maintenance costs, and average cost per vists, but still not considering how many trucks are in each group
--just looking at the data I can see there are a lot from 2015
SELECT tr.model_year,
       COUNT(mr.maintenance_id) as total_workshop_visits, -- wie viele besuch
       SUM(mr.total_cost) as total_maintenance_cost, --total cost
       AVG(mr.total_cost) as avg_cost_per_visit   -- average per visit (are some more expensive to repair?)
FROM Logistik.maintenance_records as mr
JOIN logistik.trucks as tr ON mr.truck_id = tr.truck_id
GROUP BY tr.model_year   --group by  model year
ORDER BY total_workshop_visits DESC; --sort by trips to workshop highest


----both together, same as above, but added truck ID and Make, this would be nice to try in R
-- adding both with truck id so I can have an idea of the cost per truck and per visit
SELECT tr.truck_id, --add truck id
       tr.model_year,
       tr.make,
       COUNT(mr.maintenance_id) as total_workshop_visits, --how many visits to the workshop
       SUM(mr.total_cost) as total_maintenance_cost, --total maintenance cost
       AVG(mr.total_cost) as avg_cost_per_visit --average maintenance cost per trip
FROM Logistik.maintenance_records as mr
JOIN logistik.trucks as tr ON mr.truck_id = tr.truck_id
GROUP BY tr.truck_id, tr.model_year, tr.make --truck id, model year, make
ORDER BY total_maintenance_cost DESC;
--------------
--FINAL ANSWER -- ok, maybe not, it looks overloaded ( and I know later the true issue is going to be new vs old trucks.
--- I am going to separate this into two anyway though)
------------ Does one kind of truck have more breakdowns/is more expensive to repair
SELECT tr.make, --make to list makes
       COUNT(DISTINCT tr.model_year) AS count_number_of_years, -- how many per year model
       COUNT(DISTINCT tr.truck_id) AS total_trucks_owned, -- unique to count only once per id
       COUNT(mr.maintenance_id) AS total_workshop_visits,
       SUM(mr.total_cost) AS total_maintenance_cost,
       ROUND(SUM(mr.total_cost) / COUNT(DISTINCT tr.truck_id),2) AS avg_cost_per_truck,--- average price of maintanence per truck
       ROUND(AVG(mr.total_cost),2) AS avg_cost_per_visit
FROM Logistik.maintenance_records AS mr
JOIN logistik.trucks AS tr ON mr.truck_id = tr.truck_id
GROUP BY tr.make
ORDER BY avg_cost_per_truck DESC;


SELECT tr.make, --make to list makes
       COUNT(DISTINCT tr.truck_id) AS total_trucks_owned, -- unique to count only once per id
       COUNT(mr.maintenance_id) AS total_workshop_visits,
       SUM(mr.total_cost) AS total_maintenance_cost,
       ROUND(SUM(mr.total_cost) / COUNT(DISTINCT tr.truck_id),2) AS avg_cost_per_truck,--- average price of maintanence per truck
       ROUND(AVG(mr.total_cost),2) AS avg_cost_per_visit
FROM Logistik.maintenance_records AS mr
JOIN logistik.trucks AS tr ON mr.truck_id = tr.truck_id
GROUP BY tr.make
ORDER BY avg_cost_per_truck DESC;



SELECT tr.model_year, --make to list years
       COUNT(DISTINCT tr.truck_id) AS total_trucks_owned, -- unique to count only once per id
       COUNT(mr.maintenance_id) AS total_workshop_visits,
       SUM(mr.total_cost) AS total_maintenance_cost,
       ROUND(SUM(mr.total_cost) / COUNT(DISTINCT tr.truck_id),2) AS avg_cost_per_truck,--- average price of maintanence per truck
       ROUND(AVG(mr.total_cost),2) AS avg_cost_per_visit
FROM Logistik.maintenance_records AS mr
JOIN logistik.trucks AS tr ON mr.truck_id = tr.truck_id
GROUP BY tr.model_year
ORDER BY avg_cost_per_truck DESC;

--newer truck is most expensive right now to maintain (based on the average cost per truck (1) and visits to shop (32)

--B2 Wie unterscheidet sich der durchschnittliche Kraftstoffverbrauch zwischen verschiedenen Baujahren oder
--Kraftstoffarten?

--all trucks a diesel, its the USA
-- measured in miles per gallon (directly from trips table and also by dividing the actual distance travel by actual fuel used.


SELECT tr.model_year, --year
       tr.fuel_type, --its all diesel but why not
       ROUND(AVG(ts.average_mpg), 2) AS average_MPG, --- miles per gallon average
       SUM(ts.actual_distance_miles) / NULLIF(SUM(ts.fuel_gallons_used), 0) AS true_weighted_mpg, -- do not divide by 0 (distance of actual gallons since we have that too)
       COUNT(ts.trip_id) AS total_trips --trips taken by each truck
     FROM Logistik.trucks AS tr JOIN Logistik.trips AS ts ON tr.truck_id = ts.truck_id
GROUP BY tr.model_year,tr.fuel_type
ORDER BY tr.fuel_type, tr.model_year DESC;

--lets throw in make for fun since the query is basically already written

SELECT tr.make, --type of truck
       tr.fuel_type, --its all diesel but why not
       ROUND(AVG(ts.average_mpg), 2) AS average_MPG, --- miles per gallon average
       SUM(ts.actual_distance_miles) / NULLIF(SUM(ts.fuel_gallons_used), 0) AS true_weighted_mpg, -- do not divide by 0 (distance of actual gallons since we have that too)
       COUNT(ts.trip_id) AS total_trips --trips taken by each truck
     FROM Logistik.trucks AS tr JOIN Logistik.trips AS ts ON tr.truck_id = ts.truck_id
GROUP BY tr.make,tr.fuel_type
ORDER BY tr.fuel_type, tr.make DESC;
--- they all seem about the same





---B3 Welcher Anteil der Flotte (Trucks, Trailer) ist aktuell außer Betrieb? Gibt es Standorte mit auffällig hohem
--Ausfallanteil?

--how many and of what type?
SELECT count(truck_id) AS count,
        make,
       CONCAT(MIN(model_year), '-', MAX(model_year)) AS years_list-- show the range from oldest to newest
    FROM Logistik.trucks
GROUP BY make
ORDER BY count;


--same question but for trailers

SELECT count(trailer_id) AS count,
        trailer_type,
        status,  --are they active or inactive? are they all active?
        CONCAT(MIN(model_year), '-', MAX(model_year)) AS years_list -- same as above but for the trailers
    FROM Logistik.trailers
GROUP BY trailer_type, status
ORDER BY count;


 --are they active or inactive? are they all active?
------------------------------------------------------------------------------------

SELECT count(trailer_id) AS count,
        status
    FROM Logistik.trailers
GROUP BY status
ORDER BY count; --yes

SELECT count(truck_id) AS count,
        status
    FROM Logistik.trucks
GROUP BY status
ORDER BY count; --no


--------------------------------------------------
--which trailers are not active?
SELECT count(trailer_id) AS count,
        status,
        current_location
    FROM Logistik.trailers
GROUP BY status,current_location
ORDER BY count;
---which trucks are not active?
SELECT count(truck_id) AS count,
        status
    FROM Logistik.trucks
GROUP BY status
ORDER BY count;

---------------------------------------------what about standorte??
SELECT home_terminal AS Location, --where are the trucks located (home terminal, not travel location)
    COUNT(truck_id) AS Total_Trucks, -- how many trucks at each location
    SUM(CASE WHEN status IN ('Inactive', 'Maintenance') THEN 1 ELSE 0 END) AS Broken_Trucks, -- count trucks in repair
    ROUND((SUM(CASE WHEN status IN ('Inactive', 'Maintenance') THEN 1.0 ELSE 0.0 END) * 100.0) / COUNT(truck_id), 2) AS Truck_out_Percent  -- make a percent out of service divided by total trucks in a location
FROM Logistik.trucks
GROUP BY home_terminal
ORDER BY Truck_out_Percent DESC;


SELECT home_terminal AS Location,
    model_year,
    COUNT(truck_id) AS Total_Trucks,
    SUM(CASE WHEN status IN ('Inactive', 'Maintenance') THEN 1 ELSE 0 END) AS Broken_Trucks,
    ROUND((SUM(CASE WHEN status IN ('Inactive', 'Maintenance') THEN 1.0 ELSE 0.0 END) * 100.0) / COUNT(truck_id), 2) AS Truck_out_Percent
FROM Logistik.trucks
WHERE home_terminal IN ('Detroit', 'Miami', 'Phoenix', 'New York') -- problem cities
GROUP BY model_year, home_terminal
ORDER BY Truck_out_Percent DESC;
-------





SELECT current_location AS Location,
    COUNT(trailer_id) AS Total_Trailers,  --count all trailers
    SUM(CASE WHEN status IN ('Inactive') THEN 1 ELSE 0 END) AS Broken_Trailers --count ot of service ( should be none)
FROM Logistik.trailers
GROUP BY current_location;




---------------------------------------------what about age of trucks??
SELECT model_year,
    COUNT(truck_id) AS Total_Trucks,
    SUM(CASE WHEN status IN ('Inactive', 'Maintenance') THEN 1 ELSE 0 END) AS Broken_Trucks,
    ROUND((SUM(CASE WHEN status IN ('Inactive', 'Maintenance') THEN 1.0 ELSE 0.0 END) * 100.0) / COUNT(truck_id), 2) AS Truck_outoforder_Percent
FROM Logistik.trucks
GROUP BY model_year
ORDER BY Truck_outoforder_Percent DESC; --- almost half the trucks from 2018 are out of service ( majority are from 2015)

--B5---------------------------------------------------------------------------------------------------------

  SELECT COUNT(DISTINCT (truck_id))
   FROM Logistik.maintenance_records; --all one 120 have a maintennce record...



WITH truck AS (SELECT lt.truck_id,
                      make,
                      model_year,
       AVG(total_cost) AS mc_avg_truck
               FROM Logistik.maintenance_records AS mr
JOIN Logistik.trucks as lt ON mr.truck_id = lt.truck_id
GROUP BY lt.truck_id, lt.make, lt.model_year),

fleet AS (SELECT avg(mc_avg_truck) AS mc_fleet_avg
FROM truck)

SELECT t.make,
       t.model_year,
       t.mc_avg_truck,
       f.mc_fleet_avg,
       ROUND(((t.mc_avg_truck - f.mc_fleet_avg) / f.mc_fleet_avg) * 100, 1) AS percent_above_average
FROM truck t
CROSS JOIN fleet f -- Cartesian join
WHERE t.mc_avg_truck > f.mc_fleet_avg
ORDER BY t.mc_avg_truck DESC;


--------------------------------------------------------------------------


SELECT truck_id,
        SUM(total_cost) AS total_truck_cost --get cost per truck
    FROM Logistik.maintenance_records
    GROUP BY truck_id;

    SELECT truck_id,
        SUM(actual_distance_miles) AS total_truck_miles --miles per truck
    FROM Logistik.trips
    GROUP BY truck_id;
------------------------

WITH Maintenance_Totals AS (   --query 1
    SELECT
        truck_id,
        SUM(total_cost) AS total_truck_cost   -- total lifetime truck cost per truck id
    FROM Logistik.maintenance_records
    GROUP BY truck_id
),  --- start with costs per truck
Trip_Totals AS (   --query 2
    SELECT
        truck_id,
        SUM(actual_distance_miles) AS total_truck_miles -- (total trip miles traveled in service)
    FROM Logistik.trips
    GROUP BY truck_id
), --trip miles per truck
Truck AS (  --query 3
    SELECT
        tr.truck_id,
        tr.model_year,
        tr.make,
        m.total_truck_cost AS total_truck_cost,  --total truck costs from maintenance table
        t.total_truck_miles AS total_truck_miles,  --total miles from total trips table
        m.total_truck_cost / NULLIF(t.total_truck_miles, 0) AS truck_cpm  --   -- Calculate Cost Per Mile (CPM) --replace null values if the truck went nowhere. no rounded so the numbers are more accurate
    FROM Logistik.trucks AS tr
    LEFT JOIN Maintenance_Totals m ON tr.truck_id = m.truck_id
    LEFT JOIN Trip_Totals t ON tr.truck_id = t.truck_id
),
Fleet AS (   --query 4
    SELECT AVG(truck_cpm) AS fleet_avg_cpm  --the cpm for the entire fleet. What is the average of all trucks to compare to individual trucks
    FROM Truck
)
SELECT --query 5
    tm.truck_id,
    tm.make,
    tm.model_year,
    tm.total_truck_cost,
    tm.total_truck_miles,
    tm.truck_cpm,
    ROUND(fm.fleet_avg_cpm, 2) AS fleet_avg_cpm, -- the average for the fleet.
    ROUND(((tm.truck_cpm - fm.fleet_avg_cpm) / fm.fleet_avg_cpm) * 100, 1) AS percent_above_average -- ratio truck average - fleet average / fleet average ( IE Relative variance) Can be positive or negative. (negative good, positive bad)
FROM Truck tm
CROSS JOIN Fleet fm -- Cartesian join, so here I can stack multiple values behind one (like transpose) to compare each truck avg to the entire fleet avg
WHERE tm.truck_cpm > fm.fleet_avg_cpm -- show above average
ORDER BY tm.truck_cpm DESC;



--FUEL PURCHASES RABBIT HOLE
-------I just read the cpm is usually also used for fuel cost too...I wonder if I could get that too?
--we need an average price for fleet fuel
--average fuel price per truck
--fuel purchases table ( I know this will differ from state to state) but that feels like a lot for me
--lets start with basics
--query 1
WITH truck AS (SELECT fp.truck_id,
                      lt.make,
                      lt.model_year,
       AVG(fp.total_cost) AS fuel_avg_truck
FROM Logistik.trucks as lt
   LEFT JOIN Logistik.fuel_purchases as fp ON fp.truck_id = lt.truck_id  -- I am starting to wonder why some fuel seems to be bought without a truck id
GROUP BY fp.truck_id, lt.make, lt.model_year),

fleet AS (SELECT avg(fuel_avg_truck) AS fuel_fleet_avg
FROM truck)

SELECT t.truck_id,
       t.make,
       t.model_year,
       t.fuel_avg_truck,
       f.fuel_fleet_avg,
       ROUND(((t.fuel_avg_truck - f.fuel_fleet_avg) / f.fuel_fleet_avg) * 100, 1) AS percent_above_average
FROM truck t
CROSS JOIN fleet f -- Cartesian join
--WHERE t.fuel_avg_truck > f.fuel_fleet_avg (I want to look at all and not just above avg)
ORDER BY t.fuel_avg_truck DESC;


--- im curious about drivers that bought fuel with no truck id
SELECT COUNT(*),
       SUM(total_cost)
FROM Logistik.fuel_purchases
WHERE truck_id IS NULL;

SELECT COUNT(*),
       SUM(total_cost)
FROM Logistik.fuel_purchases
WHERE driver_id IS NULL;

SELECT COUNT(*),
       SUM(total_cost)
FROM Logistik.fuel_purchases
WHERE driver_id IS NULL OR truck_id IS NULL;


SELECT COUNT(*),
       SUM(total_cost)
FROM Logistik.fuel_purchases
WHERE driver_id IS NULL AND truck_id IS NULL; -- WHAT? -- 94,44949.44

SELECT purchase_date, -- when
    location_city,   -- which city
    fuel_card_number, --which cards
    total_cost
FROM Logistik.fuel_purchases
WHERE driver_id IS NULL AND truck_id IS NULL
ORDER BY total_cost DESC;


-------------------------------
SELECT fuel_card_number,
    COUNT(*) AS total_ghosts,
    ROUND(SUM(total_cost), 2) AS total_spend,
    MIN(purchase_date) AS oldest,
    MAX(purchase_date) AS mostrecent
FROM Logistik.fuel_purchases
WHERE driver_id IS NULL AND truck_id IS NULL
GROUP BY driver_id,fuel_card_number
ORDER BY total_spend DESC;
--lets make a case when to show this better for fun

--count ghosts to assigned transactions... for graph
SELECT
    COUNT(CASE WHEN driver_id IS NULL AND truck_id IS NULL THEN 1 END) AS count_ghosts,
    COUNT(fuel_purchase_id) AS total
FROM Logistik.fuel_purchases;


SELECT fuel_card_number,
    COUNT(*) AS total_ghosts,
    ROUND(SUM(total_cost), 2) AS total_spend,
    MIN(purchase_date) AS oldest,
    MAX(purchase_date) AS mostrecent
FROM Logistik.fuel_purchases
WHERE driver_id IS NULL AND truck_id IS NULL
GROUP BY driver_id,fuel_card_number
ORDER BY total_spend DESC;




---so-- it has happened on 94 cards and only once ever?

--just check how many cards are in the system.

SELECT COUNT(DISTINCT fuel_card_number) AS total_unique_cards
FROM Logistik.fuel_purchases; --176645 (What?)

SELECT truck_id,
    COUNT(*) AS total_fuel_purchases,
    COUNT(DISTINCT fuel_card_number) AS unique_cards_assigned_to_this_truck
FROM Logistik.fuel_purchases
WHERE truck_id IS NOT NULL
GROUP BY truck_id
HAVING COUNT(*) > 50
ORDER BY unique_cards_assigned_to_this_truck DESC;

--- okay, I get it now. the internet says it is an API drop rate.
-- if we have 176645 unique cards, and most trucks have made 2283 purchases with like, 2279 cards,
-- 94 von 196442 is below the expected failure rate -- cool
