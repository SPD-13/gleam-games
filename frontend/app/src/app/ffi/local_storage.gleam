import lustre/effect.{type Effect}

pub fn get_local_storage(
  key: String,
  to_msg: fn(Result(String, Nil)) -> msg,
) -> Effect(msg) {
  effect.from(fn(dispatch) {
    do_get_local_storage(key)
    |> to_msg
    |> dispatch
  })
}

@external(javascript, "local_storage.ffi.mjs", "getLocalStorage")
fn do_get_local_storage(key: String) -> Result(String, Nil) {
  Error(Nil)
}

pub fn set_local_storage(key: String, value: String) -> Effect(msg) {
  effect.from(fn(_) { do_set_local_storage(key, value) })
}

@external(javascript, "local_storage.ffi.mjs", "setLocalStorage")
fn do_set_local_storage(key: String, value: String) -> Nil {
  Nil
}
