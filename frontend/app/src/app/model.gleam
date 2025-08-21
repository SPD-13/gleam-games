import app/ffi/local_storage as ls
import app/uuid
import lustre/effect.{type Effect}
import lustre_websocket as ws

pub type Model {
  Connecting
  WaitingForRoomCode(ws: ws.WebSocket)
  Lobby(ws: ws.WebSocket, code: String)
}

pub type Msg {
  GotUserId(maybe_id: Result(String, Nil))
  GeneratedUserId(id: String)
  WebSocket(event: ws.WebSocketEvent)
}

pub fn init(_args) -> #(Model, Effect(Msg)) {
  #(Connecting, ls.get_local_storage("user-id", GotUserId))
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    GotUserId(Error(_)) -> #(model, uuid.generate(GeneratedUserId))
    GotUserId(Ok(id)) -> #(model, ws.init("/ws?id=" <> id, WebSocket))
    GeneratedUserId(id) -> #(
      model,
      effect.batch([
        ws.init("/ws?id=" <> id, WebSocket),
        ls.set_local_storage("user-id", id),
      ]),
    )
    WebSocket(event) ->
      case event {
        ws.OnOpen(socket) -> #(WaitingForRoomCode(socket), ws.send(socket, ""))
        ws.OnTextMessage(_) -> todo
        ws.InvalidUrl | ws.OnBinaryMessage(_) | ws.OnClose(_) -> #(
          model,
          effect.none(),
        )
      }
  }
}
