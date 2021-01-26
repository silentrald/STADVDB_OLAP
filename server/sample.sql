SELECT
    t.month                     AS month,
    l.country_id                AS country_id,
    SUM(fact.sales)             AS sum_sales,
    ROUND(AVG(fact.sales), 2)   AS avg_sales
FROM
    orders fact
JOIN
    times t
    ON fact.time_id = t.time_id
JOIN
    locations l
    ON fact.location_id = l.location_id
JOIN
    order_details od
    ON fact.order_detail_id = od.order_detail_id
-- DICE AND SLICE COMMAND
WHERE
    t.month = 2
-- ROLL UP OR DRILL DOWN
GROUP BY ROLLUP(
    t.month,
    l.country_id
)
ORDER BY
    t.month,
    l.country_id;

SELECT
    t.year_id AS year,
    SUM(fact.sales) AS sum_sales,
    ROUND(AVG(fact.sales), 2) AS avg_sales
FROM
    orders fact
JOIN
    times t ON fact.time_id = t.time_id
GROUP BY ROLLUP ( t.year ) ORDER BY t.year;
