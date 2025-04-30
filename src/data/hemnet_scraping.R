# Web scraping script in R to retrieve all final sale
# prices for houses in Malmö municipality from Hemnet.
# The script crawls multiple pages and fetches detailed
# information for each sold house, including
# final sale price, number of rooms, living area,
# year of construction, operating costs, and geographic coordinates.
# The results are saved as a CSV file for further analysis.

# Load necessary libraries
library(rvest)
library(httr)
library(stringr)
library(lubridate)
library(jsonlite)
library(tibble)
library(dplyr)

user_agent_header <- user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0")

# Function for scraping property details from individual pages
scrape_property_details <- function(url) {
    Sys.sleep(2) # Delay to avoid overloading the website

    html <- read_html(GET(url, user_agent_header))

    adress <- html |>
        html_element("title") |>
        html_text(trim = TRUE)

    gata <- str_extract(adress, "^[A-Za-zåäöÅÄÖéÉ\\s]+\\s\\d+")
    område <- str_extract(adress, "[A-Za-zåäöÅÄÖ]+(?=,\\sMalmö)")

    # URL for Nominatim Geocoding API
    base_url <- "https://nominatim.openstreetmap.org/search"

    # Make the request using only the street name and number
    response <- GET(url = base_url, query = list(q = gata, format = "json"))

    # Check if the response is successful
    if (status_code(response) == 200) {
        result <- content(response, "text", encoding = "UTF-8")

        json_result <- fromJSON(result)
    }

    # Convert lat and lon to numeric values
    lat <- as.numeric(json_result$lat[1])
    long <- as.numeric(json_result$lon[1])

    # Extract the property details
    table_text <- html |>
        html_elements(
            css = ".ListingLayout_infoSection__YOaRJ > section:nth-child(4) > div:nth-child(1) > section:nth-child(1)"
        ) |>
        html_text(trim = TRUE) |>
        str_squish()

    slutpris <- str_extract(table_text, "Slutpris([0-9\\s]+)kr")
    utgangspris <- str_extract(table_text, "Utgångspris([0-9\\s]+)kr")
    prisutveckling <- str_extract(table_text, "Prisutveckling([\\+\\-0-9\\s]+)kr")
    antal_rum <- str_extract(table_text, "Antal rum([0-9]+)")
    boarea <- str_extract(table_text, "Boarea([0-9\\s]+)m²")
    biarea <- str_extract(table_text, "Biarea([0-9\\s]+)m²")
    tomtarea <- str_extract(table_text, "Tomtarea([0-9\\s]+)m²")
    byggar <- str_extract(table_text, "Byggår([0-9]{4})")
    driftkostnad <- str_extract(table_text, "Driftskostnad([0-9\\s]+)kr/år")
    sälj_datum <- str_extract(table_text, "\\((\\d{1,2} [a-zA-Z]+ \\d{4})\\)") |> str_remove_all("[\\(\\)]")

    # Clean and format the extracted data
    data_tibble <- tibble(
        slutpris = slutpris,
        utgangspris = utgangspris,
        prisutv = prisutveckling,
        antal_rum = antal_rum,
        boarea = boarea,
        biarea = biarea,
        tomtarea = tomtarea,
        byggar = byggar,
        driftkostnad = driftkostnad,
        sälj_datum = sälj_datum,
        område = as.factor(område),
        latitude = lat,
        longitude = long
    ) |>
        mutate(
            slutpris = as.numeric(str_replace_all(slutpris, "[^0-9\\-]", "")),
            utgangspris = as.numeric(str_replace_all(utgangspris, "[^0-9\\-]", "")),
            prisutv = as.numeric(str_replace_all(prisutveckling, "[^0-9\\-]", "")),
            antal_rum = as.numeric(str_replace_all(antal_rum, "[^0-9]", "")),
            boarea = as.numeric(str_replace_all(boarea, "[^0-9]", "")),
            biarea = as.numeric(str_replace_all(biarea, "[^0-9]", "")),
            tomtarea = as.numeric(str_replace_all(tomtarea, "[^0-9]", "")),
            byggar = as.numeric(str_replace_all(byggar, "[^0-9]", "")),
            driftkostnad = as.numeric(str_replace_all(driftkostnad, "[^0-9]", "")),
        )

    return(data_tibble)
}

# Function to crawl multiple pages and extract property links
scrape_hemnet <- function(max_pages) {
    results <- list()
    base_url <- "https://www.hemnet.se/salda/bostader?item_types%5B%5D=villa&location_ids%5B%5D=17989&page="

    for (i in 1:max_pages) {
        page_url <- str_c(base_url, i)
        message("Scraping page: ", i, " / ", max_pages)
        Sys.sleep(2) # Delay to avoid overloading the website

        page <- read_html(page_url)

        # Extract the links for properties
        property_links <- page %>%
            html_elements("a[href*='/salda/villa']") %>%
            html_attr("href") %>%
            str_c("https://www.hemnet.se", .)

        # End loop if no more property links exist
        if (length(property_links) == 0) {
            message("No more listings found. Stopping at page ", i - 1)
            saveRDS(bind_rows(results), "hemnet_progress.rds")
            break
        }

        print(head(property_links))

        results <- append(results, lapply(property_links, scrape_property_details))
    }

    bind_rows(results)
}

pages <- 50

# Start scraping with an explicit page limit
tidy_hemnet_data <- scrape_hemnet(pages)

# Save to an csv file
write.csv(tidy_hemnet_data, "hemnet_sold_properties.csv", row.names = FALSE)

