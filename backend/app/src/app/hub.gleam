import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/otp/actor

type State {
  State(
    clients: dict.Dict(String, Subject(Outgoing)),
    games: dict.Dict(String, String),
  )
}

pub type Outgoing {
  Abc
}

pub type Incoming {
  Register(id: String, subject: Subject(Outgoing))
  Unregister(id: String)
}

fn hub(state: State, message: Incoming) -> actor.Next(State, Incoming) {
  case message {
    Register(id, subject) ->
      actor.continue(
        State(..state, clients: state.clients |> dict.insert(id, subject)),
      )
    Unregister(id) ->
      actor.continue(State(..state, clients: state.clients |> dict.delete(id)))
  }
}

pub fn start_hub() -> Subject(Incoming) {
  let assert Ok(hub) =
    actor.new(State(dict.new(), dict.new()))
    |> actor.on_message(hub)
    |> actor.start
  hub.data
}
