library(shiny)
library(bs4Dash)
library(echarts4r)
library(thematic)
library(waiter)
library(magrittr)
library(dplyr)
library(gt)
library(gtExtras)
library(RColorBrewer)
library(maps)
library(plotly)
library(tidyverse)
library(magrittr)
library(DataExplorer)
library(maps)
library(plotly)
library(DT)
library(tidytext)
library(gridExtra)
library(factoextra)
library(kableExtra)
library(splitstackshape)
library(ggthemes)
library(data.table)
library(knitr)

load(url("https://github.com/Mahora65/Fifa_Dashboard/blob/develop/output/fifa_22_tidydata_cleaned.Rdata?raw=true"))

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

#Readme
read_me <- tabItem(tabName = "ReadMe",
                   h2("Introduction"),
                   p("FIFA 22 is a football simulation video game published by Electronic Arts as part of the FIFA series. It is the 29th installment in the FIFA sereis, and was released worldwide on 1 October 2021 for Microsoft Windows, Nintendo Switch, PlayStation 4, PlayStation 5, Xbox One, and Xbox Series X/S."),
                   h2("Features"),
                   p("This app have two tabs. The first tabs use slicer to filter Top 25 Player and Wonderkids (players under 21). The second pages show League Summary of specific league inculding the Top 5 player accouding to their position, world map of where the player come from, rating distribution, and age distribution."),
                   h2("Dataset"),
                   p("This dataset come kaggle: FIFA 22 complete player dataset"),
                   a("source", href= "https://www.kaggle.com/stefanoleone992/fifa-22-complete-player-dataset"))

# hometab
home_tab <- tabItem(tabName = 'Home',
                    fluidRow(
                      column(
                        width = 3,
                        textInput("homeName", "Name"),
                        sliderInput("homeHeight", "Height", 150, 210, c(150, 210)),
                        sliderInput("homeWeight", "Weight", 50, 110, c(50, 110)),
                        selectInput(
                          "homePos",
                          "Position",
                          list(
                            `All` = "all",
                            `Forward` = list("ST", "LW", "RW"),
                            `Midfiled` = list("LM", "RM", "CAM", "CM", "CDM"),
                            `Defender` = list("LWB", "RWB", "LB", "RB", "CB"),
                            `Keeper` = list("GK")
                          )
                        ),
                        selectInput("homeNat", "Nationality", c("All", sort(
                          unique(df$nationality_name)
                        ))),
                        selectInput("homeLeague", "League", c("All", sort(
                          unique(df$league_name)
                        ))),
                        uiOutput("homeTeamUI"),
                        checkboxInput("homeFree", "Free Agent"),
                        checkboxGroupInput("homePreFoot", "Preferred Foot", c("Left", "Right"), inline = TRUE),
                        tags$head(
                          tags$style(
                            type = "text/css",
                            ".inline label{ display: table-cell; text-align: left; vertical-align: middle; } .inline .form-group{display: table-row;}"
                          )
                        ),
                        tags$div(
                          class = "inline",
                          numericInput(
                            inputId = "homeMinVal",
                            label = "Min. Value: ",
                            value = 0
                          ),
                          numericInput(
                            inputId = "homeMaxVal",
                            label = "Max. Value: ",
                            value = 200000000
                          ),
                          numericInput(
                            inputId = "homeMinWage",
                            label = "Min. Weage",
                            value = 0
                          ),
                          numericInput(
                            inputId = "homeMaxWage",
                            label = "Max. Weage",
                            value = 350000
                          )
                        ),
                        sliderInput("homeWeakFoot", "Weak Foot", 0, 5, c(0, 5)),
                        sliderInput("homeSkill", "Skill Move", 0, 5, c(0, 5))
                      ),
                      column(
                        width = 9,
                        tabsetPanel(
                          id = "homeTabset",
                          selected = 'Players',
                          tabPanel("Players",
                                   gt_output("homeTop")),
                          tabPanel("Wonderkids",
                                   gt_output("homeKids"))
                        )
                      )
                    ))

# leaguestab
leagues_tab <- tabItem(tabName = 'Leagues',
                       fluidRow(column(
                         width = 4,
                         selectInput(
                           inputId = 'leagues_select',
                           label = 'Leagues:',
                           choices = c("All", sort(unique(df$league_name)))
                         )
                       ),
                       column(width = 8,
                              "")),
                       fluidRow(
                         box(
                           title = "Leagues Stats",
                           width = 12,
                           status = 'success',
                           solidHeader = TRUE,
                           collapsible = FALSE,
                           fluidRow(
                             bs4ValueBoxOutput("vbox1"),
                             bs4ValueBoxOutput("vbox2"),
                             bs4ValueBoxOutput("vbox3")
                           ),
                           fluidRow(column(
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
                                   'All' = "All",
                                   'Foward' = "FWD",
                                   'Midfielder' = "MID",
                                   'Defender' = "DEF",
                                   'Goalkeeper' = "GK"
                                 )
                               ),
                               gt_output("league_tb")
                             )
                           ),
                           column(
                             width = 6,
                             tabsetPanel(
                               id = "league_chart",
                               selected = 'Nationality',
                               tabPanel('Nationality',
                                        plotlyOutput("player_map")),
                               tabPanel("Rating Dist",
                                        plotlyOutput("player_dist")),
                               tabPanel("Age Dist",
                                        plotlyOutput("age_dist"))
                             )
                           ))
                         )
                       ))


# team tab
teams_tab <- tabItem(tabName = 'Teams',
                     fluidRow(
                       column(
                         width = 5,
                         selectInput(
                           inputId = 'T_leagues_select',
                           label = 'Leagues:',
                           choices = c(sort(unique(df$league_name)))
                         )
                       ),
                       column(width = 7,
                              "Leagues Logos")
                     ),
                     fluidRow(tabsetPanel(id = "teams_panel",
                                          vertical = TRUE)))

# players tab
players_tab <- tabItem(
  tabName = 'Players',
  fluidRow(
    column(width = 4,
           "player 1"),
    column(
      width = 4,
      tabBox(
        elevation = 2,
        id = "compare_players",
        width = 12,
        collapsible = FALSE,
        closable = FALSE,
        type = "tabs",
        status = "olive",
        solidHeader = TRUE,
        selected = "Overview",
        tabPanel("Overview",
                 "radar"),
        tabPanel("Traits",
                 'traits'),
        tabPanel("International",
                 "int. stat")
      )
    ),
    column(width = 4,
           "player 2")
  ),
  fluidRow("vertical mirrored barcharts")
)


dashboardPage(
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
      menuItem("ReadMe",
               tabName = "ReadMe",
               icon = icon("newspaper")),
      menuItem("Home",
               tabName = 'Home',
               icon = icon("home")),
      menuItem("Leagues",
               tabName = 'Leagues',
               icon = icon("futbol"))#,
      #menuItem("Teams", tabName = 'Teams', icon = icon("users")),
      #menuItem("Players",tabName = 'Players',icon = icon("user"))
    )
  ),
  body = dashboardBody(
    e_theme_register(echarts_dark_theme$options, name = echarts_dark_theme$name),
    tabItems(read_me,
             home_tab,
             leagues_tab#,
             #teams_tab,
             #players_tab
    )
  ),
  #    controlbar = dashboardControlbar(),
  footer = dashboardFooter(
    fixed = FALSE,
    left = p(
      "Developed by",
      a("Jitrayu Punrattanapongs",
        href = "https://www.linkedin.com/in/jitrayu-punrattanapongs/"),
      " 2022, ",
      strong("version "),
      "1.0.0"
    ),
    right = img(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/FIFA_22_logo.svg/langfr-1920px-FIFA_22_logo.svg.png", height = 30)
  ),
  title = 'FIFA 22 Dashboard'
)