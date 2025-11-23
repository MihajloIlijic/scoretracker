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

	if err := h.DB.Order("created_at DESC").Find(&matches).Error; err != nil {
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

