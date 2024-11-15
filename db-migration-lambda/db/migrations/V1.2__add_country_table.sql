CREATE TABLE country (
    country_id         text,
    country_name       text,
    CONSTRAINT some_constraint UNIQUE (country_id)
);
