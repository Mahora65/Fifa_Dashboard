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
library(waffle)
library(knitr)

load("../output/fifa_22_tidydata_cleaned.RData")

##################### VARS ################################


###########################################################

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
      tabItems(home_tab,
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
  ),
  server = function(input, output, session) {
    # Home Server
    aoi_teams = reactive({
      df %>%
        filter(if (input$homeLeague != "All")
          grepl(input$homeLeague, league_name)
          else
            grepl("*", league_name)) %>%
        pull(club_name) %>%
        unique() %>%
        sort()
    })
    output$homeTeamUI <-
      renderUI(selectInput("homeTeam", "Team", c("All", aoi_teams())))
    
    homeTop_data <- reactive({
      df %>%
        filter(
          grepl(input$homeName, short_name),
          if (input$homePos != "all")
            grepl(input$homePos, player_positions)
          else
            grepl("*", player_positions),
          if (input$homeNat != "All")
            grepl(input$homeNat, nationality_name)
          else
            grepl("*", nationality_name),
          if (input$homeLeague != "All")
            grepl(input$homeLeague, league_name)
          else
            grepl("*", league_name),
          if (input$homeTeam != "All")
            grepl(input$homeTeam, club_name)
          else
            grepl("*", club_name),
          if (input$homeFree == TRUE)
            grepl("^$", league_name)
          else
            grepl("*", league_name),
          if (is.null(input$homePreFoot))
            grepl("*", preferred_foot)
          else
            grepl(input$homePreFoot, preferred_foot),
          height_cm >= input$homeHeight[1],
          height_cm <= input$homeHeight[2],
          weight_kg >= input$homeWeight[1],
          weight_kg <= input$homeWeight[2],
          value_eur >= input$homeMinVal,
          value_eur <= input$homeMaxVal,
          wage_eur >= input$homeMinWage,
          wage_eur <= input$homeMaxWage,
          weak_foot >= input$homeWeakFoot[1],
          weak_foot <= input$homeWeakFoot[2],
          skill_moves >= input$homeSkill[1],
          skill_moves <= input$homeSkill[2]
        ) %>%
        slice_max(n = 25,
                  with_ties = FALSE,
                  order_by = overall) %>%
        select(
          player_face_url,
          nation_flag_url,
          overall,
          potential,
          short_name,
          player_positions,
          age,
          preferred_foot,
          weak_foot,
          skill_moves,
          club_logo_url
        ) %>%
        arrange(desc(overall), desc(potential)) %>%
        gt() %>%
        tab_header("Top 25 Player by Filters") %>%
        gt_img_rows(columns = player_face_url, height = 60) %>%
        gt_img_circle(column = nation_flag_url, height = 40) %>%
        gt_img_rows(columns = club_logo_url, height = 40) %>%
        fmt_number(columns = overall, decimals = 0) %>%
        fmt_number(columns = potential, decimals = 0) %>%
        fmt_number(columns = age, decimals = 0) %>%
        gt_fa_rating(column = weak_foot) %>%
        gt_fa_rating(column = skill_moves) %>%
        cols_align(
          align = "center",
          columns = c(overall, potential, age, player_positions, nation_flag_url)
        ) %>%
        gt_color_rows(columns = overall,
                      palette = "RColorBrewer::RdYlGn",
                      domain = c(0, 100)) %>%
        gt_color_rows(columns = potential,
                      palette = "RColorBrewer::RdYlGn",
                      domain = c(0, 100)) %>%
        cols_width(
          overall ~ px(75),
          age ~ px(75),
          player_face_url ~ px(75),
          nation_flag_url ~ px(50),
          preferred_foot ~ px(75)
        ) %>%
        cols_label(
          player_face_url = "",
          nation_flag_url = "",
          club_logo_url = "",
          overall = "Overall",
          potential = "Potential",
          short_name = "Name",
          player_positions = "Positions",
          preferred_foot = "Foot",
          weak_foot = "Weak Foot",
          skill_moves = "Skill Moves",
          age = "Age"
        ) %>%
        gt_theme_538()
    })
    output$homeTop <-
      render_gt(expr = homeTop_data(), width = pct(100))
    
    homeKids_data <- reactive({
      df %>%
        filter(
          grepl(input$homeName, short_name),
          if (input$homePos != "all")
            grepl(input$homePos, player_positions)
          else
            grepl("*", player_positions),
          if (input$homeNat != "All")
            grepl(input$homeNat, nationality_name)
          else
            grepl("*", nationality_name),
          if (input$homeLeague != "All")
            grepl(input$homeLeague, league_name)
          else
            grepl("*", league_name),
          if (input$homeTeam != "All")
            grepl(input$homeTeam, club_name)
          else
            grepl("*", club_name),
          if (input$homeFree == TRUE)
            grepl("^$", league_name)
          else
            grepl("*", league_name),
          if (is.null(input$homePreFoot))
            grepl("*", preferred_foot)
          else
            grepl(input$homePreFoot, preferred_foot),
          height_cm >= input$homeHeight[1],
          height_cm <= input$homeHeight[2],
          weight_kg >= input$homeWeight[1],
          weight_kg <= input$homeWeight[2],
          value_eur >= input$homeMinVal,
          value_eur <= input$homeMaxVal,
          wage_eur >= input$homeMinWage,
          wage_eur <= input$homeMaxWage,
          weak_foot >= input$homeWeakFoot[1],
          weak_foot <= input$homeWeakFoot[2],
          skill_moves >= input$homeSkill[1],
          skill_moves <= input$homeSkill[2],
          age <= 21
        ) %>%
        slice_max(n = 25,
                  with_ties = FALSE,
                  order_by = potential) %>%
        select(
          player_face_url,
          nation_flag_url,
          overall,
          potential,
          short_name,
          player_positions,
          age,
          preferred_foot,
          weak_foot,
          skill_moves,
          club_logo_url
        ) %>%
        arrange(desc(potential), desc(overall)) %>%
        gt() %>%
        tab_header("Top 25 Wonderkids by Filters") %>%
        gt_img_rows(columns = player_face_url, height = 60) %>%
        gt_img_circle(column = nation_flag_url, height = 40) %>%
        gt_img_rows(columns = club_logo_url, height = 40) %>%
        fmt_number(columns = overall, decimals = 0) %>%
        fmt_number(columns = potential, decimals = 0) %>%
        fmt_number(columns = age, decimals = 0) %>%
        gt_fa_rating(column = weak_foot) %>%
        gt_fa_rating(column = skill_moves) %>%
        cols_align(
          align = "center",
          columns = c(overall, potential, age, player_positions, nation_flag_url)
        ) %>%
        gt_color_rows(columns = overall,
                      palette = "RColorBrewer::RdYlGn",
                      domain = c(0, 100)) %>%
        gt_color_rows(columns = potential,
                      palette = "RColorBrewer::RdYlGn",
                      domain = c(0, 100)) %>%
        cols_width(
          overall ~ px(75),
          age ~ px(75),
          player_face_url ~ px(75),
          nation_flag_url ~ px(50),
          preferred_foot ~ px(75)
        ) %>%
        cols_label(
          player_face_url = "",
          nation_flag_url = "",
          club_logo_url = "",
          overall = "Overall",
          potential = "Potential",
          short_name = "Name",
          player_positions = "Positions",
          preferred_foot = "Foot",
          weak_foot = "Weak Foot",
          skill_moves = "Skill Moves",
          age = "Age"
        ) %>%
        gt_theme_538()
    })
    output$homeKids <-
      render_gt(expr = homeKids_data(), width = pct(100))
    
    #League Serve
    
    output$vbox1 <- renderbs4ValueBox({
      bs4ValueBox(
        width = 4,
        value = round((
          df %>%
            filter(
              if (input$leagues_select != "All")
                grepl(input$leagues_select, league_name)
              else
                grepl("*", league_name)
            ) %>%
            pull(value_eur) %>%
            sum()
        ) / 1000000000, digits = 2),
        footer = "Total League Value",
        subtitle = "billons Euros",
        color = "warning",
        icon = icon("dollar-sign")
      )
    })
    
    output$vbox2 <- renderbs4ValueBox({
      bs4ValueBox(
        width = 4,
        value = df %>% filter(
          if (input$leagues_select != "All")
            grepl(input$leagues_select, league_name)
          else
            grepl("*", league_name)
        ) %>% count() %>% pull(n),
        subtitle = "Players",
        footer = "Total Players in the league",
        color = 'warning',
        icon = icon("users")
      )
    })
    
    output$vbox3 <- renderbs4ValueBox({
      bs4ValueBox(
        width = 4,
        value = df %>% filter(
          if (input$leagues_select != "All")
            grepl(input$leagues_select, league_name)
          else
            grepl("*", league_name)
        ) %>%  pull(club_name) %>% unique() %>% length(),
        subtitle = "Teams",
        footer = "Total Teams competing",
        color = 'warning',
        icon = icon("trophy")
      )
    })
    
    output$player_map <-
      renderPlotly({
        ggplotly(
          ggplot(
            map_data("world") %>%
              mutate(region = as.character(region)) %>%
              left_join((
                df %>%
                  filter(
                    if (input$leagues_select != "All")
                      grepl(input$leagues_select, league_name)
                    else
                      grepl("*", league_name)
                  ) %>%
                  mutate(
                    Nationality = as.character(nationality_name),
                    Nationality = if_else(nationality_name %in% "England",
                                          "UK", nationality_name)
                  ) %>%
                  count(Nationality, name = "Number of Player") %>%
                  rename(region = Nationality) %>%
                  mutate(region = as.character(region))
              ),
              by = "region"
              ),
            aes(long, lat, group = group)
          ) +
            geom_polygon(
              aes(fill = `Number of Player`),
              color = "white",
              show.legend = FALSE
            ) +
            scale_fill_viridis_c(option = "C") +
            theme_fivethirtyeight() +
            labs(fill = "Number of Player",
                 title = "Number of Player From Around the World")
        )
      })
    output$player_dist <- renderPlotly({
      ggplotly(
        df %>%
          filter(
            if (input$leagues_select != "All")
              grepl(input$leagues_select, league_name)
            else
              grepl("*", league_name),
            if (input$league_best != "All")
              grepl(input$league_best, Class)
            else
              grepl("*", Class)
          ) %>%
          ggplot(aes(x = overall)) +
          geom_histogram(color = "white", fill =
                           "darkgrey") +
          ggtitle("Player Ratings Distribution") +
          theme_fivethirtyeight() +
          theme(axis.text.y = element_blank())
      )
    })
    output$age_dist <- renderPlotly({
      ggplotly(
        df %>%
          filter(
            if (input$leagues_select != "All")
              grepl(input$leagues_select, league_name)
            else
              grepl("*", league_name),
            if (input$league_best != "All")
              grepl(input$league_best, Class)
            else
              grepl("*", Class)
          ) %>%
          ggplot(aes(x = age)) +
          geom_histogram(color = "white", fill = "darkgrey") +
          ggtitle("Player Age Distribution") +
          theme_fivethirtyeight() +
          theme(axis.text.y = element_blank())
      )
    })
    league_tb_data <- reactive({
      df %>%
        filter(
          if (input$leagues_select != "All")
            grepl(input$leagues_select, league_name)
          else
            grepl("*", league_name),
          if (input$league_best != "All")
            grepl(input$league_best, Class)
          else
            grepl("*", Class)
        ) %>%
        select(
          player_face_url,
          nation_flag_url,
          overall,
          short_name,
          player_positions,
          age,
          club_logo_url
        ) %>%
        slice_max(n = 5,
                  with_ties = FALSE,
                  order_by = overall) %>%
        gt() %>%
        gt_img_rows(columns = player_face_url, height = 60) %>%
        gt_img_circle(column = nation_flag_url, height = 40) %>%
        gt_img_rows(columns = club_logo_url, height = 40) %>%
        fmt_number(columns = overall, decimals = 0) %>%
        gt_color_rows(columns = overall,
                      palette = "RColorBrewer::RdYlGn",
                      domain = c(0, 100)) %>%
        cols_width(overall ~ px(75),
                   age ~ px(75),
                   player_face_url ~ px(75),
                   nation_flag_url ~ px(50)) %>%
        cols_label(
          player_face_url = "",
          nation_flag_url = "",
          club_logo_url = "",
          overall = "Overall",
          short_name = "Name",
          player_positions = "Positions",
          age = "Age"
        ) %>%
        gt_theme_538()
    })
    
    output$league_tb <-
      render_gt(expr = league_tb_data(), width = pct(100))
  }
)
