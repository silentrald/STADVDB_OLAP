-- TIME DIMENSION
CREATE TABLE times (
    time_id     SERIAL  PRIMARY KEY,
    year        INT     NOT NULL,
    quarter     INT     NOT NULL,
    month       INT     NOT NULL
);

-- LOCATION DIMENSION
CREATE TABLE territories (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(5)  NOT NULL
);

CREATE TABLE countries (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(16) NOT NULL
);

CREATE TABLE cities (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(16) NOT NULL
);

CREATE TABLE locations (
    location_id                 SERIAL      PRIMARY KEY,
    territory_id                INT         NOT NULL,
    FOREIGN KEY(territory_id)   REFERENCES  territories(id),
    country_id                  INT         NOT NULL,
    FOREIGN KEY(country_id)     REFERENCES  countries(id),
    city_id                     INT         NOT NULL,
    FOREIGN KEY(city_id)        REFERENCES  cities(id)
);

-- ORDER DETAILS DIMENSION
CREATE TABLE product_lines (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(16) NOT NULL
);

CREATE TABLE product_codes (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(10)  NOT NULL
);

CREATE TABLE statuses (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(10) NOT NULL
);

CREATE TABLE order_details (
    order_detail_id                 SERIAL      PRIMARY KEY,
    status_id                       INT         NOT NULL,
    FOREIGN KEY(status_id)          REFERENCES  statuses(id),
    product_line_id                 INT         NOT NULL,
    FOREIGN KEY(product_line_id)    REFERENCES  product_lines(id),
    product_code_id                 INT         NOT NULL,
    FOREIGN KEY(product_code_id)    REFERENCES  product_codes(id)
);

-- CUSTOMERS DIMENSION
-- CREATE TABLE customers (
--     customer_id     SERIAL      PRIMARY KEY,
--     name            VARCHAR     NOT NULL, /* TODO: Set a number */
--     contact_fname   VARCHAR     NOT NULL,
--     contact_lname   VARCHAR     NOT NULL,
--     contact_num     VARCHAR     NOT NULL
-- );

-- ORDERS
CREATE TABLE orders (
    order_id                        SERIAL      PRIMARY KEY,
    time_id                         INT         NOT NULL,
    FOREIGN KEY(time_id)            REFERENCES  times(time_id),
    location_id                     INT         NOT NULL,
    FOREIGN KEY(location_id)        REFERENCES  locations(location_id),
    order_detail_id                 INT         NOT NULL,
    FOREIGN KEY(order_detail_id)    REFERENCES  order_details(order_detail_id),
    sales                           DECIMAL     NOT NULL
);
