import lustre/effect.{type Effect}

pub type Model {
  WaitingForCode
  Lobby(code: String)
}

pub type Msg

pub fn init(_args) -> #(Model, Effect(Msg)) {
  #(WaitingForCode, effect.none())
}

pub fn update(model: Model, _msg: Msg) -> #(Model, Effect(Msg)) {
  #(model, effect.none())
}
