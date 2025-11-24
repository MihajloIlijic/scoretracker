package main

import (
	"log"
	"os"
	"time"

	"scoretracker/backend/internal/database"
	"scoretracker/backend/internal/handlers"
	"scoretracker/backend/internal/middleware"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	db, err := database.Connect()
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	if err := database.Migrate(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	router := gin.Default()

	// CORS configuration - allow all origins for development
	// Safari requires specific headers and configuration
	router.Use(cors.New(cors.Config{
		AllowAllOrigins:  true, // Allow all origins for development
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD", "PATCH"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With", "Access-Control-Request-Method", "Access-Control-Request-Headers"},
		ExposeHeaders:    []string{"Content-Length", "Content-Type", "Access-Control-Allow-Origin"},
		AllowCredentials: false, // Safari has issues with credentials and AllowAllOrigins
		MaxAge:           12 * time.Hour,
	}))

	router.Use(middleware.Logger())

	router.GET("/api/health", handlers.HealthCheck)

	matchHandler := handlers.NewMatchHandler(db)
	championshipHandler := handlers.NewChampionshipHandler(db)
	playerHandler := handlers.NewPlayerHandler(db)
	
	api := router.Group("/api")
	{
		// Championships
		api.GET("/championships", championshipHandler.GetAllChampionships)
		api.POST("/championships", championshipHandler.CreateChampionship)
		api.GET("/championships/:id", championshipHandler.GetChampionship)
		api.PUT("/championships/:id", championshipHandler.UpdateChampionship)
		api.DELETE("/championships/:id", championshipHandler.DeleteChampionship)
		api.POST("/championships/:id/finalize", championshipHandler.FinalizeChampionship)
		api.GET("/championships/:id/standings", championshipHandler.GetStandings)

		// Players
		api.GET("/players", playerHandler.GetAllPlayers)
		api.POST("/players", playerHandler.CreatePlayer)
		api.GET("/players/:id", playerHandler.GetPlayer)
		api.PUT("/players/:id", playerHandler.UpdatePlayer)
		api.DELETE("/players/:id", playerHandler.DeletePlayer)

		// Matches
		api.GET("/matches", matchHandler.GetAllMatches)
		api.POST("/matches", matchHandler.CreateMatch)
		api.GET("/matches/:id", matchHandler.GetMatch)
		// DELETE endpoint removed - matches should not be deletable
		api.POST("/championships/:id/generate-matches", matchHandler.GenerateRoundRobinMatches)
		api.POST("/matches/:id/start", matchHandler.StartMatch)
		api.PUT("/matches/:id/score", matchHandler.UpdateMatchScore)
		api.POST("/matches/:id/finish", matchHandler.FinishMatch)
	}

	port := os.Getenv("API_PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

