import app/context
import app/hub
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/list
import gleam/option.{Some}
import mist
import shared

pub fn handle_websocket(req, context: context.Context) {
  use user_id <- get_user_id(req)
  mist.websocket(
    req,
    fn(state, message, conn) {
      case message {
        mist.Text(msg) -> {
          let result = msg |> json.parse(shared.client_message_decoder())
          case result {
            Ok(incoming) -> {
              case incoming {
                shared.HostRequest ->
                  process.send(context.hub_subject, hub.HostRequest(user_id))
              }
            }
            Error(_) -> Nil
          }
          mist.continue(state)
        }
        mist.Custom(out) -> {
          let result =
            out
            |> shared.server_message_to_json
            |> json.to_string
            |> mist.send_text_frame(conn, _)
          case result {
            Ok(_) -> mist.continue(state)
            Error(_) -> mist.stop()
          }
        }
        mist.Binary(_) -> mist.continue(state)
        mist.Closed | mist.Shutdown -> mist.stop()
      }
    },
    on_init: fn(_conn) {
      let socket_subject = process.new_subject()
      process.send(context.hub_subject, hub.Register(user_id, socket_subject))
      let selector = process.new_selector() |> process.select(socket_subject)
      #(Nil, Some(selector))
    },
    on_close: fn(_state) {
      process.send(context.hub_subject, hub.Unregister(user_id))
    },
  )
}

fn get_user_id(req, next) {
  let maybe_params = request.get_query(req)
  case maybe_params {
    Ok(params) ->
      case list.key_find(params, "id") {
        Ok(id) -> next(id)
        Error(_) ->
          response.new(400)
          |> response.set_body(
            mist.Bytes(bytes_tree.from_string("Missing 'id' parameter")),
          )
      }
    Error(_) ->
      response.new(400)
      |> response.set_body(
        mist.Bytes(bytes_tree.from_string("Malformed query parameters")),
      )
  }
}
