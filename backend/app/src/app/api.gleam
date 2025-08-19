import gleam/dynamic/decode
import gleam/json

pub type Incoming {
  HostRequest
}

pub fn incoming_decoder() -> decode.Decoder(Incoming) {
  use variant <- decode.then(decode.string)
  case variant {
    "host_request" -> decode.success(HostRequest)
    _ -> decode.failure(HostRequest, "Incoming")
  }
}

pub type Outgoing {
  HostResponse(code: String)
}

pub fn outgoing_to_json(outgoing: Outgoing) -> json.Json {
  let HostResponse(code:) = outgoing
  json.object([
    #("code", json.string(code)),
  ])
}
