library(DT)
library(shiny)
library(shinydashboard)
library(dashboardthemes)
source("moduleChangeTheme.R")

load("../output/fifa_22_tidydata_cleaned.Rdata")

### UI
ui <- dashboardPage(
  
  ### UI header
  dashboardHeader(
    
    ### changing logo
    title = shinyDashboardLogo(
      theme = 'grey_light',
      boldText = 'FIFA',
      mainText = '22',
      badgeText = 'Dashboard'
    )
  ),
  
  ### UI sidebar
  dashboardSidebar(
    
    ### Theme dropddown
    uiChangeThemeDropdown()
  ),
  
  ### UI body
  dashboardBody(
    
    ### changing theme
    uiChangeThemeOutput()
  )
)  

server <- function(input, output){
  
  ## Changing Theme
  callModule(module = serverChangeTheme, id= 'moduleChangeTheme')
}

# Run the app ----
shinyApp(ui = ui, server = server)