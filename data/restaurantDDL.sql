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

drop table t_cuisine cascade constraints;
drop table t_serve_alcohol cascade constraints; 
drop table t_price_range cascade constraints;
drop table t_state cascade constraints;
drop table t_restaurant cascade constraints;
drop table t_serve_cuisine cascade constraints;

drop table t_smoker cascade constraints;
drop table t_drinker cascade constraints;
drop table t_marital cascade constraints;
drop table t_budget cascade constraints;
drop table t_activity cascade constraints;
drop table t_customer cascade constraints;
drop table t_rating cascade constraints;
drop table t_customer_cuisine cascade constraints;

create table t_cuisine(
	cuisine_pk number not null primary key,
	name varchar2(30)
	);
create table t_serve_alcohol(
	serve_alc_pk number not null primary key,
	description varchar2(20)
	);
create table t_price_range(
	price_range_pk number not null primary key,
	description varchar2(20)
	);
create table t_state(
	state_pk number not null primary key,
	name varchar2(20)
	);

create table t_restaurant(
	rest_pk number(6,0) not null primary key,
	name varchar2(60) not null,
	address varchar2(70),
	zipcode varchar2(30),
	state_fk number references t_state(state_pk),
	serve_alc_fk number references t_serve_alcohol(serve_alc_pk),
	price_range_fk number references t_price_range(price_range_pk) 
	);

create table t_serve_cuisine(
	rest_fk references t_restaurant(rest_pk),
	cuisine_fk references t_cuisine(cuisine_pk),
	constraint serve_cuisine_pk primary key (rest_fk,cuisine_fk)
	);

create table t_smoker(
	smoker_pk number not null primary key,
	description varchar2(10)
	);
create table t_drinker(
	drinker_pk number not null primary key,
	description varchar2(20)
	);
create table t_marital(
	marital_pk number not null primary key,
	description varchar2(10)
	);
create table t_budget(
	budget_pk number not null primary key,
	description varchar2(10)
	);
create table t_activity(
	activity_pk number not null primary key,
	description varchar2(20)
	);

create table t_customer(
	customer_pk number not null primary key,
	birth_year number(4,0),
	weight number(3,0),
	height number(3,2),
	smoker_fk number references t_smoker(smoker_pk),
	drinker_fk number references t_drinker(drinker_pk),
	marital_fk number references t_marital(marital_pk),
	budget_fk number references t_budget(budget_pk),
	activity_fk number references t_activity(activity_pk)
	);

create table t_rating(
	customer_fk references t_customer(customer_pk),
	rest_fk references t_restaurant(rest_pk),
	constraint rating_pk primary key(customer_fk,rest_fk),
	food number(1),
	service number(1)
	);

create table t_customer_cuisine(
	customer_fk references t_customer(customer_pk),
	cuisine_fk references t_cuisine(cuisine_pk),
	constraint customer_cuisine_pk primary key (customer_fk, cuisine_fk)
	);
