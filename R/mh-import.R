library(rrdf)   # Create triples
library(Hmisc)  # XPT import
library(plyr)   # for ddply

# Set working directory to the root of the work area
setwd("C:/_github/css-linkathon")

sourceFile <- paste0("data/source/mh.XPT")

# Initialize. Includes OWL, XSD, RDF by default.
store = new.rdf()  

# Import the XPT to a dataframe
mh <- sasxport.get(sourceFile)
