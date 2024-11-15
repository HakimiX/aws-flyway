CREATE TABLE house (
    house_id         text,
    house_name       text,
    CONSTRAINT some_constraint UNIQUE (house_id)
);
