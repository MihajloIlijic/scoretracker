package main

import (
	"log"
	"os"

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

	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"http://localhost:3000", "http://localhost:8080"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	router.Use(middleware.Logger())

	router.GET("/api/health", handlers.HealthCheck)

	scoreHandler := handlers.NewScoreHandler(db)
	api := router.Group("/api")
	{
		api.GET("/scores", scoreHandler.GetAllScores)
		api.POST("/scores", scoreHandler.CreateScore)
		api.GET("/scores/:id", scoreHandler.GetScore)
		api.PUT("/scores/:id", scoreHandler.UpdateScore)
		api.DELETE("/scores/:id", scoreHandler.DeleteScore)
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

