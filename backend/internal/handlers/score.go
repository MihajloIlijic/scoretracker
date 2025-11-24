package handlers

import (
	"net/http"
	"strconv"

	"scoretracker/backend/internal/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type ScoreHandler struct {
	DB *gorm.DB
}

func NewScoreHandler(db *gorm.DB) *ScoreHandler {
	return &ScoreHandler{DB: db}
}

func (h *ScoreHandler) GetAllScores(c *gin.Context) {
	var scores []models.Score
	championshipID := c.Query("championship_id")

	query := h.DB
	if championshipID != "" {
		id, err := strconv.ParseUint(championshipID, 10, 32)
		if err == nil {
			query = query.Where("championship_id = ?", id)
		}
	}

	if err := query.Preload("Championship").Order("created_at DESC").Find(&scores).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch scores"})
		return
	}

	c.JSON(http.StatusOK, scores)
}

func (h *ScoreHandler) GetScore(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var score models.Score
	if err := h.DB.First(&score, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Score not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch score"})
		return
	}

	c.JSON(http.StatusOK, score)
}

func (h *ScoreHandler) CreateScore(c *gin.Context) {
	var score models.Score

	if err := c.ShouldBindJSON(&score); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if score.ChampionshipID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Championship ID is required"})
		return
	}

	// Verify championship exists
	var championship models.Championship
	if err := h.DB.First(&championship, score.ChampionshipID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Championship not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify championship"})
		return
	}

	if err := h.DB.Create(&score).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create score"})
		return
	}

	c.JSON(http.StatusCreated, score)
}

func (h *ScoreHandler) UpdateScore(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var score models.Score
	if err := h.DB.First(&score, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Score not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch score"})
		return
	}

	if err := c.ShouldBindJSON(&score); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.DB.Save(&score).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update score"})
		return
	}

	c.JSON(http.StatusOK, score)
}

func (h *ScoreHandler) DeleteScore(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var score models.Score
	if err := h.DB.First(&score, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Score not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch score"})
		return
	}

	if err := h.DB.Delete(&score).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete score"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Score deleted successfully"})
}

func (h *ScoreHandler) GetPlayers(c *gin.Context) {
	// This endpoint is deprecated - use /api/players instead
	// But keeping it for backward compatibility, now returns player names from Player model
	var players []models.Player
	championshipID := c.Query("championship_id")

	query := h.DB.Model(&models.Player{})
	if championshipID != "" {
		id, err := strconv.ParseUint(championshipID, 10, 32)
		if err == nil {
			// Filter players by championship using the join table
			query = query.Joins("JOIN player_championships ON players.id = player_championships.player_id").
				Where("player_championships.championship_id = ?", id)
		}
	}

	if err := query.Find(&players).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch players"})
		return
	}

	playerNames := make([]string, len(players))
	for i, p := range players {
		playerNames[i] = p.Name
	}

	c.JSON(http.StatusOK, gin.H{"players": playerNames})
}

