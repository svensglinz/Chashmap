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
#' insert elements into a hashmap 
#' @usage insert(map, keys, values)
#' @param map Hashmap object of class `C_hashmap`
#' @param keys a scalar or vector of type numeric (int or real) or strings
#' @param values a scalar or vector of type numeric (int or real) or strings
#' @details
#' When inserting key value pairs as vectors, make sure that length(key) == length(value). 
#' The insertion is vectorized over the vector. Ie. internally, the map will call `insert(map, key[i], value[i])`
#' for i in 1:length(key)
#' 
insert <- function(map, keys, values) {
  stopifnot(inherits(map, "C_hashmap"))
  stopifnot(is.character(key) || is.numeric(key))
  stopifnot (is.character(value) || is.numeric(value))
  stopifnot (length(key) == length(value))
  .Call("C_hashmap_insert", map, key, value)
}

#' @export
#' retreive values for specific keys from a hashmap
#' @usage get(map, keys)
#' @param map Hashmap object of class `C_hashmap`
#' @param keys a scalar or vector of type numeric (int or real) or strings
#' 
get <- function(map, keys) {
  stopifnot(inherits(map, "C_hashmap"))
  stopifnot(is.character(key) || is.numeric(key))
  .Call("C_hashmap_get", map, keys)
}

#' @export
`[.C_hashmap` <- function(map, val) {
  stopifnot (is.character(val) || is.numeric(val))
  .Call("C_hashmap_get", map, val)
}

#' @export
#' Initialize an empty hashmap
hashmap <- function() {
  .Call("C_hashmap_init", PACKAGE = "Chashmap")
}


#' @export
#' Retreive keys from the hashmap as a list 
#' @usage keys(map, simplify = FALSE)
#' @param simplify TRUE coerces the key list to a vector (default = FALSE)
#' @param map Hashmap object of class `C_hashmap`
keys <- function(map, simplify = FALSE) {
  stopifnot(inherits(map, "C_hashmap"))
  vals <- .Call("C_hashmap_getkeys", map)
  if (simplify)
    return(unlist(vals))
  else 
    return(vals)
}

#' @export
#' Retreive values from the hashmap as a list 
#' @usage values(map, simplify = FALSE)
#' @param simplify TRUE coerces the key list to a vector (default = FALSE)
#' @param map Hashmap object of class `C_hashmap`
values <- function(map, simplify = FALSE) {
  stopifnot(inherits(map, "C_hashmap"))

  vals <- .Call("C_hashmap_getvals", map)
  if (simplify)
    return(unlist(vals))
  else 
    return(vals)
}

#' @export
#' Clear all entries from the hashmap
#' @usage clear(map)
#' @param map Hashmap object of class `C_hashmap`
clear <- function(map) {
  stopifnot(inherits(map, "C_hashmap"))

  .Call("C_hashmap_clear", map)
}

#' @export 
#' Return the number of elements stored in the hashmap
#' @usage size(map)
#' @param map Hashmap object of class `C_hashmap`
size <- function(map) {
  stopifnot(inherits(map, "C_hashmap"))
  .Call("C_hashmap_size", map)
}

#' @export
#' Remove keys from the hashmap
#' @usage remove(map, keys)
#' @param keys a scalar or vector of type numeric (int or real) or strings
remove <- function(map, keys) {
  stopifnot(inherits(map, "C_hashmap"))
  stopifnot (is.character(keys) || is.numeric(keys))
  .Call("C_hashmap_remove", map, keys)
}