---
title: "Accessing Paleoecological Data with neotoma2"
subtitle: "PalaeOpen Training School — Sofia, 15–18 June 2026"
author: "Xavier Benito"
format:
  html:
    #date: 29/05/2026
    date-format: long
    date-modified: last-modified
    toc: true
    keep-md: true
    code-copy: true
    code-fold: show
    embed-resources: true
    code-line-numbers: true
    theme: 
      styles/custom_theme.scss
    highlight-style: none
---



# 1. Workshop overview and objectives

This workshop is designed to provide participants at the PalaeOpen Training School (Sofia, 15–19 June 2026) with an overview of the `neotoma2` R package and its use in obtaining and analysing data from the Neotoma Paleoecology Database.

The workshop combines short conceptual explanations with guided coding exercises using R. We will be using:

-   **Prášilské Lake** `Neotoma site ID 26991` [link](https://apps.neotomadb.org/explorer/?siteids=26991)
-   Available datasets for the site: **Pollen**, **diatoms**, **chironomids** & **charcoal**

## Learning Objectives

1.  Understand the basic data structure within the `neotoma2` R package
2.  Search for sites using site names and geographical coordinates
3.  Filter results using temporal and spatial parameters
4.  Obtain sample data for selected datasets
5.  Extract and inspect pollen datasets from the Neotoma Paleoecology Database
6.  Perform basic exploratory analysis and visualization of pollen data
7.  Build reproducible workflows using Quarto

## Online resources

1.  Code repository for the workshop: XXX
2.  Neotoma Palaeoecology Database Manual: https://open.neotomadb.org/manual/
3.  neotoma2 GitHub Repository: https://github.com/neotomadb/neotoma2 (including previous Neotoma workshop repositories)
4.  PalaeOpen R Zulip channel: https://palaeopen.zulipchat.com/#narrow/channel/540741-it_r
5.  [Neotoma Slack channel](https://neotomadb.slack.com/join/shared_invite/zt-cvsv53ep-wjGeCTkq7IhP6eUNA9NxYQ#/shared-invite/email) including general and specific channels such as help when using R

## Install and load the necessary packages

This workflow relies on different R libraries, including tidyverse, geojsonsf and leaflet, to handle geographic data and interactive mapping. To streamline the setup, we utilize the pacman management tool. If any required package is missing from your local environment, pacman will automatically download and install it before loading.


::: {.cell}

```{.r .cell-code}
# Clean workspace first
rm(list = ls())

pacman::p_load(neotoma2, tidyverse, riojaPlot, ggplot2, janitor)
```
:::


R is highly dependent on the sequence in which libraries are activated. Common function names such as `filter()` exist in multiple packages (e.g., both dplyr and neotoma2). If a naming conflict occurs, R might attempt to apply the wrong function to your data object

To prevent these namespace collisions, it is best practice to explicitly declare the source package using the double-colon operator (for example, `neotoma2::filter()` or `dplyr::filter()`). This ensures R executes the exact command you intend.

# 2. Introduction to neotoma2

The `neotoma2` package provides programmatic access to the Neotoma database through R. The database uses an application programming interface (API), which serves the [online explorer](https://apps.neotomadb.org/explorer/) as well as [Tilia](https://www.neotomadb.org/apps/tilia)

## Key Concepts

-   Sites
-   Datasets
-   Samples
-   Taxa
-   Chronologies --> Thomas' age-depth modeling workshop (link)


# Working with Sites

`sites` are spatial objects in `neotoma2` Sites have names, locations, and are found within the context of geopolitical units, but within the API and the package, the site itself does not have associated information about taxa, dataset types or ages. It is simply the container into which we add that information. So, when we search for sites we can search by:

| Parameter | Description |
| --------- | ----------- |
| sitename | A valid site name (case insensitive) using `%` as a wildcard. |
| siteid | A unique numeric site id from the Neotoma Database |
| loc | A bounding box vector, geoJSON or WKT string. |
| altmin | Lower altitude bound for sites. |
| altmax | Upper altitude bound for site locations. |
| database | The constituent database from which the records are pulled. |
| datasettype | The kind of dataset (see `get_table(datasettypes)`) |
| datasetid | Unique numeric dataset identifier in Neotoma |
| doi | A valid dataset DOI in Neotoma |
| gpid | A unique numeric identifier, or text string identifying a geopolitical unit in Neotoma |
| keywords | Unique sample keywords for records in Neotoma. |
| contacts | A name or numeric id for individuals associuated with sites. |
| taxa | Unique numeric identifiers or taxon names associated with sites. |
| ageyoung | A minimum spanning age for the record, in years before radiocarbon present (1950). |
| ageold | A maximum spanning age for the record, in years before radiocarbon present (1950). |
| ageof | An age which must be contained within the range of sample ages for a site. |

## Option 1 Site location: `loc` {.tabset}
Using a bounding box and search for sites based on the geographical coordinates found in it. For instance we search all sites in Europe:


::: {.cell}

```{.r .cell-code}
europe <- list(geoJSON = '{"type": "Polygon",
        "coordinates": [[
            [-30, 30],
            [70, 30],
            [70, 90],
            [-30, 90],
            [-30, 30]]]}')

eu_sites <- get_sites(loc = europe$geoJSON, all_data = FALSE) #if all_data = TRUE all available records will be queried.
neotoma2::summary(eu_sites) 
```

::: {.cell-output .cell-output-stdout}
```
   siteid                   sitename collectionunit chronologies datasets
1       9                     Adange         ADANGE            0        1
2       9                     Adange         ADANGE            0        1
3      12              Ageröds Mosse            AGE            0        1
4      12              Ageröds Mosse            AGE            0        1
5      16                  Ahlenmoor        AFM2012            0        1
6      16                  Ahlenmoor        AFM2012            0        1
7      16                  Ahlenmoor           AHL5            0        1
8      16                  Ahlenmoor           AHL5            0        1
9      20                   Akuvaara           AKUV            0        1
10     20                   Akuvaara           AKUV            0        1
11    200                     Amtkel         AMTKEL            0        1
12    200                     Amtkel         AMTKEL            0        1
13    214                 Arts Lough       ARTSLOUG            0        1
14    214                 Arts Lough       ARTSLOUG            0        1
15    214                 Arts Lough       ARTSLOUG            0        1
16    223          Ballinloghig Lake         BALLIN            0        1
17    223          Ballinloghig Lake         BALLIN            0        1
18    224                Ballybetagh       BALLYBET            0        1
19    224                Ballybetagh       BALLYBET            0        1
20    310     Bruvatnet [Rovvejávri]         BRUVAT            0        1
21    310     Bruvatnet [Rovvejávri]         BRUVAT            0        1
22    335           Selle di Carnino        CARNINO            0        1
23    335           Selle di Carnino        CARNINO            0        1
24    355                Chernikhovo        CHERNIH            0        1
25    355                Chernikhovo        CHERNIH            0        1
26    357 Chesnok Peat, Irtysh River        CHESNOK            0        1
27    357 Chesnok Peat, Irtysh River        CHESNOK            0        1
28    363       Le Marais St Boetien        CHIVRES            0        1
29    363       Le Marais St Boetien        CHIVRES            0        1
30    516               Voros-mocsar           CS-4            0        1
31    516               Voros-mocsar           CS-4            0        1
32    517                   Starniki           CTAR            0        1
33    517                   Starniki           CTAR            0        1
34    662       Demyanskoye Exposure         DEMYAN            0        1
35    662       Demyanskoye Exposure         DEMYAN            0        1
36    700                 Domsvatnet          DOMSV            0        1
37    700                 Domsvatnet          DOMSV            0        1
38    703               Dovjok Swamp         DOVJOK            0        1
39    703               Dovjok Swamp         DOVJOK            0        1
40    765                     Edessa         EDESSA            0        1
41    765                     Edessa         EDESSA            0        1
42    831                      Gagra          GAGRA            0        1
43    831                      Gagra          GAGRA            0        1
44    839            Gel'myazevskoye          GELMT            0        1
45    839            Gel'myazevskoye          GELMT            0        1
46    947                   Grasvatn       GRASVATN            0        1
47    947                   Grasvatn       GRASVATN            0        1
48   1121       Ivanovskoye Peat Bog          IVAN3            0        1
49   1121       Ivanovskoye Peat Bog          IVAN3            0        1
50   1121       Ivanovskoye Peat Bog          IVAN4            0        1
51   1121       Ivanovskoye Peat Bog          IVAN4            0        1
52   1121       Ivanovskoye Peat Bog          IVAN5            0        1
53   1121       Ivanovskoye Peat Bog          IVAN5            0        1
54   1398                 Kalsa Mire          KALSA            0        1
55   1398                 Kalsa Mire          KALSA            0        1
56   1399                  Kameničky          KAMEN            0        1
57   1399                  Kameničky          KAMEN            0        1
58   1399                  Kameničky          KAMEN            0        1
             types
1           pollen
2   geochronologic
3           pollen
4   geochronologic
5   geochronologic
6           pollen
7           pollen
8   geochronologic
9           pollen
10  geochronologic
11          pollen
12  geochronologic
13          pollen
14  geochronologic
15        charcoal
16          pollen
17  geochronologic
18          pollen
19  geochronologic
20          pollen
21  geochronologic
22          pollen
23  geochronologic
24          pollen
25  geochronologic
26          pollen
27  geochronologic
28          pollen
29  geochronologic
30          pollen
31  geochronologic
32          pollen
33  geochronologic
34          pollen
35  geochronologic
36          pollen
37  geochronologic
38          pollen
39  geochronologic
40          pollen
41  geochronologic
42          pollen
43  geochronologic
44          pollen
45  geochronologic
46          pollen
47  geochronologic
48          pollen
49  geochronologic
50          pollen
51  geochronologic
52          pollen
53  geochronologic
54          pollen
55  geochronologic
56          pollen
57  geochronologic
58 testate amoebae
```
:::
:::


Now we plot the resulting spatial object of the sites with the built-in `plotLeaflet` neotoma2 function.


::: {.cell}

```{.r .cell-code}
neotoma2::plotLeaflet(eu_sites) 
```

::: {.cell-output-display}

```{=html}
<div class="leaflet html-widget html-fill-item" id="htmlwidget-65236b39534315b3cfdb" style="width:100%;height:464px;"></div>
<script type="application/json" data-for="htmlwidget-65236b39534315b3cfdb">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"https://openstreetmap.org/copyright/\">OpenStreetMap<\/a>,  <a href=\"https://opendatacommons.org/licenses/odbl/\">ODbL<\/a>"}]},{"method":"addCircleMarkers","args":[[43.30556,55.933292,53.678,69.12326,43.26806,52.95,52.2,53.16667,70.18035,44.15,53.41667,60,49.61667,46.47722,50.26667,59.5,70.325334,48.75,40.81806,43.28333,49.66667,63.702696,56.81667,58.19142,49.726332],[41.33333,13.425594,8.757,27.67406,41.30833,-6.43333,-10.30833,-6.25,28.403788,7.69444,26.43333,66.5,3.81667,19.19083,26.01667,69.5,31.024642,28.25,21.9525,40.26667,31.83333,8.68858,38.76667,27.41146,15.970602],10,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":true,"riseOffset":250,"stroke":true,"color":"#03F","weight":5,"opacity.1":0.5,"fill":true,"fillColor":"#03F","fillOpacity":0.2},{"showCoverageOnHover":true,"zoomToBoundsOnClick":true,"spiderfyOnMaxZoom":true,"removeOutsideVisibleBounds":true,"spiderLegPolylineOptions":{"weight":1.5,"color":"#222","opacity":0.5},"freezeAtZoom":false},null,["<b>Adange<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=9>Explorer Link<\/a>","<b>Ageröds Mosse<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=12>Explorer Link<\/a>","<b>Ahlenmoor<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=16>Explorer Link<\/a>","<b>Akuvaara<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=20>Explorer Link<\/a>","<b>Amtkel<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=200>Explorer Link<\/a>","<b>Arts Lough<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=214>Explorer Link<\/a>","<b>Ballinloghig Lake<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=223>Explorer Link<\/a>","<b>Ballybetagh<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=224>Explorer Link<\/a>","<b>Bruvatnet [Rovvejávri]<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=310>Explorer Link<\/a>","<b>Selle di Carnino<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=335>Explorer Link<\/a>","<b>Chernikhovo<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=355>Explorer Link<\/a>","<b>Chesnok Peat, Irtysh River<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=357>Explorer Link<\/a>","<b>Le Marais St Boetien<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=363>Explorer Link<\/a>","<b>Voros-mocsar<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=516>Explorer Link<\/a>","<b>Starniki<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=517>Explorer Link<\/a>","<b>Demyanskoye Exposure<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=662>Explorer Link<\/a>","<b>Domsvatnet<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=700>Explorer Link<\/a>","<b>Dovjok Swamp<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=703>Explorer Link<\/a>","<b>Edessa<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=765>Explorer Link<\/a>","<b>Gagra<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=831>Explorer Link<\/a>","<b>Gel'myazevskoye<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=839>Explorer Link<\/a>","<b>Grasvatn<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=947>Explorer Link<\/a>","<b>Ivanovskoye Peat Bog<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=1121>Explorer Link<\/a>","<b>Kalsa Mire<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=1398>Explorer Link<\/a>","<b>Kameničky<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=1399>Explorer Link<\/a>"],null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[40.81806,70.325334],"lng":[-10.30833,69.5]}},"evals":[],"jsHooks":[]}</script>
```

:::
:::


We can also be more restrictive and add extra arguments in `get_sites()` and look for pollen datasets and certain site names if we know what site we are looking for 


::: {.cell}

```{.r .cell-code}
ezero_pollen <- get_sites(datasettype="pollen", loc=europe$geoJSON, sitename = "%ezero%") #Note that % is a wildcard character
neotoma2::plotLeaflet(ezero_pollen) 
```

::: {.cell-output-display}

```{=html}
<div class="leaflet html-widget html-fill-item" id="htmlwidget-9c1c29968b4c2a83eae0" style="width:100%;height:464px;"></div>
<script type="application/json" data-for="htmlwidget-9c1c29968b4c2a83eae0">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"https://openstreetmap.org/copyright/\">OpenStreetMap<\/a>,  <a href=\"https://opendatacommons.org/licenses/odbl/\">ODbL<\/a>"}]},{"method":"addCircleMarkers","args":[[50.53839,41.70757,42.06517,48.936984,48.775332,49.075004,43.95722,42.13333,43.15549,42.78009,42.77009,49.178466],[13.527398,23.50822,23.56001,16.972656,13.864648,13.399778,17.75472,23.41667,19.07039,17.34736,17.36738,13.181868],10,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":true,"riseOffset":250,"stroke":true,"color":"#03F","weight":5,"opacity.1":0.5,"fill":true,"fillColor":"#03F","fillOpacity":0.2},{"showCoverageOnHover":true,"zoomToBoundsOnClick":true,"spiderfyOnMaxZoom":true,"removeOutsideVisibleBounds":true,"spiderLegPolylineOptions":{"weight":1.5,"color":"#222","opacity":0.5},"freezeAtZoom":false},null,["<b>Komořanské jezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3201>Explorer Link<\/a>","<b>Popovo Ezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3357>Explorer Link<\/a>","<b>Suho ezero II<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3450>Explorer Link<\/a>","<b>Čejčské jezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=14470>Explorer Link<\/a>","<b>Plešné jezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=14524>Explorer Link<\/a>","<b>Prášilské jezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=26991>Explorer Link<\/a>","<b>Prokosko Jezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=28160>Explorer Link<\/a>","<b>Lake Suho Ezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=29330>Explorer Link<\/a>","<b>Zminje Jezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=30617>Explorer Link<\/a>","<b>Malo Jezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=31034>Explorer Link<\/a>","<b>Veliko Jezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=31035>Explorer Link<\/a>","<b>Černé jezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=36498>Explorer Link<\/a>"],null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[41.70757,50.53839],"lng":[13.181868,23.56001]}},"evals":[],"jsHooks":[]}</script>
```

:::
:::


## Option 2 Site location: `gpid` {.tabset}
Using a geopolitical unit to search sites in e.g.,  **Bulgaria**


::: {.cell}

```{.r .cell-code}
bulgaria_sites <- get_sites(gpid=c("Bulgaria"))
neotoma2::plotLeaflet(bulgaria_sites) 
```

::: {.cell-output-display}

```{=html}
<div class="leaflet html-widget html-fill-item" id="htmlwidget-245a3a3ba9156c1f8b41" style="width:100%;height:464px;"></div>
<script type="application/json" data-for="htmlwidget-245a3a3ba9156c1f8b41">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"https://openstreetmap.org/copyright/\">OpenStreetMap<\/a>,  <a href=\"https://opendatacommons.org/licenses/odbl/\">ODbL<\/a>"}]},{"method":"addCircleMarkers","args":[[42.329472,43.192612,41.732864,44.106212,41.98333,41.7,42.54718,41.50926,41.70757,43.188396,43.57045,44.106122,42.06517,42.36667,42.629484,42.15,42.59028,43.669696,42.21074,41.35472,42.83333,41.621166,41.734236,42.13333,41.53944],[27.724032,27.815084,23.524038,26.910492,24.33333,23.03333,23.2917,23.65766,23.50822,27.670932,28.566292,27.0699,23.56001,22.83333,26.778668,22.55,23.25167,28.544144,23.325318,23.12528,24.83333,24.677922,24.139436,23.41667,23.555],10,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":true,"riseOffset":250,"stroke":true,"color":"#03F","weight":5,"opacity.1":0.5,"fill":true,"fillColor":"#03F","fillOpacity":0.2},{"showCoverageOnHover":true,"zoomToBoundsOnClick":true,"spiderfyOnMaxZoom":true,"removeOutsideVisibleBounds":true,"spiderLegPolylineOptions":{"weight":1.5,"color":"#222","opacity":0.5},"freezeAtZoom":false},null,["<b>Arkutino Lake<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=2980>Explorer Link<\/a>","<b>Lake Varna<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=2985>Explorer Link<\/a>","<b>Besbog<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3012>Explorer Link<\/a>","<b>Mire Garvan<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3121>Explorer Link<\/a>","<b>Kupena<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3212>Explorer Link<\/a>","<b>Maleshevska Mountains Peat Bog<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3270>Explorer Link<\/a>","<b>Vitosha Mountains Peat Bog<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3278>Explorer Link<\/a>","<b>Mutorog Peat Bog<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3305>Explorer Link<\/a>","<b>Popovo Ezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3357>Explorer Link<\/a>","<b>Lake Beloslav<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3360>Explorer Link<\/a>","<b>Lake Shabla-Ezeretz<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3405>Explorer Link<\/a>","<b>Lake Srebarna<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3439>Explorer Link<\/a>","<b>Suho ezero II<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3450>Explorer Link<\/a>","<b>Tschokljovo Marsh<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=3466>Explorer Link<\/a>","<b>Straldzha mire<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=14516>Explorer Link<\/a>","<b>Peat-bog Begbunar<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=14530>Explorer Link<\/a>","<b>Kumata<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=14603>Explorer Link<\/a>","<b>Lake Durankulak<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=14645>Explorer Link<\/a>","<b>Lake Sedmo Rilsko<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=14659>Explorer Link<\/a>","<b>Mire Gyola<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=14672>Explorer Link<\/a>","<b>Tchumina peat bog<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=14673>Explorer Link<\/a>","<b>Lake Blatisto<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=15678>Explorer Link<\/a>","<b>Beliya Kanton<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=23915>Explorer Link<\/a>","<b>Lake Suho Ezero<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=29330>Explorer Link<\/a>","<b>Between Goce Delcev & Melnik + Swamp<\/b><br><b>Description:<\/b> NA<br><a href=http://apps.neotomadb.org/explorer/?siteids=37754>Explorer Link<\/a>"],null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[41.35472,44.106212],"lng":[22.55,28.566292]}},"evals":[],"jsHooks":[]}</script>
```

:::

```{.r .cell-code}
neotoma2::summary(bulgaria_sites)
```

::: {.cell-output .cell-output-stdout}
```
   siteid                             sitename collectionunit chronologies
1    2980                        Arkutino Lake            AR1            0
2    2980                        Arkutino Lake            AR1            0
3    2980                        Arkutino Lake            AR2            0
4    2980                        Arkutino Lake            AR2            0
5    2980                        Arkutino Lake      BUL/MF/05            0
6    2980                        Arkutino Lake      BUL/MF/05            0
7    2985                           Lake Varna           ARS1            0
8    2985                           Lake Varna           ARS1            0
9    2985                           Lake Varna         VARNA3            0
10   2985                           Lake Varna         VARNA3            0
11   3012                               Besbog         BESBOG            0
12   3012                               Besbog         BESBOG            0
13   3121                          Mire Garvan           GAR1            0
14   3121                          Mire Garvan           GAR1            0
15   3212                               Kupena         KUPENA            0
16   3212                               Kupena         KUPENA            0
17   3212                               Kupena        KUPENA1            0
18   3212                               Kupena        KUPENA1            0
19   3212                               Kupena        KUPENA3            0
20   3212                               Kupena        KUPENA3            0
21   3270       Maleshevska Mountains Peat Bog         MALESH            0
22   3270       Maleshevska Mountains Peat Bog         MALESH            0
23   3278           Vitosha Mountains Peat Bog          MAT-1            0
24   3278           Vitosha Mountains Peat Bog          MAT-1            0
25   3305                     Mutorog Peat Bog        MUTORO1            0
26   3305                     Mutorog Peat Bog        MUTORO1            0
27   3357                         Popovo Ezero         POPOVO            0
28   3357                         Popovo Ezero         POPOVO            0
29   3360                        Lake Beloslav           POV2            0
30   3360                        Lake Beloslav           POV2            0
31   3405                  Lake Shabla-Ezeretz      BUL/MF/04            0
32   3405                  Lake Shabla-Ezeretz      BUL/MF/04            0
33   3405                  Lake Shabla-Ezeretz         SHABLA            0
34   3405                  Lake Shabla-Ezeretz         SHABLA            0
35   3439                        Lake Srebarna           SRE4            0
36   3439                        Lake Srebarna           SRE4            0
37   3439                        Lake Srebarna         SREBAR            0
38   3439                        Lake Srebarna         SREBAR            0
39   3450                        Suho ezero II           SUH2            0
40   3450                        Suho ezero II           SUH2            0
41   3466                    Tschokljovo Marsh            TM1            0
42   3466                    Tschokljovo Marsh            TM1            0
43  14516                       Straldzha mire          CANAL            0
44  14516                       Straldzha mire          CANAL            0
45  14516                       Straldzha mire         QUARRY            0
46  14516                       Straldzha mire         QUARRY            0
47  14516                       Straldzha mire       STRALDZA            0
48  14516                       Straldzha mire       STRALDZA            0
49  14530                    Peat-bog Begbunar       BEGBUNAR            0
50  14530                    Peat-bog Begbunar       BEGBUNAR            0
51  14603                               Kumata        KUMATA1            0
52  14603                               Kumata        KUMATA1            0
53  14645                      Lake Durankulak      BUL/MF/03            0
54  14645                      Lake Durankulak      BUL/MF/03            0
55  14645                      Lake Durankulak        DURANK1            0
56  14645                      Lake Durankulak        DURANK1            0
57  14645                      Lake Durankulak        DURANK2            0
58  14645                      Lake Durankulak        DURANK2            0
59  14645                      Lake Durankulak        DURANK3            0
60  14645                      Lake Durankulak        DURANK3            0
61  14659                    Lake Sedmo Rilsko           RD7B            0
62  14659                    Lake Sedmo Rilsko           RD7B            0
63  14672                           Mire Gyola          GYOLA            0
64  14672                           Mire Gyola          GYOLA            0
65  14673                    Tchumina peat bog         TSHM-2            0
66  14673                    Tchumina peat bog         TSHM-2            0
67  15678                        Lake Blatisto       BLATISTO            0
68  15678                        Lake Blatisto       BLATISTO            0
69  23915                        Beliya Kanton       BELIYA2C            0
70  23915                        Beliya Kanton       BELIYA2C            0
71  29330                      Lake Suho Ezero         RILMAN            0
72  29330                      Lake Suho Ezero         RILMAN            0
73  37754 Between Goce Delcev & Melnik + Swamp      NODE-R385            0
   datasets                    types
1         1                   pollen
2         1           geochronologic
3         1                   pollen
4         1           geochronologic
5         1                       NA
6         1              pollen trap
7         1                   pollen
8         1           geochronologic
9         1           geochronologic
10        1                   pollen
11        1                   pollen
12        1           geochronologic
13        1                   pollen
14        1           geochronologic
15        1                   pollen
16        1           geochronologic
17        1                   pollen
18        1           geochronologic
19        1           geochronologic
20        1                   pollen
21        1                   pollen
22        1           geochronologic
23        1                   pollen
24        1           geochronologic
25        1                   pollen
26        1           geochronologic
27        1                   pollen
28        1           geochronologic
29        1                   pollen
30        1           geochronologic
31        1                       NA
32        1              pollen trap
33        1                   pollen
34        1           geochronologic
35        1                   pollen
36        1           geochronologic
37        1                   pollen
38        1           geochronologic
39        1                   pollen
40        1           geochronologic
41        1                   pollen
42        1           geochronologic
43        1           geochronologic
44        1                   pollen
45        1           geochronologic
46        1                   pollen
47        1           geochronologic
48        1                   pollen
49        1           geochronologic
50        1                   pollen
51        1           geochronologic
52        1                   pollen
53        1                       NA
54        1              pollen trap
55        1           geochronologic
56        1                   pollen
57        1           geochronologic
58        1                   pollen
59        1           geochronologic
60        1                   pollen
61        1           geochronologic
62        1                   pollen
63        1           geochronologic
64        1                   pollen
65        1           geochronologic
66        1                   pollen
67        1           geochronologic
68        1                   pollen
69        1           geochronologic
70        1                   pollen
71        1           geochronologic
72        1                   pollen
73        1 ostracode surface sample
```
:::
:::


# Working with datasets

A `sites` object contains `collectionunits` which contain `datasets`. From the table above we can see that some of the sites we have looked at contain different `dataset` types. We can also see that for each site, different `collectionunits` (i.e., usually cores) can be found. 

Having a `sites` object we can directly call `get_datasets()` to pull in more metadata about the datasets. At any time we can use `datasets()` to get more information about any datasets that a sites object may contain. Below we compare the output of `datasets(bulgaria_sites)` to the output of a similar call using the following:


::: {.cell}

```{.r .cell-code}
datasets(bulgaria_sites)
```

::: {.cell-output .cell-output-stdout}
```
 datasetid database              datasettype age_range_old age_range_young
      3883     <NA>                   pollen            NA              NA
      8887     <NA>           geochronologic            NA              NA
      3884     <NA>                   pollen            NA              NA
      8888     <NA>           geochronologic            NA              NA
  41707503     <NA>                     <NA>            NA              NA
     66650     <NA>              pollen trap            NA              NA
      3889     <NA>                   pollen            NA              NA
      8890     <NA>           geochronologic            NA              NA
     22922     <NA>           geochronologic            NA              NA
     22923     <NA>                   pollen            NA              NA
      3926     <NA>                   pollen            NA              NA
      8907     <NA>           geochronologic            NA              NA
      4063     <NA>                   pollen            NA              NA
      8981     <NA>           geochronologic            NA              NA
      4170     <NA>                   pollen            NA              NA
      9036     <NA>           geochronologic            NA              NA
      4171     <NA>                   pollen            NA              NA
      9037     <NA>           geochronologic            NA              NA
     24031     <NA>           geochronologic            NA              NA
     24032     <NA>                   pollen            NA              NA
      4247     <NA>                   pollen            NA              NA
      9083     <NA>           geochronologic            NA              NA
      4258     <NA>                   pollen            NA              NA
      9088     <NA>           geochronologic            NA              NA
      4289     <NA>                   pollen            NA              NA
      9102     <NA>           geochronologic            NA              NA
      4355     <NA>                   pollen            NA              NA
      9137     <NA>           geochronologic            NA              NA
      4358     <NA>                   pollen            NA              NA
      9138     <NA>           geochronologic            NA              NA
 167673624     <NA>                     <NA>            NA              NA
     66651     <NA>              pollen trap            NA              NA
      4413     <NA>                   pollen            NA              NA
      9178     <NA>           geochronologic            NA              NA
      4453     <NA>                   pollen            NA              NA
      9206     <NA>           geochronologic            NA              NA
      4454     <NA>                   pollen            NA              NA
      9207     <NA>           geochronologic            NA              NA
      4467     <NA>                   pollen            NA              NA
      9214     <NA>           geochronologic            NA              NA
      4485     <NA>                   pollen            NA              NA
      9226     <NA>           geochronologic            NA              NA
     22752     <NA>           geochronologic            NA              NA
     22753     <NA>                   pollen            NA              NA
     22750     <NA>           geochronologic            NA              NA
     22751     <NA>                   pollen            NA              NA
     22737     <NA>           geochronologic            NA              NA
     22738     <NA>                   pollen            NA              NA
     22766     <NA>           geochronologic            NA              NA
     22767     <NA>                   pollen            NA              NA
     22891     <NA>           geochronologic            NA              NA
     22892     <NA>                   pollen            NA              NA
  69753172     <NA>                     <NA>            NA              NA
     66652     <NA>              pollen trap            NA              NA
     22981     <NA>           geochronologic            NA              NA
     22982     <NA>                   pollen            NA              NA
     22979     <NA>           geochronologic            NA              NA
     22980     <NA>                   pollen            NA              NA
     49490     <NA>           geochronologic            NA              NA
     49491     <NA>                   pollen            NA              NA
     22999     <NA>           geochronologic            NA              NA
     23000     <NA>                   pollen            NA              NA
     23018     <NA>           geochronologic            NA              NA
     23019     <NA>                   pollen            NA              NA
     23020     <NA>           geochronologic            NA              NA
     23021     <NA>                   pollen            NA              NA
     24029     <NA>           geochronologic            NA              NA
     24030     <NA>                   pollen            NA              NA
     41490     <NA>           geochronologic            NA              NA
     41491     <NA>                   pollen            NA              NA
     55811     <NA>           geochronologic            NA              NA
     55812     <NA>                   pollen            NA              NA
     69753     <NA> ostracode surface sample            NA              NA
 age_units notes
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
      <NA>  <NA>
```
:::

```{.r .cell-code}
bulgaria_datasets <- get_datasets(bulgaria_sites)
```
:::


# Filtering records
It is sometimes recommended to do some filtering before we download the samples contained in the `dataset` or `site` objects.

If we choose to pull in information about only a single dataset type, or if there is additional filtering we want to do before we download the data, we can use the filter() function. For example, if we only want pollen records from all bulgarian datasets, and want records with known chronologies, we can filter:


::: {.cell}

```{.r .cell-code}
bulg_pollen <- bulgaria_sites %>%
  neotoma2::get_datasets() %>%
  neotoma2::filter(datasettype == "pollen" & !is.na(age_range_young))

neotoma2::summary(bulg_pollen)
```

::: {.cell-output .cell-output-stdout}
```
   siteid                       sitename collectionunit chronologies datasets
1    2980                  Arkutino Lake            AR1            0        1
2    2980                  Arkutino Lake            AR2            0        1
3    2985                     Lake Varna           ARS1            0        1
4    2985                     Lake Varna         VARNA3            0        1
5    3012                         Besbog         BESBOG            0        1
6    3121                    Mire Garvan           GAR1            0        1
7    3212                         Kupena         KUPENA            0        1
8    3212                         Kupena        KUPENA1            0        1
9    3212                         Kupena        KUPENA3            0        1
10   3270 Maleshevska Mountains Peat Bog         MALESH            0        1
11   3278     Vitosha Mountains Peat Bog          MAT-1            0        1
12   3305               Mutorog Peat Bog        MUTORO1            0        1
13   3357                   Popovo Ezero         POPOVO            0        1
14   3360                  Lake Beloslav           POV2            0        1
15   3405            Lake Shabla-Ezeretz         SHABLA            0        1
16   3439                  Lake Srebarna           SRE4            0        1
17   3450                  Suho ezero II           SUH2            0        1
18   3466              Tschokljovo Marsh            TM1            0        1
19  14516                 Straldzha mire       STRALDZA            0        1
20  14516                 Straldzha mire         QUARRY            0        1
21  14516                 Straldzha mire          CANAL            0        1
22  14530              Peat-bog Begbunar       BEGBUNAR            0        1
23  14603                         Kumata        KUMATA1            0        1
24  14645                Lake Durankulak        DURANK2            0        1
25  14645                Lake Durankulak        DURANK1            0        1
26  14645                Lake Durankulak        DURANK3            0        1
27  14659              Lake Sedmo Rilsko           RD7B            0        1
28  14672                     Mire Gyola          GYOLA            0        1
29  14673              Tchumina peat bog         TSHM-2            0        1
30  15678                  Lake Blatisto       BLATISTO            0        1
31  23915                  Beliya Kanton       BELIYA2C            0        1
32  29330                Lake Suho Ezero         RILMAN            0        1
    types
1  pollen
2  pollen
3  pollen
4  pollen
5  pollen
6  pollen
7  pollen
8  pollen
9  pollen
10 pollen
11 pollen
12 pollen
13 pollen
14 pollen
15 pollen
16 pollen
17 pollen
18 pollen
19 pollen
20 pollen
21 pollen
22 pollen
23 pollen
24 pollen
25 pollen
26 pollen
27 pollen
28 pollen
29 pollen
30 pollen
31 pollen
32 pollen
```
:::
:::


## Excercise
Think about any other filtering criteria you want to apply to search for sites in Neotoma.
**Hint**: You can type `?neotoma2::get_sites` and the helper function will open in your RStudio with the available search parameters.

Work individually for about 15 minutes and then share with your peer next to you what you have found.

# Working with samples

Up until now we have seen how to: 
1.    Search for sites applying different criteria,
2.    Plot where the site are located and,
3.    Obtain the `collectionunits` and `datasets` that a `site` object contain.

Functions like `get_sites()` or `get_datasets()` only pull down high-level metadata (site names, geographic coordinates, dataset IDs, etc) to keep things fast and avoid large files quering the API.
To populate that object with the detailed data—like analysis units, sample depth, chronologies, and taxon counts, we need to pass it into the `get_downloads()` function.

For that, we will use the site **Prášilské jezero**, a mountain lake located in Czechia (Šumava Mts.). This site has been analyzed for several proxies, including pollen, diatoms, chironomids and charcoal.


::: {.cell}

```{.r .cell-code}
pra_data <- neotoma2::get_sites(sitename = "Prášilské jezero") %>%
  neotoma2::get_datasets() %>% 
  neotoma2::get_downloads()
```
:::


In case the Neotoma API doesn't work, we have already downloaded and saved the site data

::: {.cell}

```{.r .cell-code}
## The line is commented because there is no need for you to run it
## saveRDS(pra_data, "data/PRA_download.RDS")
```
:::


For the downloaded site we now have information about all the collection units, the datasets, and, for each dataset, all the samples associated with the datasets. To extract all the samples we need to run the funcion `samples`


::: {.cell}

```{.r .cell-code}
#pra_data <- readRDS("data/PRA_download.RDS") #uncomment if you want/need to read in the donwloaded object 
allSamp <- samples(pra_data)
names(allSamp)
```

::: {.cell-output .cell-output-stdout}
```
 [1] "age"             "agetype"         "ageolder"        "ageyounger"     
 [5] "chronologyid"    "chronologyname"  "units"           "value"          
 [9] "context"         "element"         "taxonid"         "symmetry"       
[13] "taxongroup"      "elementtype"     "variablename"    "ecologicalgroup"
[17] "analysisunitid"  "sampleanalyst"   "sampleid"        "depth"          
[21] "thickness"       "samplename"      "datasetid"       "database"       
[25] "datasettype"     "age_range_old"   "age_range_young" "age_units"      
[29] "datasetnotes"    "siteid"          "sitename"        "lat"            
[33] "long"            "area"            "sitenotes"       "description"    
[37] "elev"            "collunitid"     
```
:::
:::

The resulting `data.frame` has 13735 rows and 38 variables. The reason is because the table is in **long** format. The opposite format is **wide** format, with sites/samples as rows, and taxa as columns. For certain community analysis this is the suggested format. But for now we continue with the **long** format.

We can also check how many `collectionunits` and `datasettypes` the site has by calling:

::: {.cell}

```{.r .cell-code}
unique(allSamp$collunitid)
```

::: {.cell-output .cell-output-stdout}
```
[1] 34071 34072 34073
```
:::

```{.r .cell-code}
unique(allSamp$datasettype)
```

::: {.cell-output .cell-output-stdout}
```
[1] "geochronologic"    "pollen"            "diatom"           
[4] "plant macrofossil" "chironomid"        "charcoal"         
```
:::
:::


For some dataset types, or types of analyses some of columns stored in `samples()` may not be needed, however, for other dataset types they may be critically important. The neotoma2 package includes as many column names as possible to cover a wide range of community/ proxy needs.

If you want to know what taxa we have in the record, you can use the function `taxa()` on the downloaded site object. This is basically the samples table with information about how many samples the taxon occurs, in how many sites (in this case only one). The `taxonid` values can be linked to the `taxonid` column in the `samples()`. This allows us to build taxon harmonization tables. But again, this is not the focus of this introductory part.


::: {.cell}

```{.r .cell-code}
pra_taxa <- neotoma2::taxa(pra_data)
```
:::


# Working with counts
We now get the pollen counts from the **Prášilské jezero**. We filter by `elementtype=="pollen"` and calculate pollen proportions from count data:


::: {.cell}

```{.r .cell-code}
pra_pollen_prop <- neotoma2::samples(pra_data) %>%
  dplyr::filter(datasettype == "pollen") %>% #filter by datasettype
  dplyr::filter(elementtype=="pollen") %>%   #in pollen samples there are different elements for the same taxon such as pollen and stomata. We pull in pollen grains only
  dplyr::group_by(depth, age) %>%
  dplyr::mutate(pollen_count = sum(value, na.rm = TRUE)) %>%
  dplyr::group_by(variablename) %>% 
  dplyr::mutate(prop = value / pollen_count) %>% 
  dplyr::arrange(age) %>% #arrange table by increasing age
  dplyr::select(depth, age, variablename, prop) %>% 
  dplyr::mutate(prop = as.numeric(prop)) 

# Why this happens with neotoma2
# If you are encountering this while manually pivoting data extracted from neotoma2 (rather than using their built-in toWide() function), it is usually because:
# Taxon synonyms: A single sample might have entries for both Pinus and Pinus undiff., which get cleaned/mapped into the same variable name.
# Multiple elements: The dataset might contain multiple variable elements (e.g., both "pollen" and "stomata" for the same taxon) or different units (e.g., "percent" and "grains") in the same table.
# If this is the case, filter down to a single element type or unit type using filter() before running your pivot!
#   
```
:::


We reconvene here the long vs wide format. It is useful to pivot the data to a “wide” table for use in other packages such as `vegan` or `cluster` to perform multivariate ordination and classification analyses. Wide format contains variablenames as column headings and we do this for the pollen dataset using `tidyr` of the [tidyverse](https://tidyverse.org) package


::: {.cell}

```{.r .cell-code}
site_pollen_wide <- tidyr::pivot_wider(pra_pollen_prop,
                                      id_cols = c(depth, age),
                                      names_from = variablename,
                                      values_from = prop,
                                      values_fill = 0) %>%
  janitor::clean_names() #homogenize nomenclature of pollen taxa
```
:::


Because the pollen matrix contains 91 different taxa, plotting all of them would clutter the stratigraphic diagram. To keep the plot readable, we filter the dataset to include only the most abundant pollen taxa, that is, those with a relative abundance greater than 2% in at least one sample:


::: {.cell}

```{.r .cell-code}
pra_pollen_prop_subset <- pra_pollen_prop %>%
  group_by(variablename) %>%
  filter(prop>0.02) #pollen taxa present with >2% relative abundance

site_pollen_subset_wide <- tidyr::pivot_wider(pra_pollen_prop_subset,
                                      id_cols = c(depth, age),
                                      names_from = variablename,
                                      values_from = prop,
                                      values_fill = 0) %>%
  janitor::clean_names() #homogenize nomenclature of pollen taxa
```
:::


# Stratigraphic plot
Here we use the `riojaPlot` package:


::: {.cell}

```{.r .cell-code}
riojaPlot(site_pollen_subset_wide[,-1:-2]*100, site_pollen_subset_wide[,1:2],
                       selVars = names(site_pollen_subset_wide[,-1:-2]),
                       scale.percent = TRUE,
                       sec.yvar.name="age",
                       plot.sec.axis = TRUE,
                       srt.xlabel = 60,
                       xRight = 0.85) 
```

::: {.cell-output-display}
![](intro_neotoma2_files/figure-html/unnamed-chunk-16-1.png){width=672}
:::
:::
