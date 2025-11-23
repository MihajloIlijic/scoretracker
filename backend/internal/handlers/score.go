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

	if err := h.DB.Find(&scores).Error; err != nil {
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
	var players []string

	if err := h.DB.Model(&models.Score{}).
		Distinct("player").
		Pluck("player", &players).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch players"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"players": players})
}

