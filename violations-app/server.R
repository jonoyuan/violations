library(shinydashboard)
library(dplyr)
library(leaflet)
library(shiny)
library(sf)

map_df <- readRDS("map_df.rds")

pal <- colorNumeric("viridis", domain = 0:1)

function(input, output, session) {
  
  cd_df <- reactive({
    filter(map_df, cd %in% cds[[input$cd]])
  })
  
  
  output$map <- renderLeaflet({
    
    cd_df() %>% 
      leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>% 
      addPolygons(color = NULL, fillColor = NULL) %>%
      addLegend(pal = pal, values = 0:1, opacity = 1, title = NULL, position = "bottomright")
  })
  
  observe({
    fill_var <- cd_df()[[models[[input$model]]]]
    
    leafletProxy("map", data = cd_df()) %>% 
      clearShapes() %>% 
      addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 1, fillOpacity = 1,
                  fillColor = ~pal(fill_var),
                  popup = paste("BBL:", cd_df()$bbl, "<br>",
                                "Actual Violations:", cd_df()$true_16, "<br>",
                                "Previous Year Violations:", cd_df()$past_viol, "<br>",
                                "Logit Predictions:", round(cd_df()$logit, 2), "<br>",
                                "Decision Tree Predictions:", round(cd_df()$tree, 2), "<br>",
                                "Random Forest Predictions:", round(cd_df()$forest, 2), "<br>"),
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE))
  })
  
  cd_tbl <- reactive({
    cd_df() %>% 
      tibble::as_tibble() %>% 
      rename_(.dots = setNames(models[[input$model]], "prediction")) %>% 
      select(bbl, prediction) %>% 
      arrange(desc(prediction))
  })
  
  output$tbl <- DT::renderDataTable(cd_tbl(), selection = "single")
  
  # The use of `selected_row()` here is a hack to get the pop for a selected bbl form the DT table
  # to be displayed after restoring a bookmark. Without this hack, on the newly restore page 
  # `input$tbl_rows_selected` gets set back to NULL and the bookmarked popup is cleared
  # This is possbily a `DT` bug, see: https://github.com/rstudio/DT/issues/405
  selected_row <- reactiveVal(0)
  
  observe({
    new_selected_row <- input$tbl_rows_selected
    selected_row(new_selected_row)
  })
  
  onRestored(function(state) {
    new_selected_row <- state$input$tbl_rows_selected
    selected_row(new_selected_row)
  })

  observeEvent(selected_row(), {
    if (is.null(selected_row()) | selected_row() == 0) {
      leafletProxy("map") %>% clearPopups()
      return()
    }
    
    bbl_selected <- cd_tbl()[["bbl"]][[selected_row()]]
    
    bbl_df <- filter(cd_df(), bbl == as.character(bbl_selected))

    bbl_center <- suppressWarnings(st_centroid(bbl_df))[["geometry"]][[1]]

    leafletProxy("map") %>% 
      clearPopups() %>%
      addPopups(lng = bbl_center[1], lat = bbl_center[2], 
                popup = paste("BBL:", bbl_df$bbl, "<br>",
                              "Actual Violations:", bbl_df$true_16, "<br>",
                              "Previous Year Violations:", bbl_df$past_viol, "<br>",
                              "Logit Predictions:", round(bbl_df$logit, 2), "<br>",
                              "Decision Tree Predictions:", round(bbl_df$tree, 2), "<br>",
                              "Random Forest Predictions:", round(bbl_df$forest, 2), "<br>"))
  })
  
  setBookmarkExclude("tbl_rows_all")
}

