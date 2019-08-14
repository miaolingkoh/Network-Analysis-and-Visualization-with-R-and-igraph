install.packages("igraph")

## Load package
library(igraph)
library(tidyverse)

edges <- read.csv("asoiaf-all-edges.csv")
edges <- edges[,c(1:2,5)]


################################
####Undirected weighted graph###
################################
g <- graph_from_data_frame(d=edges, directed=FALSE)
print(g, e=TRUE, v=TRUE)

############################
#####Network Properties#####
############################

#2.1 number of vertices
ver <- vcount(g)
sprintf("The number of vertices is %i", ver)

#2.2 number of edges
edg <- ecount(g)
sprintf("The number of edges is %i", edg)

#2.3 diameter
dia <- diameter(g, directed = FALSE)
sprintf("The number of diameter of the graph is %i", dia)

##2.4 Adjacenct triangles
atri <- sum(count_triangles(g, vids = V(g)))
sprintf("The number of triangles in the graph is %i", atri)

## Always true
#sum(count_triangles(g)) == length(triangles(g))

#2.4 top 10 characters with highest degree
top_10_degree <- sort(degree(g, mode = "total"), decreasing = TRUE)[1:10]
top_10_degree

#2.5 top 10 characters with highest weighted degree
top_10_weighted_degree <- sort(strength(g, mode = "total"), decreasing = TRUE)[1:10]
top_10_weighted_degree

##########################
###Entire Network graph###
##########################
color_vertices <- edges %>%
  group_by(Source, Target) %>%
  summarise(n = n())

# The default color is set to black
vertex_colors <- rep("black", vcount(g))

# Find the case with more than 100 degrees
has_more_than_100_degree <- degree(g, mode = "total") > 100

# Set the color of nodes that has connections more than 100 to blue
vertex_colors[has_more_than_100_degree] <- "blue"

size_vertices <- edges %>%
  group_by(Source, Target) %>%
  summarise(n = n())

# The default size is set to 3
vertex_size <- rep(3, vcount(g))

# Find the case with more than 100 degrees
has_more_than_100_degree_size <- degree(g, mode = "total") > 100

# Set the size of nodes that has connections more than 100 to 5
vertex_size[has_more_than_100_degree_size] <- 10

l2 = layout.fruchterman.reingold(g)

plot(
  # Plot the network
  g, 
  layout=l2,
  # Set the vertex colors to vertex_colors
  vertex.color = vertex_colors,
  vertex.label = NA,
  edge.arrow.width = 0.8, 
  edge.arrow.size = 0.2, 
  vertex.size = vertex_size,
  main  = "Entire graph",
  sub   = "GOT Characters - A Song of Ice and Fire"
)

legend(
  "topleft",
  #Set the edge color using edge_color
  fill = unique(vertex_colors),
  legend = c("Characters with more than 100 connections", "The rest of the characters"),
  pt.cex = 0.4,
  cex = 0.7
)  

# Find the case with more than 10 degrees
has_more_than_10_degree <- degree(g, mode = "total") > 10

# Subset nodes for greater than 10 connections
vertices_10_connections <- V(g)[has_more_than_10_degree]

# Induce a subgraph of the vertices
subgraph <- induced_subgraph(g, vertices_10_connections)

# The default size is set to 3
vertex_size <- rep(3, vcount(subgraph))

# Find the case with more than 50 degrees
has_more_than_50_degree_size <- degree(subgraph, mode = "total") > 50

# Set the size of nodes that has connections more than 100 to 5
vertex_size[has_more_than_50_degree_size] <- 10

# Plot the subgraph
plot(subgraph, edge.arrow.width = 0.8,
     edge.arrow.size = 0.2,
     vertex.size = vertex_size,
     main  = "Subgraph",
     sub   = "GOT Characters - A Song of Ice and Fire")

## Edge Density ##

# Entire graph 
edge_density(g)
# Subnetwork 
edge_density(subgraph)

################
###Centrality###
################

# closeness
closeness_top_15 = sort(closeness(g), decreasing = T)[1:15]
closeness_top_15

closeness <- igraph::closeness(g, mode = "total")

sort(closeness, decreasing = T)[1:15]
# Top15 Nodes according to betweeness 
betweeness_top_15 = sort(betweenness(g, directed = F), decreasing = T)[1:15]
betweeness_top_15

#############################
##Ranking and Visualization##
#############################

page_rank <- page.rank(g, directed = FALSE)

page_rank_centrality <- data.frame(name = names(page_rank$vector),
                                   page_rank = page_rank$vector) %>%
  mutate(name = as.character(name))

cent_top_10 <- page_rank_centrality %>%
  arrange(-page_rank) %>%
  .[1:10, ]

cent_top_10

fine = 500 # this will adjust the resolving power.
palette = colorRampPalette(c('blue','red'))

closCol = palette(fine)[as.numeric(cut(cent_top_10$page_rank,breaks = fine))]
plot(g,
     vertex.label = NA,
     vertex.frame.color = "white",
     vertex.color=closCol,
     vertex.size=(page_rank_centrality$page_rank)*950,
     main="Centrality Page Rank")
