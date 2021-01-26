-- TIME DIMENSION
CREATE TABLE IF NOT EXISTS periods (
    id          SERIAL  PRIMARY KEY,
    year        INT     NOT NULL,
    quarter     INT     NOT NULL,
    month       INT     NOT NULL,
    UNIQUE(year, quarter, month)
);

-- LOCATION DIMENSION
CREATE TABLE IF NOT EXISTS territories (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(5)  NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS countries (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(16) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS cities (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(16) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS locations (
    id                          SERIAL      PRIMARY KEY,
    territory_id                INT         NOT NULL,
    FOREIGN KEY(territory_id)   REFERENCES  territories(id),
    country_id                  INT         NOT NULL,
    FOREIGN KEY(country_id)     REFERENCES  countries(id),
    city_id                     INT         NOT NULL,
    FOREIGN KEY(city_id)        REFERENCES  cities(id),
    UNIQUE(territory_id, country_id, city_id)
);

-- ORDER DETAILS DIMENSION
CREATE TABLE IF NOT EXISTS product_lines (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(16) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS product_codes (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS statuses (
    id      SERIAL      PRIMARY KEY,
    name    VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS order_details (
    id                              SERIAL      PRIMARY KEY,
    status_id                       INT         NOT NULL,
    FOREIGN KEY(status_id)          REFERENCES  statuses(id),
    product_line_id                 INT         NOT NULL,
    FOREIGN KEY(product_line_id)    REFERENCES  product_lines(id),
    product_code_id                 INT         NOT NULL,
    FOREIGN KEY(product_code_id)    REFERENCES  product_codes(id),
    UNIQUE(status_id, product_line_id, product_code_id)
);

-- ORDERS
CREATE TABLE IF NOT EXISTS orders (
    id                              SERIAL      PRIMARY KEY,
    period_id                       INT         NOT NULL,
    FOREIGN KEY(period_id)          REFERENCES  periods(id),
    location_id                     INT         NOT NULL,
    FOREIGN KEY(location_id)        REFERENCES  locations(id),
    order_detail_id                 INT         NOT NULL,
    FOREIGN KEY(order_detail_id)    REFERENCES  order_details(id),
    sales                           DECIMAL     NOT NULL
);
