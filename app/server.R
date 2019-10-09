source('../app/preprocessing.R')

shinyServer(function(input, output) {
  # panel 1 - map
  Background <- leaflet() %>% 
    addResetMapButton() %>%
    addTiles("Crime Rates") %>%
    addProviderTiles("CartoDB", group = "CartoDB")  %>%
    setView(lat = 40.7130, lng = -74.0059, zoom = 11) %>%
    addLayersControl(baseGroups = c("CartoDB", "Crime Rates"), position = "bottomleft")
  
  shape <- readOGR("../data/nypp.geojson")
  
  # color function
  map2color <- function(x, pal=c('#F2D7D5','#D98880', '#CD6155', '#C0392B', '#922B21', '#641E16'), limits = NULL) {
    if (is.null(limits)) limits = range(x)
    pal[findInterval(x, seq(limits[1], limits[2], length.out = length(pal) + 1), all.inside = TRUE)]
  }
  
  # map output
  output$selective_map <- renderLeaflet({
    map_df <- crime 
    colnames(map_df) <- sapply('ld', FUN = paste0, colnames(crime))
    for (i in c('ldTIME', 'ldPLACE', 'ldDESCRIPTION')) {
      if (input[[i]] != 'All') {map_df <- map_df[map_df[, i] == input[[i]],] }
    }
    mytable <- xtabs(~ ldDESCRIPTION + ldPLACE + ldTIME + ldPRECINCT, data = map_df)
    shape@data$mappingdata <- rep(0,77)
    count <- apply(mytable, 4, sum)
    for (i in 1:length(count)) {
      index <- which(shape@data$precinct == names(count)[i])
      shape@data$mappingdata[index] <- count[i]
    }
    
    Background %>% 
      addPolygons(data = shape, weight = 1.5,  fillOpacity = .5, 
                  fillColor = map2color(shape@data$mappingdata),
                  label = ~paste0(shape@data$precinct," Number of counts: ", shape@data$mappingdata),
                  highlightOptions = highlightOptions(weight = 3, color = "white", bringToFront = TRUE))
  })
  
  # panel 2 - time series
  output$plot = renderPlot({
    plot_df <- crime
    if (isTruthy(input$DATE)) {
      plot_df <- plot_df[plot_df$DATE == input$DATE,]
    } 
    for (i in c('BORO', 'DESCRIPTION', 'DAY', 'VIC_AGE', 'VIC_RACE', 'VIC_SEX', 'SUSP_AGE', 'SUSP_RACE', 'SUSP_SEX')) {
      if (input[[i]] != 'All') {
        plot_df <- plot_df[plot_df[, i] == input[[i]] ,]
      }
    }
    plot_hist <- geom_histogram(breaks = plot_breaks, color = 'blue', fill = 'white')
    if (input$HIST == 'Density') { 
      plot_hist <- geom_histogram(aes(y = ..density..), breaks = plot_breaks, color = 'blue', fill = 'white')
    }
    if (input$DENSITY == 'On' & input$HIST == 'Frequency') { 
      plot_density <- geom_density(aes(y = ..density.. * (nrow(plot_df)*60*60)), fill = 'red', alpha = 0.25) 
    } else if (input$DENSITY == 'On' & input$HIST == 'Density') {
      plot_density <- geom_density(aes(y = ..density..), fill = 'red', alpha = 0.25)
    } else {
      plot_density <- geom_blank()
    }
    ggplot(plot_df, aes(x = DATE_TIME)) +
      plot_hist + 
      plot_density +
      geom_vline(aes(xintercept = median(plot_df$DATE_TIME)), linetype = "dashed", size = 1) +
      scale_x_datetime(labels = date_format("%H:%M"), breaks = date_breaks('2 hour')) +
      labs(caption = 'Dashed line marks median of selected population', title = input$DATE) +
      theme(plot.caption = element_text(face = "italic", size = 14),
            axis.text.x = element_text(size = 13),
            axis.text.y = element_text(size = 13),
            axis.title.x = element_text(size = 18),
            axis.title.y = element_text(size = 18)) +
      xlab('Hour') + ylab('Frequency') 
  })
  
  # panel 3 - conditional probability
  output$CBplot <- renderPlot({
    df1 <- crime
    df1$DESCRIPTION <- as.factor(df1$DESCRIPTION)
    df1 <- crime[which(crime$BORO == input$jgBORO), ]
    df1 <- df1[which(df1$HOUR == input$jgHOUR), ]
    df1 <- df1[which(df1$DAY == input$jgDAY), ]
    df1 <- df1[which(df1$VIC_SEX == input$jgVIC_SEX), ]
    df1 <- df1[which(df1$VIC_AGE == input$jgVIC_AGE),]
    df2 <- as.data.frame(xtabs(~DESCRIPTION, data = df1))
    df3 <- subset(df2, df2$Freq != 0)
    
    ggplot(df3, aes(x = DESCRIPTION, y = Freq/sum(Freq), fill = DESCRIPTION)) + 
      geom_bar(stat = "identity", position = "stack") + 
      ggtitle("Chances Of Facing Different Crimes") +
      ylab("") + xlab("") + 
      scale_colour_brewer(name = 'Crime Type', palette = 'Paired') +
      theme(plot.title = element_text(size = 25),
            axis.text.x = element_text(face = "bold", size = 13),
            axis.text.y = element_text(face = "bold", size = 13)) + 
      coord_flip()
  })
  
})
