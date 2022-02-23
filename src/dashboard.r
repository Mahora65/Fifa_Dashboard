library(shiny)
library(bs4Dash)
library(echarts4r)
library(thematic)
library(waiter)
library(magrittr)

thematic_shiny()

# echarts4r theme #3d444c
echarts_dark_theme <- list(
  options = '{
    "color":["#6610f2", "#ffc107", "#e83e8c", "#ff851b", "#17a2b8", "#3d9970"], 
    "backgroundColor": "#343a40", 
    "textStyle": {
        color: "#fff"
    }
  }',
  name = "dark_theme"
)

# hometab
home_tab <- tabItem(
  tabName = 'Home',
  "HomeTab"
)

# leaguestab
leagues_tab <- tabItem(
  tabName = 'Leagues',
  "LeaguesTab"
)

# team tab
teams_tab <- tabItem(
  tabName = 'Teams',
  "TeamsTab"
)

# players tab
players_tab <- tabItem(
  tabName = 'Players',
  "PlayersTab"
)


shinyApp(
  ui = dashboardPage(
#    preloader = list(html = tagList(spin_1(), "loading..."), color= "#344E41"),
    dark = TRUE,
    help = TRUE,
    fullscreen = TRUE,
    scrollToTop = TRUE,
    header = dashboardHeader(
      title = dashboardBrand(
        title = "FIFA 22",
        color = "olive",
        image = "https://styles.redditmedia.com/t5_5deeyy/styles/communityIcon_68pr096e11181.png?width=256&s=b82ff7cd39c6c1653c1ccb2bcf93aacda49cfa5a",
        opacity = 0.8
      ),
      fixed = TRUE
    ),
    sidebar = dashboardSidebar(
      fixed = TRUE,
      skin = "light",
      status = "primary",
      id = "sidebar",
      sidebarMenu(
        id = "current_tab",
        flat = FALSE,
        compact = FALSE,
        childIndent = TRUE,
        menuItem(
          "Home",
          tabName = 'Home',
          icon = icon("home")
        ),
        menuItem(
          "Leagues",
          tabName = 'Leagues',
          icon = icon("futbol")
        ),
        menuItem(
          "Teams",
          tabName = 'Teams',
          icon = icon("users")
        ),
        menuItem(
          "Players",
          tabName = 'Players',
          icon = icon("user")
        )
      )
    ),
    body = dashboardBody(
      e_theme_register(echarts_dark_theme$options, name = echarts_dark_theme$name),
      tabItems(
        home_tab,
        leagues_tab,
        teams_tab,
        players_tab
      )
    ),
#    controlbar = dashboardControlbar(),
    footer = dashboardFooter(
      fixed = FALSE,
      left = a(
        href= "https://twitter.com/mahora65",
        target = "_blank", "@mahora65"
      ),
      right = "2021"
    ),
    title = 'FIFA 22 Dashboard'
  ),
  server = function(input, output, session){}
)
