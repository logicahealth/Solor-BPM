# COVID-19 In-Person Pre-Arrival Clinical Workflow

This workflow specifically focuses on comprehensively handling patients that come in-person to a medical clinic and are appropriately triaged based on current clinical COVID-19 recommendations.

Below is a breakdown of the directory structure representing an attempt to automate the COVID-19 In-Person Pre-Arrival clinical workflow:

+ bpmn - these artifacts capture and model the clinical workflow in the BPMN language 
+ dmn - these artifacts capture clinical decision logic based on the BPMN
+ sdc - these artifacts capture the necessary FHIR Questionnaire and Quentionnaire resources to facilitate clinical data ingestion into the BMPN and DMN models. There is also XSLT configurations to transform the FHIR Questionnaire and Questionnaire Response into an ANF Profiled FHIR Observation resource. 