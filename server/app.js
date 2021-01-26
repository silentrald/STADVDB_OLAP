const express       = require('express');
const bodyParser    = require('body-parser');
const cors          = require('cors');
const { Pool }    = require('pg');

require('dotenv').config();

const app = express();

const PORT = process.env.PORT || 5000;

const PG_CONFIG = process.env.NODE_ENV === 'production' ? {

} : {
    user:       process.env.POSTGRES_USER,
    password:   process.env.POSTGRES_PASSWORD,
    host:       process.env.POSTGRES_HOST,
    port:       process.env.POSTGRES_PORT,
    database:   process.env.POSTGRES_DB
};

const db = new Pool(PG_CONFIG);

// MIDDLEWARES
if (process.env.NODE_ENV === 'development') {
    app.use(require('morgan')('dev'));
}

app.use(cors());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

const tables = {
    time: 't',
    location: 'l',
    order_detail: 'od'
};

const cache = {};

// territories, countries, cities
// product_lines, product_codes, statuses
app.get('/name', async (req, res) => {
    const { table } = req.query;

    if (cache[table])
        return res.status(200).send({ rows: cache[table] });

    try {
        const text = `
            SELECT  *
            FROM    ${table};
        `;

        const { rows } = await db.query(text);

        return res.status(200).send({ rows });

    } catch (err) {
        console.log(err);

        return res.status(500).send();
    }
});

app.get('/', async (req, res) => {
    const { dimensions } = req.query;

    if (typeof(dimensions) !== 'object') {
        return res.status(403).send();
    }

    if (!dimensions.length) {
        return res.status(403).send();
    }

    try {
        // Clean the dimensions
        for (let i in dimensions) {
            dimensions[i] = JSON.parse(dimensions[i]);
            const { d } = dimensions[i];
            dimensions[i].t = tables[d];
        }

        console.log(dimensions);

        let text = `
            SELECT
        `;

        for (let i in dimensions) {
            const { t, g } = dimensions[i];
            text += `${t}.${g} AS ${g},\n`;
        }

        text += `
            SUM(fact.sales) AS sum_sales
        FROM
            orders fact
        `;

        for (let i in dimensions) {
            const { d, t } = dimensions[i];
            text += `
                JOIN
                    ${d}s ${t} ON fact.${d}_id = ${t}.id
            `;
        }
        
        // DICE AND SLICE COMMANDS
        
        // ROLLUP AND DRILL DOWN
        
        let groupby = '';
        for (let i in dimensions) {
            const { t, g } = dimensions[i];
            groupby += `${t}.${g},\n`;
        }
        groupby = groupby.substring(0, groupby.length - 2);

        text += `
            GROUP BY ROLLUP (
                ${groupby}
            )
            ORDER BY
                ${groupby};
        `;
        
        text = text.trim().replace('\n', '').replace(/\s+/g, ' ');
        console.log(text);
        
        const { rows } = await db.query({ text });
        console.log(rows);

        return res.status(200).send({ rows });
    } catch (err) {
        console.log(err);

        return res.status(500).send();
    }
});

app.listen(PORT, () => {
    console.log(`Listening to port ${PORT}`);
});
