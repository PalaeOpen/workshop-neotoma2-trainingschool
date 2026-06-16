
# Exercise
# Calculate aquatic proportions of taxa relative to the entire sample dataset
pra_aquatic_pct_of_total <- pra_samples %>%
  dplyr::filter(units == "NISP") %>% # Filter first by units to keep all ecological groups intact

  #Group and calculate the total count for each sample profile
  dplyr::group_by(depth, age) %>%
  dplyr::mutate(total_sum = sum(value, na.rm = TRUE)) %>%
  dplyr::ungroup() %>%  # Ungroup to allow clean subsetting next
  
  # filter down to just the aquatic components
  dplyr::filter(ecologicalgroup %in% c("AQUA", "ALGA", "AGRP")) %>%
  dplyr::filter(elementtype %in% c("pollen", "spore", "colony", "coenobium", 
                                   "thallus", "microfossil", "statoblast")) %>%
  # Calculate individual aquatic taxon proportions out of that total sample count
  dplyr::group_by(variablename) %>% 
  dplyr::mutate(prop = value / total_sum) %>% 
  
  # Format and sort
  dplyr::arrange(age) %>% 
  dplyr::select(depth, age, variablename, elementtype, prop, ecologicalgroup) %>% 
  dplyr::mutate(prop = as.numeric(prop))

# Preview the results
head(pra_aquatic_pct_of_total)

# sum proportions of aquatic taxa for each sample
pra_aquatic_total <- pra_aquatic_pct_of_total %>%
  group_by(depth,age) %>%
  summarise(aquatics=sum(prop)*100) %>%
  arrange(age)

# make the plot
rioja::strat.plot(pra_aquatic_total$aquatics, yvar = pra_aquatic_total$age,
                  ylabel = "Calibrated Years BP", x.names="aquatics",
                  y.rev = TRUE,
                  scale.percent = TRUE)


