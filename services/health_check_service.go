package services

import (
	"errors"
	"runtime"

	"github.com/gofiber/fiber/v3/log"
	"gorm.io/gorm"
)

type HealthCheckService interface {
	GormCheck() error
	MemoryHeapCheck() error
}

type healthCheckService struct {
	DB *gorm.DB
}

func NewHealthCheckService(db *gorm.DB) HealthCheckService {
	return &healthCheckService{
		DB: db,
	}
}

func (s *healthCheckService) GormCheck() error {
	sqlDB, errDB := s.DB.DB()
	if errDB != nil {
		log.Errorf("failed to access the database connection pool: %v", errDB)
		return errDB
	}

	if err := sqlDB.Ping(); err != nil {
		log.Errorf("failed to ping the database: %v", err)
		return err
	}

	return nil
}

// MemoryHeapCheck checks if heap memory usage exceeds a threshold
func (s *healthCheckService) MemoryHeapCheck() error {
	var memStats runtime.MemStats
	runtime.ReadMemStats(&memStats) // Collect memory statistics

	heapAlloc := memStats.HeapAlloc            // Heap memory currently allocated
	heapThreshold := uint64(300 * 1024 * 1024) // Example threshold: 300 MB

	log.Infof("Heap Memory Allocation: %v bytes", heapAlloc)

	// If the heap allocation exceeds the threshold, return an error
	if heapAlloc > heapThreshold {
		log.Errorf("Heap memory usage exceeds threshold: %v bytes", heapAlloc)
		return errors.New("heap memory usage too high")
	}

	return nil
}
