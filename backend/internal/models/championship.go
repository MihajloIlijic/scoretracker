package models

import (
	"time"

	"gorm.io/gorm"
)

type ChampionshipStatus string

const (
	ChampionshipStatusDraft      ChampionshipStatus = "draft"
	ChampionshipStatusFinalized  ChampionshipStatus = "finalized"
)

type Championship struct {
	ID          uint               `json:"id" gorm:"primaryKey"`
	Name        string             `json:"name" gorm:"not null"`
	Description string             `json:"description"`
	Status      ChampionshipStatus `json:"status" gorm:"type:varchar(20);default:'draft';not null"`
	CreatedAt   time.Time          `json:"created_at"`
	UpdatedAt   time.Time          `json:"updated_at"`
	DeletedAt   gorm.DeletedAt     `json:"-" gorm:"index"`
	
	// Relations
	Players []Player `json:"players,omitempty" gorm:"many2many:player_championships;"`
	Matches []Match  `json:"matches,omitempty" gorm:"foreignKey:ChampionshipID"`
}

