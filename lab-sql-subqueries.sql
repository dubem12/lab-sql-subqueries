use sakila;

-- Write SQL queries to perform the following tasks using the Sakila database:
-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT 
    f.title ,
    i.film_id,
    (SELECT COUNT(i.film_id)) AS number_of_copies
FROM film AS f
join inventory as i
on f.film_id= i.film_id
WHERE f.title = 'Hunchback Impossible';

-- List all films whose length is longer than the average length of all the films in the Sakila database.
select title, film_id, length from film
where length > (select avg(length) from film);

select * from film;
-- Use a subquery to display all actors who appear in the film "Alone Trip".
select actor_id, concat(first_name, ' ', last_name) as actor
from actor as a
where a.actor_id in(
	select distinct(fa.actor_id)
	from film_actor as fa
	join film as f
	on f.film_id=fa.film_id
	where f.title= 'Alone Trip'
);

select title from film
where film_id in
(select category_id from film_category
where category_id=8);

-- Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.


SELECT f.film_id, f.title, c.name as category_name
FROM film as f
JOIN film_category as fc 
ON f.film_id = fc.film_id
join category as c
on fc.category_id= c.category_id
WHERE c.name = 'family';

-- alternatively 
SELECT *
FROM film as f
JOIN film_category as fc 
ON f.film_id = fc.film_id
WHERE fc.category_id = (
    SELECT category_id
    FROM category
    WHERE name = 'family'
);

-- Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
select * from address;
select * from customer;
select * from city;
select * from country;

select concat(cu.first_name, ' ', cu.last_name) as customer_name, cu.email 
from customer as cu
join address as a 
on cu.address_id= a.address_id
where a.city_id in (
select ci.city_id
from city as ci 
join country as co
on ci.country_id=co.country_id
where co.country= 'Canada');


-- Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

SELECT film_id, GROUP_CONCAT(actor_id) AS actor_ids
FROM film_actor
GROUP BY film_id;
#check mosz prolific actor using the id 
select * from film;

SELECT f.actor_id, CONCAT(a.first_name, ' ', a.last_name) AS actor_name, COUNT(*) AS role_count
FROM film_actor as f
JOIN actor as a ON f.actor_id = a.actor_id
GROUP BY actor_id, actor_name
ORDER BY role_count DESC
LIMIT 1;

-- Determine which films were starred by the most prolific actor in the Sakila database. which has actor_id 107
select f.title , f.film_id
from film as f
join film_actor as fa
on f.film_id= fa.film_id
where fa.actor_id=107;

-- alternative in a subquery
select f.title, f.film_id
from film as f
join film_actor as fa on f.film_id = fa.film_id
where fa.actor_id = (
    select actor_id
    from (
        select f.actor_id, CONCAT(a.first_name, ' ', a.last_name) as actor_name, COUNT(*) as role_count
        from film_actor as f
        join actor as a on f.actor_id = a.actor_id
        group by actor_id, actor_name
        order by role_count DESC
        limit 1
    ) as sub1
);




-- Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

-- highest renter
select customer_id, sum(amount) from payment
group by customer_id
order by sum(amount) desc
limit  1;
-- find films rented by customer_id 526
 select * from rental;
 select * from inventory;
 select * from film;
 
 select f.title
from film as f
join inventory as i on f.film_id = i.film_id
join rental as r on i.inventory_id = r.inventory_id
where r.customer_id = 526;

-- alterntaiveöy a subquery will look like thus 

-- subquery
select f.title 
from film as f
join inventory as i on f.film_id = i.film_id
join rental as r on i.inventory_id = r.inventory_id
where r.customer_id = (
    select customer_id
    from payment
    group by customer_id
    order by sum(amount) desc
    limit 1
);

-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
select customer_id, total_amount_spent
from (
    select customer_id, sum(amount) as total_amount_spent
    from payment
    group by customer_id
) as client_payments
where total_amount_spent > (
    select avg(total_amount_spent)
    from (
        select sum(amount) as total_amount_spent
        from payment
        group by customer_id
    ) as avg_payments
);
