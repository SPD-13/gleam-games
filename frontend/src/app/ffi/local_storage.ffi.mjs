import { Ok, Error } from "../../gleam.mjs";

export function getLocalStorage(key) {
  const value = window.localStorage.getItem(key);
  return value !== null ? new Ok(value) : new Error(undefined);
}

export function setLocalStorage(key, value) {
  window.localStorage.setItem(key, value);
}
