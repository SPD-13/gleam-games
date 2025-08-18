import app/hub
import gleam/erlang/process

pub type Context {
  Context(hub_subject: process.Subject(hub.Incoming))
}
