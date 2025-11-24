package models

import (
	"time"

	"gorm.io/gorm"
)

type MatchStatus string

const (
	MatchStatusPending  MatchStatus = "pending"
	MatchStatusStarted  MatchStatus = "started"
	MatchStatusFinished MatchStatus = "finished"
)

type Match struct {
	ID            uint           `json:"id" gorm:"primaryKey"`
	ChampionshipID uint          `json:"championship_id" gorm:"not null;index"`
	Player1       string         `json:"player1" gorm:"not null"`
	Player2       string         `json:"player2" gorm:"not null"`
	Game          string         `json:"game" gorm:"not null"`
	Status        MatchStatus    `json:"status" gorm:"type:varchar(20);default:'pending';not null"`
	Winner        *string        `json:"winner" gorm:"default:null"` // Nullable, wird erst beim Beenden gesetzt
	Player1Score  int            `json:"player1_score" gorm:"default:0;not null"`
	Player2Score  int            `json:"player2_score" gorm:"default:0;not null"`
	StartedAt     *time.Time     `json:"started_at" gorm:"default:null"`
	FinishedAt    *time.Time     `json:"finished_at" gorm:"default:null"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `json:"-" gorm:"index"`
	
	// Relations
	Championship Championship `json:"championship,omitempty" gorm:"foreignKey:ChampionshipID"`
}

