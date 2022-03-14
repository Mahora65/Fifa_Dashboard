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
  fluidRow(
    column(
      width = 4,
      "slicing"
    ),
    column(
      width = 8,
      tabsetPanel(
        id= "homeTabset",
        selected = 'Players',
        tabPanel(
          "Players",
          "Content"
        ),
        tabPanel(
          "Teams",
          "Content"
        ),
        tabPanel(
          "Wonderkids",
          "Content"
        ),
        tabPanel(
          "Hidden Gems",
          "Content"
        )
      )
    )
  )
)

# leaguestab
leagues_tab <- tabItem(
  tabName = 'Leagues',
  fluidRow(
    column(
      width = 5,
      selectInput(
        inputId = 'leagues_select',
        label = 'Leagues:',
        choices = c(
          'leagues_1',
          'leagues_2',
          'leagues_3',
          'leagues_4'
          ),
      actionButton(
        inputId = 'triggerLeague',
        label = 'Select'
      )
  )
    ),
    column(
      width = 7,
      "Leagues Logos"
    )
  ),
  fluidRow(
    box(
      title = "Leagues Stats",
      width = 12,
      status= 'success',
      solidHeader= TRUE,
      collapsible= FALSE,
      fluidRow(
        valueBox(
          width = 4,
          value = "$ 1.1 B",
          subtitle = "Total League Value",
          color = "warning",
          icon = icon("dollar-sign")
        ),
        valueBox(
          width = 4,
          value = 512,
          subtitle = "Players in the league",
          color = 'warning',
          icon = icon("users")
        ),
        valueBox(
          width = 4,
          value = 18,
          subtitle = "Teams competing",
          color = 'warning',
          icon = icon("trophy")
        )
      ),
      fluidRow(
        column(
          width = 6,
          box(
            title = "Best player in the League",
            width = 12,
            status = 'teal',
            solidHeader = FALSE,
            selectInput(
              inputId = 'league_best',
              label = NULL,
              choices = c(
                'All',
                'Foward',
                'Midfielder',
                'Defender',
                'Goalkeeper'
              )
            ),
            "Table"
          )
        ),
        column(
          width = 6,
          tabsetPanel(
            id = "league_chart",
            selected = 'Nationality',
            tabPanel(
              'Nationality',
              "chart"
            ),
            tabPanel(
              "Rating Dist",
              "chart"
            ),
            tabPanel(
              "Dominate Foot",
              "chart"
            )
          )
        )
      )
    )
  )
)


# team tab
teams_tab <- tabItem(
  tabName = 'Teams',
  fluidRow(
    column(
      width = 5,
      selectInput(
        inputId = 'leagues_select',
        label = 'Leagues:',
        choices = c(
          'leagues_1',
          'leagues_2',
          'leagues_3',
          'leagues_4'
          ),
      actionButton(
        inputId = 'triggerLeague',
        label = 'Select'
      )
  )
    ),
    column(
      width = 7,
      "Leagues Logos"
    )
  ),
  fluidRow(
    tabsetPanel(
      id= "teams_panel",
      selected = "Team 1",
      vertical = TRUE,
      tabPanel("Team 1", "Content 1"),
      tabPanel("Team 2", "Content 2"),
      tabPanel("Team 3", "Content 3"),
      tabPanel("Team 4", "Content 4"),
      tabPanel("Team 5", "Content 5"),
      tabPanel("Team 6", "Content 6"),
      tabPanel("Team 7", "Content 7"),
      tabPanel("Team 8", "Content 8"),
      tabPanel("Team 9", "Content 9"),
      tabPanel("Team 10", "Content 10"),
      tabPanel("Team 11", "Content 11"),
      tabPanel("Team 12", "Content 12"),
      tabPanel("Team 13", "Content 13"),
      tabPanel("Team 14", "Content 14"),
      tabPanel("Team 15", "Content 15"),
      tabPanel("Team 16", "Content 16"),
      tabPanel("Team 17", "Content 17"),
      tabPanel("Team 18", "Content 18")
    )
  )
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
      left = p("Developed by", 
      a(
        "Jitrayu Punrattanapongs", 
        href = "https://www.linkedin.com/in/jitrayu-punrattanapongs/"
        ), 
        " 2022, ",
        strong("version "),
        "1.0.0"
        ),
      right = img(src= "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/FIFA_22_logo.svg/langfr-1920px-FIFA_22_logo.svg.png", height = 30 )
    ),
    title = 'FIFA 22 Dashboard'
  ),
  server = function(input, output, session){}
)
