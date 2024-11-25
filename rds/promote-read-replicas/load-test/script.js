import sql from "k6/x/sql";
import { check } from "k6";
import { loadEnv } from "k6/x/dotenv";
import driver from "k6/x/sql/driver/postgres";

export const options = {
  vus: 10, // Number of Virtual Users
  duration: "30s", // Total test duration
};

// Load environment variables
const env = loadEnv(".env");

// Replace with your PostgreSQL connection string
const db = sql.open(
  driver,
  `postgres://${env.DB_USER}:${env.DB_PASSWORD}@${env.DB_HOST}:${env.DB_PORT}/${env.DB_NAME}`
);

export function setup() {
  db.exec(`CREATE TABLE IF NOT EXISTS person (
           id SERIAL PRIMARY KEY,
           email VARCHAR NOT NULL,
           first_name VARCHAR,
           last_name VARCHAR);`);

  db.exec(
    "INSERT INTO person (email, first_name, last_name) VALUES('johndoe@email.com', 'John', 'Doe');"
  );
  db.exec(
    "INSERT INTO person (email, first_name, last_name) VALUES('marysue@email.com', 'Mary', 'Sue');"
  );
  db.exec(
    "INSERT INTO person (email, first_name, last_name) VALUES('dorydoe@email.com', 'Dory', 'Doe');"
  );
}

export function teardown() {
  db.exec("DELETE FROM person;");
  db.exec("DROP TABLE person;");
  db.close();
}

export default function () {
  const results = sql.query(db, "SELECT * FROM person;");
  check(results, {
    "is length 3": (r) => r.length === 3,
  });
}
