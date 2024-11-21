#' @export
`[<-.C_hashmap` <- function(map, key, value) {

  # argument checking
  stopifnot(is.character(key) || is.numeric(key))
  stopifnot (is.character(value) || is.numeric(value))
  stopifnot (length(key) == length(value))

  .Call("C_hashmap_insert", map, key, value)
  map
}

#' @export
`[.C_hashmap` <- function(map, val) {
  stopifnot (is.character(val) || is.numeric(val))
  .Call("C_hashmap_get", map, val)
}

#' @export
hashmap <- function() {
  .Call("C_hashmap_init", PACKAGE = "Chashmap")
}

#' @export
keys <- function(map, simplify = FALSE) {
  stopifnot(inherits(map, "C_hashmap"))
  vals <- .Call("C_hashmap_getkeys", map)
  if (simplify)
    return(unlist(vals))
  else 
    return(vals)
}

#' @export
values <- function(map, simplify = FALSE) {
  stopifnot(inherits(map, "C_hashmap"))

  vals <- .Call("C_hashmap_getvals", map)
  if (simplify)
    return(unlist(vals))
  else 
    return(vals)
}

#' @export
clear <- function(map) {
  stopifnot(inherits(map, "C_hashmap"))

  .Call("C_hashmap_clear", map)
}

#' @export 
size <- function(map) {
  stopifnot(inherits(map, "C_hashmap"))
  .Call("C_hashmap_size", map)
}