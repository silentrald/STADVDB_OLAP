<template>
  <div id="main" class="row m-1" style="background-color: #f5f5f5;">
    <div class="col-3 m-2 card p-2 shadow-sm">
      <h1>Tables</h1>
      <div
        v-for="selection in selections"
        :id="`${selection}-dimension`"
        :key="selection"
        class="dimension"
      >
        <button type="button" class="btn btn-custom btn-success" @click="addDimension(selection)">
          <b>+</b> {{ selection }}
        </button>
      </div>
      <hr>
      <h1>Dimensions</h1>
      <div v-for="(dim, index) in dimensions" :key="dim.table" class="mt-2 dimension-container">
        <a href="javascript:;" @click="removeDimension(index)">
          <i class="far fa-times-circle text-danger" />
        </a>
        Dimension {{ index + 1 }}: <b>{{ dim.table }}</b> <br>
        <button type="button" class="btn btn-custom btn-success" @click="rollup(index)">
          Rollup
        </button>
        <button type="button" class="btn btn-custom btn-success" @click="drilldown(index)">
          Drilldown
        </button>
        <button type="button" class="btn btn-secondary" @click="up(index)">
          Up <i class="fas fa-arrow-up" />
        </button>
        <button type="button" class="btn btn-secondary" @click="down(index)">
          Down <i class="fas fa-arrow-down" />
        </button>
        <multiselect
          v-if="references[dim.hierarchy]"
          v-model="dim.where"
          :options="Object.values(names[dim.hierarchy])"
          :multiple="true"
          :close-on-select="false"
          class="mt-2"
          @input="query"
        />
      </div>
      <hr>
    </div>
    <div class="col m-2 card p-2 shadow-sm">
      <table v-if="data" class="table">
        <thead>
          <tr>
            <th v-for="col in columns" :key="col">
              <div v-if="references[col] === undefined">
                {{ col }}
              </div>
              <div v-else>
                {{ references[col] }}
              </div>
            </th>
          </tr>
        </thead>
        <tbody>
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
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import Multiselect from 'vue-multiselect'

const hierarchies = {
  period: ['year', 'quarter', 'month'],
  location: ['territory_id', 'country_id', 'city_id'],
  order_detail: ['product_line_id', 'product_code_id']
}

const references = {
  territory_id: 'territories',
  country_id: 'countries',
  city_id: 'cities',
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
  width: 200px;
  padding: 2px;
  font-weight: bold;
}

.dimension-container {
  background-color: white;
  border: 1px solid #f2f2f2;
  border-radius: 5px;
  padding: 4px 8px;
}

.btn-custom {
  background-color: #41b883 !important;
}

.data-section {
  background-color: #fafafa
}

</style>
