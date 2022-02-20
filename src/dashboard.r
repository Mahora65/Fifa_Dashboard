library(DT)
library(shiny)
library(shinydashboard)

load("../output/fifa_22_tidydata_cleaned.Rdata")

ui <- dashboardPage(           # FULL PAGE: don't touch!
  dashboardHeader(),         # Header zone
  dashboardSidebar(),        # Sidebar zone
  dashboardBody()            # Body zone
)  

server <- function(input, output){  # Server: computations!
  
}

# Run the app ----
shinyApp(ui = ui, server = server)  # Aggregates the app.