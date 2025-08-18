import gleam/erlang/process
import gleam/otp/actor

type State {
  State(clients: List(String))
}

pub type Message {
  Host
}

fn hub(state: State, message: Message) -> actor.Next(State, Message) {
  case message {
    _ -> actor.continue(state)
  }
}

pub fn start_hub() -> process.Subject(Message) {
  let assert Ok(hub) =
    actor.new(State([]))
    |> actor.on_message(hub)
    |> actor.start
  hub.data
}
