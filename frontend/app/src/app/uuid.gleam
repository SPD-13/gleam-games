import gluid
import lustre/effect.{type Effect}

pub fn generate(to_msg: fn(String) -> msg) -> Effect(msg) {
  effect.from(fn(dispatch) { gluid.guidv4() |> to_msg |> dispatch })
}
