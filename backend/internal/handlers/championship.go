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
	if err := h.DB.Preload("Players").Preload("Matches").First(&championship, id).Error; err != nil {
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

func (h *ChampionshipHandler) FinalizeChampionship(c *gin.Context) {
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

	if championship.Status == models.ChampionshipStatusFinalized {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Championship is already finalized"})
		return
	}

	// Check if there are at least 2 players in this championship
	var playerCount int64
	if err := h.DB.Table("player_championships").Where("championship_id = ?", id).Count(&playerCount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check players"})
		return
	}

	if playerCount < 2 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "At least 2 players are required to finalize a championship"})
		return
	}

	// Update only the status field
	if err := h.DB.Model(&championship).Update("status", models.ChampionshipStatusFinalized).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to finalize championship: " + err.Error()})
		return
	}

	// Reload the championship to return the updated version
	if err := h.DB.First(&championship, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to reload championship"})
		return
	}

	c.JSON(http.StatusOK, championship)
}

func (h *ChampionshipHandler) GetStandings(c *gin.Context) {
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

	// Get all finished matches for this championship
	var matches []models.Match
	if err := h.DB.Where("championship_id = ? AND status = ?", id, models.MatchStatusFinished).Find(&matches).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch matches"})
		return
	}

	// Calculate points for each player
	points := make(map[string]int)
	
	for _, match := range matches {
		if match.Winner == nil {
			// Draw - both players get 1 point
			points[match.Player1] += 1
			points[match.Player2] += 1
		} else if *match.Winner == match.Player1 {
			// Player1 wins - 3 points
			points[match.Player1] += 3
			points[match.Player2] += 0
		} else if *match.Winner == match.Player2 {
			// Player2 wins - 3 points
			points[match.Player1] += 0
			points[match.Player2] += 3
		}
	}

	// Get all players in championship
	var players []models.Player
	if err := h.DB.Joins("JOIN player_championships ON players.id = player_championships.player_id").
		Where("player_championships.championship_id = ?", id).
		Find(&players).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch players"})
		return
	}

	// Build standings
	type Standing struct {
		PlayerName string `json:"player_name"`
		Points     int    `json:"points"`
	}
	
	standings := make([]Standing, 0, len(players))
	for _, player := range players {
		standings = append(standings, Standing{
			PlayerName: player.Name,
			Points:     points[player.Name],
		})
	}

	// Sort by points (descending)
	for i := 0; i < len(standings)-1; i++ {
		for j := i + 1; j < len(standings); j++ {
			if standings[j].Points > standings[i].Points {
				standings[i], standings[j] = standings[j], standings[i]
			}
		}
	}

	c.JSON(http.StatusOK, standings)
}

