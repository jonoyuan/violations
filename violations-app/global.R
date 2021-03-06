enableBookmarking(store = "url")

cds <- c(
  "Bay Ridge/Dyker Heights" = 310L,
  "Bedford Stuyvesant" = 303L,
  "Bensonhurst" = 311L,
  "Borough Park" = 312L,
  "Brownsville" = 316L,
  "Bushwick" = 304L,
  "Coney Island" = 313L,
  "Crown Heights/Prospect Heights" = 308L,
  "East Flatbush" = 317L,
  "East New York/Starrett City" = 305L,
  "Flatbush/Midwood" = 314L,
  "Flatlands/Canarsie" = 318L,
  "Fort Greene/Brooklyn Heights" = 302L,
  "Greenpoint/Williamsburg" = 301L,
  "Park Slope/Carroll Gardens" = 306L,
  "S. Crown Hts/Lefferts Gardens" = 309L,
  "Sheepshead Bay "= 315L,
  "Sunset Park" = 307L
)

models <- c(
  "Actual Violations" = "true_16",
  "Previous Year Violations" = "past_viol",
  "Logit Predictions" = "logit",
  "Decision Tree Predictions" = "tree",
  "Random Forest Predictions" = "forest"
)