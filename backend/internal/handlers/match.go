package handlers

import (
	"net/http"
	"strconv"
	"time"

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

	// Validate that players are different
	if match.Player1 == match.Player2 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Players must be different"})
		return
	}

	// Set default status if not provided
	if match.Status == "" {
		match.Status = models.MatchStatusPending
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

func (h *MatchHandler) GenerateRoundRobinMatches(c *gin.Context) {
	championshipID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid championship ID"})
		return
	}

	// Verify championship exists and is finalized
	var championship models.Championship
	if err := h.DB.Preload("Players").First(&championship, championshipID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Championship not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch championship"})
		return
	}

	if championship.Status != models.ChampionshipStatusFinalized {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Championship must be finalized before generating matches"})
		return
	}

	if len(championship.Players) < 2 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "At least 2 players are required to generate matches"})
		return
	}

	// Check if matches already exist for this championship
	var existingMatchesCount int64
	h.DB.Model(&models.Match{}).Where("championship_id = ?", championshipID).Count(&existingMatchesCount)
	if existingMatchesCount > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Matches already exist for this championship"})
		return
	}

	// Generate round-robin matches (each player plays against every other player once)
	playerNames := make([]string, len(championship.Players))
	for i, player := range championship.Players {
		playerNames[i] = player.Name
	}

	matches := make([]models.Match, 0)
	for i := 0; i < len(playerNames); i++ {
		for j := i + 1; j < len(playerNames); j++ {
			match := models.Match{
				ChampionshipID: uint(championshipID),
				Player1:        playerNames[i],
				Player2:        playerNames[j],
				Game:           championship.Name, // Use championship name as game name
				Status:         models.MatchStatusPending,
				Player1Score:   0,
				Player2Score:   0,
			}
			matches = append(matches, match)
		}
	}

	// Create all matches
	if err := h.DB.Create(&matches).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create matches: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Matches generated successfully", "count": len(matches), "matches": matches})
}

func (h *MatchHandler) StartMatch(c *gin.Context) {
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

	if match.Status != models.MatchStatusPending {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Match is not in pending status"})
		return
	}

	now := time.Now()
	match.Status = models.MatchStatusStarted
	match.StartedAt = &now

	if err := h.DB.Save(&match).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start match"})
		return
	}

	c.JSON(http.StatusOK, match)
}

func (h *MatchHandler) UpdateMatchScore(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var request struct {
		Player1Score int `json:"player1_score"`
		Player2Score int `json:"player2_score"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
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

	if match.Status != models.MatchStatusStarted {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Match must be started to update score"})
		return
	}

	match.Player1Score = request.Player1Score
	match.Player2Score = request.Player2Score

	if err := h.DB.Save(&match).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update match score"})
		return
	}

	c.JSON(http.StatusOK, match)
}

func (h *MatchHandler) FinishMatch(c *gin.Context) {
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

	if match.Status != models.MatchStatusStarted {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Match must be started to finish it"})
		return
	}

	// Determine winner based on score
	var winner *string
	if match.Player1Score > match.Player2Score {
		winner = &match.Player1
	} else if match.Player2Score > match.Player1Score {
		winner = &match.Player2
	} else {
		// Draw - winner stays nil
		winner = nil
	}

	now := time.Now()
	match.Status = models.MatchStatusFinished
	match.Winner = winner
	match.FinishedAt = &now

	if err := h.DB.Save(&match).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to finish match"})
		return
	}

	c.JSON(http.StatusOK, match)
}

