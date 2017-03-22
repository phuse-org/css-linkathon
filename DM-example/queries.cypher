/* Import the DM graph */
Option 1: Run the python script
Option 2: Open Neo4j and open the cypher script, and run it using http://www.lyonwj.com/LazyWebCypher/#


/* Studies that contain a Placebo treatment */
match (s:study)-[*1..4]-(a:arm) where a.value contains "Placebo" return distinct s.studyNumber order by s.studyNumber

/* Number of Subjects  */
match (study:study)-[]-(subj:studySubject)-[]-(sex:sex) return  study.studyNumber as STUDYID, sex.value as SEX, count(*) as NumberOfSubjects order by study.studyNumber,sex.value

/* Subjects paticipating in multiple studies */
match (s:subject)-[]-(ss:studySubject) with s, count(*) as nstudy where nstudy > 1 with s match (s)-[]-(ss:studySubject)-[]-(stdy:study) return s.uniqueSubjectID,stdy.studyNumber order by s.uniqueSubjectID,stdy.studyNumber ;


/* Export DM Domain - CDISC Compliant */
call apoc.export.csv.query("match (study:study)
optional match(study)-[]-(ssubj:studySubject)-[]-(subj:subject)
optional match (ssubj)-[]-(race:race)
optional match (ssubj)-[]-(sex:sex)
optional match (ssubj)-[]-(eth:ethnicity)
optional match (ssubj)-[]-(inv:investigator)
optional match (ssubj)-[r1:hasPlannedArm]-(pl:arm)
optional match (ssubj)-[r2:hasActualArm]-(act:arm)
optional match (ssubj)-[]-(ds:dispositionStatus)
optional match (inv)-[]-(ctry:country)
return
study.studyNumber as STUDYID,
subj.uniqueSubjectID as USUBJID,
ssubj.subjectID as SUBJID,
ssubj.referenceStartDatetime as RFSTDTC,
ssubj.referenceEndDatetime as RFENDTC,
r2.firstStudyTreatmentDatetime as RFXSTDTC,
r2.lastStudyTreatmentDatetime as RFXENDTC,
ssubj.participationEndDatetime as RFXPDTC,
inv.siteID as SITEID,
ssubj.age as AGE,
ssubj.ageUnit as AGEU,
sex.value as SEX,
race.value as RACE,
eth.value as ETHNICITY,
case
  when pl.code is not null then pl.code
  when ds.value is not null then 'SCRNFAIL'
  else null
end as ARMCD,
coalesce(pl.value,ds.value) as ARM,
act.code as ACTARMCD,
act.value as ACTARM,
ctry.value as COUNTRY,
ssubj.demographicsCollectionDatetime as DMDTC,
ssubj.demographicsCollectionStudyDay as DMDY
order by STUDYID, USUBJID;", '/Users/ScottBahlavooni/dm_neo_cdisc.csv',{}) ;


/* Export DM Domain - FDA Compliant */
call apoc.export.csv.query("match (study:study)
optional match(study)-[]-(ssubj:studySubject)-[]-(subj:subject)
optional match (ssubj)-[]-(race:race)
optional match (ssubj)-[]-(sex:sex)
optional match (ssubj)-[]-(eth:ethnicity)
optional match (ssubj)-[]-(inv:investigator)
optional match (ssubj)-[r1:hasPlannedArm]-(pl:arm)
optional match (ssubj)-[r2:hasActualArm]-(act:arm)
optional match (ssubj)-[]-(ds:dispositionStatus)
optional match (inv)-[]-(ctry:country)
return
study.studyNumber as STUDYID,
subj.uniqueSubjectID as USUBJID,
ssubj.subjectID as SUBJID,
ssubj.referenceStartDatetime as RFSTDTC,
ssubj.referenceEndDatetime as RFENDTC,
r2.firstStudyTreatmentDatetime as RFXSTDTC,
r2.lastStudyTreatmentDatetime as RFXENDTC,
ssubj.participationEndDatetime as RFXPDTC,
inv.siteID as SITEID,
ssubj.age as AGE,
ssubj.ageUnit as AGEU,
sex.value as SEX,
race.value as RACE,
eth.value as ETHNICITY,
case
  when pl.code is not null then pl.code
  when ds.value is not null then 'SCRNFAIL'
  else null
end as ARMCD,
pl.value as ARM,
act.code as ACTARMCD,
act.value as ACTARM,
ctry.value as COUNTRY,
ssubj.demographicsCollectionDatetime as DMDTC,
ssubj.demographicsCollectionStudyDay as DMDY
order by STUDYID, USUBJID;", '/Users/ScottBahlavooni/dm_neo_fda.csv',{}) ;


/* Set site violation indicator */ match (n:investigator) where n.siteID in ['701', '703', '707'] set n.violation='Y'


/* Set site violation indicator */ match (n:investigator) where n.siteID in ['701', '703', '707'] set n.violation='Y'
