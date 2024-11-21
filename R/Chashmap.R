#' @export
`[<-.C_hashmap` <- function(map, key, value) {
  insert(map, key, value)
  map
}

#' insert elements into a hashmap 
#' @usage insert(map, keys, values)
#' @param map Hashmap object of class `C_hashmap`
#' @param keys a scalar or vector of type numeric (int or real) or strings
#' @param values a scalar or vector of type numeric (int or real) or strings
#' @details
#' When inserting key value pairs as vectors, make sure that length(key) == length(value). 
#' The insertion is vectorized over the vector. Ie. internally, the map will call `insert(map, key[i], value[i])`
#' for i in 1:length(key)
#' @export
insert <- function(map, keys, values) {
  stopifnot(inherits(map, "C_hashmap"))
  stopifnot(is.character(keys) || is.numeric(keys))
  stopifnot (is.character(values) || is.numeric(values))
  stopifnot (length(keys) == length(values))
  .Call("C_hashmap_insert", map, keys, values)
  invisible()
}


#' retreive values for specific keys from a hashmap
#' @usage get(map, keys)
#' @param map Hashmap object of class `C_hashmap`
#' @param keys a scalar or vector of type numeric (int or real) or strings
#' @export
get <- function(map, keys) {
  stopifnot(inherits(map, "C_hashmap"))
  stopifnot(is.character(keys) || is.numeric(keys))
  vals <- .Call("C_hashmap_get", map, keys)

  if (length(vals) <= 1) {
    vals <- unlist(vals)
  }
  return(vals)
}

#' @export
`[.C_hashmap` <- function(map, val) {
  get(map, val)
}


#' Initialize an empty hashmap
#' @export
hashmap <- function() {
  .Call("C_hashmap_init")
}

#' @export
print.C_hashmap <- function(map) {
  size <- .Call("C_hashmap_size", map)
  cat(crayon::silver("# C Hashmap", format(map), "\n"))
  cat(crayon::silver("# size: ", size, "Elements"))
}

#' Retreive keys from the hashmap as a list 
#' @usage keys(map, simplify = FALSE)
#' @param simplify TRUE coerces the key list to a vector (default = FALSE)
#' @param map Hashmap object of class `C_hashmap`
#' @export
keys <- function(map, simplify = FALSE) {
  stopifnot(inherits(map, "C_hashmap"))
  vals <- .Call("C_hashmap_getkeys", map)

  if (length(vals) <= 1) {
    vals <- unlist(vals)
  }

  if (simplify)
    return(unlist(vals))
  else 
    return(vals)
}

#' Retreive values from the hashmap as a list 
#' @usage values(map, simplify = FALSE)
#' @param simplify TRUE coerces the key list to a vector (default = FALSE)
#' @param map Hashmap object of class `C_hashmap`
#' @export
values <- function(map, simplify = FALSE) {
  stopifnot(inherits(map, "C_hashmap"))

  vals <- .Call("C_hashmap_getvals", map)

  if (length(vals) <= 1) {
    vals <- unlist(vals)
  }
  if (simplify)
    return(unlist(vals))
  else 
    return(vals)
}

#' Clear all entries from the hashmap
#' @usage clear(map)
#' @param map Hashmap object of class `C_hashmap`
#' @export
clear <- function(map) {
  stopifnot(inherits(map, "C_hashmap"))

  .Call("C_hashmap_clear", map)
}

#' Return the number of elements stored in the hashmap
#' @usage size(map)
#' @param map Hashmap object of class `C_hashmap`
#' @export 
size <- function(map) {
  stopifnot(inherits(map, "C_hashmap"))
  .Call("C_hashmap_size", map)
}

#' Remove keys from the hashmap
#' @usage remove(map, keys)
#' @param keys a scalar or vector of type numeric (int or real) or strings
#' @export
remove <- function(map, keys) {
  stopifnot(inherits(map, "C_hashmap"))
  stopifnot (is.character(keys) || is.numeric(keys))
  .Call("C_hashmap_remove", map, keys)
}