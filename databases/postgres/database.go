package databases

import (
	"time"

	"github.com/gofiber/fiber/v3/log"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func Connect(DBUrl string) *gorm.DB {
	db, err := gorm.Open(postgres.Open(DBUrl), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Error),
		//Logger:                 logger.Default.LogMode(logger.Info),
		SkipDefaultTransaction: true,
		PrepareStmt:            true,
		TranslateError:         true,
		// Use UTC timezone when providing datetime to created_at, uppdated_at fields etc.
		NowFunc: func() time.Time {
			return time.Now().UTC()
		},
	})
	if err != nil {
		log.Errorf("Failed to connect to database: %+v", err)
	}

	sqlDB, errDB := db.DB()
	if errDB != nil {
		log.Errorf("Failed to connect to database: %+v", errDB)
	}

	// Config connection pooling
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(60 * time.Minute)

	return db
}
