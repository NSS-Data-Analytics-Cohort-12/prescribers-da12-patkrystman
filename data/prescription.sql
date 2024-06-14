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

-- select drug.drug_name, 
-- 	drug.drug_name as drug_type,
-- 	case drug.drug_name
-- 		when 'opioid_drug_flag = 'Y'' then 'opioid'
-- 		when 'antibiotic_drug_flag = 'Y'' then 'antibiotic'
-- 		else
-- 			'neither'
-- 		end drug_type_description
-- from drug

-- select drug_name, 
-- 	case drug_name
-- 		when opioid_drug_flag = 'Y' then 'opioid'
-- 		when antibiotic_drug_flag = 'Y' then 'antibiotic'
-- 		else 'neither'
-- 	end drug_type_descrition
-- from drug





--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.





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


--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

-- select *
-- from cbsa
-- inner join population
-- using(fipscounty)
-- inner join fips_county
-- using(fipscounty)
-- order by population desc

-- select *
-- from population
-- full join fips_county
-- using(fipscounty)
-- inner join cbsa
-- using(fipscounty)
-- order by population.fipscounty desc
-- limit 100

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



--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

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



-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


-- select drug_name, specialty_description, nppes_provider_city, opioid_drug_flag
-- from prescriber
-- cross join drug
-- 	where prescriber.specialty_description = 'Pain Management'
-- 	and nppes_provider_city = 'NASHVILLE'
-- 	and opioid_drug_flag = 'Y'



--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

select drug_name, specialty_description, nppes_provider_city, opioid_drug_flag, npi, drug_name
from prescriber
cross join drug
	where prescriber.specialty_description = 'Pain Management'
	and nppes_provider_city = 'NASHVILLE'
	and opioid_drug_flag = 'Y'



--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.