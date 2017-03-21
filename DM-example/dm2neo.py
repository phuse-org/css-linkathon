import xport, math, random
from numpy.random import uniform
from py2neo import Graph, Node, Relationship

file = '../data/source/dm.xpt'

with open(file, 'rb') as f:
    fields = xport.Reader(f).fields

with open(file, 'rb') as f:
    dm = xport.to_dataframe(f)

# access local neo4j instance on port 7474 with username "phusecss" and password "Phuse1!"
graph = Graph("http://phusecss:Phuse1!@localhost:7474/")

tx = graph.begin()

def checkNAN(inVar):
    if isinstance(inVar, float) and math.isnan(inVar) == True:
        return ''
    else:
        return inVar

def write2neo(what2write, dupSubs):

    for i in what2write:

        if dupSubs == True:
            studies = ['1', '2', '3']
            studies.remove(dm['STUDYID'][i][-1:])
            dm.set_value(i, 'STUDYID', dm['STUDYID'][i][:-1] + random.choice(studies))
        else:
            rand = str(round(uniform(0.5, 3.5)))
            dm.set_value(i, 'STUDYID', dm['STUDYID'][i][:-1] + rand)
            dm.set_value(i, 'USUBJID', '0' + rand + dm['USUBJID'][i][2:])

        #create study node
        studyid = Node('study', studyNumber=dm['STUDYID'][i])
        tx.merge(studyid)

        #create unique subject node
        usubjid = Node('subject', uniqueSubjectID=dm['USUBJID'][i])
        tx.merge(usubjid)

        #create study subject node and make connections
        subjid = Node('studySubject',
                      subjectID=dm['SUBJID'][i],
                      referenceStartDatetime=dm['RFSTDTC'][i],
                      referenceEndDatetime=dm['RFENDTC'][i],
                      participationEndDatetime=dm['RFPENDTC'][i],
                      age=dm['AGE'][i],
                      ageUnit=dm['AGEU'][i],
                      demographicsCollectionDatetime=checkNAN(dm['DMDTC'][i]),
                      demographicsCollectionStudyDay=checkNAN(dm['DMDY'][i])
                      )
        if dm['DTHFL'][i] == 'Y':
            subjid["deathDatetime"] = dm['DTHDTC'][i]
        tx.create(subjid)
        tx.merge(Relationship(subjid, "includedInStudy", studyid))
        tx.merge(Relationship(subjid, "hasUniqueSubjectID", usubjid))

        #create investigator node and make connections
        investigator = Node('investigator', siteID=dm['SITEID'][i])
        tx.merge(investigator)
        tx.merge(Relationship(subjid, "hasInvestigator", investigator))

        #create sex node and make connections
        sex = Node('sex', value=dm['SEX'][i])
        tx.merge(sex)
        tx.merge(Relationship(subjid, "hasSex", sex))

        #create race node and make connections
        race = Node('race', value=dm['RACE'][i])
        tx.merge(race)
        tx.merge(Relationship(subjid, "hasRace", race))

        #create ethnicity node and make connections
        ethnicity = Node('ethnicity', value=dm['ETHNIC'][i])
        tx.merge(ethnicity)
        tx.merge(Relationship(subjid, "hasEthnicity", ethnicity))

        if dm['ARMCD'][i] == 'Scrnfail':
            status = Node('dispositionStatus', value=dm['ARM'][i])
            tx.merge(status)
            tx.merge(Relationship(subjid, "hasStatus", status))
        else:
            #create actual arm node and make connections
            actualArm = Node('arm', value=dm['ACTARM'][i], code=dm['ACTARMCD'][i])
            tx.merge(actualArm)
            tx.merge(Relationship(subjid, "hasActualArm", actualArm, firstStudyTreatmentDatetime=dm['RFXSTDTC'][i], lastStudyTreatmentDatetime=dm['RFXENDTC'][i]))

            # create planned arm node and make connections
            plannedArm = Node('arm', value=dm['ARM'][i], code=dm['ARMCD'][i])
            tx.merge(plannedArm)
            tx.merge(Relationship(subjid, "hasPlannedArm", plannedArm))

        # create country node and make connections
        country = Node('country', value=dm['COUNTRY'][i])
        tx.merge(country)
        tx.merge(Relationship(investigator, "inCountry", country))

write2neo(range(0,len(dm)), False)
write2neo(random.sample(range(0,305),5), True)

tx.commit()

