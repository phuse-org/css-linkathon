###############################################################################
# FILE: VS-RowColumn.R
# DESC: A straight rox-x-column conversion of the VS XPT data to RDF
#       Only processes columns up to vsstresu.  
# IN  : vsXPT from CDISCPILOT01 PhUSE project.
# OUT : vs-RowCOlumn.TTL
# NOTE: You must change the path in the setwd statement
#       The created RDF is not in a proper model!
###############################################################################
library(rrdf)   # Create triples
library(Hmisc)  # XPT import
library(plyr)   # for ddply

# Set working directory to the root of the work area
setwd("<ROOTPATH>/css-linkathon")

sourceFile <- paste0("data/source/vs.XPT")

# Output filename and location
outFilename = "VS-RowColumn.TTL"
outFile=paste0("data/rdf/", outFilename)

# Initialize. Includes OWL, XSD, RDF by default.
store = new.rdf()  

# Import the XPT to a dataframe
vs <- sasxport.get(sourceFile)
# vs <- head(vs, 152)  # Limit to the first patient (152 rows)

# Create an ID number for each person for use in creating the triples
vs$vsID<- 1:(nrow(vs))

#------------------------------------------------------------------------------
# -- RDF Creation 
# Create Prefixes
prefix.EG   <-"http://www.example.org/cdiscpilot01#"
# No need to dd RDFS with add.prefix: automagically done by rrdf package.
add.prefix(store,
           prefix="EG",
           namespace=prefix.EG

)
# Create data triples
# Loop over the observations to create the triples associated with each patient
for (r in 1:nrow(vs))
{
    # For each row, loop through the dataframe column names to create triples 
    #    for value in cell in that row x column
    for (c in 1:ncol(vs)){
        colName <- colnames(vs)[c]
        add.data.triple(store,
            paste0(prefix.EG, "vs_", vs[r,"vsID"]),
             paste0(prefix.EG,"has", colnames(vs)[c]),
            paste0(vs[r,c])
        )
    }
}    

#------------------------------------------------------------------------------
#---- Output ----
#   Create the TTL file on your local drive.
 store = save.rdf(store, filename=outFile, format="TURTLE")

#------------------------------------------------------------------------------
#---- Validate ----
#    If Apache RIOT is installed, validate your creation is error-free.
#    Optional
#system(paste('riot --validate ', outFile),
#             show.output.on.console = TRUE)