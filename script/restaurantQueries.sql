--
--
--  NAME
--    restaurantQueries.sql;
--
-- DESCRIPTION
--   This script contains the 20 queries along with its result samples

--  USAGE
--       SQL> START <filepath>restaurantQueries.sql

--1 Get the information of customer 1004
select * from t_customer where customer_pk = '1004';
-- 1004	1940	44	1.53	Medium	No	Abstemious	Informal	Family	Public	Single	Professional


--2 What are the cuisines that the customer 1004 like?
select *
	from t_customer_cuisine s
	where s.customer_fk = '1004';
-- CUSTOMER_FK CUISINE
-- 1004	Bagels
-- 1004	Bakery
-- 1004	Breakfast-Brunch
-- ...


--3 What are the restaurant ratings given by customer 1004?
select *
	from t_rating t
	where t.customer_fk = '1004';
-- CUSTOMER_FK REST_FK FOOD SERVICE
-- 1004	135060	1	1
-- 1004	135028	2	2
-- 1004	135106	2	2
-- ...


--4 Which customer(s) made the most rating?
--  We describe these customers as the top reviewers
--  Create a view for our top reviewers: 
--  the view contains their customer ids and number of ratings
create or replace view v_topReviewers as
select customer_fk topReviewers_pk, count(customer_fk) nbOfratings
  from t_rating 
  group by customer_fk
  having count(customer_fk) 
  	=(select max(nbOfratings)
	 from (select customer_fk, count(customer_fk) nbOfratings
	      from t_rating
		  group by customer_fk));
select * from v_topReviewers;
-- TOPREVIEWERS_PK NBOFRATINGS
-- 1106	18
-- 1061	18


--5 Give the details of our top reviewers
select *
	from t_customer, v_topReviewers
	where v_topReviewers.topReviewers_pk = t_customer.customer_pk;
-- CUSTOMER_PK BIRTH_YEAR ...
-- 1106	1930	65	1.71	Medium	No	Casual Drinker	Informal	Friends	Car Owner	Single	Professional	1106	18
-- 1061	1990	40	1.76	Medium	No	Social Drinker	No Preference	Friends	Car Owner	Single	Professional	1061	18	


--6 Give the details of the restaurants along with the ratings given by our
--  top reviewers
select t.customer_fk, r.name, t.food, t.service, r.priceRange
	from t_rating t, t_restaurant r
	where t.customer_fk in (select topReviewers_pk from v_topReviewers)
	and   t.rest_fk = r.rest_pk
	order by t.customer_fk;
-- CUSTOMER_FK NAME FOOD SERVICE PRICERANGE
-- 1061	Cafe Chaires	2	2	Low
-- 1061	Gordas De Morales	2	1	Medium
-- 1061	Cabana Huasteca	2	2	Medium
-- ...
-- 1106	Cabana Huasteca	2	1	Medium
-- 1106	Gorditas Doa Gloria	1	1	Low
-- 1106	Unicols Pizza	1	0	Low
-- 1106	La Posada Del Virrey	2	2	High
-- ....


--7 Are there any customers that always rate 0 every rating?
--  Only include the customer if he/she has contributed more than 1 ratings
--  We describe these customers as the null reviewers
select customer_fk, sum(food+service)
	from t_rating
	where customer_fk in(
		select customer_fk
			from t_rating
			group by customer_fk
			having count(customer_fk) > 1)
	group by customer_fk
	having sum(food+service) = 0
	order by customer_fk;
-- CUSTOMER_FK SUM(FOOD+SERVICE)
-- 1019	0
-- 1031	0
-- 1047	0
-- ...

--8 Redo the previous question but only include customers that
--  have made more than 10 ratings. Create a view for it
create or replace view v_nullReviewers as
select customer_fk nullReviewers_pk, sum(food+service) as ratingSum
	from t_rating
	where customer_fk in(
		select customer_fk
			from t_rating
			group by customer_fk
			having count(customer_fk) > 10)
	group by customer_fk
	having sum(food+service) = 0
	order by customer_fk;
select * from v_nullReviewers;
-- NULLREVIEWERS_PK RATINGSUM
-- 1073	0
-- 1128	0
-- 1135	0


--9 Give the details of these null reviewers
select c.customer_pk nullReviewersID, c.birth_year, c.weight, c.height, c.budget, c.smoker, c.drinkLevel, c.maritalStatus, c.transport, c.activity
	from v_nullReviewers n, t_customer c
	where n.nullReviewers_pk = c.customer_pk;
-- nullReviewersID BIRTH_YEAR WEIGHT HEIGHT ...
-- 1073	1989	118	1.79	Medium	No	Abstemious	Widow	Car Owner	Unemployed
-- 1128	1986	66	1.72	Low	No	Casual Drinker	Single	Public	Student
-- 1135	1988	66	1.54	Low	No	Casual Drinker	Single	On Foot	Student


--10 Make a recommandation of a new list of restaurants for one of the null reviewers.
--   The null reviewer must have not rated the restaurant yet, and the restaurant
--   also serves one of his favourite dishes.
-- 	 The null reviewers IDs are = {1073, 1128, 1135}
--   We choose 1073
--   Create a view on the result.
	--  restaurants that serve 1073 favourite dishes
	create or replace view v_notRatedRestaurants as
	select v.rest_fk
	from t_serve v
	where v.cuisine = any (select cuisine from t_customer_cuisine where customer_fk = '1073')
  	minus
	-- restaurants rated by 1073 that serve 1073 favourite dishes 
	select v.rest_fk
	from t_serve v
	where v.rest_fk = any (select rest_fk from t_rating where customer_fk = '1073') 
	 and  v.cuisine = any (select cuisine from t_customer_cuisine where customer_fk = '1073');
select * from v_notRatedRestaurants;
-- REST_FK
-- 132732
-- 132767
-- 132825
-- ...


--11 Use the view from the previous question and complete the list with: 
--   the restaurant name
--   the average rating for each restaurant
--   the price range
--   Order the list by the ratings
select r.rest_pk, r.name, r.priceRange, round(avg(food)), round(avg(service))
	from t_restaurant r, t_rating t
	where r.rest_pk = t.rest_fk
  and t.rest_fk in (select rest_fk from v_notRatedRestaurants)
  GROUP BY r.rest_pk, r.name, r.priceRange
  order by round(avg(food)) desc, round(avg(service)) desc;
-- REST_PK NAME PRICERANGE FOOD SERVICE
-- 132922	Cafe Punta Del Cielo	Medium	2	2
-- 135074	Restaurante La Parroquia Potosina	High	2	2
-- 135035	El Mundo De La Pasta	High	2	2
-- 135073	Restaurante Bar El Gallinero	High	2	1
-- ...


--12 What are the top 10 most popular restaurants?
-- A restaurant is popular if it receives a lot of ratings
-- Create a view out of it
create or replace view v_top10Restaurants as
select * from(select rest_fk rest10ID, r.name as name, sum(t.food + t.service) as totalRating
  from t_rating t, t_restaurant r
  where t.rest_fk = r.rest_pk
  group by rest_fk, r.name
  order by sum(food + service) desc)
  where rownum <= 10;
select * from v_top10Restaurants;
select name, TotalRating from v_top10Restaurants;
-- NAME TOTALRATING
-- Tortas Locas Hipocampo	95
-- Puesto De Tacos	73
-- Cafeteria Y Restaurant El Pacifico	60
-- La Cantina Restaurante	58
-- ...


-- 13 What are the 10 most common dishes served by the top 10 restaurants?
select * from(
	select cuisine, count(cuisine)
	  from v_top10Restaurants tp, t_serve v
	  where v.rest_fk = tp.rest10id
	  group by cuisine
	  order by count(cuisine) desc)
where rownum <=10;

-- CUISINE COUNT(CUISINE)
-- International	7
-- American	6
-- Mexican	6
-- Dutch-Belgian	4
-- Pizzeria	4
-- Bar	4
-- Italian	3
-- Bar Pub Brewery	3
-- Greek	3
-- Chinese	2

-- 14 What are the 10 most common prefered dishes among the customers?
-- create a view out of it
create or replace view v_top10CustomerDishes as
select * from(  
select cuisine, count(cuisine)
  from t_customer_cuisine
  group by cuisine
  order by count(cuisine) desc)
where rownum <=10;
select * from v_top10CustomerDishes;

-- CUISINE  COUNT(CUISINE)
-- Mexican	97
-- American	11
-- Pizzeria	9
-- Cafeteria	9
-- Family	8
-- Cafe-Coffee Shop	8
-- Italian	7
-- Japanese	7
-- Latin American	6
-- Chinese	6

-- 15 What are the dishes most commonly served by the top 10 restaurants
-- that are also the most commonly prefered dishes among the customers?
-- We call these dishes as best dishes
-- Create a view out of it
create or replace view v_bestDishes as
select cuisine from(
	select cuisine, count(cuisine) ct
	  from v_top10Restaurants tp, t_serve v
	  where v.rest_fk = tp.rest10id
	  group by cuisine
	  order by count(cuisine) desc)
where rownum <=10
intersect
select cuisine from v_top10CustomerDishes;
select * from v_bestDishes;

-- CUISINE
-- American
-- Chinese
-- Italian
-- Mexican
-- Pizzeria

-- 17 How many restaurants are there in each state?
select state, count(state)
	from t_restaurant
	group by state;

-- 18 What are the most common dishes by state?
select state, cuisine, count(cuisine) servingRestaurants
  from t_serve v, t_restaurant r
  where v.rest_fk = r.rest_pk
  group by state, cuisine
  order by state ,count(cuisine) desc;
  
-- STATE CUISINE SERVINGRESTAURANTS
-- Morelos	Mexican	13
-- Morelos	International	6
-- Morelos	Greek	6
-- ...
-- San Luis Potosi	Mexican	59
-- San Luis Potosi	American	33
-- San Luis Potosi	International	32
-- ...
-- Tamaulipas	Dutch-Belgian	4
-- Tamaulipas	Mexican	3
-- Tamaulipas	Italian	1
-- ...
-- NA	Mexican	10
-- NA	Italian	9
-- NA	American	7

-- 19 Give some statistics on the customers' weight and height.
select 'Weight' "Customer's" ,count(*) count, 
       min(weight) min, 
       max(weight) max, 
       max(weight)-min(weight) range,
       round(avg(weight),2) mean,
       round(var_pop(weight),2) var,
       round(stddev_pop(weight),2) stddev,
       median(weight) median
       from t_customer
       union
select 'Height' "Customer's",count(*) count, 
       min(height) min, 
       max(height) max, 
       max(height)-min(height) range,
       round(avg(height),2) mean,
       round(var_pop(height),2) var,
       round(stddev_pop(height),2) stddev,
       median(height) median
       from t_customer;             
                                    
-- Height	138	1.2	2	0.8	1.67	0.02	0.13	1.69
-- Weight	138	40	120	80	64.87	294.19	17.15	65

-- 20 Write a report for the database
set linesize 80;
set pagesize 18;
spool resultRestaurant.txt
ttitle center 'The best dishes' skip 1 center 'Based on top 10 restaurant servings and top 10 customer dish preferences' sql.pno
btitle off
select cuisine "Dish" from v_bestDishes;
ttitle center 'The top 10 restaurants' skip 1 center 'Based on number of ratings received by the restaurants' sql.pno
column name for a40
select name, totalRating "Tot.Rating" from v_top10Restaurants;
ttitle center 'The top 10 reviewers' skip 1 center 'Based on number of ratings contributed by the customers' sql.pno
btitle right 'Prepared by Ahmad Afiq Che Johari'
select topReviewers_pk "Reviewer ID", nbOfratings "Ratings contributed" from v_topReviewers;
ttitle off
btitle off
spool off  
