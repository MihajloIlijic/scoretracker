package handlers

import (
	"net/http"
	"strconv"
	"strings"

	"scoretracker/backend/internal/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type PlayerHandler struct {
	DB *gorm.DB
}

func NewPlayerHandler(db *gorm.DB) *PlayerHandler {
	return &PlayerHandler{DB: db}
}

func (h *PlayerHandler) GetAllPlayers(c *gin.Context) {
	var players []models.Player
	championshipID := c.Query("championship_id")

	query := h.DB
	if championshipID != "" {
		id, err := strconv.ParseUint(championshipID, 10, 32)
		if err == nil {
			// Filter players by championship using the join table
			query = query.Joins("JOIN player_championships ON players.id = player_championships.player_id").
				Where("player_championships.championship_id = ?", id)
		}
	}

	if err := query.Preload("Championships").Order("created_at DESC").Find(&players).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch players"})
		return
	}

	c.JSON(http.StatusOK, players)
}

func (h *PlayerHandler) GetPlayer(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var player models.Player
	if err := h.DB.Preload("Championships").First(&player, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Player not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch player"})
		return
	}

	c.JSON(http.StatusOK, player)
}

func (h *PlayerHandler) CreatePlayer(c *gin.Context) {
	var request struct {
		Name          string  `json:"name" binding:"required"`
		ChampionshipIDs []uint `json:"championship_ids"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if request.Name == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Name is required"})
		return
	}

	player := models.Player{
		Name: request.Name,
	}

	// If championships are provided, verify and assign them
	if len(request.ChampionshipIDs) > 0 {
		// Verify all championships exist and are not finalized
		var championships []models.Championship
		if err := h.DB.Where("id IN ?", request.ChampionshipIDs).Find(&championships).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify championships"})
			return
		}

		if len(championships) != len(request.ChampionshipIDs) {
			c.JSON(http.StatusBadRequest, gin.H{"error": "One or more championships not found"})
			return
		}

		// Check if any championship is finalized
		for _, champ := range championships {
			if champ.Status == models.ChampionshipStatusFinalized {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot add players to a finalized championship"})
				return
			}
		}

		player.Championships = championships
	}

	if err := h.DB.Create(&player).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create player"})
		return
	}

	h.DB.Preload("Championships").First(&player, player.ID)
	c.JSON(http.StatusCreated, player)
}

func (h *PlayerHandler) UpdatePlayer(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var player models.Player
	if err := h.DB.Preload("Championships").First(&player, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Player not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch player"})
		return
	}

	var request struct {
		Name          *string `json:"name"`
		ChampionshipIDs []uint `json:"championship_ids"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}


	// Update name if provided
	if request.Name != nil {
		if err := h.DB.Model(&player).Update("name", *request.Name).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update player name"})
			return
		}
	}

	// Update championships - always process if field is present (even if empty array)
	if request.ChampionshipIDs != nil {
		// Get current championships
		var currentChampionships []models.Championship
		h.DB.Model(&player).Association("Championships").Find(&currentChampionships)
		
		// Create a map of current championship IDs for quick lookup
		currentChampIDs := make(map[uint]bool)
		for _, champ := range currentChampionships {
			currentChampIDs[champ.ID] = true
		}
		
		// Create a map of new championship IDs
		newChampIDs := make(map[uint]bool)
		for _, id := range request.ChampionshipIDs {
			newChampIDs[id] = true
		}
		
		// Find championships that are being removed (in current but not in new)
		var removedChampIDs []uint
		for id := range currentChampIDs {
			if !newChampIDs[id] {
				removedChampIDs = append(removedChampIDs, id)
			}
		}
		
		// Check if any removed championships are finalized
		if len(removedChampIDs) > 0 {
			var removedChampionships []models.Championship
			if err := h.DB.Where("id IN ?", removedChampIDs).Find(&removedChampionships).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify removed championships"})
				return
			}
			
			for _, champ := range removedChampionships {
				if champ.Status == models.ChampionshipStatusFinalized {
					c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot remove players from a finalized championship"})
					return
				}
			}
		}

		// Find championships that are being added (in new but not in current)
		var addedChampIDs []uint
		for _, id := range request.ChampionshipIDs {
			if !currentChampIDs[id] {
				addedChampIDs = append(addedChampIDs, id)
			}
		}
		
		// Check if any added championships are finalized
		if len(addedChampIDs) > 0 {
			var addedChampionships []models.Championship
			if err := h.DB.Where("id IN ?", addedChampIDs).Find(&addedChampionships).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify added championships"})
				return
			}
			
			for _, champ := range addedChampionships {
				if champ.Status == models.ChampionshipStatusFinalized {
					c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot add players to a finalized championship"})
					return
				}
			}
		}

		// Use GORM's Table method for direct SQL operations
		// First, delete all existing associations for this player
		result := h.DB.Table("player_championships").Where("player_id = ?", player.ID).Delete(nil)
		if result.Error != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to clear player championships: " + result.Error.Error()})
			return
		}
		
		// Then, insert the new associations (if any)
		if len(request.ChampionshipIDs) > 0 {
			// Verify all championships exist
			var count int64
			if err := h.DB.Model(&models.Championship{}).Where("id IN ?", request.ChampionshipIDs).Count(&count).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify championships"})
				return
			}
			
			if int(count) != len(request.ChampionshipIDs) {
				c.JSON(http.StatusBadRequest, gin.H{"error": "One or more championships not found"})
				return
			}
			
			// Insert new associations using GORM's Table method
			for _, champID := range request.ChampionshipIDs {
				if err := h.DB.Table("player_championships").Create(map[string]interface{}{
					"player_id":       player.ID,
					"championship_id": champID,
				}).Error; err != nil {
					// Ignore duplicate key errors (ON CONFLICT DO NOTHING equivalent)
					if !strings.Contains(err.Error(), "duplicate key") && !strings.Contains(err.Error(), "UNIQUE constraint") {
						c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add player championship: " + err.Error()})
						return
					}
				}
			}
		}
	}

	// Reload player with associations
	if err := h.DB.Preload("Championships").First(&player, player.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to reload player"})
		return
	}

	c.JSON(http.StatusOK, player)
}

func (h *PlayerHandler) DeletePlayer(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var player models.Player
	if err := h.DB.First(&player, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Player not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch player"})
		return
	}

	if err := h.DB.Delete(&player).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete player"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Player deleted successfully"})
}

