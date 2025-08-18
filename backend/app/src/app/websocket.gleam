import app/context
import gleam/http/request
import gleam/list
import gleam/option.{None, Some}
import mist

pub fn handle_websocket(req, context: context.Context) {
  mist.websocket(
    req,
    handle_message,
    on_init: fn(_conn) {
      let maybe_params = request.get_query(req)
      let user_id = case maybe_params {
        Ok(params) ->
          case list.key_find(params, "id") {
            Ok(id) -> Some(id)
            Error(_) -> None
          }
        Error(_) -> None
      }
      #(user_id, None)
    },
    on_close: fn(state) { todo },
  )
}

fn get_user_id(state, next) {
  case state {
    Some(id) -> next(id)
    None -> mist.stop()
  }
}

fn handle_message(state, message, conn) {
  use user_id <- get_user_id(state)
  case message {
    mist.Text(_msg) -> mist.continue(state)
    mist.Binary(_) | mist.Custom(_) -> mist.continue(state)
    mist.Closed | mist.Shutdown -> mist.stop()
  }
}
