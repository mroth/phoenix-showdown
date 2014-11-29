package main

import (
	"github.com/gin-gonic/gin"
	"html/template"
)

type People []Person
type Person struct {
	Name string
}

func main() {
	// Creates a router without any middleware by default
	r := gin.New()

	// Global middlewares
	r.Use(gin.Recovery())

	// Setup templates
	html := template.Must(template.ParseFiles("./templates/layout.tmpl", "./templates/index.tmpl", "./templates/bio.tmpl"))
	r.SetHTMLTemplate(html)

	// Action handler
	r.GET("/:title", func(c *gin.Context) {
		title := c.Params.ByName("title")
		members := People{
			Person{Name: "Chris McCord"},
			Person{Name: "Matt Sears"},
			Person{Name: "David Stump"},
			Person{Name: "Ricardo Thompson"},
		}

		context := struct {
			Title   string
			Members People
		}{
			title,
			members,
		}

		c.HTML(200, "layout.tmpl", context)
	})

	// Run the server
	r.Run(":3000")
}
