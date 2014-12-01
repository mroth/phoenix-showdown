package main

import (
	"github.com/gin-gonic/gin"
)

func main() {
	// Creates a router without any middleware by default
	r := gin.New()

	// Global middlewares
	r.Use(gin.Recovery())

	// Setup templates
	r.LoadHTMLGlob("templates/*")

	// Action handler
	r.GET("/:title", func(c *gin.Context) {
		title := c.Params.ByName("title")
		members := []gin.H{
			{"Name": "Chris McCord"},
			{"Name": "Matt Sears"},
			{"Name": "David Stump"},
			{"Name": "Ricardo Thompson"}}

		c.HTML(200, "layout.tmpl", gin.H{"Title": title, "Members": members})
	})

	// Run the server
	r.Run(":3000")
}
