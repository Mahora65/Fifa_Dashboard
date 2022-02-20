# Ui functions ------------------------------------------------------------
uiChangeThemeDropdown <- function(dropDownLabel = "Change Theme", defaultTheme = "grey_light")
{
  changeThemeChoices <- c(
    "Light Theme" = "grey_light",
    "Dark Theme" = "grey_dark"
  )
  
  ns <- NS("moduleChangeTheme")
  dropdown <- tagList(
    selectizeInput(
      inputId = ns("dbxChangeTheme"),
      label = dropDownLabel,
      choices = changeThemeChoices,
      selected = defaultTheme
    )
  )
  
  return(dropdown)
}

uiChangeThemeOutput <- function()
{
  ns <- NS("moduleChangeTheme")
  themeOutput <- tagList(
    uiOutput(ns("uiChangeTheme"))
  )
  
  return(themeOutput)
}


# Server functions --------------------------------------------------------
serverChangeTheme <- function(input, output, session)
{
  observeEvent(
    input$dbxChangeTheme, 
    {
      output$uiChangeTheme <- renderUI({
        shinyDashboardThemes(theme = input$dbxChangeTheme)
      })
    }
  )
}