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

    <div v-for="(dim, index) in dimensions" :key="dim.table">
      Dimension {{ index + 1 }}: {{ dim.table }}
      <button @click="rollup(index)">
        Rollup
      </button>
      <button @click="drilldown(index)">
        Drilldown
      </button>
      <button @click="removeDimension(index)">
        Remove
      </button>
      <button @click="up(index)">
        Up ⬆
      </button>
      <button @click="down(index)">
        Down ⬇
      </button>
      <multiselect
        v-if="references[dim.hierarchy]"
        v-model="dim.where"
        :options="Object.values(names[dim.hierarchy])"
        :multiple="true"
        :close-on-select="false"
        @input="query"
      />
    </div>

    <table v-if="data">
      <thead>
        <th v-for="col in columns" :key="col">
          <div v-if="references[col] === undefined">
            {{ col }}
          </div>
          <div v-else>
            {{ references[col] }}
          </div>
        </th>
      </thead>
      <tr v-for="(obj, index) in data" :key="index">
        <td v-for="(val, key) in obj" :key="key">
          <div v-if="names[key] != undefined">
            {{ names[key][val] }}
          </div>
          <div v-else>
            {{ val }}
          </div>
        </td>
      </tr>
    </table>
  </div>
</template>

<script>
import Multiselect from 'vue-multiselect'

const hierarchies = {
  period: ['year', 'quarter', 'month'],
  location: ['territory_id', 'country_id', 'city_id'],
  order_detail: ['status_id', 'product_line_id', 'product_code_id']
}

const references = {
  territory_id: 'territories',
  country_id: 'countries',
  city_id: 'cities',
  status_id: 'statuses',
  product_line_id: 'product_lines',
  product_code_id: 'product_codes'
}

export default {
  // ignore
  components: { multiselect: Multiselect },

  data () {
    return {
      selections: ['period', 'location', 'order_detail'],
      dimensions: [],
      cached: {
        period: {},
        location: {},
        order_detail: {}
      },
      table: {},
      territory_id: {},
      country_id: {},
      city_id: {},
      product_line_id: {},
      product_code_id: {},
      status_id: {},
      columns: [],
      names: {},
      data: undefined,
      references
    }
  },

  beforeMount () {
    this.getNames()
  },

  methods: {
    // Gets all the names of the different ref table
    async getNames () {
      try {
        for (const id in references) {
          const table = references[id]

          const res = await this.$axios.get('/name', {
            params: { table }
          })

          const { rows } = res.data
          for (const i in rows) {
            const row = rows[i]
            if (!this.names[id]) { this.names[id] = {} }
            this.names[id][row.id] = row.name
          }
        }
      } catch (_err) {
        // console.log(_err)
      }
    },

    addDimension (selected) {
      this.selections.splice(this.selections.indexOf(selected), 1)

      const hierarchy = hierarchies[selected][0]
      this.dimensions.push({
        table: selected,
        hierarchy,
        ref: references[hierarchy]
      })

      this.query()
    },

    removeDimension (index) {
      const removed = this.dimensions.splice(index, 1)[0]

      this.selections.push(removed.table)
      this.query()
    },

    rollup (index) {
      const ref = this.dimensions[index]
      const { table, hierarchy } = ref
      const i = hierarchies[table].indexOf(hierarchy)

      if (i > 0) {
        const h = hierarchies[table][i - 1]
        ref.hierarchy = h
        ref.ref = references[h]
        ref.where = undefined
        this.query()
      }
    },

    drilldown (index) {
      const ref = this.dimensions[index]
      const { table, hierarchy } = ref
      const i = hierarchies[table].indexOf(hierarchy)

      if (i < hierarchies[table].length - 1) {
        const h = hierarchies[table][i + 1]
        ref.hierarchy = h
        ref.ref = references[h]
        ref.where = undefined
        this.query()
      }
    },

    up (index) {
      if (index > 0) {
        this.dimensions.splice(index - 1, 0, this.dimensions.splice(index, 1)[0])
        this.query()
      }
    },

    down (index) {
      if (index < this.columns.length - 1) {
        this.dimensions.splice(index + 1, 0, this.dimensions.splice(index, 1)[0])
        this.query()
      }
    },

    async query () {
      try {
        const { data } = await this.$axios.get('/', {
          params: {
            dimensions: this.dimensions
          }
        })

        this.data = data.rows

        this.columns = Object.keys(this.data[0])
      } catch (_err) {}
    }
  }
}
</script>

<style src="vue-multiselect/dist/vue-multiselect.min.css"></style>

<style scoped>
.dimension {
  width: 100px;
  padding: 8px 4px;
  text-align: center;

  color: white;
  background-color: blue;
}
</style>
