import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

import model

pub fn main() {
  let app = lustre.application(model.init, model.update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn view(model: model.Model) -> Element(model.Msg) {
  case model {
    model.WaitingForCode ->
      html.h1([attribute.class("text-5xl")], [html.text("Creating room...")])
    model.Lobby(..) ->
      html.h1([attribute.class("text-5xl")], [html.text("Gleam Games!")])
  }
}
