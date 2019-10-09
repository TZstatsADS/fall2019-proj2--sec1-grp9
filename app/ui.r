source('../doc/preprocessing.R')

shinyUI(
  navbarPage("NYC Crime Directory",
             theme = shinytheme("cosmo"),
             # panel 1 - map
             tabPanel("Crime Rates Map",
                      div(leafletOutput("selective_map", width = "100%", height = 800),
                          fixedPanel(id = "controls", class = "panel panel-default",
                                     draggable = TRUE, top = 60, left = 40,
                                     width = "20%", 
                                     height = "auto",
                                     fluidPage(
                                       h3("Filters"),
                                       selectInput('ldTIME', 'Time of Day',
                                                   choices = c('All', time_list), selected = 'All'),
                                       selectInput('ldPLACE', 'Place',
                                                   choices = c('All', location_list), selected = 'All'),
                                       selectInput('ldDESCRIPTION', 'Crime Type',
                                                   choices = c('All', type_list), selected = 'All')
                                     ))
                          )
                      ),
             # panel 2 - time series
             tabPanel("By the Hour",
                      fluidPage(
                        plotOutput("plot"),
                        hr(),
                        
                        fluidRow(
                          column(2,
                                 p('Hourly Crime Statistics', style = "font-size:24px"),
                                 mainPanel(
                                   # br(),
                                   p('Explore trends in New York City crime activity over the course of a day.
                                   See how activity changes accross borough, day of week, suspect and victim demographics, or select a specifc day to monitor activity for.
                                     Filter between frequency histogram and density plots overlays.',
                                     style = "font-size:18px"),
                                   width = "50%")
                                 ),
                          column(2,
                                 h4('Plot Settings'),
                                 radioButtons('HIST', 'Histogram', c('Frequency', 'Density'),
                                              selected = 'Frequency'),
                                 radioButtons('DENSITY', 'Density Plot Overlay', c('On', 'Off'),
                                              selected = 'On')
                                 ),
                          column(2,
                                 h4('Crime Features'),
                                 selectInput("BORO", label = "Borough",
                                             choices = c('All', unique(crime$BORO)), selected = 'All'),
                                 selectInput("DESCRIPTION", label = "Crime Type",
                                             choices = c('All', type_list), selected = 'All')
                                 ),
                          column(2,
                                 h4('Date'),
                                 selectInput("DAY", label = "Day of Week",
                                             choices = c('All', weekday_list), selected = 'All'),
                                 dateInput("DATE", label = "Date",
                                           min = min(crime$DATE[crime$DATE >= '2019-01-01']), max = max(crime$DATE), startview = 'year')
                                 ),
                          column(2,
                                 h4('Victims'),
                                 selectInput("VIC_AGE", label = "Age",
                                             choices = c('All', unique(crime$VIC_AGE)), selected = 'All'),
                                 selectInput("VIC_RACE", label = "Race",
                                             choices = c('All', unique(crime$VIC_RACE)), selected = 'All'),
                                 selectInput("VIC_SEX", label = "Sex",
                                             choices = c('All', unique(crime$VIC_SEX)), selected = 'All')
                                 ),
                          column(2,
                                 h4('Suspects'),
                                 selectInput("SUSP_AGE", label = "Age",
                                             choices = c('All', unique(crime$SUSP_AGE)), selected = 'All'),
                                 selectInput("SUSP_RACE", label = "Race",
                                             choices = c('All', unique(crime$SUSP_RACE)), selected = 'All'),
                                 selectInput("SUSP_SEX", label = "Sex",
                                             choices = c('All', unique(crime$SUSP_SEX)), selected = 'All')
                                 )
                          )
                        )
                      ),
             # panel 3 - conditional probability ----
             tabPanel("Test Your Chances",
                      titlePanel("User Travel Information"),
                      sidebarLayout(
                        sidebarPanel(
                          selectInput('jgDAY', 'Day of Week', weekday_list, selected = "Monday"),
                          hr(),
                          sliderInput('jgHOUR', 'Time of Day', min = 0, max = 23, value = 12),
                          hr(),
                          selectInput('jgBORO', 'Where are you going', unique(crime$BORO), selected = "MANHATTAN"),
                          hr(),
                          selectInput('jgVIC_SEX', 'Gender', gender_list, selected = "F"),
                          hr(),
                          selectInput("jgVIC_AGE", "Your age:", age_list, selected = "25-44")
                          ),
                        
                        mainPanel(width = 8,
                                  plotOutput("CBplot", height = "700px", width = "100%")
                                  )
                        )
                      ),
             tabPanel("Data source",
                      fluidPage(title = "Data Description",
                                fluidRow(
                                  column(4,
                                         img(src='Logo.PNG', align = "left")
                                         ),
                                  column(8,
                                         h2('Data Description:'),
                                         br(),
                                         h4('This application utilizes data from NYC Open Data (https://opendata.cityofnewyork.us/).'),
                                         h4('The dataset consists of 2019 police report records from the months of January to July. Each entry in the dataset represents one crime and information from the corresponding police report.'),
                                         h4('Relevant fields used and analyzed over the course of production include: borough, date, time, crime description, crime category, crime severity, place of crime, suspect demographic information, victim demographic information, and the latitude and longitude of the crime.')
                                         )
                                  )
                                )
                      ),
             tabPanel("Developers", align = "middle",
                      hr(),
                      h1(("Please contact us for further information.")),
                      h3(("We also value your insightful feedback!")),
                      hr(),
                      h4(("Dong, Lulu")),
                      h4(("ld2820@columbia.edu")),
                      h4(("Gao, Jason")),
                      h4(("yg2583@columbia.edu")),
                      h4(("Hadzic, Samir")),
                      h4(("sh3586@columbia.edu")),
                      h4(("Song, Mingming")),
                      h4(("ms5710@columbia.edu")), br(),
                      h4(("The contact info is listed in alphabetical order.")),br(),br(),
                      img(src='bottom.gif')
                      )
             )
  )