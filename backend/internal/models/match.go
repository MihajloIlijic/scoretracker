package models

import (
	"time"

	"gorm.io/gorm"
)

type Match struct {
	ID            uint           `json:"id" gorm:"primaryKey"`
	ChampionshipID uint          `json:"championship_id" gorm:"not null;index"`
	Player1       string         `json:"player1" gorm:"not null"`
	Player2       string         `json:"player2" gorm:"not null"`
	Game          string         `json:"game" gorm:"not null"`
	Winner        string         `json:"winner" gorm:"not null"`
	Player1Score  int            `json:"player1_score" gorm:"not null"`
	Player2Score  int            `json:"player2_score" gorm:"not null"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `json:"-" gorm:"index"`
	
	// Relations
	Championship Championship `json:"championship,omitempty" gorm:"foreignKey:ChampionshipID"`
}

