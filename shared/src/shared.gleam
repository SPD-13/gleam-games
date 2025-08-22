import gleam/dynamic/decode
import gleam/json

pub type ClientMessage {
  HostRequest
}

pub fn client_message_decoder() -> decode.Decoder(ClientMessage) {
  use variant <- decode.then(decode.string)
  case variant {
    "host_request" -> decode.success(HostRequest)
    _ -> decode.failure(HostRequest, "ClientMessage")
  }
}

pub type ServerMessage {
  HostResponse(code: String)
}

pub fn server_message_to_json(server_message: ServerMessage) -> json.Json {
  let HostResponse(code:) = server_message
  json.object([
    #("code", json.string(code)),
  ])
}
