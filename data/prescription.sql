-- ## Prescribers Database

-- For this exericse, you'll be working with a database derived from the [Medicare Part D Prescriber Public Use File](https://www.hhs.gov/guidance/document/medicare-provider-utilization-and-payment-data-part-d-prescriber-0). More information about the data is contained in the Methodology PDF file. See also the included entity-relationship diagram.

-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

-- select prescriber.nppes_provider_last_org_name, prescription.total_claim_count
-- from prescriber
-- left join prescription
-- using (npi)
-- limit 10

-- answer_'CHOUNZOM, 18'

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

-- select prescriber.nppes_provider_last_org_name, prescription.total_claim_count, prescriber.nppes_provider_first_name, prescriber.specialty_description
-- from prescriber
-- left join prescription
-- using (npi)
-- limit 10

-- answer_'TENZING, CHOUNZOM, Interal Medicine, 18'


-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

-- select prescriber.specialty_description, prescription.total_claim_count
-- from prescriber
-- left join prescription
-- using(npi)
-- limit 10

-- answer_'Internal Medicine'

--     b. Which specialty had the most total number of claims for opioids?


-- select prescriber.specialty_description, SUM(prescription.total_claim_count)
-- from prescriber
-- inner join prescription
-- using(npi)
-- inner join drug
-- using(drug_name)
-- where opioid_drug_flag = 'Y'
-- 	or long_acting_opioid_drug_flag = 'Y'
-- group by specialty_description
-- order by sum desc

-- answer_'Nurse Pracitioner, 900845'


--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

-- an except can be used here


--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?




-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

-- select drug.generic_name, prescription.total_drug_cost
-- from drug
-- inner join prescription
-- using(drug_name)
-- order by prescription.total_drug_cost desc
-- limit 10

-- answer_'PERFENIDONE, $2,829,174.30'




--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

-- select drug.generic_name, (prescription.total_drug_cost / 365) as total_cost_per_day
-- from drug
-- inner join prescription
-- using(drug_name)
-- order by prescription.total_drug_cost desc
-- limit 10

-- answer_'PIRFENIDONE, $7,751.16 per day'


-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 

-- select 
-- 	drug_name,
-- 	case
-- 		when opioid_drug_flag = 'Y' then 'opioid'
-- 		when antibiotic_drug_flag = 'Y' then 'antibiotic'
-- 		else 'neither'
-- 	end drug_type
-- from drug
-- order by drug_type


--     b. Building off of the query you wrote for part a, determine 
-- 	whether more was spent (total_drug_cost) on opioids or on antibiotics. 
-- 	Hint: Format the total costs as MONEY for easier comparision.

-- select sum(total_drug_cost) ::MONEY,
-- 	case
-- 		when opioid_drug_flag = 'Y' then 'opioid'
-- 		when antibiotic_drug_flag = 'Y' then 'antibiotic'
-- 		else 'neither'
-- 	end drug_type
-- from drug
-- inner join prescription
-- 	using(drug_name)
-- group by drug_type
-- order by sum(total_drug_cost) desc



-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

-- select *
-- from cbsa
-- left join fips_county
-- using(Fipscounty)
-- where fips_county.state = 'TN'

-- answer_'42'

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

-- select distinct cbsa, population, cbsaname
-- from cbsa
-- inner join population
-- using(fipscounty)
-- order by population

-- answer_'largest, 32820, 937847', 'smallest, 34980, 8773'


--     c. What is the largest (in terms of population) county which is not included in a CBSA? 
-- 		Report the county name and population.

-- select *
-- from population
-- 	left join cbsa
-- using(fipscounty)
-- 	left join fips_county
-- using(fipscounty)
-- order by population desc

-- answer_'county name Sevier, population 95523'

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

-- select p1.drug_name, p1.total_claim_count
-- from prescription as p1
-- 	where p1.total_claim_count >= 3000
-- order by p1.total_claim_count desc

-- answer_'OXYCODONE HCL, 4538'



--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

-- select p1.drug_name, p1.total_claim_count, drug.opioid_drug_flag
-- from prescription as p1
-- inner join drug
-- using(drug_name)
-- where p1.total_claim_count >= 3000
-- order by p1.total_claim_count desc



--     c. Add another column to you answer from the previous part which gives the 
--		prescriber first and last name associated with each row.

-- select p1.drug_name, 
-- 	p1.total_claim_count, 
-- 	drug.opioid_drug_flag, 
-- 	p2.nppes_provider_first_name, 
-- 	p2.nppes_provider_last_org_name
-- from prescription as p1
-- inner join drug
-- using(drug_name)
-- inner join prescriber as p2
-- using(npi)
-- where p1.total_claim_count >= 3000
-- order by p1.total_claim_count desc



-- 7. The goal of this exercise is to generate a full list of all pain management specialists 
--		in Nashville and the number of claims they had for each opioid. 
--		**Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for 
--		pain management specialists (specialty_description = 'Pain Management) in the 
--		city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an 
--		opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. 
--		You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


-- select drug_name, specialty_description, nppes_provider_city, opioid_drug_flag
-- from prescriber
-- cross join drug
	-- where prescriber.specialty_description = 'Pain Management'
	-- and nppes_provider_city = 'NASHVILLE'
	-- and opioid_drug_flag = 'Y'



--     b. Next, report the number of claims per drug per prescriber. Be sure to include all 
--		combinations, whether or not the prescriber had any claims. You should report the npi, 
-- 		the drug name, and the number of claims (total_claim_count).

-- select nppes_provider_first_name, nppes_provider_last_org_name, npi, drug_name, total_claim_count
-- from prescriber
-- cross join drug
-- left join prescription
-- using(npi, drug_name)
-- where prescriber.specialty_description = 'Pain Management'
-- 	and nppes_provider_city = 'NASHVILLE'
-- 	and opioid_drug_flag = 'Y'
-- order by nppes_provider_first_name



--     c. Finally, if you have not done so already, fill in any missing values 
-- 		for total_claim_count with 0. Hint - Google the COALESCE function.

-- select nppes_provider_first_name, nppes_provider_last_org_name, npi, drug_name, coalesce(total_claim_count, 0)
-- from prescriber
-- cross join drug
-- left join prescription
-- using(npi, drug_name)
-- where prescriber.specialty_description = 'Pain Management'
-- 	and nppes_provider_city = 'NASHVILLE'
-- 	and opioid_drug_flag = 'Y'
-- order by total_claim_count



-- In this set of exercises you are going to explore additional ways to group and organize the output of a query when using postgres. 

-- For the first few exercises, we are going to compare the total number of claims from Interventional Pain Management Specialists compared to those from Pain Managment specialists.

-- 1. Write a query which returns the total number of claims for these two groups. 
-- Your output should look like this: 

-- specialty_description         |total_claims|
-- ------------------------------|------------|
-- Interventional Pain Management|       55906|
-- Pain Management               |       70853|


-- select specialty_description, sum(total_claim_count) as total_claims
-- from prescriber
-- inner join prescription
-- using(npi)
-- where specialty_description = 'Interventional Pain Management'
-- 	or specialty_description = 'Pain Management'
-- group by specialty_description
-- order by total_claims


-- 2. Now, let's say that we want our output to also include the total number of claims between these two groups. 
-- Combine two queries with the UNION keyword to accomplish this. Your output should look like this:

-- specialty_description         |total_claims|
-- ------------------------------|------------|
--                               |      126759|
-- Interventional Pain Management|       55906|
-- Pain Management               |       70853|

select specialty_description, sum(total_claim_count) as total_claims
from prescriber
inner join prescription
using(npi)
where specialty_description = 'Interventional Pain Management'
	or specialty_description = 'Pain Management'
group by specialty_description
order by total_claims
UNION
select 




-- 3. Now, instead of using UNION, make use of GROUPING SETS (https://www.postgresql.org/docs/10/queries-table-expressions.html#QUERIES-GROUPING-SETS) to achieve the same output.

-- 4. In addition to comparing the total number of prescriptions by specialty, let's also bring in information about the number of opioid vs. non-opioid claims by these two specialties. Modify your query (still making use of GROUPING SETS so that your output also shows the total number of opioid claims vs. non-opioid claims by these two specialites:

-- specialty_description         |opioid_drug_flag|total_claims|
-- ------------------------------|----------------|------------|
--                               |                |      129726|
--                               |Y               |       76143|
--                               |N               |       53583|
-- Pain Management               |                |       72487|
-- Interventional Pain Management|                |       57239|

-- 5. Modify your query by replacing the GROUPING SETS with ROLLUP(opioid_drug_flag, specialty_description). How is the result different from the output from the previous query?

-- 6. Switch the order of the variables inside the ROLLUP. That is, use ROLLUP(specialty_description, opioid_drug_flag). How does this change the result?

-- 7. Finally, change your query to use the CUBE function instead of ROLLUP. How does this impact the output?

-- 8. In this question, your goal is to create a pivot table showing for each of the 4 largest cities in Tennessee (Nashville, Memphis, Knoxville, and Chattanooga), the total claim count for each of six common types of opioids: Hydrocodone, Oxycodone, Oxymorphone, Morphine, Codeine, and Fentanyl. For the purpose of this question, we will put a drug into one of the six listed categories if it has the category name as part of its generic name. For example, we could count both of "ACETAMINOPHEN WITH CODEINE" and "CODEINE SULFATE" as being "CODEINE" for the purposes of this question.

-- The end result of this question should be a table formatted like this:

-- city       |codeine|fentanyl|hyrdocodone|morphine|oxycodone|oxymorphone|
-- -----------|-------|--------|-----------|--------|---------|-----------|
-- CHATTANOOGA|   1323|    3689|      68315|   12126|    49519|       1317|
-- KNOXVILLE  |   2744|    4811|      78529|   20946|    84730|       9186|
-- MEMPHIS    |   4697|    3666|      68036|    4898|    38295|        189|
-- NASHVILLE  |   2043|    6119|      88669|   13572|    62859|       1261|

-- For this question, you should look into use the crosstab function, which is part of the tablefunc extension (https://www.postgresql.org/docs/9.5/tablefunc.html). In order to use this function, you must (one time per database) run the command
-- 	CREATE EXTENSION tablefunc;

-- Hint #1: First write a query which will label each drug in the drug table using the six categories listed above.
-- Hint #2: In order to use the crosstab function, you need to first write a query which will produce a table with one row_name column, one category column, and one value column. So in this case, you need to have a city column, a drug label column, and a total claim count column.
-- Hint #3: The sql statement that goes inside of crosstab must be surrounded by single quotes. If the query that you are using also uses single quotes, you'll need to escape them by turning them into double-single quotes.