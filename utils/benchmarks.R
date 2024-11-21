library(Chashmap)
library(r2r)
library(tidyverse)

Chashmap <- Chashmap::hashmap()
r2rmap <- r2r::hashmap()
#======== INSERTION ===========#

# generate random keys
set.seed(1)

i_vals <- c(1e2, 1e3, 1e4, 1e5, 1e6)

benchmark_results <- data.frame(
  i = integer(),
  method = character(),
  avg_time_ns = numeric()
)

for (i in i_vals) {
  Chashmap <- Chashmap::hashmap()
  r2rmap <- r2r::hashmap()
  keys_num <- runif(i, 1, 1e8)
  vals_num <- runif(i, 1, 1e8)
  keys_str <- replicate(i, paste0(sample(letters, 10, replace = TRUE), collapse = ""))

  res <- microbenchmark::microbenchmark(
    Chashmap_num = {
      Chashmap[keys_num] <- vals_num
    },
    Chashmap_str = {
      Chashmap[keys_str] <- vals_num
    },
    r2rmap_num = {
      if (i < 1e5)
        r2rmap[keys_num] <- vals_num
      else 
        NULL
    },
    r2rmap_str = {
      if (i < 1e5)
        r2rmap[keys_str] <- vals_num
      else 
        NULL
    },
    times = 3L
  )

  avg_times <- aggregate(time ~ expr, data = as.data.frame(res), FUN = mean)

  benchmark_results <- rbind(
    benchmark_results,
    data.frame(
      i = i,
      method = avg_times$expr,
      avg_time_ns = avg_times$time
    )
  )
}

# plot
benchmark_results |> 
  mutate(avg_time_ns = ifelse(str_detect(method, "r2rmap") & i >= 1e5, NA, avg_time_ns)) |> 
  ggplot(aes(x = log10(i), y = log10(avg_time_ns), color = method)) +
  geom_point(size = 4, show.legend = FALSE) + 
  theme_classic(base_size = 16) + 
  scale_color_manual(values = c("orange", "orange", "blue", "blue")) +
  scale_linetype_manual(values = c("solid", "dashed", "solid", "dashed")) +
  geom_line(aes(linetype = method)) +
  labs(
    title = "Insertion of random values (key = (numeric / string[10]), value = numeric)", 
    x = "log10(number of insertions)", 
    y = "log10(Insertion time), ns"
  )

ggsave(last_plot(), filename = "b1.png", height = 8, width = 12)


#======== LOOKUP ===========#

# generate random keys
set.seed(1)

i_vals <- c(1e2, 1e3, 1e4, 1e5, 1e6)

benchmark_results2 <- data.frame(
  i = integer(),
  method = character(),
  avg_time_ns = numeric()
)

for (i in i_vals) {
  Chashmap1 <- Chashmap::hashmap()
  Chashmap2 <- Chashmap::hashmap()
  r2rmap1 <- r2r::hashmap()
  r2rmap2 <- r2r::hashmap()

  keys_num <- runif(i, 1, 1e8)
  vals_num <- runif(i, 1, 1e8)
  keys_str <- replicate(i, paste0(sample(letters, 10, replace = TRUE), collapse = ""))

  # populate maps
  Chashmap1[keys_num] <- vals_num
  Chashmap2[keys_str] <- vals_num

  if (i < 1e5) {
    r2rmap1[keys_num] <- vals_num
    r2rmap2[keys_str] <- vals_num
  }

  res <- microbenchmark::microbenchmark(
    Chashmap_num = {
      Chashmap1[keys_num]
    },
    Chashmap_str = {
      Chashmap2[keys_str]
    },
    r2rmap_num = {
      if (i < 1e5)
        r2rmap1[keys_num]
      else 
        NULL
    },
    r2rmap_str = {
      if (i < 1e5)
        r2rmap2[keys_str]
      else 
        NULL
    },
    times = 3L
  )

  avg_times <- aggregate(time ~ expr, data = as.data.frame(res), FUN = mean)

  benchmark_results2 <- rbind(
    benchmark_results2,
    data.frame(
      i = i,
      method = avg_times$expr,
      avg_time_ns = avg_times$time
    )
  )
  print(i)
}

# plot
benchmark_results2 |> 
  mutate(avg_time_ns = ifelse(str_detect(method,"r2rmap") & i >= 1e5, NA, avg_time_ns)) |> 
  ggplot(aes(x = log10(i), y = log10(avg_time_ns), color = method)) +
  geom_point(size = 4, show.legend = FALSE) + 
  theme_classic(base_size = 16) + 
  scale_color_manual(values = c("orange", "orange", "blue", "blue")) +
  geom_line(aes(linetype = method)) +
  scale_linetype_manual(values = c("solid", "dashed", "solid", "dashed")) +
  labs(
    title = "lookup of all inserted keys (key = (numeric / string[10]), value = numeric)", 
    x = "log10(number of lookups)", 
    y = "log10(Insertion time), ns"
  )

  ggsave(last_plot(), filename = "b2.png", height = 8, width = 12)
