import fs from 'fs';
import path from 'path';
import sequelize from '../db/connection.js';

// Simple migration runner for SQL files
export class MigrationRunner {
  static async runMigration(migrationFile: string) {
    try {
      const migrationPath = path.join(process.cwd(), 'migrations', migrationFile);
      const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
      
      // Split SQL statements by semicolon and execute each one
      const statements = migrationSQL
        .split(';')
        .map(stmt => stmt.trim())
        .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));

      console.log(`Running migration: ${migrationFile}`);
      
      for (const statement of statements) {
        if (statement.trim()) {
          await sequelize.query(statement);
          console.log(`✓ Executed: ${statement.substring(0, 50)}...`);
        }
      }
      
      console.log(`✅ Migration ${migrationFile} completed successfully!`);
    } catch (error) {
      console.error(`❌ Error running migration ${migrationFile}:`, error);
      throw error;
    }
  }

  static async runAllPendingMigrations() {
    try {
      const migrationsDir = path.join(process.cwd(), 'migrations');
      const migrationFiles = fs.readdirSync(migrationsDir)
        .filter(file => file.endsWith('.sql'))
        .sort(); // This ensures migrations run in order

      console.log('🚀 Starting database migrations...');
      
      for (const file of migrationFiles) {
        await this.runMigration(file);
      }
      
      console.log('🎉 All migrations completed successfully!');
    } catch (error) {
      console.error('❌ Migration failed:', error);
      throw error;
    }
  }
}

// CLI usage
if (process.argv.length > 2) {
  const command = process.argv[2];
  const migrationFile = process.argv[3];

  if (command === 'run' && migrationFile) {
    MigrationRunner.runMigration(migrationFile)
      .then(() => process.exit(0))
      .catch(() => process.exit(1));
  } else if (command === 'run-all') {
    MigrationRunner.runAllPendingMigrations()
      .then(() => process.exit(0))
      .catch(() => process.exit(1));
  } else {
    console.log('Usage:');
    console.log('  npm run migrate run <migration-file>    - Run a specific migration');
    console.log('  npm run migrate run-all                - Run all pending migrations');
  }
}
