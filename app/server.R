server <- function(input, output, session){
  
  # Reading data
  db <<- data.table::fread('data/ships.csv')
  
  
  # Update select Inputs - ship_type
  observe(
    updateSelectInput(
      session = session,
      inputId = "ship_type",
      choices = unique(db$ship_type)
    )
  )
  
  
  # Update select Inputs - ship_name
  observe(
    updateSelectInput(
      session = session,
      inputId = "ship_name",
      choices = db %>% filter(ship_type == input$ship_type) %>% .$SHIPNAME %>% unique()
    )
  )
  
  # Distance and Filter
  db_dist <- reactive({
    
    db_dist <- db %>%
      filter(
        ship_type == input$ship_type,
        SHIPNAME == input$ship_name
      ) %>%
      mutate(
        lat_lag = lag(LAT),
        lon_lag = lag(LON)
      ) %>%
      rowwise() %>%
      mutate(
        distance = raster::pointDistance(
          p1 = c(LON, LAT), 
          p2 = c(lon_lag, lat_lag),
          lonlat = TRUE)
      ) %>%
      ungroup()
    
    return(db_dist)
    
  })
  
  
  # Longest Distances
  long_dist <- reactive({
  
    db_dist <- db_dist()
    
    long_dist <- db_dist %>%
      filter(
        distance == max(distance, na.rm = TRUE)
      ) %>%
      top_n(
        n = 1,
        wt = DATETIME
      )
    
    return(long_dist)
    
  })
  
  
  # Map
  dist_map <- reactive({
    
    long_dist <- long_dist()
    
    # create leaflet icon
    ship_start <- makeIcon(
      iconUrl = "www/img/ship_start.png",
      iconWidth = 50, 
      iconHeight = 50
    )
    
    ship_end <- makeIcon(
      iconUrl = "www/img/ship_end.png",
      iconWidth = 50, 
      iconHeight = 50
    )
    
    # create map
    leaftlet_map <- leaflet(long_dist) %>% 
      addTiles() %>%
      addMarkers(lat = ~LAT, lng = ~LON, popup = 'Start Point', icon = ship_start) %>%
      addMarkers(lat = ~lat_lag, lng = ~lon_lag, popup = 'End Point', icon = ship_end) %>%
      addPolylines(
        lat = ~c(LAT,lat_lag),
        lng = ~c(LON, lon_lag),
        stroke = TRUE,
        opacity = 1,
        weight = 5,
        color = 'black',
        dashArray =  '10, 10',
        popup = ~paste(round(distance, 2), "m")
      ) 
      
    
   return(leaftlet_map)
    
  })
  
  
  # Box
  note_box <- reactive({
  
    db_dist <- db_dist()
    
    db_summ <- db_dist %>%
      group_by(SHIPNAME) %>%
      summarise(
        avg_speed = mean(SPEED, na.rm = TRUE),
        avg_dist = mean(distance, na.rm = TRUE),
        min_dist = min(distance, na.rm = TRUE),
        max_dist = max(distance, na.rm = TRUE),
        dist_total = sum(distance, na.rm = TRUE)
      )
    
    note <- absolutePanel(
      class = "note_box",
      bottom = 50,
      right = 50,
      
      # BOX
      h2(tags$b(db_summ$SHIPNAME)),
      hr(class = "hr_box"),
      h3("Average Speed:", tags$b(round(db_summ$avg_speed, 2), "knots")),
      h3("Average Distance:", tags$b(round(db_summ$avg_dist, 2), "m")),
      h3("Total Distance:", tags$b(round(db_summ$dist_total, 2), "m")),
      h3("Maximum Distance:", tags$b(round(db_summ$max_dist, 2), "m")),
      h3("Minimum Distance:", tags$b(round(db_summ$min_dist, 2), "m"))
    )
    
    return(note)
    
  })
  
  
  
  # OUTPUTS
  output$leaflet_map <- renderLeaflet(dist_map())
  output$note_box <- renderUI(note_box())
  
}