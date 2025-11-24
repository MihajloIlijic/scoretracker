package database

import (
	"fmt"
	"os"
	"time"

	"scoretracker/backend/internal/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func Connect() (*gorm.DB, error) {
	dbHost := getEnv("DB_HOST", "localhost")
	dbPort := getEnv("DB_PORT", "5432")
	dbUser := getEnv("DB_USER", "scoretracker")
	dbPassword := getEnv("DB_PASSWORD", "scoretracker_pass")
	dbName := getEnv("DB_NAME", "scoretracker_db")

	// Use sslmode=require for production (Render), disable for local
	sslMode := getEnv("DB_SSLMODE", "")
	if sslMode == "" {
		// Auto-detect: if not localhost, use require
		if dbHost != "localhost" && dbHost != "127.0.0.1" {
			sslMode = "require"
		} else {
			sslMode = "disable"
		}
	}
	
	// Log connection details (without password)
	fmt.Printf("Connecting to database: host=%s port=%s user=%s dbname=%s sslmode=%s\n", 
		dbHost, dbPort, dbUser, dbName, sslMode)
	
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		dbHost, dbPort, dbUser, dbPassword, dbName, sslMode)

	// Retry connection with exponential backoff
	var db *gorm.DB
	var err error
	maxRetries := 10
	retryDelay := 2 * time.Second

	for i := 0; i < maxRetries; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.Default.LogMode(logger.Info),
		})

		if err == nil {
			fmt.Printf("Successfully connected to database\n")
			return db, nil
		}

		if i < maxRetries-1 {
			fmt.Printf("Failed to connect to database (attempt %d/%d): %v. Retrying in %v...\n", 
				i+1, maxRetries, err, retryDelay)
			time.Sleep(retryDelay)
			retryDelay *= 2 // Exponential backoff
		}
	}

	return nil, fmt.Errorf("failed to connect to database after %d attempts: %w", maxRetries, err)
}

func Migrate(db *gorm.DB) error {
	// First, create Championship and Player tables
	if err := db.AutoMigrate(
		&models.Championship{},
		&models.Player{},
	); err != nil {
		return fmt.Errorf("failed to migrate database: %w", err)
	}

	// Check if matches table exists and has data
	var matchCount int64
	db.Table("matches").Count(&matchCount)
	
	// Check if scores table exists and has data - migrate to players
	var scoreCount int64
	db.Table("scores").Count(&scoreCount)

	// If there are existing matches or scores, we need to handle the migration carefully
	if matchCount > 0 || scoreCount > 0 {
		// Create a default championship for existing data
		var defaultChamp models.Championship
		result := db.Where("name = ?", "Default Championship").First(&defaultChamp)
		if result.Error == gorm.ErrRecordNotFound {
			defaultChamp = models.Championship{
				Name:        "Default Championship",
				Description: "Default championship for existing data",
			}
			if err := db.Create(&defaultChamp).Error; err != nil {
				return fmt.Errorf("failed to create default championship: %w", err)
			}
		}

		// Add championship_id column as nullable first
		if matchCount > 0 {
			if !db.Migrator().HasColumn(&models.Match{}, "championship_id") {
				if err := db.Exec("ALTER TABLE matches ADD COLUMN championship_id bigint").Error; err != nil {
					// Column might already exist, ignore error
				}
				// Update existing matches
				if err := db.Exec("UPDATE matches SET championship_id = ? WHERE championship_id IS NULL", defaultChamp.ID).Error; err != nil {
					return fmt.Errorf("failed to update existing matches: %w", err)
				}
			}
		}

		// Migrate scores to players and existing players to many-to-many
		if scoreCount > 0 {
			// Get unique player names from scores with their championship_id
			type ScoreData struct {
				Player        string
				ChampionshipID uint
			}
			var scoreData []ScoreData
			if err := db.Table("scores").
				Select("DISTINCT player, COALESCE(championship_id, ?) as championship_id", defaultChamp.ID).
				Scan(&scoreData).Error; err != nil {
				return fmt.Errorf("failed to read scores: %w", err)
			}

			// Create players from unique score entries
			for _, sd := range scoreData {
				// Check if player already exists by name
				var existingPlayer models.Player
				result := db.Where("name = ?", sd.Player).First(&existingPlayer)
				if result.Error == gorm.ErrRecordNotFound {
					// Create new player
					player := models.Player{
						Name: sd.Player,
					}
					if err := db.Create(&player).Error; err != nil {
						fmt.Printf("Warning: Could not create player %s: %v\n", sd.Player, err)
						continue
					}
					existingPlayer = player
				}
				
				// Associate player with championship
				var champ models.Championship
				if err := db.First(&champ, sd.ChampionshipID).Error; err == nil {
					db.Model(&existingPlayer).Association("Championships").Append(&champ)
				}
			}
		}

		// Migrate existing players with championship_id to many-to-many
		if db.Migrator().HasColumn(&models.Player{}, "championship_id") {
			var playersWithChamp []struct {
				ID            uint
				ChampionshipID uint
			}
			if err := db.Table("players").
				Select("id, championship_id").
				Where("championship_id IS NOT NULL AND championship_id != 0").
				Scan(&playersWithChamp).Error; err == nil {
				for _, pwc := range playersWithChamp {
					var player models.Player
					var champ models.Championship
					if db.First(&player, pwc.ID).Error == nil &&
						db.First(&champ, pwc.ChampionshipID).Error == nil {
						db.Model(&player).Association("Championships").Append(&champ)
					}
				}
			}
		}
	}

	// Now migrate Match with NOT NULL constraint
	if err := db.AutoMigrate(
		&models.Match{},
	); err != nil {
		return fmt.Errorf("failed to migrate database: %w", err)
	}

	// Make winner column nullable if it exists and is not nullable
	if db.Migrator().HasColumn(&models.Match{}, "winner") {
		// Check if column is nullable by trying to alter it
		// If it fails, it might already be nullable, so we ignore the error
		db.Exec("ALTER TABLE matches ALTER COLUMN winner DROP NOT NULL")
	}

	// Make sure status column has default value
	if db.Migrator().HasColumn(&models.Match{}, "status") {
		db.Exec("ALTER TABLE matches ALTER COLUMN status SET DEFAULT 'pending'")
	}

	return nil
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

