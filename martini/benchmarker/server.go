package main

import (
  "github.com/go-martini/martini"
  "github.com/martini-contrib/render"
)

type People []Person
type Person struct {
  Name string
}

func main() {
  // m := martini.Classic()

  // apparently to disable logging we can't use ClassicMartini(?), so do
  // everything it would normally do and leave out logging, then make a
  // ClassicMartini struct anyhow so we can use it the way all the tutorials
  // say.
	r := martini.NewRouter()
	mn := martini.New()
	// mn.Use(martini.Logger())
	mn.Use(martini.Recovery())
	mn.Use(martini.Static("public"))
	mn.MapTo(r, (*martini.Routes)(nil))
	mn.Action(r.Handle)
  m := &martini.ClassicMartini{mn, r}


  // set default layout
  m.Use( render.Renderer(render.Options{ Layout: "layout" }) )


  m.Get("/:title", func(params martini.Params, r render.Render) {
    title := params["title"]
    members := People{
      Person{Name: "Chris McCord"},
      Person{Name: "Matt Sears"},
      Person{Name: "David Stump"},
      Person{Name: "Ricardo Thompson"},
    }

    // use an anonymous struct to pass template data
    // see http://talks.golang.org/2012/10things.slide#2
    context := struct {
      Title string
      Members People
    }{
      title,
      members,
    }

    r.HTML(200, "index", context)
  })

  m.Run()
}
