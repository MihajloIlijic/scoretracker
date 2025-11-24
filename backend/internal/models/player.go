package models

import (
	"time"

	"gorm.io/gorm"
)

type Player struct {
	ID            uint           `json:"id" gorm:"primaryKey"`
	Name          string         `json:"name" gorm:"not null"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `json:"-" gorm:"index"`
	
	// Many-to-Many Relations
	Championships []Championship `json:"championships,omitempty" gorm:"many2many:player_championships;"`
}

