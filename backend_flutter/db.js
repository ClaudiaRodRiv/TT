const { Pool } = require('pg');

const pool = new Pool({
  connectionString: 'postgresql://postgres.oeqmsjqmhhjvptkfzyum:reportescuidadanos@aws-1-us-east-2.pooler.supabase.com:6543/postgres',
  ssl: {
    rejectUnauthorized: false
  }
});

module.exports = pool;