<template>
  <div id="main">
    <div
      v-for="selection in selections"
      :id="`${selection}-dimension`"
      :key="selection"
      class="dimension"
    >
      {{ selection }}
      <button @click="addDimension(selection)">
        ADD
      </button>
    </div>

    <table v-if="dim === 1">
      <tr v-for="(val, rowkey) in table" :key="rowkey">
        <td @click="drilldown(0, rowkey)">
          {{ rowkey }}
        </td>
        <td>
          {{ val }}
        </td>
      </tr>
    </table>

    <table v-else-if="dim === 2">
      <tr v-for="(row, rowkey) in table" :key="rowkey">
        <td>
          {{ rowkey }}
        </td>
        <td v-for="(col, colkey) in row" :key="colkey">
          {{ col }}
        </td>
      </tr>
    </table>
  </div>
</template>

<script>
const hierarchy = {
  time: ['year', 'quarter', 'month'],
  location: ['territory_id', 'country_id', 'city_id'],
  order_detail: ['status_id', 'product_line_id', 'product_code_id']
}
/*
  const months = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December'
  }
*/

export default {
  data () {
    return {
      selections: ['time', 'location', 'order_detail'],
      dimensions: [],
      cached: {
        time: {},
        location: {},
        order_detail: {}
      },
      dim: 0,
      table: {},
      territory_id: {},
      country_id: {},
      city_id: {},
      product_line_id: {},
      product_code_id: {},
      status_id: {}
    }
  },

  beforeMount () {
    this.getNames()
  },

  methods: {
    // Gets all the names of the different ref table
    async getNames () {
      const tables = [
        {
          name: 'territories',
          id: 'territory_id'
        }, {
          name: 'countries',
          id: 'country_id'
        }, {
          name: 'cities',
          id: 'city_id'
        }, {
          name: 'product_lines',
          id: 'product_line_id'
        }, {
          name: 'product_codes',
          id: 'product_code_id'
        }, {
          name: 'statuses',
          id: 'status_id'
        }
      ]

      try {
        for (const index in tables) {
          const table = tables[index]

          const res = await this.$axios.get('/name', {
            params: { table: table.name }
          })

          const { rows } = res.data
          for (const i in rows) {
            const row = rows[i]
            this[table.id][row.id] = row.name
          }
        }
      } catch (_err) {}
    },

    addDimension (selected) {
      this.selections.splice(this.selections.indexOf(selected), 1)
      this.dimensions.push({
        d: selected,
        g: hierarchy[selected][0]
      })

      this.query()
    },

    async drilldown () {

    },

    async query () {
      try {
        let { data } = await this.$axios.get('/', {
          params: {
            dimensions: this.dimensions
          }
        })

        data = data.rows
        // Clean the data
        const table = {}
        const keys = Object.keys(data[0])
        // console.log(keys)
        this.dim = keys.length - 1

        for (const index in data) {
          const d = data[index]
          for (let i = 0; i < this.dim; i++) {
            const key = d[keys[i]]
            if (i === 0) {
              if (this.dim === 1) {
                table[key] = d[keys[1]]
              } else if (!table[key]) {
                table[key] = {}
              }
            } else if (i === 1) {
              if (this.dim === 2) {
                table[d[keys[0]]][key] = d[keys[2]]
              } else if (!table[d[keys[0]]][key]) {
                table[d[keys[0]]][key] = {}
              }
            } else {
              table[d[keys[0]]][d[keys[1]]][key] = d[keys[3]]
            }
          }
        }

        this.$set(this, 'table', table)

        // console.log(table)
      } catch (_err) {
        console.log(_err)
      }
    }
  }
}
</script>

<style scoped>
.dimension {
  width: 100px;
  padding: 8px 4px;
  text-align: center;

  color: white;
  background-color: blue;
}
</style>
