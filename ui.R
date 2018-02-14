library(shiny)
library(leaflet)

ui <- dashboardPage(
  dashboardHeader(
    title = "LA Homeless Encampment Project",
    titleWidth = 350),
  dashboardSidebar(
    width = 350,
    sidebarMenu(
      menuItem("Description Analysis", tabName = "Description_app"),
      menuItem("Regression Analysis", tabName = "Regression_app"),
      menuItem("GeoSpatial Analysis", tabName = "GeoSpatial_app")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "Description_app",
              {
                
                titlePanel("Descriptive Analysis",
                           windowTitle = "Descriptive Analysis")
                sidebarLayout(
                  sidebarPanel(
                    selectInput(inputId = "desc_select",
                                label = "Choose the Dataset",
                                choices = list("311 Calls","Crime","Homeless Count"),
                                selected="311 Calls"
                    ),
                    #############################    #############################    #############################
                    conditionalPanel(
                      condition = "input.desc_select == 'Crime'",
                      radioButtons(inputId = "crime_year",
                                   label = "Choose a Year",
                                   choices = list("2017",
                                                  "2016",
                                                  "2015"),
                                   selected = "2017"),
                      selectInput(inputId = "desc_crime_var",
                                  label = "Choose a Variable",
                                  choices = list("Month",
                                                 "Week",
                                                 "Age",
                                                 "Race"),
                                  selected = "Month")
                    ),
                    #############################    #############################    #############################
                    conditionalPanel(
                      condition = "input.desc_select == '311 Calls'",
                      radioButtons(inputId = "year_obs",
                                   label = "Choose a Year: ",
                                   choices = list("2017" = 2017,
                                                  "2016" = 2016,
                                                  "2015" = 2015),
                                   selected = "2017"),
                      selectInput(inputId = "category",
                                  label = "Source and Time Analysis",
                                  choices = list("Request by Source" = "a_req",
                                                 "Efficiency by Source" = "b_req",
                                                 "Total Request by Month" = "c_req",
                                                 "Total Request by Weekday" = "d_req",
                                                 "Request Source by Month" = "e_req",
                                                 "Request Source by Weekday" = "f_req"),
                                  selected = "Request by Source")
                      
                      
                    ),
                    textInput(inputId = "tract", label = "Enter Tract Number (Leave it empty for having the whole data)" , ""),
                    textInput(inputId = "CD", label = "Enter Council District Number (Leave it empty for having the whole data)" , "")
                    
                  ),
                  
                  mainPanel(
                    plotOutput(outputId = "plot")
                  )
                  
                )
              }
      ),
      tabItem(tabName = "Regression_app",
              {
                titlePanel("Basic Variable Regression",
                           windowTitle = "Regression")
                
                sidebarLayout(
                  sidebarPanel(
                    helpText("Create regression lines with data from the census information"),
                    
                    selectInput(inputId = "var1",
                                label = "Choose a variable to display",
                                choices = list ("count_311",
                                                "count_crime",
                                                "homeless_2017",
                                                "count_shelter",
                                                "count_population"),
                                selected = "count_311"),
                    selectInput(inputId = "var2",
                                label = "Choose a variable to display",
                                choices = list ("count_311",
                                                "count_crime",
                                                "homeless_2017",
                                                "count_shelter",
                                                "count_population"),
                                selected = "count_shelter")
                    
                  ),
                  mainPanel(
                    # textOutput(outputId = "selected_var")
                    plotOutput(outputId = "plot_reg"),
                    textOutput(outputId = "text")
                  )
                )
              }),
      tabItem(tabName = "GeoSpatial_app",
              {
                titlePanel("Geo-Spatial Visulization",windowTitle="Geo-Spatial Visulization")
                sidebarLayout(
                sidebarPanel(
                  textInput(inputId = "target_zone", label = "Search For a Place" , ""),
                  
                  selectInput(inputId = "mapping",
                              label = "Choose the Mapping Level",
                              choices = list("Census Tract","Council District"),
                              selected="Census Tract"
                  ),
                  
                  checkboxInput("county", label = "Show the Whole LA County", value = FALSE),
                  
                  selectInput(inputId = "select1", label = "Select the Measure to Show", 
                              choices = list("Crime"="num_crime" , "Shelter"="num_shelt","311 Calls"="num_call","Homeless Count"="num_homeless","Combined Measure")),
                  
                  conditionalPanel(
                    condition = "input.select1 == 'num_shelt'",
                    radioButtons("shelt_var", label = "Choose a Variable",
                                 choices = list("Absolute Number of Shelters" = "num_shelt_abs", "Number of shelters/Number of Homeless")
                    )
                  ),    
                  conditionalPanel(
                    condition = "input.select1 == 'num_crime'",
                    dateRangeInput(inputId = 'DateRange_Crime',
                                   label = 'Date range for crime data: yyyy-mm-dd',
                                   start = min(crime$DateOccurred), end = max(crime$DateOccurred)
                    ),
                    radioButtons("crime_var", label = "Choose a Variable",
                                 choices = list("Absolute Number of Crimes" = "num_crime_abs", "Number of Crimes/Number of Homeless")
                    )
                  ),
                  
                  
                  conditionalPanel(
                    condition = "input.select1 == 'num_call'",
                    dateRangeInput(inputId = 'DateRange_Call',
                                   label = 'Date range for 311 calls: yyyy-mm-dd',
                                   start = min(calls$CreatedDate), end = max(calls$CreatedDate)
                    ),
                    radioButtons("call_var", label = "Choose a Variable",
                                 choices = list("Absolute Number of Calls" = "num_call_abs","Number of Calls/Number of Homeless" = "num_call_normal", "Average Response Time" = "response")
                                 
                    )
                  ),
                  
                  conditionalPanel(
                    condition = "input.select1 == 'num_homeless'",
                    radioButtons("homeless_year", label = "Choose a Year",
                                 choices = list("2017", "2016","2015")
                    ),
                    radioButtons("homeless_var", label = "Choose a Variable",
                                 choices = list("Homeless Count" = "num_homeless","Number of Homeless/Population"="num_homeless_normal","Unsheltered Rate" = "unshelt_rate")
                    )
                  ),
                  
                  conditionalPanel(
                    condition="input.select1 == 'Combined Measure'",
                    radioButtons("measure_year", label = "Choose a Year",
                                 choices = list("2017", "2016","2015")
                    ),
                    helpText("Choose the Weights For Different Variables"),
                    numericInput(inputId="crime_w", label="Crime Weight", value=1,min = 0,max=100),
                    numericInput(inputId="shelt_w", label="Shelter Weight", value=1,min = 0,max=100),
                    numericInput(inputId="homeless_w", label="Homeless Count Weight", value=1,min = 0,max=100),
                    numericInput(inputId="call_w", label="311 Calls Weight", value=1,min = 0,max=100)
                  )
                  
                ),
                mainPanel(
                  leafletOutput(outputId = "map",height = 340),
                  plotOutput(outputId = "bar",height = 140)
                  
                ))
              })
    )
  )
)

