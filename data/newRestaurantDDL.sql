--
--
--  NAME
--    restaurantDDL.sql;
--
-- DESCRIPTION
--   This script contains the DDLfor the restaurant database (c.f README)
--    14 tables: 
	 -- t_cuisine cascade constraints;
	 -- t_serve_alcohol cascade constraints; 
	 -- t_price_range cascade constraints;
	 -- t_state cascade constraints;
	 -- t_restaurant cascade constraints;
	 -- t_serve_cuisine cascade constraints;

	 -- t_smoker cascade constraints;
	 -- t_drinker cascade constraints;
	 -- t_marital cascade constraints;
	 -- t_budget cascade constraints;
	 -- t_activity cascade constraints;
	 -- t_customer cascade constraints;
	 -- t_rating cascade constraints;
	 -- t_customer_cuisine cascade constraints;
--  USAGE
--       SQL> START <filepath>restaurantDDL.sql


create table t_restaurant(
	rest_pk number(6,0) not null primary key,
	name varchar2(70) not null,
	address varchar2(70),
	state varchar2(10),
	zipcode number(5) check (zipcode between 00001 and 99999),
	alcohol varchar2(20),
	smoking varchar2(20),
	dressCode varchar2(10),
	priceRange varchar2(10)
	);

create table t_serve_cuisine(
	rest_fk references t_restaurant(rest_pk),
	cuisine varchar2(30)
	);

create table t_customer(
	customer_pk number not null primary key,
	birth_year number(4,0) check (birth_year > 1900),
	weight number(3,0) check (weight between 40 and 150),
	height number(3,2) check (height between 1.2 and 2.20),
	budget varchar2(10),
	smoker varchar2(3),
	drinkLevel varchar2(20),
	dressCode varchar2(20),
	ambiance varchar2(10),
	transport varchar2(15),
	maritalStatus varchar2(10),
	activity varchar2(20)
	);

create table t_rating(
	customer_fk references t_customer(customer_pk),
	rest_fk references t_restaurant(rest_pk),
	constraint rating_pk primary key(customer_fk,rest_fk),
	food number(1) check (food in (0, 1, 2)),
	service number(1) check (service in (0, 1, 2))
	);

create table t_customer_cuisine(
	customer_fk references t_customer(customer_pk),
	cuisine_fk references t_cuisine(cuisine_pk),
	constraint customer_cuisine_pk primary key (customer_fk, cuisine_fk)
	);
