import app/context
import app/hub
import app/router
import app/websocket
import gleam/erlang/process
import gleam/http/request
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let hub_subject = hub.start_hub()
  let context = context.Context(hub_subject)

  let assert Ok(_) =
    fn(req) {
      case request.path_segments(req) {
        ["ws"] -> websocket.handle_websocket(req, context)
        _ -> wisp_mist.handler(router.handle_request, secret_key_base)(req)
      }
    }
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}
