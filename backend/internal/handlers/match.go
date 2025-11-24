package handlers

import (
	"net/http"
	"strconv"

	"scoretracker/backend/internal/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type MatchHandler struct {
	DB *gorm.DB
}

func NewMatchHandler(db *gorm.DB) *MatchHandler {
	return &MatchHandler{DB: db}
}

func (h *MatchHandler) GetAllMatches(c *gin.Context) {
	var matches []models.Match
	championshipID := c.Query("championship_id")

	query := h.DB
	if championshipID != "" {
		id, err := strconv.ParseUint(championshipID, 10, 32)
		if err == nil {
			query = query.Where("championship_id = ?", id)
		}
	}

	if err := query.Preload("Championship").Order("created_at DESC").Find(&matches).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch matches"})
		return
	}

	c.JSON(http.StatusOK, matches)
}

func (h *MatchHandler) GetMatch(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var match models.Match
	if err := h.DB.First(&match, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Match not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch match"})
		return
	}

	c.JSON(http.StatusOK, match)
}

func (h *MatchHandler) CreateMatch(c *gin.Context) {
	var match models.Match

	if err := c.ShouldBindJSON(&match); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if match.ChampionshipID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Championship ID is required"})
		return
	}

	// Verify championship exists
	var championship models.Championship
	if err := h.DB.First(&championship, match.ChampionshipID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Championship not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify championship"})
		return
	}

	// Validate that winner is one of the players
	if match.Winner != match.Player1 && match.Winner != match.Player2 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Winner must be one of the players"})
		return
	}

	// Validate that players are different
	if match.Player1 == match.Player2 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Players must be different"})
		return
	}

	// Verify players exist and are in the championship
	var player1, player2 models.Player
	if err := h.DB.Where("name = ?", match.Player1).First(&player1).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Player1 not found"})
		return
	}
	if err := h.DB.Where("name = ?", match.Player2).First(&player2).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Player2 not found"})
		return
	}

	// Check if both players are in the championship
	var count1, count2 int64
	h.DB.Table("player_championships").
		Where("player_id = ? AND championship_id = ?", player1.ID, match.ChampionshipID).
		Count(&count1)
	h.DB.Table("player_championships").
		Where("player_id = ? AND championship_id = ?", player2.ID, match.ChampionshipID).
		Count(&count2)

	if count1 == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Player1 is not in this championship"})
		return
	}
	if count2 == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Player2 is not in this championship"})
		return
	}

	if err := h.DB.Create(&match).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create match"})
		return
	}

	c.JSON(http.StatusCreated, match)
}

func (h *MatchHandler) DeleteMatch(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var match models.Match
	if err := h.DB.First(&match, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Match not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch match"})
		return
	}

	if err := h.DB.Delete(&match).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete match"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Match deleted successfully"})
}

