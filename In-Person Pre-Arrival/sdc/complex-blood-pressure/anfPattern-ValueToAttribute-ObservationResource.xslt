<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="fn xs" version="3.0" xmlns="http://hl7.org/fhir" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://hl7.org/fhir">
    <xsl:output indent="true" method="xml" omit-xml-declaration="no"/>
    <xsl:variable name="pipe">|</xsl:variable>
    <xsl:variable name="colon">:</xsl:variable>
    <xsl:variable name="comma">,</xsl:variable>
    <xsl:variable name="statusPreliminary">preliminary</xsl:variable>
    <xsl:variable name="statusFinal">final</xsl:variable>
    <xsl:variable name="statusAmended">amended</xsl:variable>
    <xsl:variable name="statusEnteredInError">entered-in-error</xsl:variable>
    <xsl:variable name="statusCancelled">cancelled</xsl:variable>
    <xsl:template match="/">
        <xsl:for-each select="//Questionnaire/item">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="item">
        <!-- Depth first search to get to leaf item -->
        <xsl:for-each select=".">
            <xsl:apply-templates select="item"/>
            <xsl:if test="count(./item) = 0">
                <xsl:variable name="outputFileName" select="ancestor-or-self::item/linkId/@value"/>
                <xsl:result-document href="{$outputFileName}.xml" method="xml">
                    <Observation>
                        <!-- UUID from java api -->
                        <identifier>
                            <value value="3d1861ca-ea96-48ae-a99c-3b40518c0249"/>
                        </identifier>
                        <!-- status will be based off questionnaireResponse status -->
                        <status>
                            <xsl:attribute name="value">
                                <xsl:choose>
                                    <xsl:when test="document('questionnaireResponse.xml')/QuestionnaireResponse/status/@value = 'in-progress'">
                                        <xsl:value-of select="$statusPreliminary"/>
                                    </xsl:when>
                                    <xsl:when test="document('questionnaireResponse.xml')/QuestionnaireResponse/status/@value = 'completed'">
                                        <xsl:value-of select="$statusFinal"/>
                                    </xsl:when>
                                    <xsl:when test="document('questionnaireResponse.xml')/QuestionnaireResponse/status/@value = 'amended'">
                                        <xsl:value-of select="$statusAmended"/>
                                    </xsl:when>
                                    <xsl:when test="document('questionnaireResponse.xml')/QuestionnaireResponse/status/@value = 'entered-in-error'">
                                        <xsl:value-of select="$statusEnteredInError"/>
                                    </xsl:when>
                                    <xsl:when test="document('questionnaireResponse.xml')/QuestionnaireResponse/status/@value = 'stopped'">
                                        <xsl:value-of select="$statusCancelled"/>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                        </status>
                        <!-- this is the postcoordinated topic -->
                        <code>
                            <coding>
                                <code>
                                    <xsl:attribute name="value">
                                        <!-- Handle all previously traversed items-->
                                        <xsl:for-each select="ancestor-or-self::item">
                                            <xsl:apply-templates select="code">
                                                <xsl:with-param name="linkId" select="linkId/@value"/>
                                            </xsl:apply-templates>
                                        </xsl:for-each>
                                    </xsl:attribute>
                                </code>
                            </coding>
                        </code>
                        <!-- subject based off the Questionnaire subjectType-->
                        <subject>
                            <reference>
                                <xsl:attribute name="value">
                                    <xsl:value-of select="/Questionnaire/subjectType/@value"/>
                                </xsl:attribute>
                            </reference>
                        </subject>
                        <!-- subject based off the Questionnaire subjectType-->
                        <focus>
                            <reference>
                                <xsl:attribute name="value">
                                    <xsl:value-of select="/Questionnaire/subjectType/@value"/>
                                </xsl:attribute>
                            </reference>
                        </focus>
                        <!-- from QuestionnaireResponse authored value (YYYY-MM-DDThh:mm:ss+zz:zz) -->
                        <effectiveDateTime>
                            <xsl:attribute name="value">
                                <xsl:value-of select="document('questionnaireResponse.xml')/QuestionnaireResponse/authored/@value"/>
                            </xsl:attribute>
                        </effectiveDateTime>
                        <!-- from xpath current-dateTime() (instant dataType) -->
                        <issued>
                            <xsl:attribute name="value">
                                <xsl:value-of select="fn:current-dateTime()"/>
                            </xsl:attribute>
                        </issued>
                        <!-- will always be Practitioner (for now) -->
                        <performer>
                            <reference value="Practitioner"/>
                        </performer>
                        <!-- Assumption: enableWhen points to 1  on same item or have none -->
                        <valueRange>
                            <xsl:variable name="answerLinkId" select="if(count(ancestor-or-self::item/enableWhen) &gt;0) then ancestor-or-self::item/enableWhen[1]/question/@value else ./linkId/@value"/>
                            <xsl:apply-templates select="document('questionnaireResponse.xml')//item/linkId[@value = $answerLinkId]/../answer"/>
                        </valueRange>
                    </Observation>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!-- Create Topic based on expected Questionnaire nesting structure/layout -->
    <xsl:template match="code">
        <xsl:param name="linkId"/>
        <xsl:value-of select="code/@value"/>
        <xsl:value-of select="$pipe"/>
        <xsl:value-of select="display/@value"/>
        <xsl:value-of select="$pipe"/>
        <!-- Checks to see if there is an associated response code to add to topic -->
        <xsl:if test="document('questionnaireResponse.xml')//item/linkId[@value = $linkId]/../answer/valueCoding">
            <xsl:value-of select="document('questionnaireResponse.xml')//item/linkId[@value = $linkId]/../answer/valueCoding/code/@value"/>
            <xsl:value-of select="$pipe"/>
            <xsl:value-of select="document('questionnaireResponse.xml')//item/linkId[@value = $linkId]/../answer/valueCoding/display/@value"/>
            <xsl:value-of select="$pipe"/>
        </xsl:if>
    </xsl:template>
    <!-- Create result for ANF statement based on identified question response answer -->
    <xsl:template match="answer">
        <!-- Will need an extension to Range where Quantitiy is implemented versus SimpleQuantity -->
        <!-- Will need an extension to code (within Quantity extension) implements Coding -->
        <!-- Will need an extension to value (within Quantity extension) that allows for infity -->
        <xsl:choose>
            <xsl:when test="valueBoolean">
                <xsl:choose>
                    <xsl:when test="valueBoolean/@value = 'true'">
                        <low>
                            <value value="0"/>
                            <comparator value="&gt;"/>
                            <code>
                                <system value="http://snomed.info/sct"/>
                                <code value="118595003"/>
                                <display value="Quantity content"/>
                            </code>
                        </low>
                        <high>
                            <value value="PINF"/>
                            <comparator value="&lt;"/>
                            <code>
                                <system value="http://snomed.info/sct"/>
                                <code value="118595003"/>
                                <display value="Quantity content"/>
                            </code>
                        </high>
                    </xsl:when>
                    <xsl:when test="valueBoolean/@value = 'false'">
                        <low>
                            <value value="0"/>
                            <comparator value="&gt;"/>
                            <code>
                                <system value="http://snomed.info/sct"/>
                                <code value="118595003"/>
                                <display value="Quantity content"/>
                            </code>
                        </low>
                        <high>
                            <value value="0"/>
                            <comparator value="="/>
                            <code>
                                <system value="http://snomed.info/sct"/>
                                <code value="118595003"/>
                                <display value="Quantity content"/>
                            </code>
                        </high>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="valueDecimal">
                <low>
                    <value>
                        <xsl:attribute name="value">
                            <xsl:value-of select="valueDecimal/@value"/>
                        </xsl:attribute>
                    </value>
                    <comparator value="="/>
                    <code>
                        <system value="http://snomed.info/sct"/>
                        <code value="118595003"/>
                        <display value="Quantity content"/>
                    </code>
                </low>
                <high>
                    <value>
                        <xsl:attribute name="value">
                            <xsl:value-of select="valueDecimal/@value"/>
                        </xsl:attribute>
                    </value>
                    <comparator value="="/>
                    <code>
                        <system value="http://snomed.info/sct"/>
                        <code value="118595003"/>
                        <display value="Quantity content"/>
                    </code>
                </high>
            </xsl:when>
            <xsl:when test="valueInteger">
                <low>
                    <value>
                        <xsl:attribute name="value">
                            <xsl:value-of select="valueInteger/@value"/>
                        </xsl:attribute>
                    </value>
                    <comparator value="="/>
                    <code>
                        <system value="http://snomed.info/sct"/>
                        <code value="118595003"/>
                        <display value="Quantity content"/>
                    </code>
                </low>
                <high>
                    <value>
                        <xsl:attribute name="value">
                            <xsl:value-of select="valueInteger/@value"/>
                        </xsl:attribute>
                    </value>
                    <comparator value="="/>
                    <code>
                        <system value="http://snomed.info/sct"/>
                        <code value="118595003"/>
                        <display value="Quantity content"/>
                    </code>
                </high>
            </xsl:when>
            <xsl:when test="valueDate"/>
            <xsl:when test="valueDateTime"/>
            <xsl:when test="valueTime"/>
            <xsl:when test="valueAttachment"/>
            <xsl:when test="valueCoding"/>
            <xsl:when test="valueQuantity">
                <low>
                    <value>
                        <xsl:attribute name="value">
                            <xsl:value-of select="valueInteger/@value"/>
                        </xsl:attribute>
                    </value>
                    <comparator value="="/>
                    <code>
                        <system value="http://snomed.info/sct"/>
                        <code value="118595003"/>
                        <display value="Quantity content"/>
                    </code>
                </low>
                <high>
                    <value>
                        <xsl:attribute name="value">
                            <xsl:value-of select="valueInteger/@value"/>
                        </xsl:attribute>
                    </value>
                    <comparator value="="/>
                    <code>
                        <system value="http://snomed.info/sct"/>
                        <code value="118595003"/>
                        <display value="Quantity content"/>
                    </code>
                </high>
            </xsl:when>
            <xsl:when test="valueReference"/>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>