# Structure Data Capture

This directory contains all of the knowledge artifacts needed to successfully capture clinical information/data that is imported and used throughout BPMN and DMN models. Each child directory represents a clinical question used within the BPMN and DMN models for the COVID-19 In-Person Pre-Arrival Clinical Workflow.

## Running XSLT Transformations

Each XSLT transformation is using [Saxon](http://www.saxonica.com/documentation/index.html#!using-xsl/commandline) (from Saxonic). Below are the stops to run the various XSLT based FHIR -> ANF transformations:

1. Download the open-source version (Home Edition) of [Saxon](https://sourceforge.net/projects/saxon/files/Saxon-HE/)
2. Properly integrate the .jar file into your operating system

...For example, adding the saxon-he-XX.X.jar to your class path OR droping it into the directory where the .xslt transformation file is

3. Run the following command to perform the XSLT based transformation: java -jar /path/to/saxon-he-XX.X.jar -s:/Path/to/source/FHIR/Questionnaire.xml -xsl:/Path/to/XSLT/file.xslt -o:/Path/to/output/file.xml 

Below are the questions:

+ [**Complex Blood Pressure**](https://github.com/logicahealth/Solor-BPM/tree/master/In-Person%20Pre-Arrival/sdc/complex-blood-pressure)