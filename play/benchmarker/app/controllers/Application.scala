package controllers

import play.api._
import play.api.mvc._
import models._

class Application extends Controller {

  def index(title: String) = Action {
     Ok(views.html.index(Seq(
       Member("Chris McCord"),
       Member("Matt Sears"),
       Member("David Stump"),
       Member("Ricardo Thompson")
    ), title))
  }
}
