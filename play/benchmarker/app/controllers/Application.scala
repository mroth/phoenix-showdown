package controllers

import play.api._
import play.api.mvc._

object Application extends Controller {

  def index(title: String) = Action {
     val members = List(Map("name" -> "Chris McCord"), Map("name" -> "Matt Sears"), Map("name" -> "David Stump"), Map("name" -> "Ricardo Thompson"))
    Ok(views.html.index(members, title))
  }
}
