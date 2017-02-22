###############################################################################
# FILE: DM-RowColumn.R
# DESC: A straight rox-by-column conversion of the DM XPT data to RDF
# IN  : dm.XPT from CDISCPILOT01 PhUSE project.
# OUT : DM-RowCOlumn.TTL
# NOTE: You must change the path in the setwd statement
#       The created RDF is not in a proper model!
###############################################################################
library(rrdf)   # Create triples
library(Hmisc)  # XPT import
library(plyr)   # for ddply

# Set working directory to the root of the work area
setwd("<ROOTPATH>/css-linkathon")

sourceFile <- paste0("data/source/dm.XPT")

# Output filename and location
outFilename = "DM-RowCOlumn.TTL"
outFile=paste0("data/rdf/", outFilename)

# Initialize. Includes OWL, XSD, RDF by default.
store = new.rdf()  

# Import the XPT to a dataframe
dm <- sasxport.get(sourceFile)
dm <- head(dm, 5)  # Limit to the first 5 patients

# Create an ID number for each person for use in creating the triples
dm$personID<- 1:(nrow(dm))

# Data cleaning
# rfpendtc is a mix of date and datetime in the source XPT. Convert to Date
#    for the purpose of this exercise.
dm$rfpendtc <- as.Date(dm$rfpendtc, format = "%Y-%m-%d") 

# Create some additional data for testing  (informed constent date = start date)
dm$rficdtc <- dm$rfstdtc

#------------------------------------------------------------------------------
# -- RDF Creation 
# Create Prefixes
prefix.EG   <-"http://www.example.org/cdiscpilot01#"
prefix.RDFS <- "http://www.w3.org/2000/01/rdf-schema#"

# No need to dd RDFS with add.prefix: automagically done by rrdf package.
add.prefix(store,
           prefix="EG",
           namespace=prefix.EG

)

# Create data triples. See VS-RowColumn for another, more generic method.
# Loop over the observations to create the triples associated with each patient
ddply(dm, .(subjid), function(dm)
{
    # A triple not in the original data to identify this "thing" as a type 
    #      of person.
    add.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.RDFS,"type" ),
        paste0(prefix.EG, "Person")
    )
    # Triples from the data start here
    add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasStudyID" ),
        paste0(dm$studyid), type="string"
    )
    add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasDomain" ),
        paste0(dm$domain), type="string"
   )
   add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasUsubjid" ),
        paste0(dm$usubjid), type = "string"
   )    
   add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasSubjid" ),
        paste0(dm$subjid), type = "string"
   )
   add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasRfstdtc" ),
        paste0(dm$rfstdtc), type="date"
   )
   add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasRfendtc" ),
        paste0(dm$rfendtc), type="date"
   )
   add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasRfxstdtc" ),
        paste0(dm$rfxstdtc), type="date"
   )
    add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasRfxendtc" ),
        paste0(dm$rfxendtc), type="date"
    )
    add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasrficdtc" ),
        paste0(dm$rficdtc), type="date"
    )
    add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasRfpendtc" ),
        paste0(dm$rfpendtc), type="date"
    )
    # Death dates and flags often missing. 
    #   NB: All triple creation should have  ! is.na logic
    #       Funky detection of missing here. There is something in the blank
    #       within these next two fields.
    if (! as.character(dm$dthdtc)=="") {
        add.data.triple(store,
            paste0(prefix.EG, "Person_", dm$personID),
            paste0(prefix.EG,"hasdthdtc" ),
            paste0(dm$dthdtc), type="date"
        )    
    }    
    if (! as.character(dm$dthfl)=="") {
        add.data.triple(store,
            paste0(prefix.EG, "Person_", dm$personID),
            paste0(prefix.EG,"hasdthfl" ),
            paste0(dm$dthfl), type="string"
        )
    }
    add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasSiteID" ),
        paste0(dm$siteid), type="string"
    )
    add.data.triple(store,
        paste0(prefix.EG, "Person_", dm$personID),
        paste0(prefix.EG,"hasAge" ),
        paste0(dm$age), type="integer"
   )
   add.data.triple(store,
       paste0(prefix.EG, "Person_", dm$personID),
       paste0(prefix.EG,"hasAgeU" ),
       paste0(dm$ageu), type="string"
   )
   add.data.triple(store,
       paste0(prefix.EG, "Person_", dm$personID),
       paste0(prefix.EG,"hasSex" ),
       paste0(dm$sex), type="string"
   )
   add.data.triple(store,
       paste0(prefix.EG, "Person_", dm$personID),
       paste0(prefix.EG,"hasRace" ),
       paste0(dm$race), type="string"
   )
   add.data.triple(store,
       paste0(prefix.EG, "Person_", dm$personID),
       paste0(prefix.EG,"hasEthnic" ),
       paste0(dm$ethnic), type="string"
   )
   add.data.triple(store,
       paste0(prefix.EG, "Person_", dm$personID),
       paste0(prefix.EG,"hasArmcd" ),
       paste0(dm$armcd), type="string"
   )
   add.data.triple(store,
       paste0(prefix.EG, "Person_", dm$personID),
       paste0(prefix.EG,"hasArm" ),
       paste0(dm$arm), type="string"
   )
   add.data.triple(store,
       paste0(prefix.EG, "Person_", dm$personID),
       paste0(prefix.EG,"hasActArmCd" ),
       paste0(dm$actarmcd), type="string"
   )
   add.data.triple(store,
       paste0(prefix.EG, "Person_", dm$personID),
       paste0(prefix.EG,"hasActArm" ),
       paste0(dm$actarm), type="string"
   )
   add.data.triple(store,
       paste0(prefix.EG, "Person_", dm$personID),
       paste0(prefix.EG,"hasCountry" ),
       paste0(dm$country), type="string"
   )
   add.data.triple(store,
       paste0(prefix.EG, "Person_", dm$personID),
       paste0(prefix.EG,"hasDmdtc" ),
       paste0(dm$dmdtc), type="date"
   )
   add.data.triple(store,
       paste0(prefix.EG, "Person_", dm$personID),
       paste0(prefix.EG,"hasDmdy" ),
       paste0(dm$dmdy), type="integer"
   )

})

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