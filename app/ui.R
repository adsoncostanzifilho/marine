require(shiny)
require(leaflet)
require(dplyr)
# require(raster)

ui <- fluidPage(
  
  # PAGE NAME
  title = "Marine Case", 
  
  tags$head(
    
    # PAGE LOGO
    HTML('<link rel="icon", href="img/ship_logo.png", type="image/png" />'),
    
    # THEME 
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    
    #- Remove error messages
    tags$style(
      type="text/css",
      ".shiny-output-error { visibility: hidden; }",
      ".shiny-output-error:before { visibility: hidden; }"
    )
    
  ),
  
  br(),
  
  # PAGE START
  fluidRow(

    column(
      width = 2,
      class = 'title_logo',
      tags$a(
        href = "https://adsoncostanzi.shinyapps.io/csgoanalyzer/",
        tags$img(src = 'img/ship_logo.png', class = 'main_logo')
      ),
      h1("Marine Case", class = "title")
    ),
    
    # INPUTS 
    
    # selector ship_type
    column(
      width = 3,
      selectInput(
        inputId = 'ship_type',
        label = 'Select the Ship Type:',
        choices = "",
        selected = NULL,
        multiple = FALSE
      )
    ),
    
    # selector ship_name
    column(
      width = 3,
      selectInput(
        inputId = 'ship_name',
        label = 'Select the Vessel:',
        choices = "",
        selected = NULL, 
        multiple = FALSE
      )
    )
    
  ),
  
  
  hr(),
  
  
  # MAP
  leafletOutput("leaflet_map"),
  
  
  # LEGEND
  absolutePanel(
    class = "note_legend",
    top = 230,
    right = 10,
    
    column(
      width = 6,
      tags$img(src = 'img/ship_start.png', class = 'legend'),
      h5("Start Point")
    ),
    column(
      width = 6,
      tags$img(src = 'img/ship_end.png', class = 'legend'),
      h5("End Point")
    )
  ),
  
  
  # BOX
  uiOutput("note_box")
)
