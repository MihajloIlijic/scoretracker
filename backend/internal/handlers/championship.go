package handlers

import (
	"net/http"
	"strconv"

	"scoretracker/backend/internal/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type ChampionshipHandler struct {
	DB *gorm.DB
}

func NewChampionshipHandler(db *gorm.DB) *ChampionshipHandler {
	return &ChampionshipHandler{DB: db}
}

func (h *ChampionshipHandler) GetAllChampionships(c *gin.Context) {
	var championships []models.Championship

	if err := h.DB.Order("created_at DESC").Find(&championships).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch championships"})
		return
	}

	c.JSON(http.StatusOK, championships)
}

func (h *ChampionshipHandler) GetChampionship(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var championship models.Championship
	if err := h.DB.Preload("Players").Preload("Matches").Preload("Scores").First(&championship, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Championship not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch championship"})
		return
	}

	c.JSON(http.StatusOK, championship)
}

func (h *ChampionshipHandler) CreateChampionship(c *gin.Context) {
	var championship models.Championship

	if err := c.ShouldBindJSON(&championship); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if championship.Name == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Name is required"})
		return
	}

	if err := h.DB.Create(&championship).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create championship"})
		return
	}

	c.JSON(http.StatusCreated, championship)
}

func (h *ChampionshipHandler) UpdateChampionship(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var championship models.Championship
	if err := h.DB.First(&championship, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Championship not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch championship"})
		return
	}

	if err := c.ShouldBindJSON(&championship); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.DB.Save(&championship).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update championship"})
		return
	}

	c.JSON(http.StatusOK, championship)
}

func (h *ChampionshipHandler) DeleteChampionship(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var championship models.Championship
	if err := h.DB.First(&championship, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Championship not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch championship"})
		return
	}

	if err := h.DB.Delete(&championship).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete championship"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Championship deleted successfully"})
}

