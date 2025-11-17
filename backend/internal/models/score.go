package models

import (
	"time"

	"gorm.io/gorm"
)

type Score struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	Player    string         `json:"player" gorm:"not null"`
	Points    int            `json:"points" gorm:"not null"`
	Game      string         `json:"game" gorm:"not null"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

