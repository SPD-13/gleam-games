import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/list
import gleam/otp/actor
import gleam/string
import shared.{type ServerMessage}

type State {
  State(
    clients: dict.Dict(String, Subject(ServerMessage)),
    games: dict.Dict(String, String),
  )
}

pub type Incoming {
  Register(id: String, subject: Subject(ServerMessage))
  Unregister(id: String)
  HostRequest(id: String)
}

fn generate_room_code() {
  let generate_char = fn(_) {
    // 'A' to 'Z'
    let ascii = int.random(26) + 65
    let assert Ok(codepoint) = string.utf_codepoint(ascii)
    codepoint
  }
  list.range(0, 3) |> list.map(generate_char) |> string.from_utf_codepoints()
}

fn hub(state: State, message: Incoming) -> actor.Next(State, Incoming) {
  case message {
    Register(id, subject) ->
      actor.continue(
        State(..state, clients: state.clients |> dict.insert(id, subject)),
      )
    Unregister(id) ->
      actor.continue(State(..state, clients: state.clients |> dict.delete(id)))
    HostRequest(id) -> {
      let response_subject = state.clients |> dict.get(id)
      case response_subject {
        Ok(subject) -> {
          let room_code = generate_room_code()
          process.send(subject, shared.HostResponse(room_code))
          actor.continue(
            State(..state, games: state.games |> dict.insert(room_code, id)),
          )
        }
        Error(_) -> actor.continue(state)
      }
    }
  }
}

pub fn start_hub() -> Subject(Incoming) {
  let assert Ok(hub) =
    actor.new(State(dict.new(), dict.new()))
    |> actor.on_message(hub)
    |> actor.start
  hub.data
}
